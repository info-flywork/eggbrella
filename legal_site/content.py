"""Eggbrella yasal metinleri (TR + EN). Uygulamanın ve eggbrella-backend'in
gerçekte işlediği verilere göre yazılmıştır: anonim cihaz hesabı (ad / e-posta
yok), oyun ilerlemesi (coin, rekor kat, oyun sayısı), isteğe bağlı paylaşım
klibi (Bunny CDN); reklam, analitik, push bildirimi, takip ve (şu an) uygulama
içi satın alma SDK'sı yoktur."""

EMAIL = '<a href="mailto:support@fly-work.com">support@fly-work.com</a>'

# ───────────────────────────── GİZLİLİK ─────────────────────────────

PRIVACY_TR = f"""
<div class="note">Eggbrella, şemsiyeli yumurta <strong>Yumi</strong> ile binadan aşağı süzüldüğün bir düşüş
oyunudur. Senden <strong>ad, e-posta veya telefon numarası istemeyiz</strong>, verilerini
<strong>satmayız</strong>, uygulamada <strong>reklam yoktur</strong> ve seni uygulamalar arasında
<strong>takip etmeyiz</strong>. Bu politika, hangi verileri neden işlediğimizi ve haklarını açıklar
(6698 sayılı KVKK ve AB Genel Veri Koruma Tüzüğü – GDPR).</div>

<h2>1. Veri sorumlusu</h2>
<p>Eggbrella uygulaması ("Uygulama") Fly Work tarafından geliştirilir ve işletilir. Kişisel verilerinle ilgili tüm talepler
için: {EMAIL}</p>

<h2>2. Topladığımız veriler</h2>
<h3>2.1 Anonim oyuncu hesabı</h3>
<ul>
<li>Uygulamayı ilk açtığında cihazında rastgele bir <strong>cihaz kimliği</strong> oluşturulur ve sunucumuzda buna bağlı anonim
bir oyuncu hesabı açılır. Hesap açmak, giriş yapmak veya kişisel bilgi vermek gerekmez.</li>
<li>Oyuncu hesabına rastgele bir kullanıcı kimliği atanır; bu kimlik adını veya iletişim bilgini içermez.</li>
</ul>
<h3>2.2 Oyun ilerlemesi</h3>
<p>Coin bakiyen, en yüksek katın (rekor), oynadığın oyun sayısı, biten oyunların özeti (ulaşılan kat, toplanan coin, kullanılan
devam hakkı, süre) ve coin hareketlerinin kaydı (toplama, devam için harcama).</p>
<h3>2.3 Paylaşım klipleri (isteğe bağlı)</h3>
<p>Oyun sonunda "Klibi paylaş" seçersen, düşüşünün kısa bir MP4 kaydı cihazında oluşturulur ve paylaşım bağlantısı için
sunucumuza yüklenir. Klipte yalnızca oyun görüntüsü vardır; kamera, mikrofon veya galeri erişimi <strong>istenmez</strong>.</p>
<h3>2.4 Teknik veriler</h3>
<ul>
<li>Platform (iOS / Android) ve uygulama sürümü; dil tercihi cihazda tutulur.</li>
<li>Güvenlik ve kötüye kullanımı önleme amaçlı sunucu istek kayıtları (IP adresi dahil).</li>
</ul>
<p>Konum, rehber, fotoğraf, kamera, mikrofon, sağlık verisi veya tarama geçmişi <strong>toplamayız</strong>. Uygulamada analitik,
reklam veya hata izleme SDK'sı <strong>bulunmaz</strong>. Uygulama içi satın alma şu an sunulmuyorsa ödeme verisi de
işlenmez.</p>

<h2>3. Verileri neden ve hangi hukuki sebeple işliyoruz</h2>
<div class="table"><table>
<tr><th>Amaç</th><th>Hukuki sebep</th></tr>
<tr><td>Oyuncu hesabını oluşturmak, oturumunu yönetmek, oyunu çalıştırmak</td><td>Sözleşmenin kurulması ve ifası</td></tr>
<tr><td>İlerlemeni ve coin bakiyeni saklamak; cihaz değiştirmeden kaybolmamasını sağlamak</td><td>Sözleşmenin ifası</td></tr>
<tr><td>Devam hakkını ve coin harcamasını doğrulamak</td><td>Sözleşmenin ifası</td></tr>
<tr><td>Paylaşım klibini yüklemek ve bağlantısını sağlamak (sen seçtiğinde)</td><td>Sözleşmenin ifası</td></tr>
<tr><td>Güvenlik, hile ve kötüye kullanımı önleme, hata giderme</td><td>Meşru menfaat</td></tr>
<tr><td>Yasal yükümlülükler (ör. ticari kayıtlar)</td><td>Kanuni yükümlülük</td></tr>
</table></div>
<p>Verilerini reklam, profil çıkarma veya pazarlama amacıyla <strong>kullanmayız</strong>.</p>

<h2>4. Verilerin aktarıldığı taraflar</h2>
<p>Verilerini <strong>satmayız</strong> ve reklam ağlarıyla <strong>paylaşmayız</strong>. Yalnızca bizim adımıza çalışan
hizmet sağlayıcılarla, gereken en az veriyi paylaşırız:</p>
<div class="table"><table>
<tr><th>Hizmet sağlayıcı</th><th>Veri</th><th>Konum</th></tr>
<tr><td>Barındırma (sunucu ve veritabanı)</td><td>Oyuncu hesabı, ilerleme ve oyun kayıtları</td><td>Avrupa Birliği</td></tr>
<tr><td>Bunny CDN</td><td>Paylaşmayı seçtiğin oyun klipleri (MP4)</td><td>Global CDN</td></tr>
<tr><td>Apple / Google</td><td>Uygulama dağıtımı; ileride satın alma eklenirse mağaza işlemleri</td><td>Global</td></tr>
</table></div>
<p>Ayrıca yasal bir zorunluluk veya yetkili makam talebi olduğunda veri paylaşabiliriz. Paylaşım klibinin herkese açık bağlantısını
sen oluşturursun; bağlantıyı kimlerle paylaşacağın senin tercihindir.</p>

<h2>5. Yurt dışına aktarım</h2>
<p>CDN ve uygulama mağazaları Türkiye ve Avrupa Ekonomik Alanı dışında bulunabilir. Bu aktarımları KVKK ve GDPR'ın öngördüğü
güvencelerle (standart sözleşme hükümleri ve ilgili bildirimler) yaparız.</p>

<h2>6. Saklama süreleri</h2>
<div class="table"><table>
<tr><th>Veri</th><th>Süre</th></tr>
<tr><td>Oyuncu hesabı ve ilerleme</td><td>Hesap kullanıldığı sürece</td></tr>
<tr><td>Oyun ve coin hareketi kayıtları</td><td>Hesap aktifken; silme talebinden sonra kaldırılır</td></tr>
<tr><td>Paylaşım klipleri</td><td>Hesap silinene veya klibi kaldırma talebine kadar (günlük yükleme sınırı uygulanır)</td></tr>
<tr><td>Veri silme sonrası</td><td>Oyun verileri ve klipler silinir / anonimleştirilir; kullanıcı satırı kişiye bağlanamaz hale gelir</td></tr>
<tr><td>Sunucu istek kayıtları</td><td>30 gün</td></tr>
</table></div>

<h2>7. Hakların</h2>
<p>KVKK m.11 ve GDPR kapsamında; verilerinin işlenip işlenmediğini öğrenme, bilgi ve kopya talep etme, düzeltme, silme,
işlemeyi kısıtlama ve itiraz etme ve verilerin taşınması hakların vardır.</p>
<ul>
<li><strong>Verilerini silme:</strong> {EMAIL} adresine "Eggbrella veri silme" konulu e-posta gönder. Talebin üzerine
ilgili oyun verilerin, oturumların ve yüklediğin klipler (CDN dahil) silinir veya anonimleştirilir; aynı cihazda uygulamayı
yeniden açarsan yeni bir anonim hesap oluşur. Hesabını bulabilmemiz için mümkünse cihaz platformunu (iOS / Android) yaz.</li>
<li><strong>Diğer talepler</strong> (bilgi, kopya, itiraz): {EMAIL}. Talebini en geç 30 gün içinde yanıtlarız.</li>
<li>Kişisel Verileri Koruma Kurulu'na veya bulunduğun ülkedeki veri koruma otoritesine şikâyette bulunma hakkın saklıdır.</li>
</ul>

<h2>8. Çocuklar</h2>
<p>Eggbrella her yaştan oyuncuya uygun bir düşüş oyunudur ve ad, e-posta veya iletişim bilgisi istemez. 13 yaşından küçük
çocuklardan bilerek kişisel bilgi toplamayız; oyun yalnızca çalışması için gereken anonim kimliği kullanır. Ayrıca
<a href="../csae/">Çocuk Güvenliği Standartları (CSAE)</a> sayfamıza bak.</p>

<h2>9. Güvenlik</h2>
<p>Veriler aktarım sırasında TLS ile şifrelenir; oturum anahtarları cihazın güvenli deposunda tutulur ve sunucu erişimi yetkiyle
sınırlıdır. Hiçbir sistem yüzde yüz güvenli olmasa da verilerini korumak için makul teknik ve idari önlemleri alırız.</p>

<h2>10. Değişiklikler</h2>
<p>Bu politikayı güncelleyebiliriz. Önemli değişikliklerde uygulama içinde seni bilgilendiririz. Güncel sürüm her zaman bu
sayfadadır.</p>

<h2>11. İletişim</h2>
<p>Sorular ve talepler için: {EMAIL}</p>
"""

