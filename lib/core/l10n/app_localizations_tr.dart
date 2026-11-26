// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get app_title => 'Cemaat';

  @override
  String get nav_home => 'Ana sayfa';

  @override
  String get nav_mosques => 'Camiler';

  @override
  String get nav_community => 'Topluluk';

  @override
  String get common_cancel => 'İptal';

  @override
  String get common_delete => 'Sil';

  @override
  String get common_save => 'Kaydet';

  @override
  String get common_close => 'Kapat';

  @override
  String get common_continue => 'İleri';

  @override
  String get common_skip => 'Atla';

  @override
  String get common_show_all => 'Tümünü göster';

  @override
  String get common_loading_please_wait => 'Lütfen biraz bekleyin …';

  @override
  String get common_internet_required =>
      'Bunun için internet bağlantısı gerekiyor.';

  @override
  String get common_irreversible => 'Bu işlem geri alınamaz.';

  @override
  String get image_change => 'Resmi değiştir';

  @override
  String get image_choose => 'Resim seç';

  @override
  String get image_view => 'Resmi görüntüle';

  @override
  String get image_remove => 'Resmi kaldır';

  @override
  String get tooltip_qibla => 'Kıble pusulası';

  @override
  String get tooltip_settings => 'Ayarlar';

  @override
  String get date_today => 'Bugün';

  @override
  String get date_tomorrow => 'Yarın';

  @override
  String get ago_now => 'az önce';

  @override
  String ago_minutes(int n) {
    return '$n dk önce';
  }

  @override
  String ago_hours(int n) {
    return '$n saat önce';
  }

  @override
  String ago_days(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n gün önce',
      one: '1 gün önce',
    );
    return '$_temp0';
  }

  @override
  String duration_hm(int h, int m) {
    return '$h sa $m dk';
  }

  @override
  String duration_m(int m) {
    return '$m dk';
  }

  @override
  String distance_km(String km) {
    return '$km km';
  }

  @override
  String get home_my_mosques => 'Camilerim';

  @override
  String get home_add_mosque => 'Ekle';

  @override
  String get home_no_mosque_title => 'Camini seç';

  @override
  String get home_no_mosque_message =>
      'Böylece etkinlikleri, duyuruları ve namaz vakitleri burada görünür.';

  @override
  String get home_choose_mosque => 'Cami seç';

  @override
  String get home_events => 'Etkinlikler';

  @override
  String get home_events_empty => 'Yaklaşan etkinlik yok.';

  @override
  String get home_notices => 'Duyurular';

  @override
  String get home_nearby => 'Çevrede';

  @override
  String home_nearby_count(int count, int km) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cami',
      zero: 'başka cami yok',
    );
    return '$km km çevrede $_temp0';
  }

  @override
  String get home_nearby_empty =>
      'Çevrede yaklaşan etkinlik yok. Daha fazlası için mesafeyi artır.';

  @override
  String get radius_title => 'Mesafe';

  @override
  String radius_hint(String name) {
    return 'Ana camin ($name) esas alınır.';
  }

  @override
  String get prayer_title => 'Namaz vakitleri';

  @override
  String get prayer_fajr => 'İmsak';

  @override
  String get prayer_sunrise => 'Güneş';

  @override
  String get prayer_dhuhr => 'Öğle';

  @override
  String get prayer_asr => 'İkindi';

  @override
  String get prayer_maghrib => 'Akşam';

  @override
  String get prayer_isha => 'Yatsı';

  @override
  String prayer_next_in(String prayer, String duration) {
    return '$prayer vaktine $duration';
  }

  @override
  String prayer_for(String city, String method) {
    return '$city · $method';
  }

  @override
  String prayer_friday(String time) {
    return 'Cuma namazı $time';
  }

  @override
  String get prayer_method_diyanet => 'Diyanet';

  @override
  String get prayer_method_muslimWorldLeague => 'Muslim World League';

  @override
  String get prayer_method_northAmerica => 'ISNA (Kuzey Amerika)';

  @override
  String get kind_info => 'Duyuru';

  @override
  String get kind_event => 'Etkinlik';

  @override
  String get kind_cenaze => 'Cenaze';

  @override
  String get kind_course => 'Kurs';

  @override
  String get kind_festival => 'Kermes & Şenlik';

  @override
  String get kind_youth => 'Gençlik';

  @override
  String get announcement_open_mosque => 'Camiye git';

  @override
  String get mosques_search_hint => 'Cami veya şehir';

  @override
  String get mosques_view_map => 'Harita';

  @override
  String get mosques_view_list => 'Liste';

  @override
  String get mosques_all_regions => 'Tüm bölgeler';

  @override
  String mosques_only_radius(int km) {
    return '$km km çevre';
  }

  @override
  String get mosques_empty => 'Cami bulunamadı.';

  @override
  String mosques_count(int count) {
    return '$count cami';
  }

  @override
  String region_label(int number) {
    return '$number. Bölge';
  }

  @override
  String get map_attribution => '© OpenStreetMap katkıda bulunanlar';

  @override
  String get mosque_mine => 'Camim';

  @override
  String get mosque_primary => 'Ana cami';

  @override
  String get mosque_add_mine => 'Camim olarak ekle';

  @override
  String get mosque_remove_mine => 'Kaldır';

  @override
  String get mosque_make_primary => 'Ana cami yap';

  @override
  String get mosque_verified => 'Doğrulanmış';

  @override
  String get mosque_about => 'Cami hakkında';

  @override
  String get mosque_prayer_today => 'Bugünkü namaz vakitleri';

  @override
  String get mosque_no_events => 'Şu an etkinlik yok.';

  @override
  String get mosque_picker_title => 'Cami seç';

  @override
  String get association_ditib => 'DİTİB';

  @override
  String get association_igmg => 'IGMG';

  @override
  String get association_vikz => 'VIKZ';

  @override
  String get association_zmd => 'ZMD';

  @override
  String get association_independent => 'Bağımsız';

  @override
  String get community_all => 'Tümü';

  @override
  String get community_offers => 'Teklif';

  @override
  String get community_requests => 'Arayan';

  @override
  String get community_sort_newest => 'En yeni önce';

  @override
  String get community_sort_nearby => 'En yakın önce';

  @override
  String get community_all_categories => 'Tüm kategoriler';

  @override
  String get community_hint =>
      'Sadece metin, sohbet yok: İletişim bilgileri ancak iki taraf da onaylarsa paylaşılır.';

  @override
  String get community_empty => 'Bu seçim için ilan yok.';

  @override
  String get category_education => 'Ders & eğitim';

  @override
  String get category_children => 'Çocuk bakımı';

  @override
  String get category_moving => 'Taşınma';

  @override
  String get category_transport => 'Ulaşım';

  @override
  String get category_repair => 'Tamir & teknik';

  @override
  String get category_accompany => 'Refakat & günlük yardım';

  @override
  String get category_giveaway => 'Hediye';

  @override
  String get category_other => 'Diğer';

  @override
  String get post_offer => 'Teklif';

  @override
  String get post_request => 'Arıyor';

  @override
  String get post_mine => 'Senin ilanın';

  @override
  String get post_interest => 'İlgileniyorum';

  @override
  String get post_interest_done => 'İlgi bildirildi';

  @override
  String post_interest_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kişi ilgileniyor',
      zero: 'Henüz ilgilenen yok',
    );
    return '$_temp0';
  }

  @override
  String post_interest_sent(String name) {
    return 'İlgin bildirildi. $name onaylayınca birbirinizin iletişim bilgilerini görürsünüz.';
  }

  @override
  String get post_report => 'İlanı bildir';

  @override
  String get post_reported => 'Teşekkürler, ilan incelenecek.';

  @override
  String get post_new => 'İlan';

  @override
  String get post_new_title => 'Yeni ilan';

  @override
  String get post_form_title => 'Başlık';

  @override
  String get post_form_body => 'Açıklama';

  @override
  String get post_form_category => 'Kategori';

  @override
  String get post_form_mosque => 'Cemaat';

  @override
  String get post_form_rules =>
      'Lütfen telefon numarası, adres veya ticari teklif yazma. İlanlar bildirilebilir.';

  @override
  String get post_form_publish => 'Yayınla';

  @override
  String get post_form_required => 'Lütfen doldur.';

  @override
  String get post_created => 'İlan yayınlandı.';

  @override
  String get account_needed_title => 'Bunun için hesap gerekli';

  @override
  String get account_needed_message =>
      'Okumak için hesap gerekmez. İlan vermek veya ilgi bildirmek için hesap gerekir. Böylece topluluk güvende kalır.';

  @override
  String get qibla_title => 'Kıble';

  @override
  String qibla_degrees(int degrees) {
    return 'Kuzeyden $degrees°';
  }

  @override
  String qibla_based_on(String place) {
    return '$place için hesaplandı';
  }

  @override
  String get qibla_no_sensor =>
      'Pusula yok. Telefonu kuzeye çevir, ok Mekke yönünü gösterir.';

  @override
  String get qibla_calibrate =>
      'Doğru sonuç için telefonu düz tut ve bir kez sekiz çiz.';

  @override
  String get qibla_aligned => 'Yön doğru';

  @override
  String get qibla_turn => 'Ok yukarıyı gösterene kadar dön.';

  @override
  String get qibla_no_mosque =>
      'Önce bir cami seç. Yön, caminin konumuna göre hesaplanır.';

  @override
  String get settings_title => 'Ayarlar';

  @override
  String get settings_general => 'Genel';

  @override
  String get settings_appearance => 'Görünüm';

  @override
  String get settings_theme => 'Tema';

  @override
  String get theme_system => 'Sistem';

  @override
  String get theme_light => 'Açık';

  @override
  String get theme_dark => 'Koyu';

  @override
  String get settings_accent => 'Vurgu rengi';

  @override
  String get settings_language => 'Dil';

  @override
  String get settings_prayer => 'Namaz vakitleri';

  @override
  String get settings_prayer_method => 'Hesaplama';

  @override
  String get settings_data => 'Veriler';

  @override
  String get settings_mode => 'Veri kaynağı';

  @override
  String get mode_test => 'Test verileri';

  @override
  String get mode_cloud => 'Bulut';

  @override
  String get mode_hint =>
      'Test verileri: denemek için uydurma etkinlik ve ilanlar. Bulut: eklendiğinde gerçek veriler.';

  @override
  String get mode_cloud_unavailable => 'Bulut henüz eklenmedi.';

  @override
  String get settings_show_intro => 'Tanıtımı göster';

  @override
  String get settings_reset => 'Ayarları sıfırla';

  @override
  String get settings_about => 'Uygulama hakkında';

  @override
  String get settings_version => 'Sürüm';

  @override
  String get settings_licenses => 'Lisanslar';

  @override
  String get account_sign_in => 'Giriş yap';

  @override
  String get account_sign_in_hint => 'Toplulukta ilan vermek için';

  @override
  String get account_test => 'Test hesabı · sadece bu cihazda';

  @override
  String get account_change_name => 'Adı değiştir';

  @override
  String get account_change_email => 'E-postayı değiştir';

  @override
  String get account_change_password => 'Şifreyi değiştir';

  @override
  String get account_sign_out => 'Çıkış yap';

  @override
  String get account_delete => 'Hesabı sil';

  @override
  String get account_delete_confirm => 'Hesabın ve ilanların silinecek.';

  @override
  String get account_not_in_test => 'Test sürümünde henüz yok.';

  @override
  String get intro_mosque_title => 'Camin cebinde';

  @override
  String get intro_mosque_body =>
      'Caminin etkinlikleri, duyuruları ve cenaze namazları – doğrudan telefonunda.';

  @override
  String get intro_prayer_title => 'Namaz vakitleri ve kıble';

  @override
  String get intro_prayer_body =>
      'Bulunduğun yer için Diyanet\'e göre vakitler ve Mekke yönünü gösteren pusula.';

  @override
  String get intro_nearby_title => 'Yakındaki camiler';

  @override
  String get intro_nearby_body =>
      'Tüm camiler tek haritada. Çevrendeki kermes ve etkinlikler bir bakışta.';

  @override
  String get intro_community_title => 'Birlikte yardımlaşalım';

  @override
  String get intro_community_body =>
      'Ders, taşınma, çocuk bakımı: Toplulukta yardım bul ya da yardım et.';

  @override
  String get intro_start_title => 'Nasıl başlamak istersin?';

  @override
  String get intro_guest_title => 'Hesapsız';

  @override
  String get intro_guest_1 => 'Etkinlikler, namaz vakitleri, kıble ve harita';

  @override
  String get intro_guest_2 => 'Topluluk ilanlarını okuma';

  @override
  String get intro_guest_3 => 'Kişisel veri gerekmez';

  @override
  String get intro_account_title => 'Hesapla';

  @override
  String get intro_account_1 => 'Hesapsız her şey, ayrıca:';

  @override
  String get intro_account_2 => 'Toplulukta ilan verme';

  @override
  String get intro_account_3 => 'İlgi bildirme ve iletişime geçme';

  @override
  String get intro_register => 'Kayıt ol';

  @override
  String get intro_login => 'Zaten hesabım var';

  @override
  String get intro_guest => 'Hesapsız devam et';

  @override
  String get intro_later_hint =>
      'Daha sonra istediğin zaman ayarlardan giriş yapabilirsin.';

  @override
  String get auth_login_title => 'Giriş yap';

  @override
  String get auth_register_title => 'Kayıt ol';

  @override
  String get auth_name => 'Ad';

  @override
  String get auth_email => 'E-posta';

  @override
  String get auth_password => 'Şifre';

  @override
  String get auth_submit_login => 'Giriş yap';

  @override
  String get auth_submit_register => 'Hesap oluştur';

  @override
  String get auth_switch_to_register => 'Hesabın yok mu? Kayıt ol';

  @override
  String get auth_switch_to_login => 'Hesabın var mı? Giriş yap';

  @override
  String get auth_test_hint =>
      'Test modu: Hesap sadece bu cihazda canlandırılır. Hiçbir şey gönderilmez.';

  @override
  String get auth_age_note =>
      'Kayıt olarak en az 16 yaşında olduğunu onaylarsın.';

  @override
  String get auth_invalid_name => 'Lütfen adını gir.';

  @override
  String get auth_invalid_email => 'Lütfen geçerli bir e-posta gir.';

  @override
  String get auth_invalid_password => 'En az 6 karakter.';

  @override
  String get nav_admin => 'Yönetim';

  @override
  String get common_copied => 'Kopyalandı';

  @override
  String get common_saved => 'Kaydedildi';

  @override
  String get location_use => 'Konumu kullan';

  @override
  String get location_hint =>
      'Kıble, harita ve çevre için. Yaklaşık konum, cihazda kalır.';

  @override
  String get location_mine => 'Konumun';

  @override
  String get location_denied => 'Konum izni verilmedi.';

  @override
  String get location_service_off => 'Konum servisleri kapalı.';

  @override
  String get location_unavailable => 'Konum şu an alınamıyor.';

  @override
  String get location_open_settings => 'Ayarlar';

  @override
  String get radius_hint_location => 'Konumun esas alınır.';

  @override
  String get radius_off => 'Kapalı';

  @override
  String get mosques_radius => 'Çevre';

  @override
  String get association_info_ditib =>
      'Diyanet İşleri Türk İslam Birliği – Almanya\'daki en büyük cami birliği. Cemaatler bağımsız derneklerdir.';

  @override
  String get association_info_other => 'Bu caminin bağlı olduğu birlik.';

  @override
  String region_info(int number) {
    return 'DİTİB Württemberg Bölge Gençlik Birliği $number. Bölge.';
  }

  @override
  String get admin_role_owner => 'Sahip';

  @override
  String get admin_role_admin => 'Yönetici';

  @override
  String get admin_role_editor => 'Editör';

  @override
  String get admin_preview => 'Önizleme';

  @override
  String get admin_preview_setting => 'Yönetim (önizleme)';

  @override
  String get admin_preview_hint =>
      'Cami yöneticilerinin gördüğü sekmeyi gösterir – ana camin için.';

  @override
  String get admin_no_mosque => 'Önce bir ana cami seç.';

  @override
  String get admin_view_page => 'Sayfayı gör';

  @override
  String get admin_entries => 'Etkinlik & duyurular';

  @override
  String get admin_new_entry => 'Yeni kayıt';

  @override
  String get admin_entries_empty => 'Henüz kayıt yok.';

  @override
  String get admin_page => 'Cami sayfası';

  @override
  String get admin_edit_info => 'Bilgi ve resim';

  @override
  String get admin_categories => 'Kategoriler';

  @override
  String get admin_team => 'Ekip';

  @override
  String get admin_past => 'geçti';

  @override
  String get admin_test_note =>
      'Değişiklikler test verilerinde uygulama yeniden başlatılana kadar geçerlidir.';

  @override
  String get entry_new => 'Yeni kayıt';

  @override
  String get entry_edit => 'Kaydı düzenle';

  @override
  String get entry_category => 'Kategori';

  @override
  String get entry_title => 'Başlık';

  @override
  String get entry_body => 'Metin';

  @override
  String get entry_has_date => 'Tarihli';

  @override
  String get entry_date => 'Tarih';

  @override
  String get entry_time => 'Saat';

  @override
  String get entry_notify => 'Üyelere bildir';

  @override
  String get entry_notify_hint => 'Bulut eklendiğinde anlık bildirim.';

  @override
  String get entry_delete_confirm => 'Kayıt silinsin mi?';

  @override
  String get entry_required => 'Lütfen doldur.';

  @override
  String get mosque_contact => 'İletişim';

  @override
  String get mosque_edit_about => 'Açıklama';

  @override
  String get mosque_edit_friday => 'Cuma namazı';

  @override
  String get mosque_edit_phone => 'Telefon';

  @override
  String get mosque_edit_website => 'Web sitesi';

  @override
  String get mosque_edit_none => 'Belirtilmedi';

  @override
  String get mosque_edit_locked =>
      'Ad, adres ve rozetleri uygulama yönetimi değiştirir.';

  @override
  String get category_new => 'Yeni kategori';

  @override
  String get category_edit => 'Kategoriyi düzenle';

  @override
  String get category_name => 'Ad';

  @override
  String get category_color => 'Renk';

  @override
  String get category_icon => 'Simge';

  @override
  String get category_builtin => 'Standart';

  @override
  String get category_custom_hint =>
      'Standart kategoriler her yerde var. Kendi kategorilerin sadece camin için geçerli.';

  @override
  String get category_delete_confirm =>
      'Bu kategorideki kayıtlar „Etkinlik“ olur.';

  @override
  String get team_invite => 'Davet et';

  @override
  String get team_invite_title => 'Davet kodu';

  @override
  String get team_invite_message =>
      'Bu kodu kişiye ilet. Bir kez ve 7 gün geçerlidir.';

  @override
  String get team_you => 'Sen';

  @override
  String get team_roles_hint =>
      'Sahip: her şey, ekip dahil. Yönetici: sayfa, etkinlikler, kategoriler. Editör: sadece etkinlik ve duyurular.';

  @override
  String get team_remove => 'Çıkar';

  @override
  String get common_copy => 'Kopyala';

  @override
  String get category_own => 'Kendi kategoriler';

  @override
  String get qibla_based_on_location => 'Konumun için hesaplandı';
}
