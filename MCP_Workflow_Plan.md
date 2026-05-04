# Hatchi MCP Workflow Plan

Bu belge, projeyi MCP odakli ve test kapili kucuk fazlarla ilerletmek icin kullanilir.
Kural: Bir fazin test kapisi gecilmeden sonraki faza gecilmez.

## Faz 1 - MCP Smoke Test

Amac:
- Editor MCP plugin baglantisini dogrulamak
- Runtime MCP autoload sunucusunu dogrulamak
- Editor ve oyun runtime tarafinin ayni anda gorulebildigini netlestirmek

Beklenen mevcut durum:
- `project.godot` icinde `MCPRuntime` autoload aktif
- `godot_mcp_editor`, `godot_mcp_runtime`, `auto_reload` pluginleri aktif
- Runtime TCP portu: `7777`
- Editor bridge websocket hedefi: `ws://127.0.0.1:6505/godot`

Adimlar:
1. Godot editoru bu proje ile ac.
2. Toolbar uzerinde `MCP: Connected` yazisini dogrula.
3. Oyun sahnesini calistir.
4. Editor Output icinde runtime loglarini dogrula:
   - `[MCP Runtime] Server listening on port 7777`
   - `[MCP Runtime] Autoload ready, server starting on port 7777`
5. MCP tarafindan su temel cagrilari dene:
   - `ping`
   - `get_tree`
   - `get_node`

Test kapisi:
- Editor bagli
- Runtime sunucusu acik
- En az bir `get_tree` ve bir `get_node` cevabi aliniyor

Ornek runtime komutlari:
```json
{"id":"1","command":"ping","params":{}}
{"id":"2","command":"get_tree","params":{"root":"/root","depth":3,"include_properties":false}}
{"id":"3","command":"get_node","params":{"path":"/root/Main/NeedSystem"}}
```

Sorun olursa bakilacak yerler:
- `addons/godot_mcp_editor/mcp_client.gd`
- `addons/godot_mcp_runtime/mcp_runtime_autoload.gd`
- Godot editor Output paneli

## Faz 2 - Core Loop Gozlemlenebilirligi

Amac:
- Need, state ve idle event akislarini MCP uzerinden okunabilir hale getirmek
- Oyun davranisini tahminle degil veriyle izlemek

Hedef node/path referanslari:
- `NeedSystem`
- `RootLayout/PetArea/StateLabel`
- `PetIdleController`
- `MicroEventController`

Adimlar:
1. `get_tree` ile node pathleri dogrula.
2. `get_node` ile `NeedSystem` durumunu oku.
3. `get_node` ile `StateLabel` script state alanlarini oku.
4. `watch_signal` ile kritik sinyalleri izlemeyi dene:
   - `micro_event_triggered`
   - Gerekirse yeni sinyaller ekle
5. `set_property` veya `call_method` ile kontrollu state degisimi yarat.

Test kapisi:
- Need degerleri disaridan okunuyor
- State gecisi gozleniyor
- En az bir idle veya micro event akisi goruluyor

Ornek runtime komutlari:
```json
{"id":"10","command":"get_node","params":{"path":"/root/Main/RootLayout/PetArea/StateLabel"}}
{"id":"11","command":"call_method","params":{"path":"/root/Main/MicroEventController","method":"trigger_random_event","args":[]}}
{"id":"12","command":"watch_signal","params":{"path":"/root/Main/MicroEventController","signal":"micro_event_triggered"}}
```

Not:
- Bu fazda gerekirse debug amacli ek sinyaller eklenebilir.
- Ama oyun mantigi henuz buyutulmez, sadece gozlem kolaylastirilir.

## Faz 3 - Sleep Sistemi Tamamlama

Amac:
- Sleep state ile sleep need davranisini tek mantikta birlestirmek

Mevcut durum:
- Sleep butonu state toggle akisina bagli
- `sleep` need su an uyurken otomatik toparlanmiyor