PRIVACY_EN = f"""
<div class="note">Eggbrella is a fall game where you glide down a building with the umbrella egg
<strong>Yumi</strong>. We <strong>do not ask for your name, email or phone number</strong>, we
<strong>do not sell</strong> your data, the app has <strong>no ads</strong> and we
<strong>do not track</strong> you across apps. This policy explains what data we process, why, and your rights (Turkish
Personal Data Protection Law No. 6698 – KVKK and the EU General Data Protection Regulation – GDPR).</div>

<h2>1. Data controller</h2>
<p>The Eggbrella app (the "App") is developed and operated by Fly Work. For any request regarding your personal data:
{EMAIL}</p>

<h2>2. Data we collect</h2>
<h3>2.1 Anonymous player account</h3>
<ul>
<li>When you first open the App, a random <strong>device identifier</strong> is created on your device and an anonymous player
account linked to it is opened on our server. You don't need to sign up, log in or provide personal information.</li>
<li>The player account gets a random user ID; it does not contain your name or contact details.</li>
</ul>
<h3>2.2 Game progress</h3>
<p>Your coin balance, best floor (record), games played, summaries of finished runs (floor reached, coins collected, continues
used, duration) and a record of coin changes (pickups, spending for continues).</p>
<h3>2.3 Share clips (optional)</h3>
<p>If you choose "Share clip" at the end of a run, a short MP4 of your fall is created on your device and uploaded to our server
so we can provide a share link. The clip shows only gameplay; we <strong>do not</strong> request camera, microphone or gallery
access.</p>
<h3>2.4 Technical data</h3>
<ul>
<li>Platform (iOS / Android) and app version; language preference is kept on the device.</li>
<li>Server request logs (including IP address) for security and abuse prevention.</li>
</ul>
<p>We <strong>do not collect</strong> location, contacts, photos, camera, microphone, health data or browsing history. The App
contains <strong>no</strong> analytics, advertising or crash-tracking SDKs. If in-app purchases are not offered, we also do not
process payment data.</p>

<h2>3. Why we process data and on what legal basis</h2>
<div class="table"><table>
<tr><th>Purpose</th><th>Legal basis</th></tr>
<tr><td>Creating your player account, managing your session, running the game</td><td>Performance of a contract</td></tr>
<tr><td>Storing your progress and coin balance so they are not lost</td><td>Performance of a contract</td></tr>
<tr><td>Verifying continues and coin spending</td><td>Performance of a contract</td></tr>
<tr><td>Uploading a share clip and providing its link (when you choose to)</td><td>Performance of a contract</td></tr>
<tr><td>Security, cheat and abuse prevention, debugging</td><td>Legitimate interest</td></tr>
<tr><td>Legal obligations (e.g. commercial records)</td><td>Legal obligation</td></tr>
</table></div>
<p>We <strong>do not use</strong> your data for advertising, profiling or marketing.</p>

<h2>4. Who we share data with</h2>
<p>We <strong>do not sell</strong> your data and <strong>do not share</strong> it with ad networks. We share only the minimum
necessary data with service providers acting on our behalf:</p>
<div class="table"><table>
<tr><th>Provider</th><th>Data</th><th>Location</th></tr>
<tr><td>Hosting (server and database)</td><td>Player account, progress and game records</td><td>European Union</td></tr>
<tr><td>Bunny CDN</td><td>Gameplay clips you choose to share (MP4)</td><td>Global CDN</td></tr>
<tr><td>Apple / Google</td><td>App distribution; store transactions if purchases are added later</td><td>Global</td></tr>
</table></div>
<p>We may also disclose data where required by law or by a competent authority. You create the public link for a share clip;
who you share that link with is your choice.</p>

<h2>5. International transfers</h2>
<p>The CDN and app stores may be located outside Türkiye and the European Economic Area. We carry out these transfers with the
safeguards required by KVKK and GDPR (standard contractual clauses and related notifications).</p>

<h2>6. Retention</h2>
<div class="table"><table>
<tr><th>Data</th><th>Period</th></tr>
<tr><td>Player account and progress</td><td>As long as the account is in use</td></tr>
<tr><td>Game and coin transaction records</td><td>While the account is active; removed after a deletion request</td></tr>
<tr><td>Share clips</td><td>Until account deletion or a removal request (a daily upload limit applies)</td></tr>
<tr><td>After data deletion</td><td>Game data and clips are deleted / anonymised; the user row can no longer be linked to a person</td></tr>
<tr><td>Server request logs</td><td>30 days</td></tr>
</table></div>

<h2>7. Your rights</h2>
<p>Under KVKK Art. 11 and the GDPR you have the right to know whether your data is processed, to request information and a copy,
to rectification, erasure, restriction and objection, and to data portability.</p>
<ul>
<li><strong>Deleting your data:</strong> email {EMAIL} with the subject "Eggbrella data deletion". We then delete or anonymise
your related game data, sessions and uploaded clips (including on the CDN); opening the App again on the same device creates a
new anonymous account. If possible, include your device platform (iOS / Android) so we can locate the account.</li>
<li><strong>Other requests</strong> (information, copy, objection): {EMAIL}. We respond within 30 days at the latest.</li>
<li>You may also lodge a complaint with the Turkish Personal Data Protection Authority or the data protection authority in your
country.</li>
</ul>

<h2>8. Children</h2>
<p>Eggbrella is a fall game suitable for players of all ages and does not ask for a name, email or contact details. We do not
knowingly collect personal information from children under 13; the game only uses the anonymous identifier it needs to work. See
also our <a href="../csae/">Child Safety Standards (CSAE)</a>.</p>

<h2>9. Security</h2>
<p>Data is encrypted in transit with TLS; session keys are stored in the device's secure storage and server access is restricted.
No system is 100% secure, but we take reasonable technical and organisational measures to protect your data.</p>

<h2>10. Changes</h2>
<p>We may update this policy. We will inform you in the App about significant changes. The current version is always on this
page.</p>

<h2>11. Contact</h2>
<p>For questions and requests: {EMAIL}</p>
"""

