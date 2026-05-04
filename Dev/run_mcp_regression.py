#!/usr/bin/env python3

import base64
import hashlib
import json
import os
import signal
import socket
import subprocess
import sys
import threading
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_GODOT_BIN = Path("/home/bora/Masaüstü/Godot_v4.6.2-stable_linux.x86_64")
DEFAULT_PORT = 7777
DEFAULT_LOG_PATH = PROJECT_ROOT / "Dev" / "mcp_regression.log"
DEFAULT_EDITOR_LOG_PATH = PROJECT_ROOT / "Dev" / "mcp_editor_regression.log"
DEFAULT_EDITOR_BRIDGE_PORT = 6507
WEBSOCKET_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"


@dataclass
class CheckResult:
	name: str
	ok: bool
	details: str


class MockEditorBridgeServer:
	def __init__(self, host: str = "127.0.0.1", port: int = DEFAULT_EDITOR_BRIDGE_PORT) -> None:
		self.host = host
		self.port = port
		self.connected = False
		self.first_message = ""
		self.error = ""
		self._server: socket.socket | None = None
		self._thread: threading.Thread | None = None

	def start(self) -> None:
		self._thread = threading.Thread(target=self._run, daemon=True)
		self._thread.start()

	def stop(self) -> None:
		if self._server is not None:
			try:
				self._server.close()
			except OSError:
				pass
		if self._thread is not None:
			self._thread.join(timeout=1.0)

	def wait_for_ready(self, timeout_seconds: float = 12.0) -> bool:
		deadline = time.time() + timeout_seconds
		while time.time() < deadline:
			if self.connected and self.first_message:
				return True
			if self.error:
				return False
			time.sleep(0.05)
		return False

	def _run(self) -> None:
		try:
			with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server:
				server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
				server.bind((self.host, self.port))
				server.listen(1)
				server.settimeout(6.0)
				self._server = server
				conn, _addr = server.accept()
				with conn:
					conn.settimeout(3.0)
					request = self._recv_until(conn, b"\r\n\r\n")
					key = self._extract_websocket_key(request.decode(errors="ignore"))
					if not key:
						self.error = "missing websocket key"
						return

					accept = base64.b64encode(hashlib.sha1((key + WEBSOCKET_GUID).encode()).digest()).decode()
					response = (
						"HTTP/1.1 101 Switching Protocols\r\n"
						"Upgrade: websocket\r\n"
						"Connection: Upgrade\r\n"
						f"Sec-WebSocket-Accept: {accept}\r\n\r\n"
					)
					conn.sendall(response.encode())
					self.connected = True
					self.first_message = self._read_websocket_text_frame(conn)
		except Exception as exc:
			self.error = str(exc)

	def _recv_until(self, conn: socket.socket, marker: bytes) -> bytes:
		data = b""
		while marker not in data:
			chunk = conn.recv(4096)
			if not chunk:
				break
			data += chunk
		return data

	def _extract_websocket_key(self, request_text: str) -> str:
		for line in request_text.splitlines():
			if line.lower().startswith("sec-websocket-key:"):
				return line.split(":", 1)[1].strip()
		return ""

	def _read_exact(self, conn: socket.socket, size: int) -> bytes:
		data = b""
		while len(data) < size:
			chunk = conn.recv(size - len(data))
			if not chunk:
				raise ConnectionError("websocket closed before frame completed")
			data += chunk
		return data

	def _read_websocket_text_frame(self, conn: socket.socket) -> str:
		header = self._read_exact(conn, 2)
		length = header[1] & 0x7F
		if length == 126:
			length = int.from_bytes(self._read_exact(conn, 2), "big")
		elif length == 127:
			length = int.from_bytes(self._read_exact(conn, 8), "big")

		masked = (header[1] & 0x80) != 0
		mask = self._read_exact(conn, 4) if masked else b""
		payload = self._read_exact(conn, length)
		if masked:
			payload = bytes(value ^ mask[index % 4] for index, value in enumerate(payload))

		return payload.decode(errors="ignore")


