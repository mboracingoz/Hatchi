

Hatchling GDD v1.0  ·  1
HATCHLINGGame Design Document
n
## HATCHLING
## Virtual Pet Life Simulation
Game Design Document — v1.0
## Production Ready · Mobile First · Portrait Orientation
StudioSolo Developer
PlatformiOS / Android — Portrait (9:16)
Engine ÖneriGodot 4 veya Unity (2D)
GenreVirtual Pet / Life Simulation
Core ReferencesTamagotchi (1996), Tomodachi Life (2013), Adorable Home
Target Audience16–35 yan, casual-mid core, nostalji + modern mobil
MonetizationSoft IAP (Freemium)
MVP Hedefi8–12 hafta solo gelintirme
Döküman TarihiNisan 2026

Hatchling GDD v1.0  ·  2
HATCHLINGGame Design Document
nçindekiler
## 1. Core Vizyon & Oyun Pilleri
## 2. Core Mekanikler
## 3. Tomodachi Ruhu — Sosyal & Absürt Sistemler
## 4. Game Loop Tasarnmn
## 5. Progression & Meta Sistemler
## 6. Mini Oyun Tasarnmn
- UI & UX Tasarnmn
## 8. Art & Animasyon Yönü
## 9. Ses Tasarnmn
## 10. Monetization Sistemi
## 11. Retention & Live Ops
## 12. Design Riskleri & Çözümler
- MVP Scope

Hatchling GDD v1.0  ·  3
HATCHLINGGame Design Document
## 1. Core Vizyon & Oyun Pilleri
## Vizyon Cümlesi
Hatchling;  rastgele  bir  yumurtadan  çnkan  bir  hayvann  büyütüp  onunla  ban  kurdunun,  absürt  ve  duygusal
anlarla  dolu,  her  oturumda  bir  neyler  önreten  modern  bir  virtual  pet  deneyimidir.  Oyun  seni  sorumlu  knlar,
güldürür ve bazen nannrtnr.
## Üç Temel Pili
SorumlulukKinilikKoleksiyon
Hayvannn ihtiyaçlarnnn
karnnlamak oyuncunun
omuzlarnndadnr. nhmal sonuç
donurur.
Oyuncunun her seçimi hayvannn
karakterini nekillendirir. Aynn tür,
farkln oyuncularda tamamen farkln
biri olur.
Her hayvan benzersizdir. Oyuncu
onu yetintirip 'mezun' ettikten sonra
koleksiyonunda yanatnr.
## Hedef Deneyim
Oyuncu  sabah  uyandnnnnda  'acaba  ne  yaptn'  diye  telefonu  açar.  Gün  içinde  knsa  oturumlarla  ihtiyaçlarn
karnnlar, sürpriz eventlere güler. Haftalarca büyüyen bir karakteri final forma ulantnrdnnnnda gerçek bir veda
hissi yanar ve bir sonraki yumurtayn merakla bekler.
Günlük aktif süre5–15 dakika (4–6 knsa oturum)
Duygusal tonSncak, komik, zaman zaman melankolik
Viral potansiyelAbsürt davrannnlar ekran görüntüsü / paylannm tetikler
Retention hedefiD7: %40+ | D30: %20+

Hatchling GDD v1.0  ·  4
HATCHLINGGame Design Document
## 2. Core Mekanikler
## 2.1  Yumurta Sistemi
Her  oyun  yeni  bir  yumurtayla  banlar.  Yumurta  görsel  olarak  opaktnr;  içinden  ne  çnkacann  belli  olmaz.
Yumurta rengi 'Rarity Tier' belirler.
Renk / TierÇnkma Süresinçerik
Gri — Common2 saat (gerçek zaman)Temel 6 hayvan türü
Mavi — Uncommon4 saatÖzel renk varyasyonu veya napka
ile donar
Altnn — Rare8 saatNadir tür (Axolotl, Capybara vb.) +
özel banlangnç animasyonu
Mor — Legendary24 saatUnique hayvan + özel yumurta
çatlama cutscene
n Yumurtalar ücretsiz kazannlnr. Enerji toplanarak veya günlük görevle elde edilir. Legendary yumurta manazada
satnnta olmaz; yalnnzca özel eventlerde kazannlnr.
## Yumurta Çatlama Ritüeli
- Pasif: Yumurta gerçek zamanln sayaçla çatlar. Uygulama kapalnyken de süre ilerler.
- Aktif Dokunma: Oyuncu yumurtaya dokunarak 'çatlaklar' açabilir; bu görsel feedback verir ama süreyi
%10'dan fazla knsaltmaz. Ritüel hissi yaratnr, exploit denil.
- Hnzlandnrma (IAP): Premium para birimiyle annnda açnlabilir. Zorunlu denil.
- Çatlama ann: Kamera zoom, parçacnk efekti, hayranlnk sesi. Hangi hayvannn çnktnnn 0.5 saniyelik
sisleme animasyonuyla açnklannr.
## 2.2  Hayvan Türleri & Varyasyonlar
Her tür, baknm davrannnnna farkln tepkiler üretecek nekilde tasarlanmnntnr. Türler mekaniksel fark denil,
kinilik ve animasyon setini belirler.
TürRarity PoolKinilik Enilimi
KediCommonBannmsnz, zaman zaman ukala,
dokunmaya tepki geç
KöpekCommonAnnrn sevecen, enerji çok tüketir,
oyun sever
TavnanCommonÇekingen, baknmsnz kalnnca
kaprisli
PenguenUncommonKomik yürüyün, çok yeme sever,
tatln dilli
AxolotlRareSakin, absürt davrannnlar, su
animasyonlarn