# ───────────────────────────── KOŞULLAR ─────────────────────────────

TERMS_TR = f"""
<div class="note"><strong>Kısaca:</strong> Eggbrella ücretsiz oynanır ve reklam içermez. Coin'leri oyunda toplayarak kazanır,
kırılınca devam etmek için harcarsın. Coin'lerin gerçek para değeri yoktur, nakde çevrilemez ve başkasına devredilemez.</div>

<h2>1. Kabul</h2>
<p>Eggbrella uygulamasını ("Uygulama") indirerek veya kullanarak bu Kullanım Koşulları'nı ve
<a href="../privacy-policy/">Gizlilik Politikası</a>'nı kabul etmiş olursun. Kabul etmiyorsan Uygulamayı kullanma. Uygulama
Fly Work ("biz") tarafından sunulur.</p>

<h2>2. Oyun</h2>
<p>Eggbrella; şemsiyeli yumurta Yumi ile binadan aşağı düştüğün, engelleri (balkon, çamaşır ipi, tente, güvercin) hızını ayarlayarak
geçtiğin bir sonsuz düşüş oyunudur. Kat sayacı skordur; ortadaki altınları toplayabilir, kırılınca coin ile kısa süre içinde devam
edebilirsin. Bölgeleri, ödülleri, fiyatları ve özellikleri zaman içinde değiştirebilir, ekleyebilir veya kaldırabiliriz.</p>

<h2>3. Oyuncu hesabı</h2>
<ul>
<li>Uygulama, cihazına bağlı anonim bir oyuncu hesabıyla çalışır; kayıt veya giriş gerekmez.</li>
<li>İlerlemen ve coin bakiyen (ağ varken) sunucumuzda bu hesaba bağlı saklanır. Cihazı sıfırlarsan, değiştirirsen veya (özellikle
Android'de) uygulamayı silersen hesabına erişimini kaybedebilirsin. Böyle bir durumda {EMAIL} adresinden bize ulaşabilirsin.</li>
<li>Oyun içi ilerlemeyi veya coin'leri hile, otomasyon veya güvenlik açığı kullanarak elde etmek yasaktır.</li>
</ul>

<h2>4. Sanal para birimi (coin) ve oyun içi özellikler</h2>
<ul>
<li>Coin'leri düşerken toplayarak kazanır; kırılınca aynı kattan devam etmek için harcayabilirsin.</li>
<li>Coin'ler sana Uygulama içinde kullanman için verilen, <strong>sınırlı, devredilemez ve geri alınabilir bir lisanstır</strong>;
mülkiyet hakkı doğurmaz.</li>
<li>Coin'lerin <strong>gerçek para değeri yoktur</strong>; nakde çevrilemez, satılamaz, başka hesaba aktarılamaz.</li>
<li>Şu an uygulama içi satın alma sunulmuyorsa coin'ler yalnızca oyunda kazanılır. İleride coin paketleri eklenirse ödemeler App
Store veya Google Play üzerinden alınır; o durumda mağaza koşulları ve iade kuralları da geçerli olur.</li>
</ul>

<h2>5. Paylaşım klipleri</h2>
<ul>
<li>Oyun sonunda kısa bir düşüş klibi oluşturup sistem paylaşım sayfasıyla paylaşabilirsin. Ağ varsa klip sunucuya yüklenip
bağlantısı metne eklenebilir.</li>
<li>Klipte yalnızca oyun görüntüsü vardır. Bağlantıyı paylaştığın kişiler klibi izleyebilir; bağlantıyı kiminle paylaşacağın senin
sorumluluğundadır.</li>
<li>Kötüye kullanımı önlemek için günlük yükleme sınırı uygulanabilir.</li>
</ul>

<h2>6. Kabul edilebilir kullanım</h2>
<p>Uygulamayı kullanırken şunları yapmamayı kabul edersin: tersine mühendislik, kazıma veya otomatik araçlarla kötüye kullanım;
hile yazılımı veya değiştirilmiş istemci kullanmak; sunucularımıza aşırı yük bindirmek; güvenlik önlemlerini atlatmaya çalışmak;
paylaşım kliplerini yasa dışı veya zararlı amaçlarla kullanmak. İhlal halinde ilgili ilerleme, coin veya hesap iptal edilebilir.</p>

<h2>7. Fikri mülkiyet</h2>
<p>Uygulama, karakterler (Yumi dahil), tasarımlar, sesler, metinler ve yazılım bize veya lisans verenlerimize aittir. Sana
Uygulamayı kişisel ve ticari olmayan amaçla kullanman için sınırlı, devredilemez bir kullanım hakkı veriyoruz.</p>

<h2>8. Üçüncü taraf hizmetleri</h2>
<p>Apple, Google ve (klip yüklemesi için) CDN gibi hizmetlerin kullanımı, o hizmetlerin kendi koşullarına tabidir.</p>

<h2>9. Sorumluluğun sınırlandırılması</h2>
<p>Uygulama "olduğu gibi" sunulur. Kesintisiz veya hatasız çalışacağını garanti etmeyiz. Yürürlükteki hukukun izin verdiği ölçüde;
Uygulamanın kullanımından doğan dolaylı zararlardan sorumlu değiliz. Kast veya ağır ihmalden doğan sorumluluk ile tüketici olarak
sahip olduğun yasal haklar saklıdır.</p>

<h2>10. Fesih</h2>
<p>Uygulamayı istediğin zaman kullanmayı bırakabilir ve {EMAIL} üzerinden verilerini sildirebilirsin; bu durumda kalan coin'lerin
ve ilerlemen geri getirilemez. Bu koşulları ihlal edersen hesabını askıya alabilir veya kapatabiliriz.</p>

<h2>11. Uygulanacak hukuk</h2>
<p>Bu koşullar Türkiye Cumhuriyeti hukukuna tabidir. Tüketici olarak ikamet ettiğin ülkenin emredici hükümlerinden doğan hakların
saklıdır.</p>

<h2>12. Değişiklikler</h2>
<p>Bu koşulları güncelleyebiliriz. Önemli değişikliklerde Uygulama içinde bilgilendiririz.</p>

<h2>13. İletişim</h2>
<p>{EMAIL}</p>
"""