class MCPRuntimeClient:
	def __init__(self, host: str = "127.0.0.1", port: int = DEFAULT_PORT) -> None:
		self.host = host
		self.port = port

	def request(self, command: str, params: dict[str, Any], read_seconds: float = 1.0) -> list[dict[str, Any]]:
		payload = {
			"id": command,
			"command": command,
			"params": params,
		}
		with socket.create_connection((self.host, self.port), timeout=3.0) as sock:
			sock.sendall(json.dumps(payload).encode())
			sock.shutdown(socket.SHUT_WR)
			raw = self._collect(sock, read_seconds)
		return self._parse_messages(raw)

	def _collect(self, sock: socket.socket, read_seconds: float) -> bytes:
		sock.setblocking(False)
		deadline = time.time() + read_seconds
		data = b""

		while time.time() < deadline:
			try:
				chunk = sock.recv(16384)
				if chunk:
					data += chunk
				else:
					time.sleep(0.03)
			except BlockingIOError:
				time.sleep(0.03)
			except OSError:
				break

		return data

	def _parse_messages(self, raw: bytes) -> list[dict[str, Any]]:
		messages: list[dict[str, Any]] = []
		text = raw.decode(errors="ignore")

		for line in text.splitlines():
			start = line.find("{")
			if start == -1:
				continue
			try:
				messages.append(json.loads(line[start:]))
			except json.JSONDecodeError:
				continue

		return messages


def launch_game(godot_bin: Path, log_path: Path) -> subprocess.Popen[str]:
	log_path.parent.mkdir(parents=True, exist_ok=True)
	log_file = log_path.open("w", encoding="utf-8")
	return subprocess.Popen(
		[str(godot_bin), "--path", str(PROJECT_ROOT)],
		stdout=log_file,
		stderr=subprocess.STDOUT,
		text=True,
	)


def launch_editor(godot_bin: Path, log_path: Path, bridge_port: int) -> subprocess.Popen[str]:
	log_path.parent.mkdir(parents=True, exist_ok=True)
	log_file = log_path.open("w", encoding="utf-8")
	env = os.environ.copy()
	env["MCP_BRIDGE_PORT"] = str(bridge_port)
	return subprocess.Popen(
		[str(godot_bin), "--path", str(PROJECT_ROOT), "--editor"],
		stdout=log_file,
		stderr=subprocess.STDOUT,
		text=True,
		env=env,
	)


def wait_for_runtime(client: MCPRuntimeClient, timeout_seconds: float = 6.0) -> bool:
	deadline = time.time() + timeout_seconds
	while time.time() < deadline:
		try:
			messages = client.request("ping", {}, read_seconds=0.5)
			if any(message.get("type") == "pong" for message in messages):
				return True
		except OSError:
			time.sleep(0.2)
	return False


def get_last_message(messages: list[dict[str, Any]], expected_type: str) -> dict[str, Any]:
	for message in reversed(messages):
		if message.get("type") == expected_type:
			return message
	return {}


def call_method_result(
	client: MCPRuntimeClient,
	path: str,
	method: str,
	args: list[Any],
	timeout_seconds: float = 2.0,
) -> dict[str, Any]:
	deadline = time.time() + timeout_seconds
	last_error: dict[str, Any] = {}

	while time.time() < deadline:
		messages = client.request("call_method", {"path": path, "method": method, "args": args}, read_seconds=0.5)
		method_result = get_last_message(messages, "method_result")
		if method_result:
			return method_result.get("result", {})

		error_message = get_last_message(messages, "error")
		if error_message:
			last_error = error_message
		time.sleep(0.05)

	return {"__error__": last_error.get("message", "method_result_timeout")}


def get_node_data(
	client: MCPRuntimeClient,
	path: str,
	timeout_seconds: float = 2.0,
) -> dict[str, Any]:
	deadline = time.time() + timeout_seconds
	last_error: dict[str, Any] = {}

	while time.time() < deadline:
		messages = client.request("get_node", {"path": path}, read_seconds=0.5)
		node_message = get_last_message(messages, "node")
		if node_message:
			return node_message.get("data", {})

		error_message = get_last_message(messages, "error")
		if error_message:
			last_error = error_message
		time.sleep(0.05)

	return {"__error__": last_error.get("message", "get_node_timeout")}


