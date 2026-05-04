# Hatchi MCP Next Steps and Smoke Test

Bu belge, mevcut implementasyona gore en dogru sirayi sabitlemek icin hazirlandi.
Odak: once MCP dogrulama, sonra gozlemlenebilirlik, sonra davranis tamamlama.

## 1. Net Oncelik Sirasi

1. Faz 1 - MCP Smoke Test
2. Faz 2 - Core Loop Gozlemlenebilirligi
3. Faz 3 - Sleep Sisteminin Tek Kaynakli Hale Getirilmesi
4. Faz 4 - Choice Event Data ve Sonuc Sistemi
5. Faz 5 - Regression Rutini
6. Personality Drift
7. Bond / Progression
8. Egg / Hatch / Content / Mini Game

## 2. Neden Bu Sira

Su an ana risk, oyun mantiginin eksik olmasindan once MCP test akisinin henuz fiilen dogrulanmamis olmasi.

Mevcut durumda:
- MCP runtime ve editor plugin ayarlari mevcut
- Need/state/idle/event/choice omurgasi mevcut
- Ama sistem davranislari hala gozlemsel olarak sabitlenmis degil
- Sleep davranisi iki farkli yerde yasiyor
- Event sistemi icerik olarak cok ince

Sonuc:
- Personality, bond veya content tarafina erken gitmek su an riskli
- Once test edilebilirlik ve davranis netligi kapanmali

## 3. Faz 1 Smoke Test Checklist

Amac:
- Editor bridge calisiyor mu
- Runtime server aciliyor mu
- Runtime komutlari cevap veriyor mu

Kontrol listesi:

1. Projeyi Godot editorunde ac
2. Toolbar uzerinde `MCP: Connected` gor
3. Oyunu calistir
4. Output icinde su iki logu dogrula:
   - `[MCP Runtime] Server listening on port 7777`
   - `[MCP Runtime] Autoload ready, server starting on port 7777`
5. Runtime tarafina `ping` gonder
6. Runtime tarafina `get_tree` gonder
7. Runtime tarafina `get_node` gonder
8. Su node pathlerinin gercekten var oldugunu dogrula:
   - `/root/Main/NeedSystem`
   - `/root/Main/PetIdleController`
   - `/root/Main/MicroEventController`
   - `/root/Main/RootLayout/PetArea/StateLabel`
   - `/root/Main/OverlayLayer/OverlayRoot/CenterContainer/ChoicePanel`

Faz 1 biter sayilmasi icin:
- Editor bagli
- Runtime ayakta
- `ping` cevabi aliniyor
- `get_tree` cevabi aliniyor
- En az bir `get_node` cevabi aliniyor

## 4. Faz 2 Checklist

Amac:
- Core loopu tahminle degil veriyle izlemek

Kontrol listesi:

1. `NeedSystem` node verisini oku
2. `StateLabel` node verisini oku
3. `MicroEventController.micro_event_triggered` signalini watch et
4. `trigger_random_event()` cagir
5. Choice panelin acildigini dogrula
6. Bir secenek secildiginde need degisimi oldugunu dogrula
7. State degisimi gerekiyorsa bunun da goruldugunu dogrula

Faz 2 biter sayilmasi icin:
- Need degerleri okunuyor
- Event tetiklenmesi goruluyor
- Choice sonucu need seviyesinde gozleniyor

## 5. Faz 3 Checklist

Amac:
- Sleep davranisini tek kaynakli hale getirmek

Mevcut problem:
- `PetStateController.is_sleeping` var
- `NeedSystem` sleep recovery mantigini bilmiyor

Hedef:
- Uyku mantigi state ve need tarafinda senkron olsun

Kontrol listesi:

1. `toggle_sleep()` cagir
2. `current_state == sleeping` oldugunu gor
3. Zamanla `sleep` degerinin toparlandigini gor
4. Gerekirse diger need decay oranlarinin ayristigini gor
5. Hunger kritik olunca sleep state bozuluyor mu kontrol et

## 6. Faz 4 Checklist

Amac:
- Choice event sistemini sabit UI davranisindan cikarip veri tabanli hale getirmek

Hedef:
- Event payload icinde soru
- Secenek metinleri
- Sonuc etkileri

Kontrol listesi:

1. `question_simple` payloadini zenginlestir
2. UI bu payloadi okuyarak acilsin
3. `option_a` ve `option_b` farkli sonuc uretsin
4. Sonuc MCP uzerinden okunabilir olsun

## 7. Teknik Gercek Durum Ozeti

Su an guvenle soylenebilen durum:
- Core loop var
- MCP altyapisi dosya seviyesinde kurulu
- GDD'nin tam oyunu henuz yok
- En dogru odak, "once calistigini ve gozlenebildigini kanitla" yaklasimi

## 8. Bir Sonraki Aksiyon

En dogru anlik aksiyon:
- Godot editorunde Faz 1 Smoke Test'i gercekten kosturmak

Faz 1 gecmeden:
- Sleep refactor
- Personality sistemi
- Yeni content genisletmesi

baslamamali.