TERMS_EN = f"""
<div class="note"><strong>In short:</strong> Eggbrella is free to play and has no ads. You earn coins by collecting them in a
run and spend them to continue after a crash. Coins have no real-world monetary value, cannot be cashed out and cannot be
transferred to others.</div>

<h2>1. Acceptance</h2>
<p>By downloading or using the Eggbrella app (the "App") you accept these Terms of Use and our
<a href="../privacy-policy/">Privacy Policy</a>. If you do not agree, do not use the App. The App is provided by Fly Work
("we").</p>

<h2>2. The game</h2>
<p>Eggbrella is an endless fall game where you descend a building with the umbrella egg Yumi, adjusting your speed to pass
obstacles (balconies, clothes lines, awnings, pigeons). The floor counter is your score; you can collect coins in the middle and,
after a crash, continue from the same floor with coins for a short time. We may change, add or remove regions, rewards, prices
and features over time.</p>

<h2>3. Player account</h2>
<ul>
<li>The App works with an anonymous player account tied to your device; no sign-up or login is required.</li>
<li>Your progress and coin balance are stored on our server under this account when online. If you reset or change your device,
or uninstall the App (especially on Android), you may lose access to your account. If that happens, contact us at {EMAIL}.</li>
<li>Obtaining progress or coins through cheats, automation or security vulnerabilities is prohibited.</li>
</ul>

<h2>4. Virtual currency (coins) and in-game features</h2>
<ul>
<li>You earn coins by collecting them while falling and can spend them to continue from the same floor after a crash.</li>
<li>Coins are a <strong>limited, non-transferable, revocable licence</strong> to use them within the App; they do not grant
ownership.</li>
<li>Coins have <strong>no real-world monetary value</strong>; they cannot be exchanged for cash, sold or transferred to another
account.</li>
<li>If in-app purchases are not currently offered, coins are earned only in play. If coin packs are added later, payments will be
processed by the App Store or Google Play and the store's terms and refund rules will also apply.</li>
</ul>

<h2>5. Share clips</h2>
<ul>
<li>At the end of a run you can create a short fall clip and share it through the system share sheet. When online, the clip may be
uploaded so its link can be added to the share text.</li>
<li>Clips show only gameplay. People you share the link with can watch the clip; who you share with is your responsibility.</li>
<li>A daily upload limit may apply to prevent abuse.</li>
</ul>

<h2>6. Acceptable use</h2>
<p>You agree not to: reverse engineer, scrape or abuse the App with automated tools; use cheat software or modified clients; place
excessive load on our servers; try to circumvent security measures; or use share clips for unlawful or harmful purposes.
Violations may result in the affected progress, coins or account being revoked.</p>

<h2>7. Intellectual property</h2>
<p>The App, characters (including Yumi), designs, sounds, texts and software belong to us or our licensors. We grant you a
limited, non-transferable right to use the App for personal, non-commercial purposes.</p>

<h2>8. Third-party services</h2>
<p>Use of services such as Apple, Google and (for clip uploads) the CDN is subject to their own terms.</p>

<h2>9. Limitation of liability</h2>
<p>The App is provided "as is". We do not guarantee that it will operate without interruption or errors. To the extent permitted
by applicable law, we are not liable for indirect damages arising from the use of the App. Liability for intent or gross
negligence and your statutory rights as a consumer remain unaffected.</p>

<h2>10. Termination</h2>
<p>You can stop using the App at any time and ask us to delete your data via {EMAIL}; your remaining coins and progress cannot be
restored afterwards. If you violate these terms, we may suspend or close your account.</p>

<h2>11. Governing law</h2>
<p>These terms are governed by the laws of the Republic of Türkiye. Mandatory consumer protection rights of your country of
residence remain unaffected.</p>

<h2>12. Changes</h2>
<p>We may update these terms. We will inform you in the App about significant changes.</p>

<h2>13. Contact</h2>
<p>{EMAIL}</p>
"""