Hatchling GDD v1.0  ·  5
HATCHLINGGame Design Document
CapybaraRareSosyal, diner hayvanlara sempatik,
relax
Kristal TilkiLegendaryMistik, absürt bilgece sözler, özel
efektler
Void KediLegendaryTamamen siyah, evreni anlayan
komik nihilist
n Her türün 3–4 renk varyasyonu vardnr. Varyasyonlar mekaniksel fark yaratmaz, koleksiyon deneri tannr.
## 2.3  Enerji Sistemi
Enerji,  oyuncunun  hayvana  aktif  aksiyon  uygulayabilmesini  dengeleyen  günlük  kaynak  birimidir.  Spam  oturum
yerine anlamln knsa oturumlarn tenvik eder.
Günlük maksimum20 Enerji
YenilemeHer 30 dakikada 1 enerji — maksimumda birikir
Sabah bonusuGün ilk açnlnnta +5 enerji
Aksiyon maliyetleriBesleme: 1 | Oyun: 2 | Banyo: 2 | Uyutma: 0 (pasif)
Enerji annmnMaksimum 30 (premium item ile geçici +10 cap)
Enerji  knsntlamasn  oyuncuyu  saatler  boyu  oturmaya  zorlamaz.  Günlük  birkaç  kontrol  yeterlidir.  Bu,  retention
loopunu besler.
## 2.4  Need (nhtiyaç) Sistemi
Her  hayvannn  4  temel  ihtiyacn  vardnr.  Her  biri  0–100  arasn  bir  denerle  temsil  edilir.  nhtiyaçlar  gerçek
zamanln düner; uygulama kapalnyken de ilerler.
nhtiyaçDünün HnznKritik Etkisi
Açlnk (Hunger)12 puan / saat0'a dününce enerji harcamaz,
animasyon üzgün, personality
negatife kayar
Mutluluk (Happiness)8 puan / saatDünük iken random event
snklnnn azalnr, karakter
sonuklannr
Temizlik (Hygiene)6 puan / saatÇok dünükse görsel kirlilik efekti,
sosyal eventler bloklannr
Uyku (Sleep)5 puan / saat (gece hnzlannr)0'da hayvan uyuma moduna girer,
6 saat interaksiyon kapaln
n Dört ihtiyacnn tümü aynn anda kritik olmaz tasarnmsal kural. Oyun, aynn anda en fazla 2 ihtiyacn kritik enine
sürükler. Böylece panik denil, öncelik hissi yaratnr.

Hatchling GDD v1.0  ·  6
HATCHLINGGame Design Document
## 2.5  Personality Drift Sistemi
Personality  Drift,  oyunun  en  önemli  differentiator  mekanizmidir.  Oyuncunun  her  kararn  hayvannn  karakterini
hafifçe  kaydnrnr.  Bu  sistem  görünmezdir  —  oyuncu  'stat  atnyorum'  hissetmez,  davrannn  deninimini
gözlemler.
Oyuncu DavrannnnPersonality Kaymasn
Sürekli erken beslemeObur, yiyecek taknntnln diyaloglar
Oyuna çok zaman harcamaEnerjik, dnna dönük, abartnln tepkiler
nhmal (ihtiyaçlar dünük kalnyor)Melankolik, mesafeli, pek konunmayan
Gece yarnsn oturumGece baykunu kinilini, gündüz tembel
Her günkü düzenli baknmSakin, güvenli banln, paylannmcn
Seçimlerde sürekli absürt yanntKaotik, beklenmedik davrannnlar üretir
Seçimlerde sürekli ciddi yanntOlgun, felsefi diyaloglar
Personality,  5  boyutlu  bir  vektörde  tutulur:  Enerji,  Sosyallik,  Empati,  Kaos,  Olgunluk.  Her  eksen  0–100  arasn.
Davrannnlar bu vektörün bölgelerine göre tetiklenir. Oyuncuya hiçbir zaman sayn gösterilmez.
## 2.6  Yanam Döngüsü
Hayvan  4  anamada  büyür.  Geçinler  otomatik  denil,  belirli  'milestone'larn  tamamlamayn  gerektirir.  Bu;
progression'n oyuncunun kontrolünde hissettirir.
AnamaSüreÖzellikler
Bebek (Baby)Gerçek zaman 1–2 günnhtiyaçlar çok hnzln düner, küçük
ve ninman görsel, snnnrln
diyalog, çok sevimli animasyonlar
Genç (Juvenile)3–5 günnhtiyaçlar normale gelir,
personality olunmaya banlar, ilk
mini oyunlar açnlnr, diyalog seti
geninler
Yetinkin (Adult)5–10 günTam need sistemi aktif, tüm
personality davrannnlarn açnk,
random eventler çonalnr, görsel
olarak tam boyut
Final FormÖzel milestone sonrasnRarity'ye göre özel görsel form,
benzersiz animasyonlar, veda
ritüeli haznrlnnn
## Büyüme Milestone'larn
- Baby → Juvenile: 10 yemek verilmeli + 5 oyun oturumu + 1 'personality event' seçimi yapnlmnn olmaln
- Juvenile → Adult: Bond puann enine ulanmaln (bkz. Bölüm 5) + 3 mini oyun tamamlanmaln