def get_node_visibility(
	client: MCPRuntimeClient,
	path: str,
	timeout_seconds: float = 2.0,
) -> bool | None:
	node_data = get_node_data(client, path, timeout_seconds)
	return node_data.get("properties", {}).get("visible")


def run_regression(client: MCPRuntimeClient) -> list[CheckResult]:
	results: list[CheckResult] = []

	tree_messages = client.request("get_tree", {"root": "/root", "depth": 3, "include_properties": False})
	tree_message = get_last_message(tree_messages, "tree")
	tree_root = tree_message.get("root", {})
	main_found = _tree_contains_path(tree_root, "/root/Main")
	results.append(CheckResult("scene_opens", main_found, "Main scene found in runtime tree" if main_found else "Main scene missing from runtime tree"))

	egg_before = call_method_result(client, "/root/Main/EggSystem", "get_egg_snapshot", [])
	egg_readable = bool(egg_before) and egg_before.get("is_hatched") is False
	results.append(CheckResult("egg_system_readable", egg_readable, json.dumps(egg_before, ensure_ascii=True)))

	pre_hatch_visibility_targets = {
		"egg_panel": ("/root/Main/RootLayout/PetArea/EggOverlay/EggPanel", True),
		"pet_visual": ("/root/Main/RootLayout/PetArea/PetVisualLayer/PetVisual", False),
		"need_panel": ("/root/Main/RootLayout/NeedPanel", False),
		"action_panel": ("/root/Main/RootLayout/ActionPanel", False),
		"bottom_nav": ("/root/Main/RootLayout/BottomNav", False),
		"idle_event_ui": ("/root/Main/RootLayout/PetArea/IdleEventUI", False),
		"sleep_warning_label": ("/root/Main/RootLayout/PetArea/SleepWarningLabel", False),
		"overlay_root": ("/root/Main/OverlayLayer/OverlayRoot", False),
		"pet_area_placeholder_label": ("/root/Main/RootLayout/PetArea/Label", False),
	}
	pre_hatch_visibility_results: dict[str, bool | None] = {}
	pre_hatch_visibility_ok = False
	visibility_deadline = time.time() + 1.5
	while time.time() < visibility_deadline:
		pre_hatch_visibility_ok = True
		for check_name, (node_path, expected_visible) in pre_hatch_visibility_targets.items():
			actual_visible = call_method_result(client, node_path, "is_visible_in_tree", [])
			pre_hatch_visibility_results[check_name] = actual_visible
			if actual_visible is not expected_visible:
				pre_hatch_visibility_ok = False
		if pre_hatch_visibility_ok:
			break
		time.sleep(0.08)
	results.append(CheckResult("egg_stage_visibility_lock", pre_hatch_visibility_ok, json.dumps(pre_hatch_visibility_results, ensure_ascii=True)))

	lifecycle_egg_snapshot = call_method_result(client, "/root/Main/LifecycleSystem", "get_lifecycle_snapshot", [])
	egg_stage_ok = lifecycle_egg_snapshot.get("current_stage") == "egg" and lifecycle_egg_snapshot.get("is_gameplay_unlocked") is False
	results.append(CheckResult("lifecycle_starts_in_egg", egg_stage_ok, json.dumps(lifecycle_egg_snapshot, ensure_ascii=True)))

	egg_progress_before = float(egg_before.get("progress_ratio", 0.0))
	egg_after_tap = call_method_result(client, "/root/Main/EggSystem", "tap_egg", [])
	egg_progress_after = float(egg_after_tap.get("progress_ratio", 0.0))
	egg_tap_ok = egg_progress_after > egg_progress_before
	results.append(CheckResult("egg_tap_progress", egg_tap_ok, f"progress {egg_progress_before:.3f} -> {egg_progress_after:.3f}"))

	call_method_result(client, "/root/Main/EggSystem", "force_hatch", [])
	egg_after_hatch = call_method_result(client, "/root/Main/EggSystem", "get_egg_snapshot", [])
	egg_hatch_ok = egg_after_hatch.get("is_hatched") is True
	results.append(CheckResult("egg_can_hatch", egg_hatch_ok, json.dumps(egg_after_hatch, ensure_ascii=True)))

	lifecycle_after_hatch = call_method_result(client, "/root/Main/LifecycleSystem", "get_lifecycle_snapshot", [])
	hatch_stage_ok = lifecycle_after_hatch.get("current_stage") == "baby" and lifecycle_after_hatch.get("is_gameplay_unlocked") is True
	results.append(CheckResult("lifecycle_hatch_unlocks_baby", hatch_stage_ok, json.dumps(lifecycle_after_hatch, ensure_ascii=True)))

	need_result = call_method_result(client, "/root/Main/NeedSystem", "get_needs_snapshot", [])
	need_ok = all(key in need_result for key in ["hunger", "happiness", "hygiene", "sleep"])
	results.append(CheckResult("need_system_readable", need_ok, f"Need keys: {sorted(need_result.keys())}" if need_result else "Need snapshot missing"))

	lifecycle_before = call_method_result(client, "/root/Main/LifecycleSystem", "get_lifecycle_snapshot", [])
	lifecycle_before_counters = lifecycle_before.get("counters", {})
	personality_before = call_method_result(client, "/root/Main/PersonalitySystem", "get_personality_snapshot", [])
	personality_before_traits = personality_before.get("traits", {})
	bond_before = call_method_result(client, "/root/Main/BondSystem", "get_bond_snapshot", [])
	bond_before_value = float(bond_before.get("current_bond", 0.0))

	call_method_result(client, "/root/Main/NeedSystem", "feed", [20.0])
	call_method_result(client, "/root/Main/RootLayout/ActionPanel/ActionsContainer/FeedButton", "_on_pressed", [])
	personality_after_feed = call_method_result(client, "/root/Main/PersonalitySystem", "get_personality_snapshot", [])
	personality_after_feed_traits = personality_after_feed.get("traits", {})
	lifecycle_after_feed = call_method_result(client, "/root/Main/LifecycleSystem", "get_lifecycle_snapshot", [])
	lifecycle_after_feed_counters = lifecycle_after_feed.get("counters", {})
	empathy_before = float(personality_before_traits.get("empathy", 0.0))
	empathy_after_feed = float(personality_after_feed_traits.get("empathy", 0.0))
	personality_care_ok = empathy_after_feed > empathy_before
	results.append(CheckResult("personality_care_drift", personality_care_ok, f"empathy {empathy_before:.3f} -> {empathy_after_feed:.3f}"))
	lifecycle_feed_before = int(lifecycle_before_counters.get("feed_count", 0))
	lifecycle_feed_after = int(lifecycle_after_feed_counters.get("feed_count", 0))
	lifecycle_feed_ok = lifecycle_feed_after > lifecycle_feed_before
	results.append(CheckResult("lifecycle_care_progress", lifecycle_feed_ok, f"feed_count {lifecycle_feed_before} -> {lifecycle_feed_after}, stage={lifecycle_after_feed.get('current_stage', '')!r}"))
	bond_after_feed = call_method_result(client, "/root/Main/BondSystem", "get_bond_snapshot", [])
	bond_after_feed_value = float(bond_after_feed.get("current_bond", 0.0))
	bond_care_ok = bond_after_feed_value > bond_before_value
	results.append(CheckResult("bond_care_gain", bond_care_ok, f"bond {bond_before_value:.3f} -> {bond_after_feed_value:.3f}"))

	call_method_result(client, "/root/Main/RootLayout/PetArea/StateLabel", "toggle_sleep", [])
	time.sleep(1.2)
	sleep_state = call_method_result(client, "/root/Main/RootLayout/PetArea/StateLabel", "get_state_snapshot", [])
	sleeping_ok = sleep_state.get("current_state") == "sleeping" and sleep_state.get("is_sleeping") is True
	results.append(CheckResult("sleep_toggle", sleeping_ok, json.dumps(sleep_state, ensure_ascii=True)))

	pre_wake_needs = call_method_result(client, "/root/Main/NeedSystem", "get_needs_snapshot", [])
	sleep_before = float(pre_wake_needs.get("sleep", {}).get("current_value", 0.0))
	time.sleep(1.2)
	post_sleep_needs = call_method_result(client, "/root/Main/NeedSystem", "get_needs_snapshot", [])
	sleep_after = float(post_sleep_needs.get("sleep", {}).get("current_value", 0.0))
	sleep_recovery_ok = sleep_after > sleep_before
	results.append(CheckResult("state_transition_correct", sleep_recovery_ok, f"sleep {sleep_before:.3f} -> {sleep_after:.3f}"))

	call_method_result(client, "/root/Main/MicroEventController", "trigger_event", ["music_moment"])
	question_messages = client.request("get_node", {"path": "/root/Main/OverlayLayer/OverlayRoot/CenterContainer/ChoicePanel/Content/QuestionLabel"})
	question_data = get_last_message(question_messages, "node").get("data", {})
	question_text = question_data.get("properties", {}).get("text", "")
	micro_event_ok = question_text == "The pet is humming. How do you react?"
	results.append(CheckResult("micro_event_triggers", micro_event_ok, f"question={question_text!r}"))

	signal_ok, signal_details = watch_signal_event(
		client,
		"/root/Main/MicroEventController",
		"micro_event_triggered",
		"trigger_event",
		{"path": "/root/Main/MicroEventController", "method": "trigger_event", "args": ["music_moment"]},
	)
	results.append(CheckResult("signal_watch_broadcasts", signal_ok, signal_details))

	choice_before = call_method_result(client, "/root/Main/NeedSystem", "get_needs_snapshot", [])
	happiness_before = float(choice_before.get("happiness", {}).get("current_value", 0.0))
	call_method_result(client, "/root/Main/OverlayLayer/OverlayRoot/CenterContainer/ChoicePanel", "_on_option_a_pressed", [])
	time.sleep(0.4)
	choice_after = call_method_result(client, "/root/Main/NeedSystem", "get_needs_snapshot", [])
	happiness_after = float(choice_after.get("happiness", {}).get("current_value", 0.0))
	choice_snapshot = call_method_result(client, "/root/Main/MicroEventController", "get_last_event_snapshot", [])
	last_choice = choice_snapshot.get("last_choice_result", {})
	choice_ok = happiness_after > happiness_before and last_choice.get("option_id") == "option_a"
	results.append(CheckResult("choice_result_applied", choice_ok, f"happiness {happiness_before:.3f} -> {happiness_after:.3f}, choice={last_choice}"))
	bond_after_choice = call_method_result(client, "/root/Main/BondSystem", "get_bond_snapshot", [])
	bond_after_choice_value = float(bond_after_choice.get("current_bond", 0.0))
	bond_choice_ok = bond_after_choice_value > bond_after_feed_value
	results.append(CheckResult("bond_choice_gain", bond_choice_ok, f"bond {bond_after_feed_value:.3f} -> {bond_after_choice_value:.3f}"))
	lifecycle_after_choice = call_method_result(client, "/root/Main/LifecycleSystem", "get_lifecycle_snapshot", [])
	lifecycle_after_choice_counters = lifecycle_after_choice.get("counters", {})
	personality_event_before = int(lifecycle_after_feed_counters.get("personality_event_count", 0))
	personality_event_after = int(lifecycle_after_choice_counters.get("personality_event_count", 0))
	lifecycle_choice_ok = personality_event_after > personality_event_before
	results.append(CheckResult("lifecycle_choice_progress", lifecycle_choice_ok, f"personality_event_count {personality_event_before} -> {personality_event_after}, stage={lifecycle_after_choice.get('current_stage', '')!r}"))

	personality_after_choice = call_method_result(client, "/root/Main/PersonalitySystem", "get_personality_snapshot", [])
	personality_after_choice_traits = personality_after_choice.get("traits", {})
	social_after_choice = float(personality_after_choice_traits.get("social", 0.0))
	social_after_feed = float(personality_after_feed_traits.get("social", 0.0))
	personality_choice_ok = social_after_choice > social_after_feed
	results.append(CheckResult("personality_choice_drift", personality_choice_ok, f"social {social_after_feed:.3f} -> {social_after_choice:.3f}"))

	return results