# ───────────────────────────── ÇEREZLER ─────────────────────────────

COOKIES_TR = f"""
<div class="note">Kısaca: Eggbrella <strong>reklam veya takip çerezi kullanmaz</strong>. Uygulama, yalnızca çalışması için
gereken bilgileri cihazında saklar. Bu sayfalar da çerez veya yerel depolama kullanmaz.</div>

<h2>1. Çerez nedir?</h2>
<p>Çerezler, web sitelerinin tarayıcına kaydettiği küçük dosyalardır. Mobil uygulamalar tarayıcı çerezi yerine cihazdaki benzer
depolama alanlarını (ör. güvenli anahtar deposu, uygulama tercihleri) kullanır. Bu politika her ikisini de kapsar.</p>

<h2>2. Uygulamanın cihazında sakladığı bilgiler</h2>
<p>Bunların tamamı <strong>zorunlu</strong> niteliktedir; Uygulamanın çalışması için gerekir ve reklam ya da takip amacıyla
kullanılmaz:</p>
<div class="table"><table>
<tr><th>Bilgi</th><th>Amaç</th><th>Nerede</th></tr>
<tr><td>Oturum anahtarları (erişim / yenileme)</td><td>Oyuncu hesabına bağlı kalmanı sağlamak</td><td>Cihazın güvenli deposu (Keychain / Keystore)</td></tr>
<tr><td>Rastgele cihaz kimliği</td><td>Anonim oyuncu hesabını cihazına bağlamak</td><td>Cihazın güvenli deposu</td></tr>
<tr><td>İlerleme önbelleği ve bekleyen olaylar</td><td>Çevrimdışıyken oynayabilmen; bağlantı gelince sunucuya iletmek</td><td>Uygulama tercihleri</td></tr>
<tr><td>Ses, müzik, titreşim, dil ve kontrol tercihleri</td><td>Ayarlarını hatırlamak</td><td>Uygulama tercihleri</td></tr>
<tr><td>Yerel klip dosyası (geçici)</td><td>Paylaşım klibini oluşturmak ve sistem paylaşımına vermek</td><td>Uygulama belgeler alanı</td></tr>
</table></div>
<p>Uygulamayı kaldırdığında bu bilgiler cihazından kaldırılır (iOS'ta güvenli depodaki cihaz kimliği, aynı cihaza yeniden
kurulumda ilerlemeni geri getirmek için korunabilir).</p>

<h2>3. Üçüncü taraf bileşenler</h2>
<ul>
<li><strong>Bunny CDN:</strong> Paylaşmayı seçtiğin kliplerin dosya barındırması için kullanılır.</li>
</ul>
<p>Uygulamada reklam, analitik veya uygulamalar arası takip <strong>yoktur</strong>.</p>

<h2>4. Bu web sayfaları</h2>
<p>Eggbrella yasal sayfaları çerez, yerel depolama veya analitik araç kullanmaz. Dil seçimi yalnızca sayfa adresi üzerinden
yapılır.</p>

<h2>5. Tercihlerini yönetme</h2>
<ul>
<li>Ses, müzik, titreşim, dil ve kontrolü uygulamadaki <em>Ayarlar</em> ekranından değiştirebilirsin.</li>
<li>Uygulamanın cihazında sakladığı bilgileri uygulamayı kaldırarak silebilirsin.</li>
<li>Ayrıntılar için <a href="../privacy-policy/">Gizlilik Politikası</a>'na bak.</li>
</ul>

<h2>6. İletişim</h2>
<p>{EMAIL}</p>
"""