Yapilacaklar:
1. `NeedSystem` icinde uyku sirasinda `sleep` need artis mantigi ekle.
2. Gerekirse uyurken diger need decay oranlarini dusur veya ayir.
3. `PetStateController` ile `NeedSystem` arasinda tek kaynakli sleep davranisi kur.

Test adimlari:
1. MCP ile `toggle_sleep` cagir.
2. `current_state == sleeping` oldugunu dogrula.
3. Zaman gecince `sleep` need arttigini dogrula.
4. Aciklik kritik seviyeye inerse sleep state’in bozuldugunu test et.

Test kapisi:
- Sleep state ve sleep need birbiriyle uyumlu
- Wake/sleep gecisleri deterministik

Ornek runtime komutlari:
```json
{"id":"20","command":"call_method","params":{"path":"/root/Main/RootLayout/PetArea/StateLabel","method":"toggle_sleep","args":[]}}
{"id":"21","command":"get_node","params":{"path":"/root/Main/NeedSystem"}}
{"id":"22","command":"get_node","params":{"path":"/root/Main/RootLayout/PetArea/StateLabel"}}
```

## Faz 4 - Choice Event Sonuclari

Amac:
- Choice event sistemini yalnizca UI acmaktan cikarip anlamli sonuclar ureten hale getirmek

Mevcut durum:
- `question_simple` event’i var
- `option_a` ve `option_b` temel feedback uretiyor

Yapilacaklar:
1. `question_simple` sonucunu need/state seviyesinde netlestir.
2. Event verisini buyut:
   - soru metni
   - secenek metinleri
   - sonuc etkileri
3. Sonucu MCP uzerinden tetiklenebilir tut.

Test adimlari:
1. `MicroEventController.trigger_random_event()` cagir.
2. Choice panelin acildigini dogrula.
3. `option_a` sec ve sonucunu kaydet.
4. `option_b` sec ve farkli sonuc verdigini dogrula.

Test kapisi:
- Choice event aciliyor
- Her secenek farkli sonuc veriyor
- Need veya state uzerinde gozlenebilir etki olusuyor

Ornek runtime komutlari:
```json
{"id":"30","command":"call_method","params":{"path":"/root/Main/MicroEventController","method":"trigger_random_event","args":[]}}
{"id":"31","command":"get_node","params":{"path":"/root/Main/OverlayLayer/OverlayRoot/CenterContainer/ChoicePanel"}}
```

## Faz 5 - MCP Regression Rutini

Amac:
- Her degisiklikten sonra ayni kisa test paketini tekrar calistirabilmek

Kisa regression listesi:
1. Scene aciliyor mu?
2. `NeedSystem` okunuyor mu?
3. State gecisi dogru mu?
4. Sleep toggle calisiyor mu?
5. Micro event tetikleniyor mu?
6. Choice sonucu uygulanıyor mu?

Test kapisi:
- Bu altı kontrol tek tek geciyor

## Uygulama Prensibi

Her faz icin su sira kullanilacak:
1. Hedef davranisi sabitle
2. Kucuk kod degisikligi yap
3. MCP ile test et
4. Sonucu not et
5. Sonraki faza gec

## Su Anki Durum

Tamamlananlar:
- Faz 1 Smoke Test gecildi (`MCP_Smoke_Test_Report_2026-05-01.md`)
- Faz 2 Core Loop Gozlemlenebilirligi gecildi (`MCP_Phase2_Report_2026-05-01.md`)
- Faz 3 Sleep tek kaynakli mimariye tasindi (`MCP_Phase3_Report_2026-05-01.md`)
- Faz 4 Choice event data/result sistemi gecildi (`MCP_Phase4_Report_2026-05-01.md`)
- Faz 5 Regression rutini dokumante edildi (`MCP_Regression_Routine.md`)

Kod tabaninda gozlenen ek ilerleme:
- Egg, Lifecycle, Personality ve Bond sistemleri sahneye entegre
- Regression scripti bu sistemleri ayni senaryoda test edecek sekilde genisletilmis

Siradaki aktif odak:
- Yeni MCP fazi acmaktan cok, event/content derinligi + mini game + UX polish + GDD kapsam tamamlama