Hatchling GDD v1.0  ·  7
HATCHLINGGame Design Document
- Adult → Final Form: Toplam 20+ personality event + tür'e özgü özel konul (örn. Axolotl: 5 banyo + 3 su
minnigame)
## 2.7  Ölüm, Veda & Koleksiyon Geçini
'Ölüm'  kelimesi  oyun  içinde  kullannlmaz.  Hayvan  'yolculununa  devam  eder'  ya  da  'mezun  olur'.  Bu  frame,
çocuk/genç oyuncularn incitmeden duygusal annrlnk yaratnr.
nhmal Senaryosu
nhtiyaçlarnn  tümü  3  gün  boyunca  sürekli  kritik  kalnrsa  hayvan  giderek  hareketsizlenir.  Son  gün  özel  bir
'hastalanma'   animasyonu   oynar.   Oyuncuya   recovery   nansn   verilir   (enerji   harcamasn   ile).   Recovery
yapnlmazsa hayvan 'yola çnkar'.
## Donal Final Form Vedasn
Oyuncu Final Form'a ulantnnnnda 'Graduation Event' tetiklenir. Bu özel, atlatnlamaz bir cutscene'dir. Hayvan
oyuncuya knsa bir mesaj bnraknr (diyalog, personality'ye göre dinamik üretilir). Akabinde Koleksiyona geçer.
n Veda ann duygusal bir tasarnm kararndnr. Oyunun viral potansiyelinin bir knsmn burada gizlidir. Oyuncular bu
ann ekran görüntüsüyle paylannr.

Hatchling GDD v1.0  ·  8
HATCHLINGGame Design Document
## 3. Tomodachi Ruhu — Sosyal & Absürt Sistemler
## 3.1  Random Event Sistemi
Random   Eventler   oyunun   'duygusal   nabzndnr'.   Oyuncu   her   oturumda   bekledininden   farkln   bir   neyle
karnnlannr. Bu, açnlnn motivasyonunu canln tutar.
Tetiklenme snklnnnAdult anamasnnda günde 2–4 event (personality etkiler)
Event tipleriDavrannn eventi, Soru eventi, Duygu eventi, Mini kriz eventi
GörsellentirmeEkranda hayvannn üstünde bubble / thought cloud belirir
Oyuncu etkilenimiBazn eventler sadece izlenir, baznlarn seçim ister
## Örnek Event Katalonu
Event nsmiAçnklama
Varolun KriziHayvan aniden durur, dününce balonunda '...ben neden
buradaynm?' yazar. 3 saniye bekler, sonra atlar ve
devam eder.
Müzik AnnHayvan hayali bir enstrüman çalar, notalar uçar. Oyuncu
'alknn' veya 'git yatmaya' seçeneniyle tepki verebilir.
Gizli NesneHayvan, ekrannn könesinde bir ney bulur. Oyuncuya
gösterir. Nadiren bir item, çonunlukla absürt bir ney
(tan, havuç).
Yansnma BaknnnHayvan ekranda sana bakar. Dününce balonu: 'nu an
bana baktnnnnn biliyorum.' Sonra devam eder.
Rüya KonunmasnHayvan uyurken anznndan komik kelimeler çnkar
(konuntunu dile banln).
Felsefi SoruHayvan oyuncuya bir soru yöneltir: 'Balnk mn tercih
edersin, odada bir balnk mn?' — iki seçenek, ikisi de
saçma.
Beklenmedik BeceriHayvan aniden akrobasi yapar, durur ve sanki bir ney
olmamnn gibi devam eder.
Gece FnsnltnsnSadece gece 23:00–02:00 arasn tetiklenir. Hayvan
karanlnkta parlayan gözlerle sana bakar.
## 3.2  Soru & Seçim Sistemi
Hayvan günde 1–2 kez oyuncuya donrudan soru sorar. Sorular iki kategoridedir:
Tercih Sorularn (Personality Drift Üretir)
Bu sorular personality vektörünü kaydnrnr. Oyuncu farknnda olmadan hayvannnn nekillendirir.

Hatchling GDD v1.0  ·  9
HATCHLINGGame Design Document
- 'Bugün dnnarnda mn gezmek isterdin, yoksa içeride tek bannna mn?' → Sosyallik ekseni
- 'Bir neyi biliyor olmak mn güzel, yoksa önrenmekte olmak mn?' → Olgunluk ekseni
- 'Kurallar ne zaman knrnlmaln?' → Kaos ekseni (3 opsiyon: hiçbir zaman, bazen, her zaman)
Absürt Durum Sorularn (Komedi + Viral)
Bu sorular mekaniksel etki üretmez; sadece diyalog & animasyon tetikler. Viral potansiyelleri yüksektir.
- 'Ener tüm yastnklar aniden kaybolsa dünya daha mn kötü olurdu?'
- 'Bana bir snr anlat. Ben kimseye söylemem.' (Oyuncu bir ney yazarsa hayvan bunu asla tekrar etmez, ama
log'da saklar ve bazen 'hatnrlar')
- 'nu an kaç adet çorap sende var?' (Cevap ne olursa olsun hayvan abartnln tepki verir)
## 3.3  Seçim → Sonuç → Drift Döngüsü
Seçim annHayvan sorar, oyuncu 2–3 seçenekten birini seçer. UI sade; büyük butonlar,
knsa metin.
Anlnk sonuçHayvan seçime göre animasyonla tepki verir. Mutlu, üzgün, nanknn veya
absürt.
Gecikmin sonuçErtesi gün veya sonraki oturumda hayvan o seçimi 'hatnrlar'. Yeni bir
diyalona yol açar.
Uzun vadeBiriken seçimler personality vektörünü kaydnrnr. 2 hafta sonra karakter
belirgin nekilde farklndnr.
Oyuncuya geri bildirimOyuncuya hiçbir zaman 'personality deninti' gösterilmez. Davrannn
deninimini gözlemler.
## 3.4  Absürt Anlar — Viral Tasarnm Katmann
Her hayvanda tür'e özgü 5–8 adet 'signature absürt moment' bulunur. Bunlar nadiren tetiklenir (haftada 1–2), bu
yüzden denerleri yüksektir.
TürSignature Absürt Moment
KediEkrannn könesine gider, 10 saniye hiçbir ney yapmaz,
döner ve sanki hata yakalamnn gibi kendi ekrannnn
inceler.
KöpekAniden 'kuyruk kovalama' moduyla döner, kendini
kaybeder, durur, oyuncuya bakar: 'Gördün mü?'
AxolotlYerinden kalkar, tam ortada durur ve ekrana: 'Su içtin mi
bugün?' yazar. Bekler.
CapybaraDününce balonu: 'Her ney yolunda.' Hiçbir ney yolunda
olmasa da.
Void KediEkran 0.5 saniye kararnr. Hayvan karanlnkta gözler
açar: 'Uyku mu istiyorsun? Ben uyumam.' Ekran açnlnr.

Hatchling GDD v1.0  ·  10
HATCHLINGGame Design Document
## 4. Game Loop Tasarnmn
## 4.1  Core Loop — Dakikalnk Gameplay
Tek bir oturumun süresi 2–5 dakikadnr. Her oturum ananndaki döngüyü takip eder:
- Açnlnn GözlemiHayvannn mevcut durumu gözlemlenir. Animasyon, yüz ifadesi ve need
barlarn ilk bilgiyi verir. Oyuncu 'ne durumda?' sorusuna 3 saniyede cevap
alnr.
- nhtiyaç TespitiKritik veya dünük ihtiyaç varsa oyuncu enerji harcayarak karnnlar. Besleme,
oyun, banyo aksiyonlarn.
- Event KontrolüEkranda bekleyen bir event veya soru varsa oyuncu etkilenime girer. Seçim
yapar veya animasyonu izler.
- AktiviteEnerji varsa mini oyun oynama veya dekorasyon yerlentirme gibi opsiyonel
aktiviteler.
- Kapannn BonusuOturum 2+ dakika sürdüyse ve 2+ aksiyon yapnldnysa küçük bond puann
kazannlnr.
## 4.2  Günlük Loop
Sabah (07–11)Önlen (12–15)Aknam/Gece (18–23)
Push notification: hayvan uyandn.
Sabah bonusu enerji +5. Dün gece
davrannnn raporu (knsa). Hnzln
besleme oturumu.
Opsiyonel: enerji doldu, mini oyun
açnk. nhtiyaç kontrolü. Günlük
görev ilerleme kontrol.
Ana oturum. Personality event
olasnlnnn yüksek. Günlük görev
kapannnn. Uyutma aksiyonu.
n Oyun üç oturum için tasarlanmnntnr ama tek oturumla da sanlnkln ilerleme mümkündür. nkinci ve üçüncü
oturum 'daha iyi ama gerekli denil' hissini verir.
## 4.3  Haftalnk & Uzun Vadeli Loop
Zaman DilimiOyuncu Deneyimi
Gün 1–2Yumurtayn açma, baby anamasn heyecann, ilk
personality sinyalleri
Gün 3–5Juvenile anamasn, ilk mini oyunlar, karakter
nekillenmeye banlar, ban kurulur
Gün 6–10Adult anamasn, tam event seti aktif, oyuncu artnk
karakteri 'tannr', günlük rutine yerlenir
Gün 11–18Final form milestone beklentisi, büyük personality
eventleri, veda haznrlnnn
Gün 18+Graduation, koleksiyona ekleme, yeni yumurta
heyecann, farkln tür denemek isteme

Hatchling GDD v1.0  ·  11
HATCHLINGGame Design Document
Uzun vade (ay+)Koleksiyon tamamlama, event döngüleri, sezonsal içerik,
bond rekoru knrmak

Hatchling GDD v1.0  ·  12
HATCHLINGGame Design Document
## 5. Progression & Meta Sistemler
5.1  Bond (Ban) Sistemi
Bond,  oyuncunun  o  anki  hayvanla  kurdunu  ilinkinin  saynsal  göstergesidir.  0–1000  arasnnda  birikir.  Görsel
olarak 'kalp ölçeni' neklinde gösterilir.
Bond kazanmaHer ihtiyaç karnnlamada: +2–5 | Mini oyun: +8–15 | Personality event
yanntn: +5–20 | Tam haftalnk rutin: +30 bonus
Bond kaybnnhmal günleri: -10/gün | Kritik ölüm senaryosu: -50
Bond'un etkisiYüksek bond → hayvan daha fazla event üretir, diyaloglar daha samimi,
graduation animasyonu daha uzun
Bond kalncnlnnnHayvan koleksiyona geçtininde o hayvanla bond puann 'legacy puan' olarak
kalncn tabloya girer
## Bond Milestone Ödülleri
- Bond 100: nlk 'hafnza' event'i — hayvan bir neyi hatnrladnnnnn gösterir
- Bond 300: Özel dekorasyon item unlocked
- Bond 500: Hayvan oyuncu adnnn kullanmaya banlar
- Bond 750: 'Derin ban' personality tier açnlnr, nadir davrannnlar tetiklenir
- Bond 1000: Graduation eventinde maksimum uzun versiyon cutscene
## 5.2  Unlock Sistemi
Unlock  sistemi  yatay  geninlemedir;  daha  güçlü  denil,  daha  çenitli.  Oyuncu  'ilerliyor'  hissini  kazannr,  üstün
olmak için denil, biriktirmek için.
KategorinçerikUnlock Yöntemi
Aksesuarlarnapkalar, boyunbann, gözlük,
arka plan itemlarn
Bond milestone, günlük görev
ödülü, IAP
Oda DekorasyonuMobilya, duvar kanndn, zemin,
objeler
Koleksiyon puann, görev, IAP
Yiyecek VaryasyonlarnÖzel yemekler (mutluluk veya
enerji bonusu)
Günlük görev, mini oyun ödülü
Animasyon SetleriEk idle ve tepki animasyonlarnNadir event tamamlama, IAP
bundle
Yumurta KozmetikleriÖzel yumurta kabn görünümüEvent ödülü, IAP
## 5.3  Koleksiyon Sistemi

Hatchling GDD v1.0  ·  13
HATCHLINGGame Design Document
Koleksiyon, oyunun uzun vadeli banlnlnk çnpasndnr. Mezun edilen her hayvan buraya girer ve kalncn olarak
## 'yanar'.
Koleksiyon defteriHayvan türleri x renk varyasyonlarn x personality arketipleri grid'i
Hayvan detaynHer koleksiyon kaydn: hayvan adn, kaç günde büyütüldü, en yüksek bond,
son söyledini söz, bir fotonraf ann
Koleksiyon puannUnique entry her biri puan üretir. Bu puan kilit item ve oda dekorasyonu açar
Eksik slot motivasyonu'?' ile gösterilen bon slotlar merak yaratnr. Türü gösterilir, içerini belli denil
Personality arketipleriAynn türü farkln personality ile yetintirmek ayrn slot: 'Kaotik Axolotl' vs
'Sakin Axolotl'
## 5.4  Replayability Tasarnmn
- Her hayvan yetintiricilini farkln bir deneyimdir; aynn türü iki kez aynn nekilde yetintirmek imkansnzdnr.
- Personality vektörünün 5 ekseni ve her eksen 0–100 arasn → teorik olarak sonsuz varyasyon.
- Koleksiyon completion drive: oyuncu 'nu türü hiç yetintirmedim' motivasyonuyla devam eder.
- Sezonsal hayvan ve event içerikleri (Live Ops) yeni deneyim katmann açar.
- Hata yapma ve farkln seçimler: oyuncu geçen seferde kaçnrdnnn bir personality arketipini denemek ister.

Hatchling GDD v1.0  ·  14
HATCHLINGGame Design Document
## 6. Mini Oyun Tasarnmn
## Genel Prensipler
Mini oyunlar iki amaca hizmet eder: Skill oyunlarn beceri ve dikkat ister, ödülü yüksektir. Ritual oyunlarn dünük
streslidir,  ban  ve  rutin  hissini  pekintirir.  Her  hayvannn  bir  favori  mini  oyunu  vardnr  (personality  tabanln);  o
oyunda bonus ödül kazannlnr.
Mini Oyun 1 — 'Beslenme Ritmi' (Ritual)
TipRitual / Zamanlama
AmaçHayvann beslemek. Happiness ve Hunger doldurmak.
MekanikYiyecek itemlarn yukarndan anannya düner. Oyuncu hayvannn anznnn
soldan sana kaydnrarak donru yiyeceni yakalar. Yanlnn yiyecek (tan, çöp)
kaçnrnlmaln.
KontrolTek parmak drag — portrait uyumlu
Süre30 saniye
Difficulty ScalingBaby: yavan dünün, az item | Juvenile: orta hnz, daha fazla item | Adult:
hnzln, sahte itemlar eklenir
Banarn ÖdülüHunger +40, Happiness +15, Bond +8
Tam Kombo BonusuHiç yanlnn yakalamadan bitirme: +5 ekstra bond + nadir yiyecek item
Hayvan TepkisiMutlu animasyon, özel ses efekti, personality'e göre farkln reaksiyon
Mini Oyun 2 — 'Hafnza Enlentirme' (Skill)
TipSkill / Hafnza
AmaçHayvanla 'birlikte' oynamak; happiness ve bond üretmek.
Mekanik4x4 kart gridi (toplam 8 çift). Kartlar yüz üstü çevrilir, enlentirilir. Klasik
hafnza oyunu. Ancak hayvan zaman zaman bir karta baktnnnnda hafif bir
'ipucu' animasyonu verir. Bu ipuçlarn bond yüksekse artar.
KontrolDokunma
SüreSüresiz ama hamle snnnrln: 20 hamle
Difficulty ScalingBaby: 3x2 grid | Juvenile: 4x3 | Adult: 4x4 | Adult+ (hard mod): 5x4 + kart
içerikleri deninir
Banarn ÖdülüHappiness +30, Bond +15, nadir cosmetic item (dünük olasnlnk)
BanarnsnzlnkHamle bitti ama tamamlanmadn: Hayvan 'üzgün ama anlaynnln'
animasyonu oynar, yarn ödül

Hatchling GDD v1.0  ·  15
HATCHLINGGame Design Document
Hayvan npucu SistemiBond 500+ ise hayvan %30 ihtimalle donru kartn inaret eder. Bu hayvannn
'zeki' oldunu hissi verir.
Mini Oyun 3 — 'Banyo Vakti' (Ritual + Mikro Skill)
TipRitual / Dokunma Tabanln
AmaçTemizlik barnnn doldurmak, Happiness hafifçe artnrmak.
MekanikHayvan küvette oturur. Ekranda 'kir' parçacnklarn belirir. Oyuncu
parmannyla sürterek temizler (fnrça veya sünger hareketi). Köpük, su sesi,
balonlar. Özel 'zor alan' lekeleri vardnr — bunlar daha fazla sürme gerektirir.
Hayvan bu sürede reaksiyon verir: bazn hayvanlar seviniyor, baznlarn
bannrnyor.
KontrolÇoklu parmak sürme hareketi
Süre45 saniye veya tüm kirler temizlenene kadar
Difficulty ScalingBaby: az kir, kolay alan | Adult: çok kir, baznlarn tekrar belirir
Banarn ÖdülüHygiene +60, Happiness +10, Bond +5
Özel MomentHayvan %10 ihtimalle banyoda kendi kendine bir narkn söyler (absürt ses
efekti). Ekran görüntüsü alma motivasyonu yüksek.

Hatchling GDD v1.0  ·  16
HATCHLINGGame Design Document
- UI & UX Tasarnmn
7.1  Ana Ekran Layout (Portrait)
Tüm kritik bilgi ve aksiyon tek ekranda, kaydnrma olmadan erinilebilir. Ana ekran 5 bölgeye ayrnlnr:
## Bölgençerik & Tasarnm Kararn
Üst Bar (sabit, %10 yükseklik)Sol: Enerji ikonu + sayaç. Orta: Hayvan adn + anama
badge. San: Premium para birimi + ayar ikonu. Minimal,
bilgi yonun denil.
Need Bar Paneli (%15 yükseklik)4 bar yatay dizilir. Her bar: küçük ikon + renk dolgu. Kritik
bar titrenir ve renk denintirir
(sarn→turuncu→knrmnzn). Sayn gösterilmez, yüzde
bar yeterli.
Hayvan Sahnesi (%50 yükseklik)Hayvannn yanadnnn alan. Arka plan denintirilebilir
(dekorasyon). Hayvan bu alanda serbest dolannr,
animasyonlar oynar. Dokunun: hayvan tepki verir. Uzun
basnn: aksiyon menüsü açnlnr.
Aksiyon Alann (%15 yükseklik)4 büyük buton: Besle, Oyna, Banyo, Konun. Enerji
maliyeti küçük saynyla buton üzerinde. Yetersiz enerji:
buton soluk, dokununta açnklama gösterilir.
Alt Nav Bar (sabit, %10 yükseklik)Ana Sayfa | Koleksiyon | Manaza | Görevler. Aktif sekme
belirgin. Badge sistemi: yeni görev varsa knrmnzn
nokta.
7.2  Aksiyon Menüsü (Uzun Basnn)
Hayvan  sahnesine  uzun  basnldnnnnda  hafif  bir  blur  efektiyle  radyal  menü  açnlnr.  6  hnzln  aksiyon  ikonu
çember  neklinde:  Besle,  Oyna,  Banyo,  Uyut,  Fotonraf  Çek,  Konun.  Her  ikona  küçük  tooltip.  Menü  dnnnna
dokunarak kapannr.
## 7.3  Bar Göstergesi Tasarnmn
Renk skalasn100–60: Yenil | 59–30: Sarn | 29–10: Turuncu | 9–0: Knrmnzn
AnimasyonBar dolumu: smooth slide, enerji harcama: küçük azalma animasyonu
Kritik durumBar titrer + hafif knrmnzn arka plan parlamasn, not: fazla yapnlmaz, spam
denil
TooltipBar'a uzun basnnta saynsal dener ve 'yaklannk kaç saate kritik' bilgisi
## 7.4  Feedback Sistemleri

Hatchling GDD v1.0  ·  17
HATCHLINGGame Design Document
## Aksiyon Feedbacki
- Besleme: yiyecek uçar hayvannn anznna, hapy ses efekti, hunger bar dolar animasyonla
- Oynama: konfeti/parçacnk efekti, hayvan atlama animasyonu
- Banyo: köpük parçacnklarn, su sesi, hayvan parlayarak temizlenir
## Event Feedbacki
- Event banlangncn: hayvan duraklar, dününce balonu büyür, ses efekti
- Seçim ann: butonlar büyür, hafif titrenim (haptic)
- Seçim sonucu: hayvan tepki animasyonu, knsa metin, ses
## Hata Feedbacki
- Yetersiz enerji: knsa shake animasyonu + 'Enerji yetersiz — X dakikaya dolar' tooltip
- Uyku modunda aksiyon: hayvan hafifçe homurdar, 'uyuyor, rahatsnz etme' balonu
7.5  Bildirim (Push Notification) Tasarnmn
Bildirimler  dener  tannmaln,  spam  olmamaln.  Maksimum  günde  3  bildirim.  Oyuncunun  bildirim  yorgunlunu
yanamamasn önceliktir.
Bildirim TipiMetin & Zamanlama
Açlnk kritik'[nsim] biraz aç görünüyor...' — Hunger %15 altnna
dününce, günde max 1
Yumurta haznr'Yumurtanda bir neyler knpnrdnyor! Gel bak.' —
Yumurta çatlama tamamlandnnnnda
Günlük görev'Bugünkü görevlerin seni bekliyor.' — Sabah 09:00, tek
seferlik
Event bekliyor'[nsim]'in aklnnda bir ney var.' — Bekleyen event 4+
saat beklediyse
Sezonsal event'Yeni bir event banladn! [nsim] de heyecanln.' — Event
banlangncnnda
n Bildirimlerde hayvan ismi kullanmak kinisellentirme hissini artnrnr ve tnklanma orannnn %20–30 yükseltir
(sektör verisi). Her bildirim knsa, merakln ve neneli olmalndnr.

Hatchling GDD v1.0  ·  18
HATCHLINGGame Design Document
## 8. Art & Animasyon Yönü
## 8.1  Görsel Stil Kararn
Önerilen stil: 2D Flat + Soft Shadow Hybrid. Bu stil hem sanatçn bannmsnz sürdürülebilirlik hem de modern
mobil estetik açnsnndan optimaldnr. Referanslar: Tamagotchi Uni, Adorable Home, Neko Atsume'nin temizlini
+ Spiritfarer'nn yumunaklnnn.
Karakter stiliBold outline, yumunak dolgular, minimal shading. Karakterler 'chibi'
oranlarnnda: büyük ban, küçük gövde.
Renk paletiHayvan türüne göre pastel base + bir accent renk. Background: derin koyu
renkler veya yumunak pastel, kontrast sanlar.
ÇözünürlükKarakterler 256x256 sprite, 3x scale — dünük çözünürlük cihazda da net
görünür.
Neden Low-poly denil?Low-poly 3D, solo gelintiriciye rig ve animasyon maliyeti getirir. 2D sprite
daha hnzln iterasyona izin verir.
UI stiliDark mode default. Cam morphism (frosted glass) kartlar. Pastel accent
renkler. Yuvarlak köneler.
## 8.2  Karakter Animasyon Seti
Her hayvannn minimum animasyon seti ananndaki gibidir. Baby anamasnnda set daha küçük, adult'ta tam:
AnimasyonAçnklama & Teknik Not
Idle Loop3–4 saniyelik döngü. Hafif nefes, göz knrpma. Her türün
2 idle varyasyonu olmaln (sürekli aynn görünmemek
için)
YemeAnnz açnlnr, yiyecek gider, mutlu yüz. 1.5 saniye.
Oyun (Happy)Atlama veya dans. Enerji seviyesine göre 3 varyant:
hafif, orta, çnlgnn.
ÜzgünKulaklar iner, gözler yarn kapannr, yavan nefes. Dünük
need durumu.
UykuKapaln gözler, ZZZ balonu, yavan nefes. Loop.
Tepki — SevinçHnzln atlama, parçacnk efekti. Olumlu event yanntn.
Tepki — nanknnlnkGözler büyür, annz açnlnr. Beklenmedik event.
Büyüme GeçiniParlama efekti, scale animasyonu, yeni form ortaya
çnkar. 2 saniye.
GraduationÖzel cutscene animasyonu. Hayvan oyuncuya el
sallayarak uzaklannr.
Signature AbsürtTüre özgü, nadir tetiklenen. 3–5 saniye.

Hatchling GDD v1.0  ·  19
HATCHLINGGame Design Document
8.3  UI Animasyonlarn
- Ekran geçinleri: slide in/out, 200ms ease-out. Hiçbir hard cut yok.
- Buton basnnn: hafif scale down (0.95x) + scale up, 100ms.
- Bar dolunu: smooth lerp, 500ms easing.
- Koleksiyon açnlnnn: yeni hayvan kartn fan-out animasyonuyla girer.
- Event balonu: pop-up + gentle bounce, dikkat çekici ama agresif denil.
## 8.4  Juice & Polish Katmann
Juice; oyuncunun her aksiyonunun 'canln' hissettirmesi için eklenen mikro feedback katmanndnr. Bu detaylar
retention üzerinde orantnsnz büyük etki yaratnr.
- Her buton basnnnnda hafif haptic titrenim (device izin verirse)
- Yiyecek karaktere donru uçarken trail efekti
- Need bar doldununda küçük 'complete' parçacnnn
- Yumurta çatlarken ekran hafifçe titrer
- Gece modu: arka plan ynldnz parçacnklarn, daha yavan idle animasyonu
- Graduation annnda ekran kenarnndan hafif parnltn

Hatchling GDD v1.0  ·  20
HATCHLINGGame Design Document
## 9. Ses Tasarnmn
## 9.1  Karakter Sesleri
Karakter sesleri için tercih: Pitch-shifted ses efektleri sistemi. TTS denil. Her hayvan türüne özgü 'ses karakteri'
(tiz,  kalnn,  tatln  vb.)  belirlenir.  Diyalog  metni  ekranda  gösterilir;  karakter  'ses  efektiyle  konunur',  kelimeleri
söylemez. Bu hem lokalizasyon maliyetini ortadan kaldnrnr hem de sevimlilik artar. Referans: Animal Crossing
karakterleri.
KediKnsa, keskin, bazen hnrnltnln mrrp sesleri
KöpekEnerjik, yüksek, woof / arf varyasyonlarn
AxolotlYumunak, baloncuk sesleri, su efektiyle karnnnk
Void KediDünük, reverb'lü, bazen sessizlik (konunmaz, sadece bakar)
CapybaraDerin, sakin, nadir ses çnkarnr
9.2  UI & Feedback Sesleri
- Buton basnnn: knsa, temiz 'tick' sesi — fatigue yaratmayacak kadar hafif
- Besleme: mutlu yemek sesi + hafif müzik notasn
- Banyo: su aknnn, köpük efekti
- Görev tamamlama: knsa, tatmin edici 'ding' veya melodik çarpncn ses
- Event banlangncn: hayvannn ses karakterinden 'ünlem' ses
- Kritik need uyarnsn: hafif, dikkat çekici ama rahatsnz etmeyen ses (alarm denil, fnsnltn)
- Graduation: özel, melankolik ve güzel melodik ses efekti — bu an için ayrn bütçe
## 9.3  Müzik Sistemi
Müzik  moodbased  layered  sistem  kullannr.  Tek  bir  track  denil;  temel  loop  üzerine  mood  katmanlarn
eklenir/çnkarnlnr.
Base TrackHafif, nötr, lofi-ambient 2 dakikalnk loop. Her zaman çalar.
Happy KatmannHayvan mutlu / need'ler doluyken: melodik enstrüman katmann eklenir
Sad KatmannNeed'ler kritikken: base track yavanlar, minor nota katmann
Event MüziniEvent snrasnnda: küçük motif, base track üzerine bindirilir
Gece Katmann23:00–07:00: daha yavan, drone, sessiz ortam sesi
GraduationTamamen ayrn parça. Duygusal, hafif, kinisel. 60–90 saniye.
Gelintirici notuTüm müzik royalty-free veya solo gelintirici tarafnndan üretilmeli.
OpenGameArt veya itch.io kaynaklarnndan banlanabilir.

Hatchling GDD v1.0  ·  21
HATCHLINGGame Design Document
## 10. Monetization Sistemi
Seçilen Model: Soft IAP (Freemium)
Rewarded  Ads  modeli  reddedildi.  Gerekçe:  Virtual  pet  oyunlarnnda  reklam  gösterimi  duygusal  ban  kurma
annnn  böler,  retention'n  negatif  etkiler.  Soft  IAP  modeli  oyuncuyu  rahatsnz  etmeden  gelir  üretebilir  ve  uzun
vadeli banlnlnkla daha yüksek LTV sanlar.
n 'Soft IAP': Oyunun tamamn ücretsiz oynanabilir. IAP yalnnzca konforla hnz ve kozmetik sunar; zorunlu veya
duvar olmadan.
## 10.1  Para Birimleri
Para BirimiAçnklama
Çekirdek (Ücretsiz)Oyun içi soft currency. Günlük görev, mini oyun ve
aktivitelerden kazannlnr. Yiyecek, standart aksesuar
alnmn için kullannlnr.
Kristal (Premium)Hard currency. IAP ile satnn alnnnr. Enerji yenileme,
hnzlandnrma, özel kozmetik için. Çok az miktarda
ücretsiz kazannlnr (özel görev ödülü).
10.2  IAP Ürün Katalonu
ÜrünTürFiyat Aralnnn
Kristal paketi (küçük)Consumable$0.99 — banlangnç paketi,
conversion testi
Kristal paketi (orta)Consumable$4.99 — en yaygnn satnlan
Kristal paketi (büyük)Consumable$9.99 — %50 bonus kristal
Starter Pack (one-time)One-time offer$2.99 — yeni oyuncuya: kristal +
özel aksesuar + yumurta
hnzlandnrma x3
Kozmetik BundleOne-time veya seasonal$1.99–$3.99 — 5 aksesuar + oda
item paketi
Enerji Pass (haftalnk)Subscription$1.99/hafta — günlük +10 bonus
enerji cap, priority bildirim
Legendary Yumurta TokenConsumable$3.99 — guaranteed Legendary tier
yumurta
## 10.3  Oyuncu Rahatsnz Etmeme Kurallarn
- Hiçbir paywall yok: her içerik ücretsiz oynanabilirlini engellemez

Hatchling GDD v1.0  ·  22
HATCHLINGGame Design Document
- IAP teklifi: sadece manaza ekrannnda ve 'Enerji Tükendi' annnda küçük banner olarak gösterilir
- 'Enerji Tükendi' annnda: önce bekleme seçeneni önerilir, sonra satnn alma
- Hiçbir upsell popup, zorla reklam veya ödeme basknsn yok
- Starter Pack: yalnnzca bir kez, ilk 48 saatte gösterilir
- Subscription: sadece 'Profil' veya 'Manaza' sayfasnnda görünür, popup ile sunulmaz
10.4  Retention–Monetization Dengesi
IAP  hnzlandnrma  sanlar,  içerini  engellemez.  Enerji  sistemi  'acn  denil  merak'  hissi  yaratmaln:  oyuncu  enerji
bitince  'ne  zaman  gelecek'  diye  denil  'nimdi  ne  yapalnm'  diye  dününmeli.  Bu  yüzden  enerji  bitmesi  daima
günlük görev kontrolü veya koleksiyon gezme fnrsatnna yönlendirir.

Hatchling GDD v1.0  ·  23
HATCHLINGGame Design Document
## 11. Retention & Live Ops
## 11.1  Günlük Görev Sistemi
Günde  3  görev  verilir.  Biri  basit,  biri  orta,  biri  uzun  vadeli.  Görevler  tamamlandnkça  snradaki  tetiklenir.  Reset
her gece 00:00.
KategoriÖrnek GörevÖdül
Basit (2–3 dk)'Hayvannnn bir kez besle' | 'Bugün
banyo yaptnr'
## 20 Çekirdek
Orta (5–8 dk)'Bir mini oyun tamamla' | 'Bir
personality sorusunu yanntla'
50 Çekirdek + aksesuar nansn
Uzun vadeli'Bu hafta 5 gün üst üste otur' |
'Bond 200 yap'
Kristal + nadir item
## 11.2  Login Ödül Sistemi
7 günlük çark sistemi denil, 'birikim' sistemi. Kaçnrnlan günler snfnrlanmaz; bir sonraki günden devam eder.
Bu; 'bugün giremesem yarnn her ney gider' korkusunu kaldnrnr.
## Gün 130 Çekirdek
Gün 2Yiyecek item x3
## Gün 350 Çekirdek + Aksesuar
Gün 4Enerji +10 (tek seferlik)
Gün 5Nadir yumurta rengi tokeni
Gün 6Kristal x5
Gün 7Legendary Yumurta Tokeni veya nadir kozmetik
## 11.3  Sezonsal Event Sistemi
Her ay 1 büyük event, her 2 haftada 1 küçük event. Eventler yeni hayvan varyasyonlarn, özel dekorasyonlar ve
geçici görevler içerir.
Event TipiIçerik & Mekanik
Sezonsal Tema (büyük)Knn / Yaz / Bahar / Sonbahar temaln oda dekorasyonu,
özel yumurta, geçici hay van varyasyonu, 14 günlük
görev zinciri
Hayvan FestivaliBelirli bir türe odakln event. O türü yetintirenlere bonus
bond + özel aksesuar

Hatchling GDD v1.0  ·  24
HATCHLINGGame Design Document
Absürt Event'Tüm hayvanlar napka taknyor' gibi komik, dünük
maliyetli event. Social share tenviki.
Koleksiyon YarnnmasnEn çok unique tür toplayan hafnzaya alnnnr, küçük
in-game ödül
## 11.4  Uzun Vadeli Banlnlnk Mekanizmalarn
- Koleksiyon tamamlama: tüm türler ve varyasyonlar merak yaratnr
- Legacy puann: koleksiyona eklenen her hayvannn 'en iyi skor'u knrnlabilir
- Personality arnivi: aynn türü farkln arketiplerle yetintirme motivasyonu
- Sezonsal içerik: her mevsim bir öncekinden farkln olan item seti
- Sosyal paylannm loop'u: absürt eventler → screenshot → paylannm → yeni oyuncu

Hatchling GDD v1.0  ·  25
HATCHLINGGame Design Document
## 12. Design Riskleri & Çözümler
## Riskler & Mitigation Stratejileri
RiskÇözüm
Snkncnlnk: Oyuncu 3. günde rutin hisseder,
oynamayn bnraknr.
Personality drift görünür hale geldininde (gün 4–5)
oyuncu 'bir neyler deniniyor' hisseder. Event snklnnn
gün 3–5 arasn kasntln artnrnlnr. 'Sürpriz günü'
tasarnmn: her 3 günde bir garantili nadir event.
Grind: Need'leri doldurmak mekanik ve snkncn hale
gelir.
Need karnnlama aksiyonlarn asla uzun mini oyun
denildir. Basit dokunun + animasyon yeterlidir. Mini
oyunlar istene banlndnr. Oyuncu 1 dakikada tüm
ihtiyaçlarn karnnlayabilir.
Enerji duvarn: Enerji bitmesi frustrasyon yaratnr.Enerji bitini, içerik bitini denildir. Enerji yokken
koleksiyon gezme, dekorasyon, personality geçmini
okuma gibi pasif aktiviteler açnktnr. 'Enerji Bitti' ekrann
asla sonuk bir duvar denildir.
Ölüm acnsn: Hayvan ölürse oyuncu uygulamayn
siler.
nhmal senaryosunda 3 uyarn bildirimi + recovery
nansn verilir. Hayvan 'ölmez', 'gider'. Koleksiyona geçer.
Oyuncu kaynp denil geçin yanar. Mezun olan hayvan
hafnzada kalnr.
Monetization basknsn: IAP teklifi spam, oyuncu
yorgunlunu.
IAP sunumu maksimum günde 1 kez. Sadece manaza
sayfasnnda ve enerji tükenmesinde. Popup yok.
Abonelik öne çnkarnlmaz, könede durur.
Solo gelintirici içerik açnnn: Oyun hnzla tükenir.Event ve personality sistemi procedural üretir; her
hayvan her oturumda farklndnr. Sabit içerik minimum
tutulur, dinamik sistemler maximum. Bu sayede 'az içerik
çok deneyim' sanlannr.
Karmannklnk ninmesi: Çok fazla sistem en
zamanln açnlnr.
Baby anamasnnda yalnnzca Hunger + Happiness barn
vardnr. Her yeni anama yeni bir sistem açar. Oyuncu
overwhelmed olmadan önrenir.

Hatchling GDD v1.0  ·  26
HATCHLINGGame Design Document
- MVP Scope
MVP'de Olmasn Gereken Minimum Sistemler
MVP hedefi: oyunun 'ruhunu' tannyan, solo gelintirici tarafnndan 8–12 haftada tamamlanabilecek versiyondur.
Her neyin az ama iyi çalnnmasn gerekir.
SistemMVP Kapsamn
Yumurta sistemi2 tier (Common, Rare). Gerçek zamanln sayaç.
Dokunma ritüeli. Basit açnlnn animasyonu.
Hayvan türleri3 tür: Kedi, Köpek, Axolotl. Her birinin tam animasyon
seti.
Need sistemi4 ihtiyaç, tam fonksiyonel. Gerçek zaman dününü.
Enerji sistemi20 enerji, 30 dk yenileme, sabah bonusu.
Personality drift5 eksenin 3'ü (Enerji, Sosyallik, Kaos). Yalnnzca diyalog
farklnlnnn olarak gösterilir.
Yanam döngüsüBaby → Adult (2 anama). Final Form MVP'de yok.
Mini oyun1 adet: Beslenme Ritmi.
Event sistemi10 event entry. 5 soru eventi, 5 davrannn eventi.
UIAna ekran tam, koleksiyon temel seviye, manaza basit.
BildirimAçlnk kritik + yumurta haznr. Yalnnzca 2 bildirim tipi.
SesTemel karakter sesi + UI sesleri + 1 müzik loopn.
MonetizationSadece manaza sayfasn. IAP entegrasyonu yok (soft
launch sonrasn ekle).
MVP'ye KESnNLnKLE Dahil Etme
n Final Form ve Graduation cutscene — v1.1'e ertele
n Sezonsal event sistemi — v1.2'e ertele
n Legendary yumurta tipi — v1.1'e ertele
n Oda dekorasyon sistemi — v1.1'e ertele
n 3'ten fazla hayvan türü — v1.1'e ertele
n Abonelik IAP — v1.2'e ertele
n Koleksiyon defteri (tam) — temel versiyon MVP'de, personality arketip slotslarn v1.1'e
n Hafnza sistemi (hayvan snr saklama) — v1.1'e ertele
MVP Sonrasn Yol Haritasn (Knsa)

Hatchling GDD v1.0  ·  27
HATCHLINGGame Design Document
v1.0 — MVP3 tür, 2 anama, 1 mini oyun, temel event, temel bildirim, soft launch
v1.1 — DerinlikFinal Form, Graduation, 2 yeni tür, 2. mini oyun, oda dekorasyonu, tam
koleksiyon
v1.2 — MonetizationIAP entegrasyonu, premium currency, Starter Pack, Enerji Pass
v1.3 — Live Opsnlk sezonsal event, login ödül sistemi, günlük görev tam sistemi
v2.0 — GeninlemeLegendary tier, tüm hayvan seti, personality arketip koleksiyonu
Hatchling GDD v1.0 · Nisan 2026 · Tüm haklarn saklndnr.
Bu döküman üretim haznr tasarnm rehberi olarak haznrlanmnntnr.