COOKIES_EN = f"""
<div class="note">In short: Eggbrella <strong>does not use advertising or tracking cookies</strong>. The App only stores on
your device what it needs to work. These pages do not use cookies or local storage either.</div>

<h2>1. What are cookies?</h2>
<p>Cookies are small files that websites store in your browser. Mobile apps use similar storage on the device (e.g. secure key
storage, app preferences) instead of browser cookies. This policy covers both.</p>

<h2>2. Information the App stores on your device</h2>
<p>All of this is <strong>strictly necessary</strong> for the App to work and is not used for advertising or tracking:</p>
<div class="table"><table>
<tr><th>Information</th><th>Purpose</th><th>Where</th></tr>
<tr><td>Session keys (access / refresh)</td><td>Keeping you connected to your player account</td><td>Device secure storage (Keychain / Keystore)</td></tr>
<tr><td>Random device identifier</td><td>Linking the anonymous player account to your device</td><td>Device secure storage</td></tr>
<tr><td>Progress cache and pending events</td><td>Letting you play offline and syncing when you're back online</td><td>App preferences</td></tr>
<tr><td>Sound, music, haptics, language and control preferences</td><td>Remembering your settings</td><td>App preferences</td></tr>
<tr><td>Local clip file (temporary)</td><td>Building the share clip and handing it to the system share sheet</td><td>App documents area</td></tr>
</table></div>
<p>Uninstalling the App removes this information from your device (on iOS, the device identifier in secure storage may be kept so
that your progress returns if you reinstall on the same device).</p>

<h2>3. Third-party components</h2>
<ul>
<li><strong>Bunny CDN:</strong> used to host clips you choose to share.</li>
</ul>
<p>There is <strong>no</strong> advertising, analytics or cross-app tracking in the App.</p>

<h2>4. These web pages</h2>
<p>The Eggbrella legal pages do not use cookies, local storage or analytics. The language is selected only via the page
address.</p>

<h2>5. Managing your preferences</h2>
<ul>
<li>You can change sound, music, haptics, language and controls in the App's <em>Settings</em> screen.</li>
<li>You can delete the information stored on your device by uninstalling the App.</li>
<li>See our <a href="../privacy-policy/">Privacy Policy</a> for details.</li>
</ul>

<h2>6. Contact</h2>
<p>{EMAIL}</p>
"""

# ───────────────────────────── CSAE ─────────────────────────────