def watch_signal_event(
	client: MCPRuntimeClient,
	path: str,
	signal_name: str,
	trigger_method_name: str,
	trigger_params: dict[str, Any],
) -> tuple[bool, str]:
	with socket.create_connection((client.host, client.port), timeout=3.0) as sock:
		payload = {
			"id": "watch_signal",
			"command": "watch_signal",
			"params": {
				"path": path,
				"signal": signal_name,
			},
		}
		sock.sendall(json.dumps(payload).encode())
		ack_messages = client._parse_messages(client._collect(sock, 0.8))
		client.request("call_method", trigger_params)
		event_messages = client._parse_messages(client._collect(sock, 1.8))

	messages = ack_messages + event_messages
	ack = get_last_message(messages, "signal_watched")
	event = get_last_message(messages, "signal_event")
	event_id = ""
	if event:
		args = event.get("args", [])
		if args and isinstance(args[0], dict):
			event_id = str(args[0].get("id", ""))

	ok = bool(ack) and event_id == "music_moment"
	return ok, f"ack={bool(ack)}, signal_event_id={event_id!r}, trigger={trigger_method_name}"


def _tree_contains_path(node: dict[str, Any], wanted_path: str) -> bool:
	if node.get("path") == wanted_path:
		return True
	for child in node.get("children", []):
		if _tree_contains_path(child, wanted_path):
			return True
	return False


