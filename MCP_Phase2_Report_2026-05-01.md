# MCP Phase 2 Report

Tarih: 2026-05-01
Proje: Hatchi

## Kapsam

Bu turda iki is yapildi:

1. Bootstrap scene gecis hatasi duzeltildi
2. Faz 2 - Core Loop Gozlemlenebilirligi MCP uzerinden test edildi

## Yapilan Duzeltmeler

### 1. Bootstrap fix

Dosya:
- `Scenes/Bootstrap/bootstrap.gd`

Degisiklik:
- `change_scene_to_file()` cagrisi `_ready()` icinde dogrudan calistirilmadi
- Scene degisimi `call_deferred()` ile ertelendi

Sonuc:
- Daha once gorulen `remove_child() can't be called at this time` hatasi artik tekrar etmedi

### 2. MCP signal watch fix

Dosya:
- `addons/godot_mcp_runtime/mcp_runtime_autoload.gd`

Degisiklik:
- `watch_signal` lambda'si artik gelen signal argumanlarini array'e cevirip broadcast ediyor

Sonuc:
- `micro_event_triggered` signal'i MCP istemcisine gercekten ulasiyor

### 3. Debug helper API'leri

Dosyalar:
- `Systems/Needs/need_system.gd`
- `Core/pet/PetStateController.gd`

Eklenenler:
- `NeedSystem.get_needs_snapshot()`
- `PetStateController.get_state_snapshot()`

Sonuc:
- Faz 2 icin state ve need verileri MCP uzerinden okunabilir hale geldi

## Faz 2 Testleri

### 1. State snapshot

`/root/Main/RootLayout/PetArea/StateLabel`

Sonuc:
- `current_state = critical`
- `previous_state = normal`
- `is_sleeping = false`

### 2. Need snapshot

`/root/Main/NeedSystem`

Sonuc:
- `hunger`, `happiness`, `hygiene`, `sleep` degerleri MCP uzerinden okundu
- `current_value`, `max_value`, `normalized`, `decay_per_second` alanlari goruldu

### 3. Signal watch

Izlenen signal:
- `/root/Main/MicroEventController`
- `micro_event_triggered`

Sonuc:
- `signal_watched` ack alindi
- Event tetiklenince `signal_event` paketi geldi

Alinan event:
- `{"id":"question_simple","type":"choice"}`

### 4. Event tetikleme

Cagri:
- `trigger_random_event()`

Sonuc:
- `method_result` dondu
- Runtime logunda event emission goruldu
- Choice flow aktif oldu

## Faz 2 Durum Karari

Faz 2:
- GECTI

Gecis kosullari saglandi:
- Need degerleri okunuyor
- State durumu okunuyor
- Event signal'i izleniyor
- Event tetiklenmesi goruluyor

## Siradaki Dogru Adim

Siradaki faz:
- Faz 3 - Sleep Sisteminin Tek Kaynakli Hale Getirilmesi

Sebep:
- `is_sleeping` state controller tarafinda
- `sleep` recovery mantigi need system tarafinda henuz yok
- Iki taraf henuz tek mantikta bulusmuyor