CSAE_TR = f"""
<div class="note">Eggbrella, <strong>çocukların cinsel istismarı ve sömürüsüne (CSAE)</strong> ve çocuk cinsel istismarı
materyaline (CSAM) karşı <strong>sıfır tolerans</strong> politikası uygular.</div>

<h2>1. Kapsam</h2>
<p>Bu standartlar Eggbrella uygulaması ve ilgili tüm hizmetler için geçerlidir. Eggbrella tek oyunculu bir düşüş oyunudur;
kullanıcılar arası mesajlaşma, sohbet, profil veya herkese açık sosyal akış <strong>yoktur</strong>. Paylaşım klipleri yalnızca
senin başlattığın sistem paylaşımıyla gider; başka oyuncuların içerik yükleyeceği bir alan yoktur.</p>

<h2>2. Yasaklanan içerik ve davranışlar</h2>
<ul>
<li>Çocukların cinsel istismarını gösteren, teşvik eden veya cinselleştiren her türlü görsel, metin veya diğer içerik (CSAM).</li>
<li>Çocuklarla cinsel amaçlı iletişim kurmaya, onları kandırmaya veya istismara yönelik her türlü girişim (grooming).</li>
<li>Çocukların cinsel sömürüsünü, insan ticaretini veya bunlara aracılığı içeren her türlü faaliyet.</li>
</ul>

<h2>3. Önleme</h2>
<ul>
<li>Uygulamada kullanıcılar arası iletişim kanalı ve kullanıcı içeriği yüklenecek genel bir alan bulunmaz.</li>
<li>Uygulama ad, e-posta, fotoğraf veya konum gibi kişisel bilgiler istemez.</li>
<li>Paylaşım klipleri yalnızca oyun görüntüsüdür; kamera veya galeri erişimi yoktur.</li>
</ul>

<h2>4. Bildirim</h2>
<p>Uygulamada veya hizmetlerimizde çocuk güvenliğini tehdit eden bir içerik ya da davranış görürsen hemen bize bildir:</p>
<ul>
<li><strong>E-posta:</strong> {EMAIL} (konu: "Çocuk güvenliği")</li>
</ul>
<p>Bir çocuk acil tehlikedeyse önce <strong>112</strong>'yi (veya bulunduğun ülkedeki acil durum hattını) ara.</p>

<h2>5. Müdahale</h2>
<ul>
<li>Bildirimler öncelikli olarak incelenir.</li>
<li>Çocuk cinsel istismarı materyali tespit edildiğinde yürürlükteki yasalar uyarınca yetkili makamlara bildirilir ve soruşturmalarda
yetkili makamlarla iş birliği yapılır.</li>
</ul>

<h2>6. Yasalara uyum</h2>
<p>Eggbrella, çocuk güvenliğine ilişkin yürürlükteki yasalara ve Google Play ile App Store politikalarına uyar.</p>

<h2>7. Çocuk güvenliği irtibat kişisi</h2>
<p>Çocuk güvenliği uygulamalarımız ve bu standartlar hakkında soruların için irtibat: {EMAIL}</p>
"""

CSAE_EN = f"""
<div class="note">Eggbrella has a <strong>zero-tolerance</strong> policy against <strong>child sexual abuse and exploitation
(CSAE)</strong> and child sexual abuse material (CSAM).</div>

<h2>1. Scope</h2>
<p>These standards apply to the Eggbrella app and all related services. Eggbrella is a single-player fall game; there is
<strong>no</strong> messaging, chat, profiles or public social feed between users. Share clips leave the device only through the
system share sheet you start; there is no area for other players to upload content.</p>

<h2>2. Prohibited content and behaviour</h2>
<ul>
<li>Any imagery, text or other content depicting, promoting or sexualising the sexual abuse of children (CSAM).</li>
<li>Any attempt to contact, deceive or exploit children for sexual purposes (grooming).</li>
<li>Any activity involving or facilitating the sexual exploitation or trafficking of children.</li>
</ul>

<h2>3. Prevention</h2>
<ul>
<li>The App has no communication channel between users and no general area for uploading user content.</li>
<li>The App does not ask for personal information such as name, email, photos or location.</li>
<li>Share clips are gameplay only; there is no camera or gallery access.</li>
</ul>

<h2>4. Reporting</h2>
<p>If you see content or behaviour in our App or services that threatens child safety, report it to us immediately:</p>
<ul>
<li><strong>Email:</strong> {EMAIL} (subject: "Child safety")</li>
</ul>
<p>If a child is in immediate danger, first call your local emergency number (<strong>112</strong> in Türkiye and the EU).</p>

<h2>5. Response</h2>
<ul>
<li>Reports are reviewed with priority.</li>
<li>Where child sexual abuse material is identified, it is reported to the competent authorities as required by law, and we
cooperate with authorities in investigations.</li>
</ul>

<h2>6. Legal compliance</h2>
<p>Eggbrella complies with applicable child safety laws and with Google Play and App Store policies.</p>

<h2>7. Child safety point of contact</h2>
<p>For questions about our child safety practices and these standards: {EMAIL}</p>
"""

# ───────────────────────────── HAKKINDA ─────────────────────────────

