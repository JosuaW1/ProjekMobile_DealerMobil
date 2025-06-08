# Aplikasi Dealer Mobil

## Informasi Proyek

**Nama:** Josua Waruwu  
**NIM:** 123220083  
**Tema Proyek:** Aplikasi Mobile Dealer Mobil

## Deskripsi Aplikasi

Aplikasi Dealer Mobil adalah sebuah aplikasi mobile yang dikembangkan menggunakan Flutter untuk memudahkan pengguna dalam membeli mobil dan mengelola sistem dealer mobil. Aplikasi ini memiliki fitur lengkap untuk user dan admin dengan berbagai teknologi terintegrasi.

## Fitur Utama

### Untuk User
- Login dan register dengan enkripsi password
- Melihat katalog mobil dengan konversi mata uang (IDR, USD, EUR)
- Memesan mobil dengan form pemesanan otomatis
- Melihat riwayat pemesanan dan edit metode pembayaran
- Mencari dealer terdekat menggunakan GPS (Location-Based Services)
- Upload foto profil dari kamera atau galeri
- Demo sensor gyroscope dengan visualisasi real-time

### Untuk Admin
- Dashboard dengan statistik sistem
- Kelola users (promote ke admin, hapus user)
- Kelola data mobil (CRUD operations)
- Monitor dan kelola semua pesanan
- Akses ke semua fitur user

## Teknologi yang Digunakan

### Framework dan Database
- Flutter SDK untuk development mobile
- SQLite untuk database lokal (users, orders)
- Hive untuk penyimpanan pengaturan aplikasi
- REST API untuk data mobil dari server eksternal

### Fitur Teknis
- Enkripsi password menggunakan SHA256
- Session management dengan SharedPreferences
- State management menggunakan Provider pattern
- Geolocator untuk layanan lokasi
- Sensors Plus untuk integrasi gyroscope
- Image Picker untuk upload foto
- Flutter Local Notifications untuk notifikasi

### Konversi dan Utilitas
- Konversi mata uang (IDR, USD, EUR)
- Konversi zona waktu (WIB, WITA, WIT, London)
- Real-time clock dengan timezone selection

## Cara Kerja Aplikasi

### Alur Pengguna
1. User melakukan registrasi atau login ke aplikasi
2. Setelah login, user dapat melihat halaman utama dengan menu navigasi
3. User dapat menjelajahi katalog mobil dan melihat detail dengan harga terkonversi
4. Untuk memesan mobil, user mengisi form pemesanan yang otomatis mengambil data profil
5. User dapat melihat riwayat pesanan dan melakukan perubahan jika diperlukan
6. Fitur dealer terdekat membantu user menemukan lokasi dealer menggunakan GPS

### Alur Admin
1. Admin login menggunakan akun khusus (josua@tes.com)
2. Admin dapat mengakses dashboard dengan overview statistik sistem
3. Admin dapat mengelola user, mengubah role, dan menghapus akun
4. Admin dapat menambah, edit, atau hapus data mobil melalui API
5. Admin dapat memonitor semua pesanan dan melakukan perubahan

### Arsitektur Data
- Data user dan pesanan disimpan di SQLite database lokal
- Data mobil diambil dari API eksternal secara real-time
- Pengaturan aplikasi (mata uang, timezone) disimpan menggunakan Hive
- Session login disimpan menggunakan SharedPreferences

## Struktur Navigasi

Aplikasi menggunakan bottom navigation dengan 4 tab utama:
- Home: Dashboard user dengan quick actions dan statistik
- Profile: Kelola profil user dan upload foto
- LBS: Location-Based Services untuk dealer terdekat
- Help: FAQ, kontak, demo sensor, dan logout

## Keamanan

- Password dienkripsi menggunakan algoritma SHA256
- Validasi input di semua form untuk mencegah data tidak valid
- Role-based access control untuk membedakan user dan admin
- Session timeout untuk keamanan login

## Setup dan Instalasi

### Prerequisites
- Flutter SDK versi 3.0 atau lebih tinggi
- Android Studio atau VS Code dengan Flutter extension
- Device Android/iOS atau emulator untuk testing

### Dependencies
Aplikasi menggunakan dependencies berikut:
- flutter_local_notifications untuk notifikasi
- http untuk REST API calls
- provider untuk state management
- sqflite untuk database SQLite
- path_provider untuk file system access
- hive untuk key-value storage
- geolocator untuk layanan lokasi
- intl untuk internasionalization
- sensors_plus untuk sensor integration
- shared_preferences untuk session storage
- crypto untuk enkripsi password
- permission_handler untuk mengelola permissions
- image_picker untuk upload foto

### Instalasi
1. Clone atau download source code aplikasi
2. Jalankan `flutter pub get` untuk menginstall dependencies
3. Setup permissions di AndroidManifest.xml untuk location, camera, storage
4. Jalankan aplikasi menggunakan `flutter run`

## Data Default

Aplikasi sudah dilengkapi dengan data default:
- Akun admin: Email josua@tes.com, Password tes1234
- 5 dealer dummy di area Jakarta dengan koordinat GPS
- Berbagai metode pembayaran (Transfer Bank, Kartu Kredit, Cash, Cicilan, Leasing)

## API Integration

Aplikasi terhubung dengan REST API untuk data mobil:
- Base URL: https://dealer-project-935996462481.us-central1.run.app
- Endpoints: GET /mobil, POST /tambahmobil, PUT /updatemobil, DELETE /deletemobil
- Format data: JSON dengan struktur nama, merek, tahun_produksi, harga

## Fitur Khusus

### Location-Based Services
Menggunakan GPS device untuk menghitung jarak ke dealer terdekat dengan akurasi tinggi dan permission handling yang proper.

### Sensor Integration
Demo sensor gyroscope dengan visualisasi real-time, deteksi gerakan, dan animasi interaktif untuk pengalaman user yang menarik.

### Currency Conversion
Konversi harga mobil secara real-time dari format Indonesia (juta/miliar) ke mata uang internasional dengan exchange rate yang akurat.

### Timezone Management
Sistem waktu yang dapat disesuaikan dengan berbagai zona waktu Indonesia dan internasional dengan update real-time.

## Kontributor

Aplikasi ini dikembangkan oleh Josua Waruwu (NIM: 123220083) sebagai proyek akhir aplikasi mobile dealer mobil.