def resolve_godot_bin() -> Path:
	env_bin = os.environ.get("GODOT_BIN")
	if env_bin:
		return Path(env_bin)
	return DEFAULT_GODOT_BIN


def terminate_process(process: subprocess.Popen[str]) -> None:
	if process.poll() is not None:
		return
	process.send_signal(signal.SIGTERM)
	try:
		process.wait(timeout=2.0)
	except subprocess.TimeoutExpired:
		process.kill()
		process.wait(timeout=2.0)


def main() -> int:
	godot_bin = resolve_godot_bin()
	if not godot_bin.exists():
		print(f"Godot binary not found: {godot_bin}", file=sys.stderr)
		return 2

	log_path = Path(os.environ.get("MCP_REGRESSION_LOG", DEFAULT_LOG_PATH))
	editor_log_path = Path(os.environ.get("MCP_EDITOR_REGRESSION_LOG", DEFAULT_EDITOR_LOG_PATH))
	editor_bridge_port = int(os.environ.get("MCP_EDITOR_BRIDGE_PORT", str(DEFAULT_EDITOR_BRIDGE_PORT)))
	client = MCPRuntimeClient()
	bridge_server = MockEditorBridgeServer(port=editor_bridge_port)
	bridge_server.start()
	editor_process = launch_editor(godot_bin, editor_log_path, editor_bridge_port)
	editor_result = CheckResult("editor_bridge_connects", False, "")

	try:
		editor_ok = bridge_server.wait_for_ready()
		editor_message = bridge_server.first_message
		editor_result = CheckResult(
			"editor_bridge_connects",
			editor_ok and "\"type\":\"godot_ready\"" in editor_message,
			editor_message if editor_message else bridge_server.error or "editor bridge handshake not received",
		)
	finally:
		terminate_process(editor_process)
		bridge_server.stop()

	process = launch_game(godot_bin, log_path)
	results: list[CheckResult] = [editor_result]

	try:
		if not wait_for_runtime(client):
			print("MCP runtime did not become ready in time.", file=sys.stderr)
			return 3

		results.extend(run_regression(client))
	finally:
		terminate_process(process)

	failed = [result for result in results if not result.ok]
	report = {
		"ok": not failed,
		"results": [
			{
				"name": result.name,
				"ok": result.ok,
				"details": result.details,
			}
			for result in results
		],
		"log_paths": {
			"runtime": str(log_path),
			"editor": str(editor_log_path),
		},
	}
	print(json.dumps(report, indent=2, ensure_ascii=True))
	return 1 if failed else 0


if __name__ == "__main__":
	sys.exit(main())