ABOUT_TR = f"""
<div class="note"><strong>Eggbrella</strong>, şemsiyeli yumurta <strong>Yumi</strong> ile gökdelenlerden aşağı süzüldüğün
neşeli bir düşüş oyunudur. Bir Fly Work ürünüdür. Reklam yok, kayıt yok — sadece sen, Yumi ve rüzgâr.</div>

<h2>1. Nasıl oynanır?</h2>
<ul>
<li><strong>Basılı tut:</strong> şemsiye açılır, yavaş düşersin. <strong>Bırak:</strong> şemsiye kapanır, hızlanırsın.</li>
<li>Ayarlardan "Dokun aç-kapa" modunu da seçebilirsin.</li>
<li>Engel sıralarının (balkon, çamaşır ipi, tente) arasındaki açıklık sallanır; ortadayken geçmek için hızını ayarla.</li>
<li>Tenteye yavaş düşersen sekersin, hızlı düşersen kırılırsın. Güvercinlere dikkat!</li>
<li>Kat sayacı skordur; ortadaki altınları topla. Kırılınca kısa süre içinde coin ile aynı kattan devam edebilirsin.</li>
</ul>

<h2>2. Bölgeler</h2>
<p>Yükseldikçe (aslında alçaldıkça) ortam değişir: belirli katlardan sonra cam ofis ve neon tonları belirir.</p>

<h2>3. Klipler</h2>
<p>Oyun sonunda son saniyelerini kısa bir videoya çevirip arkadaşlarınla paylaşabilirsin. Ayrıntılar:
<a href="../privacy-policy/?lang=tr">Gizlilik Politikası</a>.</p>

<h2>4. Satın alımlar</h2>
<p>Oyun ücretsizdir ve reklam içermez. Coin'ler oyunda toplanır. İleride isteğe bağlı coin paketleri eklenirse App Store ve Google
Play üzerinden sunulur. Ayrıntılar: <a href="../terms/?lang=tr">Kullanım Koşulları</a>.</p>

<h2>5. Destek</h2>
<ul>
<li>E-posta: {EMAIL}</li>
<li>Web: <a href="https://fly-work.com">fly-work.com</a> · <a href="https://fly-work.com/contact-us/">İletişim formu</a></li>
<li>Gizlilik: Uygulama içi <em>Ayarlar → Gizlilik</em>.</li>
</ul>
"""

ABOUT_EN = f"""
<div class="note"><strong>Eggbrella</strong> is a cheerful fall game where you glide down skyscrapers with the umbrella egg
<strong>Yumi</strong>. A Fly Work product. No ads, no sign-up — just you, Yumi and the wind.</div>

<h2>1. How to play</h2>
<ul>
<li><strong>Hold:</strong> the umbrella opens and you fall slowly. <strong>Release:</strong> it closes and you speed up.</li>
<li>You can also pick "Tap to toggle" in Settings.</li>
<li>The gap between obstacle rows (balconies, clothes lines, awnings) sways; adjust your speed to pass when it's centred.</li>
<li>Hit an awning slowly and you bounce; hit it fast and you crack. Watch out for pigeons!</li>
<li>The floor counter is your score; collect the coins in the middle. After a crash you can continue from the same floor with coins
for a short time.</li>
</ul>

<h2>2. Regions</h2>
<p>As you go deeper the scenery changes: after certain floors a glass-office look and neon tint appear.</p>

<h2>3. Clips</h2>
<p>At the end of a run you can turn your last seconds into a short video and share it with friends. Details:
<a href="../privacy-policy/?lang=en">Privacy Policy</a>.</p>

<h2>4. Purchases</h2>
<p>The game is free and has no ads. Coins are collected in play. If optional coin packs are added later, they will be offered
through the App Store and Google Play. Details: <a href="../terms/?lang=en">Terms of Use</a>.</p>

<h2>5. Support</h2>
<ul>
<li>Email: {EMAIL}</li>
<li>Web: <a href="https://fly-work.com">fly-work.com</a> · <a href="https://fly-work.com/contact-us/">Contact form</a></li>
<li>Privacy: in-app <em>Settings → Privacy</em>.</li>
</ul>
"""

PAGES = {
    "about": {
        "title": {"tr": "Eggbrella Hakkında", "en": "About Eggbrella"},
        "desc": "About Eggbrella — umbrella egg fall game by Fly Work / Eggbrella hakkında",
        "body": {"tr": ABOUT_TR, "en": ABOUT_EN},
    },
    "privacy-policy": {
        "title": {"tr": "Eggbrella – Gizlilik Politikası", "en": "Eggbrella – Privacy Policy"},
        "desc": "Eggbrella privacy policy / gizlilik politikası",
        "body": {"tr": PRIVACY_TR, "en": PRIVACY_EN},
    },
    "terms": {
        "title": {"tr": "Eggbrella – Kullanım Koşulları", "en": "Eggbrella – Terms of Use"},
        "desc": "Eggbrella terms of use / kullanım koşulları",
        "body": {"tr": TERMS_TR, "en": TERMS_EN},
    },
    "cookies": {
        "title": {"tr": "Eggbrella – Çerez Politikası", "en": "Eggbrella – Cookie Policy"},
        "desc": "Eggbrella cookie policy / çerez politikası",
        "body": {"tr": COOKIES_TR, "en": COOKIES_EN},
    },
    "csae": {
        "title": {
            "tr": "Eggbrella – Çocuk Güvenliği Standartları (CSAE)",
            "en": "Eggbrella – Child Safety Standards (CSAE)",
        },
        "desc": "Eggbrella child safety standards against CSAE / çocuk güvenliği standartları",
        "body": {"tr": CSAE_TR, "en": CSAE_EN},
    },
}
