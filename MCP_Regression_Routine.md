# MCP Regression Routine

Bu rutin Faz 5 icin tek komutluk regression kontroludur.

## Kapsam

Script artik su 19 kontrolu yapar:

1. Editor bridge baglaniyor mu
2. Scene aciliyor mu
3. Egg sistemi okunuyor mu
4. Lifecycle egg stage'de basliyor mu
5. Egg tap ile ilerliyor mu
6. Egg kontrollu hatch olabiliyor mu
7. Hatch sonrasi gameplay `baby` stage'ine aciliyor mu
8. `NeedSystem` okunuyor mu
9. Care aksiyonu personality drift uretiyor mu
10. Care aksiyonu lifecycle ilerlemesi yaziyor mu
11. Care aksiyonu bond kazandiriyor mu
12. Sleep state gecisi dogru mu
13. Sleep recovery artiyor mu
14. Micro event tetikleniyor mu
15. `watch_signal` broadcast calisiyor mu
16. Choice sonucu uygulanıyor mu
17. Choice bond kazandiriyor mu
18. Choice lifecycle ilerlemesi yaziyor mu
19. Choice personality drift uretiyor mu

## Script

Dosya:
- `Dev/run_mcp_regression.py`

## Calistirma

Varsayilan Godot binary:
- `/home/bora/Masaüstü/Godot_v4.6.2-stable_linux.x86_64`

Varsayilan editor bridge test portu:
- `6507`

Komut:

```bash
python3 Dev/run_mcp_regression.py
```

Alternatif binary:

```bash
GODOT_BIN=/path/to/Godot python3 Dev/run_mcp_regression.py
```

Alternatif log path:

```bash
MCP_REGRESSION_LOG=/tmp/hatchi_regression.log python3 Dev/run_mcp_regression.py
```

Alternatif editor bridge portu:

```bash
MCP_EDITOR_BRIDGE_PORT=6510 python3 Dev/run_mcp_regression.py
```

## Cikti

Script JSON doner:
- `ok`: genel durum
- `results`: check listesi
- `log_paths.runtime`: runtime log
- `log_paths.editor`: editor log

## Not

Editor bridge check'i mock WebSocket bridge ile yapilir.
Boylece harici MCP bridge servisi olmasa bile editor plugin baglanti akisi regression icinde test edilir.
