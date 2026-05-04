# MCP Phase 3 Report

Tarih: 2026-05-01
Proje: Hatchi

## Kapsam

Bu fazda sleep sistemi GDD ve workflow hedefine daha yakin olacak sekilde tek kaynakli hale getirildi.

Odak:
- Sleep state ile sleep need davranisini birlestirmek
- Sleep mantigini UI controller'dan need/domain tarafina tasimak
- MCP ile deterministik dogrulama yapmak

## Mimari Karar

Sleep davranisinin sahibi artik `NeedSystem`.

Sebep:
- GDD'de sleep bir ihtiyac davranisi
- `PetStateController` esas olarak presentation/state yansitimi yapmali
- Boylece state ve need ayni kurali iki farkli yerde tasimiyor

Bu karar SRP ve daha temiz bagimlilik yonu acisindan daha dogru.

## Yapilanlar

### 1. Sleep ownership tasindi

Dosya:
- `Systems/Needs/need_system.gd`

Eklenenler:
- `is_sleeping`
- `sleep_mode_changed`
- `request_sleep()`
- `wake_up()`
- `toggle_sleep()`
- `is_sleeping_enabled()`
- `get_sleep_block_reason()`
- `set_need_value()` test helper

Sonuc:
- Sleep mode artik need/domain seviyesi tarafinda yonetiliyor

### 2. Sleep recovery mantigi eklendi

Dosya:
- `Systems/Needs/need_system.gd`

Davranis:
- Uyurken `sleep` need artik artiyor
- Uyurken diger need'ler tam hizda degil, dusurulmus carpanlarla akiyor
- Hunger kritik seviyeye inerse sleep bozuluyor

Bu, workflow Faz 3 hedefiyle uyumlu.

### 3. Controller inceltildi

Dosya:
- `Core/pet/PetStateController.gd`

Degisiklik:
- `PetStateController` artik sleep mode'u sahiplenmiyor
- `NeedSystem` uzerinden okuyup UI/state tarafina yansitiyor
- `toggle_sleep()` artik delegasyon yapiyor

Sonuc:
- Cift kaynakli sleep mantigi kaldirildi

## MCP Dogrulama Sonucu

### Dogrulananlar

1. Hunger yeterli oldugunda sleep toggle aciliyor
2. `current_state` -> `sleeping` oluyor
3. Sleep sirasinda `sleep` need sayisal olarak artiyor
4. Hunger kritik seviyeye zorlaninca:
   - `is_sleeping` -> `false`
   - `current_state` -> `critical`

### Sayisal kanit

Sleep oncesi:
- `sleep.current_value = 74.6516`
- `is_sleeping = false`

Sleep sirasinda:
- `sleep.current_value = 77.4728`
- `is_sleeping = true`

Yani sleep need gercekten toparlaniyor.

## GDD Uyumu

Daha uyumlu hale gelen kisimlar:
- Sleep bir need davranisi olarak ele aliniyor
- Uyku pasif aksiyon mantigina yaklasiyor
- Uyku halinde interaksiyon bloklama akisi korunuyor
- Hunger baskisi sleep'i bozabiliyor

Henuz tam olmayan kisimlar:
- GDD'deki gercek zaman / saat bazli denge henuz prototype seviyesinde
- `sleep == 0` durumunda 6 saatlik tam otomatik lock mantigi yok
- Gece hizlanmasi henuz yok

Yani:
- Faz 3 workflow hedefi gecti
- Ama GDD'nin final sleep sistemi henuz tamamen bitmis degil

## Durum Karari

Faz 3:
- GECTI

## Siradaki Dogru Adim

Siradaki faz:
- Faz 4 - Choice Event Sonuclari

Ama istenirse Faz 3.5 olarak sunlar yapilabilir:
- gece hizlanmasi
- otomatik sleep-at-zero davranisi
- daha sistematik zaman olcegi
