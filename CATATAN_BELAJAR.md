# Catatan Belajar FinFamily

Catatan ini merangkum project **FinFamily** dari sisi materi Flutter: widget, layouting, dan state.

- **Project:** `finfamily` (Flutter)
- **Fokus materi:** Bab 2–4 dan Bab 5.1 (Stateless vs Stateful)
- **Sumber modul:** `image/Modul_Mobile_Programming.pdf`
- **Sifat:** catatan belajar, tidak memengaruhi build aplikasi (file `.md` tidak dibaca Flutter)

---

## Daftar Isi

1. [Cakupan materi](#1-cakupan-materi)
2. [Gambaran project](#2-gambaran-project)
3. [Entry point dan struktur folder](#3-entry-point-dan-struktur-folder)
4. [Dart dan OOP yang dipakai](#4-dart-dan-oop-yang-dipakai)
5. [Widget (Bab 4)](#5-widget-bab-4)
6. [Layouting (Bab 4.4)](#6-layouting-bab-44)
7. [Stateless vs Stateful (Bab 5.1)](#7-stateless-vs-stateful-bab-51)
8. [Navigasi ringkas (pendukung)](#8-navigasi-ringkas-pendukung)
9. [Logika bisnis aplikasi](#9-logika-bisnis-aplikasi)
10. [Peta file ke konsep](#10-peta-file-ke-konsep)
11. [Cheat sheet](#11-cheat-sheet)
12. [Bank pertanyaan dan jawaban](#12-bank-pertanyaan-dan-jawaban)
13. [Di luar cakupan](#13-di-luar-cakupan)
14. [Rencana presentasi dan demo](#14-rencana-presentasi-dan-demo)
15. [Glosarium](#15-glosarium)
16. [Tambahan: peta cepat dan pertanyaan singkat](#16-tambahan-peta-cepat-dan-pertanyaan-singkat)

---

## 1. Cakupan materi

| Bab modul | Isi | Halaman |
|---|---|---|
| Bab 2–3 | Dart dasar, OOP, Flutter dasar, struktur project | 11–54 |
| Bab 4 | Widget dan layouting | 55–67 |
| Bab 5.1 | Stateless vs Stateful | 68–69 |

Materi pendukung (boleh disebut sekilas, bukan fokus):

| Bab modul | Isi | Halaman |
|---|---|---|
| Bab 5.2–5.4 | Dialog, SnackBar, TextField, Dropdown, TabBar, navigasi, BottomSheet, Drawer | 69–76 |
| Bab 6 | CRUD SQLite | 77–97 |
| Bab 7 | Media (gambar, video, audio) | 98–105 |
| Bab 8 | Deployment | 106–112 |

Kalimat aman saat presentasi:

> "Fokus project ini pada Bab 3 sampai 5.1: Dart, widget, layouting, dan state. SQLite dan GetX belum diterapkan; data masih dummy di repository agar lapisan UI dan data terpisah."

---

## 2. Gambaran project

FinFamily adalah aplikasi pencatat keuangan keluarga. Alurnya:

1. User mendaftar atau masuk.
2. Akun baru mengisi gaji, kebutuhan, cicilan, dan tabungan di **Pengaturan Awal**.
3. Aplikasi menghitung **sisa uang bebas belanja**.
4. **Beranda** menampilkan sisa uang, pemakaian batas, menu cepat, dan transaksi terbaru.

### Struktur folder

```text
lib/
├── main.dart                  → titik masuk aplikasi (runApp + MaterialApp)
├── theme/                     → warna dan style global
│   ├── app_colors.dart
│   └── status_style.dart
├── models/                    → bentuk data (class dan enum)
│   ├── transaction.dart
│   ├── finance_setup.dart
│   └── usage_status.dart
├── data/                      → "database" sementara di memori
│   ├── auth_repository.dart
│   ├── finance_repository.dart
│   └── transaction_repository.dart
├── services/                  → logika rekomendasi (titik sambung model ML)
│   └── recommendation_service.dart
├── utils/                     → fungsi bantu
│   ├── validators.dart
│   ├── rupiah.dart
│   └── date_labels.dart
├── widgets/                   → komponen UI yang dipakai ulang
│   ├── app_text_field.dart
│   ├── gradient_button.dart
│   ├── app_background.dart
│   ├── login_background.dart
│   ├── brand_logo.dart
│   ├── error_banner.dart
│   └── info_card.dart
└── screens/                   → satu file = satu layar
    ├── login_screen.dart
    ├── register_screen.dart
    ├── setup_screen.dart
    ├── main_shell.dart
    ├── home_screen.dart
    └── placeholder_screen.dart   (tidak dipakai lagi / sisa pengembangan)
```

Ini disebut **separation of concerns**:

- `screens` = tampilan dan interaksi
- `widgets` = komponen kecil yang bisa dipakai ulang
- `models` = struktur data
- `data` = sumber data
- `utils` = fungsi murni tanpa UI
- `theme` = warna dan style global

### Alur aplikasi

```text
main.dart
  └─ LoginScreen
       ├─ "Daftar" → RegisterScreen ──(pop bawa email)──> kembali ke Login
       └─ "Masuk"
            ├─ akun lama  (setupDone = true)  → MainShell → HomeScreen
            └─ akun baru  (setupDone = false) → SetupScreen → MainShell → HomeScreen

Logout → pushAndRemoveUntil → LoginScreen
```

Akun demo:

- Email: `budi.santoso@example.com`
- Password: `Keluarga123`
- Data contoh sudah terisi.

---

## 3. Entry point dan struktur folder

### `lib/main.dart`

```dart
void main() {
  runApp(const FinFamilyApp());
}

class FinFamilyApp extends StatelessWidget {
  const FinFamilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinFamily',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary)
            .copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
      ),
      home: const LoginScreen(),
    );
  }
}
```

Penjelasan:

| Istilah | Arti |
|---|---|
| `main()` | Titik mulai program |
| `runApp()` | Memasang widget root ke layar |
| `MaterialApp` | Wadah global: tema, navigasi, title |
| `theme` | Tema global aplikasi |
| `home` | Halaman pertama |
| `StatelessWidget` | Widget tanpa state berubah |
| `const` | Objek dibuat saat compile-time, tidak dibuat ulang saat rebuild |

`useMaterial3: true` membuat komponen memakai desain Material 3, contohnya `NavigationBar`.

`ColorScheme.fromSeed(...)` membuat palet otomatis dari satu warna, lalu `copyWith` menimpa warna tertentu.

`fontFamily: 'PlusJakartaSans'` terhubung ke `pubspec.yaml` yang mendaftarkan font di `assets/fonts/`.

Kalau ditanya "kenapa `main.dart` cuma sedikit?": karena tanggung jawab layar sudah dipindah ke `screens/`. `main.dart` hanya konfigurasi global.

### `Scaffold`

Dipakai di:

- `login_screen.dart`
- `register_screen.dart`
- `setup_screen.dart`
- `main_shell.dart`
- `placeholder_screen.dart`

`HomeScreen` **tidak** memakai `Scaffold` karena hidup di dalam `Scaffold` milik `MainShell` (`main_shell.dart`). Tidak perlu Scaffold bersarang.

Scaffold di project menyediakan:

- `backgroundColor`
- `body`
- `bottomNavigationBar` (khusus `MainShell`)
- `ScaffoldMessenger.of(context)` untuk SnackBar

Yang **tidak** dipakai: `AppBar`. Header dibuat manual dengan `Row` di `home_screen.dart` agar bentuknya bebas sesuai desain.

Jawaban kalau ditanya "kok tidak ada AppBar?":

> "Header saya buat manual dengan Row supaya sesuai desain. AppBar tidak wajib; Scaffold tetap bisa dipakai tanpa AppBar."

---

## 4. Dart dan OOP yang dipakai

### 4.1 Tipe data dan null safety

```dart
final String name;          // wajib diisi, tidak boleh null
final String note;          // tidak boleh null
String? pesanError;         // boleh null
```

Contoh nyata di `login_screen.dart`:

```dart
String? _loginError;
```

Artinya error mungkin belum ada. Kalau null, banner error tidak ditampilkan.

Null safety juga muncul di validator:

```dart
String? email(String? value) {
  if (email.isEmpty) return 'Email wajib diisi';
  return null;               // null = valid
}
```

Poin penting: `validator` mengembalikan `null` kalau input valid, dan `String` kalau error.

### 4.2 `final` vs `const`

| | Arti | Contoh |
|---|---|---|
| `final` | Nilai ditetapkan sekali saat runtime | `final user = AuthRepository.instance.currentUser;` |
| `const` | Nilai diketahui saat compile-time | `const Text('Halo')`, `const SizedBox(height: 20)` |

Widget statis di project hampir selalu memakai `const`, misalnya:

```dart
const SizedBox(height: 20),
```

Alasannya: objek `const` tidak dibuat ulang saat rebuild, lebih hemat.

### 4.3 Function dan arrow function

```dart
void _logout() { ... }

int get sisa => gaji - pengeluaranTetap;

UsageStatus get status => usageStatusFor(ratio);
```

### 4.4 Async/await

```dart
Future<void> _handleLogin() async {
  setState(() => _isLoading = true);
  await Future<void>.delayed(const Duration(milliseconds: 600));
  if (!mounted) return;
  ...
}
```

Kalau ditanya:

> "`async` membuat fungsi berjalan tanpa memblokir UI. `await` menunggu hasil. `mounted` memastikan widget masih ada sebelum `setState`."

### 4.5 OOP yang dipakai

| Konsep | Contoh di project |
|---|---|
| Class | `Transaction`, `FinanceSetup`, `AppUser` |
| Constructor | `const Transaction({required this.id, ...})` |
| Field `final` | `final int amount;` |
| Getter | `FinanceSetup.sisa` |
| Enum | `Kategori { primer, sekunder, tersier }` |
| Extension | `KategoriX.label` |
| Abstract class | `RecommendationService` |
| Inheritance | `class LoginScreen extends StatefulWidget` |
| `implements` | `DefaultRecommendationService implements RecommendationService` |
| Singleton | `AuthRepository.instance` |

Contoh getter yang bagus untuk presentasi:

```dart
int get pengeluaranTetap => kebutuhan + cicilan + tabungan;
int get sisa => gaji - pengeluaranTetap;
```

Narasi:

> "Sisa tidak disimpan sebagai field, tetapi dihitung lewat getter. Jadi tidak mungkin nilainya tidak sinkron dengan data lain."

Contoh enum dan extension:

```dart
enum Kategori { primer, sekunder, tersier }

extension KategoriX on Kategori {
  String get label => switch (this) {
        Kategori.primer => 'Primer',
        Kategori.sekunder => 'Sekunder',
        Kategori.tersier => 'Tersier',
      };
}
```

Contoh singleton:

```dart
class AuthRepository {
  AuthRepository._() { reset(); }          // constructor privat
  static final AuthRepository instance = AuthRepository._();  // satu objek global
  final List<AppUser> _users = [];
  AppUser? currentUser;
}
```

Kenapa singleton? Karena data demo harus bisa diakses dari banyak layar tanpa mengoper objek berlapis-lapis. Ini penyederhanaan; di aplikasi nyata bisa diganti Provider, Riverpod, atau GetX.

---

## 5. Widget (Bab 4)

### 5.1 Konsep dasar

> Widget adalah konfigurasi immutable yang membentuk UI. Semua yang terlihat (Text, Icon, Container) dan yang tidak terlihat (Row, Column, Padding, Center) adalah widget. Widget disusun menjadi **widget tree**.

Yang perlu disebut:

- Widget itu **immutable**; kalau berubah, dibuat widget baru.
- `build()` mengembalikan susunan widget.
- Widget baru dibuat dengan **komposisi**, bukan inheritance.
- `BuildContext` = posisi widget di tree.

### 5.2 Visible widget

| Widget | Lokasi | Keterangan |
|---|---|---|
| `Text` | semua layar | menampilkan teks |
| `Icon` | `home_screen.dart` | ikon Material |
| `Container` | `home_screen.dart` | styling, padding, dekorasi |
| `TextFormField` | `app_text_field.dart` | input |
| `TextButton` | `login_screen.dart` | tombol teks |
| `IconButton` | `app_text_field.dart` | tombol ikon |
| `Slider` | `setup_screen.dart` | input persentase |
| `LinearProgressIndicator` | `home_screen.dart` | progress batas |
| `CircularProgressIndicator` | `gradient_button.dart` | loading |
| `RichText` | `register_screen.dart` | teks beda style dalam satu baris |

Yang **tidak** dipakai: `ElevatedButton`, `Image`, `GridView`, `AppBar`, `ListView`.

Jawaban kalau ditanya:

> "Tidak semua widget harus dipakai. Saya memilih yang sesuai desain. Tombol utama butuh gradient sehingga saya komposisi sendiri."

### 5.3 `Container`

Contoh kartu "Sisa Uang Bebas Belanja":

```dart
Container(
  padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFAE5C), Color(0xFFF97316)],
    ),
    borderRadius: BorderRadius.circular(30),
    boxShadow: const [
      BoxShadow(color: Color(0x33F97316), blurRadius: 24, offset: Offset(0, 12)),
    ],
  ),
  child: Column(...),
)
```

Yang harus bisa disebut:

- `padding` = jarak dalam; `margin` = jarak luar.
- `decoration` = dekorasi: warna/gradient, border, radius, shadow.
- Kalau memakai `decoration`, warna diisi lewat `BoxDecoration`, bukan `color:` langsung.
- `BorderRadius.circular(30)` = sudut membulat.
- `BoxShadow` = bayangan; `0x33` adalah alpha.

### 5.4 Komposisi widget sendiri

`GradientButton` (`lib/widgets/gradient_button.dart`):

```dart
Container(
  height: 54,
  decoration: BoxDecoration(borderRadius: radius, boxShadow: [...]),
  child: Material(
    color: Colors.transparent,
    borderRadius: radius,
    clipBehavior: Clip.antiAlias,
    child: Ink(
      decoration: BoxDecoration(gradient: AppColors.buttonDeepGradient),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        child: Center(child: isLoading ? spinner : Text(label)),
      ),
    ),
  ),
)
```

Narasi:

> "Saya tidak mewarisi class Button. Saya menyusun widget bawaan: Container untuk ukuran dan shadow, Material untuk ripple, Ink untuk gradient, InkWell untuk area tap. Ini yang disebut composition."

Contoh komposisi lain:

- `AppTextField` = `Column(Text label + TextFormField)`
- `ErrorBanner` = `Container + Row(Icon + Expanded(Text))`
- `InfoCard` = `Container + Row(Icon + Expanded(child))`
- `BrandLogo` = `Row(CustomPaint + Column(RichText + Text))`

Kenapa dipisah ke `widgets/`? Agar bisa dipakai ulang (contoh `ErrorBanner` dipakai di Login dan Setup), layar tidak terlalu panjang, dan style konsisten.

### 5.5 `CustomPainter` (bonus)

`login_background.dart` dan `brand_logo.dart` menggambar ilustrasi langsung dengan `Canvas`, tanpa file PNG.

```dart
class LoginBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(painter: _LoginBackgroundPainter()),
    );
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // gambar path, circle, dan sebagainya
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

- `CustomPaint` = widget yang memakai `CustomPainter`.
- `paint(canvas, size)` = tempat menggambar.
- `Path` + `moveTo/lineTo/cubicTo/quadraticBezierTo` = menggambar bentuk.
- `Paint` = warna, stroke, shader (gradient).
- `shouldRepaint => false` = gambar statis, tidak perlu repaint.
- `RepaintBoundary` = memisahkan layer agar tidak ikut repaint saat widget lain berubah.

Alasan teknis: ilustrasi vektor tetap tajam di semua resolusi dan ukuran aplikasi lebih kecil karena tidak membawa gambar besar.

---

## 6. Layouting (Bab 4.4)

Modul membagi:

- **Visible widget** = terlihat (Text, Icon, Container).
- **Invisible widget / layouting** = tidak terlihat tetapi mengatur posisi (Center, Column, Row, Stack, SingleChildScrollView, ListView, GridView).

### 6.1 Resep layout FinFamily

Semua layar utama memakai urutan ini:

```text
Stack                          → background di belakang
└── SafeArea                   → aman dari notch
    └── SingleChildScrollView  → bisa scroll
        └── Center             → tengah di layar lebar
            └── ConstrainedBox(maxWidth: 430)
                └── Column(crossAxisAlignment: stretch)
                    ├── header
                    ├── card
                    ├── form
                    └── tombol
```

Bukti:

- `login_screen.dart`
- `register_screen.dart`
- `setup_screen.dart`
- `home_screen.dart`

Alasan tiap lapisan:

| Widget | Alasan dipakai |
|---|---|
| `Stack` | menaruh background dekoratif di belakang konten |
| `Positioned.fill` | background memenuhi seluruh layar |
| `SafeArea` | konten tidak tertutup notch/status bar |
| `SingleChildScrollView` | mencegah overflow saat layar kecil atau keyboard muncul |
| `Center` | konten di tengah pada layar lebar |
| `ConstrainedBox` | membatasi lebar maksimal 430 px |
| `Column` | menyusun konten vertikal |
| `stretch` | semua anak selebar layar |

Kalau ditanya "bagaimana menangani layar besar?":

> "Center + ConstrainedBox(maxWidth: 430). Di HP konten mengikuti lebar layar; di tablet atau web dibatasi dan diletakkan di tengah."

### 6.2 `Column` — vertikal

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [ ... ],
)
```

- `mainAxisAlignment` = posisi di sumbu utama (vertikal).
- `crossAxisAlignment` = posisi di sumbu silang (horizontal).
- `stretch` = anak melebar penuh.
- `MainAxisAlignment.center` dipakai di `main_shell.dart` untuk menaruh konten di tengah.

### 6.3 `Row` — horizontal

Contoh header Home:

```text
Row
├── Container 52x52        → ikon
├── SizedBox(width: 14)    → jarak
├── Expanded(Column)       → teks mengisi sisa
└── PopupMenuButton        → menu
```

`Expanded` adalah kunci. Tanpa `Expanded`, teks panjang akan mendorong widget lain keluar layar sehingga muncul **RenderFlex overflowed**.

Contoh `Expanded` lain:

- `home_screen.dart` → 4 menu cepat sama lebar.
- `error_banner.dart` → teks mengisi sisa setelah ikon.
- `info_card.dart` → isi card mengisi sisa.
- `home_screen.dart` → nama transaksi tidak menabrak nominal.

Cara menjelaskan:

> "Row memberi batas lebar. Widget tetap (ikon, jarak, menu) dihitung dulu, lalu Expanded mengambil sisa ruang. Jadi teks tidak overflow."

### 6.4 `Stack` — tumpuk

```dart
Stack(
  fit: StackFit.expand,
  children: [
    const Positioned.fill(child: AppBackground()),
    SafeArea(child: ...),
  ],
)
```

- Anak pertama = paling belakang.
- `Positioned.fill` = `top/right/bottom/left = 0`.
- `fit: StackFit.expand` = anak non-Positioned memenuhi area.
- `IgnorePointer` di `app_background.dart` = background tidak menangkap sentuhan.

### 6.5 `SingleChildScrollView`

Dipakai karena halaman lebih tinggi dari layar. Tanpa ini muncul error **RenderFlex overflowed**.

Kalau ditanya "kenapa bukan ListView?":

> "Isi halaman bukan daftar homogen, tetapi campuran header, card, form, dan tombol. SingleChildScrollView + Column lebih tepat. ListView untuk daftar item dinamis."

### 6.6 Widget layout lain

| Widget | Fungsi | Lokasi |
|---|---|---|
| `SizedBox` | jarak atau ukuran tetap | hampir semua layar |
| `Expanded` | ambil sisa ruang | `home_screen.dart` |
| `Center` | tengah | `home_screen.dart` |
| `Align` | posisi bebas | `register_screen.dart` |
| `Padding` | jarak dalam | `main_shell.dart` |
| `SafeArea` | hindari notch | semua layar |
| `ConstrainedBox` | batas lebar | `home_screen.dart` |
| `Wrap` | turun baris jika sempit | `login_screen.dart` |
| `ClipRRect` | potong sudut anak | `home_screen.dart` |
| `IndexedStack` | tumpuk layar, tampil satu | `main_shell.dart` |
| `LayoutBuilder` | layout berdasarkan ukuran | `login_screen.dart` |

`Wrap` vs `Row`: `Row` akan overflow, `Wrap` memindahkan anak ke baris berikutnya. Dipakai di footer "Belum punya akun? Daftar".

`ClipRRect` + `LinearProgressIndicator`:

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: LinearProgressIndicator(
    value: summary.ratio.clamp(0.0, 1.0),
    minHeight: 10,
  ),
)
```

`clamp(0.0, 1.0)` mencegah nilai lebih dari 1 merusak progress bar.

`LayoutBuilder`:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final logoGap = (constraints.maxHeight * 0.09).clamp(48.0, 84.0);
    ...
  },
)
```

Memberi tahu ukuran area yang tersedia, sehingga layout bisa adaptif.

`IndexedStack`:

```dart
IndexedStack(
  index: _index,
  children: [
    HomeScreen(onNavigate: _go),
    const _ComingSoonTab(title: 'Layar Transaksi'),
    ...
  ],
)
```

Semua anak tetap dibangun dan disimpan; hanya satu yang ditampilkan. Efeknya state tiap tab tidak hilang saat pindah tab.

### 6.7 `NavigationBar` Material 3

```dart
NavigationBarTheme(
  data: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: AppColors.softFill,
    height: 72,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      final selected = states.contains(WidgetState.selected);
      return TextStyle(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? AppColors.accentDeep : AppColors.body,
      );
    }),
  ),
  child: NavigationBar(
    selectedIndex: _index,
    onDestinationSelected: _go,
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Beranda'),
      ...
    ],
  ),
)
```

- `NavigationBar` = versi Material 3 dari `BottomNavigationBar`.
- `selectedIndex` dikontrol state `_index`.
- `onDestinationSelected` memanggil `setState` lewat `_go`.
- `WidgetStateProperty.resolveWith` memilih style berdasarkan state (`selected`, `hover`, `disabled`).
- `NavigationDestination` punya `icon` dan `selectedIcon`.

Alur tab: `HomeScreen` menerima callback `onNavigate`. Menu cepat memanggil `onNavigate(1/2/3)`, lalu `MainShell._go` mengubah `_index`. Ini contoh **lifting state up**: state tab dipegang parent, anak hanya memberi perintah.

---

## 7. Stateless vs Stateful (Bab 5.1)

### 7.1 Perbandingan

| | StatelessWidget | StatefulWidget |
|---|---|---|
| State internal | tidak ada | ada (`State`) |
| Perubahan UI | dari properti parent | `setState()` |
| `build()` | dipanggil saat parent rebuild | dipanggil saat `setState` |
| Contoh project | `HomeScreen`, `ErrorBanner`, `GradientButton` | `LoginScreen`, `MainShell`, `AppTextField`, `SetupScreen` |

### 7.2 Stateless di project

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;   // data dari parent

  @override
  Widget build(BuildContext context) { ... }
}
```

Kenapa Stateless?

- Tidak punya nilai yang dia ubah sendiri.
- Data dibaca dari repository saat `build`.
- Aksi tombol diteruskan ke parent lewat `onNavigate`.

`ErrorBanner`, `InfoCard`, `BrandLogo`, `GradientButton` juga Stateless karena hanya menampilkan properti yang dikirim.

Catatan jujur: `HomeScreen` tetap bisa menampilkan data baru ketika dia dibangun ulang oleh parent atau route baru. Dia tidak memiliki state sendiri, tetapi membaca data terbaru saat `build`.

### 7.3 Stateful di project

```dart
class MainShell extends StatefulWidget {
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int index) => setState(() => _index = index);
}
```

Kenapa Stateful? Karena `_index` berubah saat user memilih tab dan UI harus ikut berubah.

`LoginScreen`:

```dart
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _loginError;
}
```

State yang berubah:

- `_isLoading` → spinner di tombol.
- `_loginError` → banner error merah.

`AppTextField`:

```dart
class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;
}
```

Contoh bagus: widget input butuh state hanya untuk toggle lihat/sembunyikan password.

### 7.4 `setState`

```dart
setState(() {
  _index = index;
});
```

Alur:

1. Nilai berubah.
2. `setState` memberi tahu Flutter.
3. Flutter menjadwalkan `build()` ulang.
4. UI menampilkan nilai baru.

Tanpa `setState`, variabel berubah tetapi layar tidak berubah.

### 7.5 Lifecycle

```dart
@override
void initState() {
  super.initState();
  for (final controller in _controllers) {
    controller.addListener(_onInputChanged);
  }
}

@override
void dispose() {
  for (final controller in _controllers) {
    controller.removeListener(_onInputChanged);
    controller.dispose();
  }
  super.dispose();
}
```

| Method | Kapan dipanggil | Untuk apa |
|---|---|---|
| `initState()` | sekali saat widget masuk tree | memasang listener, inisialisasi |
| `build()` | setiap rebuild | menyusun UI |
| `dispose()` | saat widget keluar tree | membuang controller/listener |

Kalau ditanya "kenapa dispose penting?":

> "Mencegah memory leak dan listener yang tetap jalan setelah layar ditutup."

### 7.6 `key` dan `const`

- `super.key` meneruskan key ke parent. Key membantu Flutter mengenali widget yang sama saat rebuild.
- `GlobalKey<FormState>` dipakai untuk mengakses state `Form` dari luar, yaitu memanggil `validate()`.
- `const` mencegah pembuatan ulang widget yang tidak berubah.

### 7.7 Contoh penjelasan satu layar

Pakai `LoginScreen` karena mencakup hampir semua materi dalam cakupan.

Urutan menjelaskan:

1. **Jenis widget** — `LoginScreen` adalah `StatefulWidget` karena punya input dan status loading.
2. **State** — `_isLoading` dan `_loginError`.
3. **Layout** — `AnnotatedRegion → Scaffold → Stack → SafeArea → LayoutBuilder → SingleChildScrollView → Center → ConstrainedBox → Column`.
4. **Widget visible** — `BrandLogo`, `Text`, `Form`, `GradientButton`, `TextButton`.
5. **Layouting** — `Stack` untuk background, `Column` vertikal, `Wrap` di footer, `SizedBox` untuk jarak.
6. **Interaksi** — tombol memanggil `_handleLogin`, mengubah `_isLoading`, memvalidasi form.
7. **Validasi** — `GlobalKey<FormState>` + `validator` dari `Validators`.

Kalimat pembuka yang aman:

> "LoginScreen saya jelaskan dari tiga sisi: jenis widget dan state-nya, susunan layout-nya, lalu interaksinya. Dari sisi state, layar ini Stateful karena menyimpan status loading dan pesan error. Dari sisi layout, saya pakai Stack untuk background, SafeArea agar aman dari notch, SingleChildScrollView agar bisa scroll, dan ConstrainedBox 430 supaya rapi di layar lebar."

---

## 8. Navigasi ringkas (pendukung)

| Kode | Lokasi | Fungsi |
|---|---|---|
| `Navigator.push` + `MaterialPageRoute` | `login_screen.dart` | Buka layar baru di atas layar sekarang |
| `Navigator.pop(email)` | `register_screen.dart` | Tutup layar sambil mengirim data balik |
| `Navigator.pushReplacement` | `login_screen.dart`, `setup_screen.dart` | Ganti layar; tombol back tidak kembali ke layar lama |
| `Navigator.pushAndRemoveUntil(..., (route) => false)` | `home_screen.dart` | Hapus seluruh riwayat, lalu buka Login (logout) |
| `IndexedStack` | `main_shell.dart` | Pindah tab tanpa route baru |

Contoh mengirim data balik:

```dart
final email = await Navigator.of(context).push<String>(
  MaterialPageRoute<String>(builder: (_) => const RegisterScreen()),
);
if (!mounted || email == null) return;
setState(() {
  _emailController.text = email;
  _passwordController.clear();
});
```

Kenapa login memakai `pushReplacement`? Supaya user tidak bisa menekan back dan kembali ke halaman login setelah masuk.

Kenapa logout memakai `pushAndRemoveUntil`? Menghapus semua route sebelumnya agar back tidak membuka layar yang sudah tidak valid.

### SnackBar dan Dialog

```dart
ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(const SnackBar(content: Text('Registrasi berhasil. Silakan masuk.')));
```

- `ScaffoldMessenger` = pengelola SnackBar.
- `..` (cascade) = memanggil dua method pada objek yang sama.
- `hideCurrentSnackBar()` mencegah SnackBar menumpuk.

```dart
final proceed = await showDialog<bool>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: const Text('Periksa kembali datamu'),
    content: const Text('Pengeluaran tetap melebihi pemasukan. Tetap simpan data ini?'),
    actions: [
      TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Perbaiki')),
      TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Tetap simpan')),
    ],
  ),
);
if (proceed != true) return;
```

- `showDialog<bool>` mengembalikan hasil pilihan.
- `null` = dialog ditutup di luar tombol, ditangani `proceed != true`.

---

## 9. Logika bisnis aplikasi

Ini bukan Flutter, tetapi sering ditanya saat presentasi.

### 9.1 Sisa uang bebas belanja

```text
sisa = gaji − kebutuhan − cicilan − tabungan
```

Contoh data Budi:

```text
8.000.000 − 4.000.000 − 1.500.000 − 1.000.000 = 1.500.000
```

### 9.2 Pemakaian batas

```text
used = total(Sekunder) + total(Tersier)
```

Data contoh:

```text
Sekunder 650.000 + Tersier 400.000 = 1.050.000
```

### 9.3 Rasio dan status

```text
ratio = used / limit = 1.050.000 / 1.500.000 = 0.70
```

```text
< 70%   → Aman
>= 70%  → Waspada
>= 90%  → Merah
>= 100% → Melebihi
```

0.70 masuk `waspada`, sesuai tampilan "Waspada 70%".

Kalau `limit <= 0`: kalau ada pengeluaran dianggap `melebihi`, kalau tidak ada dianggap `aman`. Ini menghindari pembagian nol.

### 9.4 Pembagian Sekunder/Tersier

- Default 70% Sekunder, 30% Tersier.
- `RecommendationService` adalah abstract class, titik sambung kalau nanti memakai model ML/API.
- `RecommendationService.instance` bisa diganti tanpa mengubah layar.
- `recommendSafely` memakai `try/catch`; jika gagal, kembali ke aturan 70/30 agar aplikasi tidak crash.

Contoh desain yang baik:

> "Saya program ke abstraksi RecommendationService, bukan ke implementasi. Jadi kalau model sudah siap, layar tidak perlu diubah."

---

## 10. Peta file ke konsep

| File | Konsep utama |
|---|---|
| `main.dart` | `runApp`, `MaterialApp`, `ThemeData` |
| `login_screen.dart` | Stateful, `Form`, `GlobalKey`, async, `pushReplacement`, `push<String>` |
| `register_screen.dart` | Stateful, validasi, `pop` membawa data, `RichText` |
| `setup_screen.dart` | `initState/dispose`, listener, `Slider`, `showDialog`, formatter |
| `main_shell.dart` | Stateful, `IndexedStack`, `NavigationBar`, `NavigationBarTheme` |
| `home_screen.dart` | Stateless, `Stack`, `SafeArea`, `SingleChildScrollView`, `Row`, `Expanded`, `ConstrainedBox`, `LinearProgressIndicator` |
| `app_text_field.dart` | Stateful kecil, `TextFormField`, `InputDecoration`, `obscureText` |
| `gradient_button.dart` | Komposisi `Container/Material/Ink/InkWell`, loading state |
| `app_background.dart` | `Stack`, `Positioned`, `IgnorePointer` |
| `login_background.dart` | `CustomPaint`, `CustomPainter`, `Canvas`, `Path`, `RepaintBoundary` |
| `brand_logo.dart` | `Row`, `RichText`, `CustomPaint` |
| `error_banner.dart` / `info_card.dart` | `Container`, `Row`, `Expanded` |
| `app_colors.dart` | `static const`, `LinearGradient` |
| `status_style.dart` | `switch` expression, mapping status ke warna |
| `transaction.dart` | enum, extension, immutable model |
| `usage_status.dart` | enum, getter, logika ambang |
| `*_repository.dart` | singleton, `Map`, data dummy |
| `recommendation_service.dart` | abstract class, strategy, fallback |
| `rupiah.dart` | `TextInputFormatter`, format angka |
| `validators.dart` | `RegExp`, validasi |
| `date_labels.dart` | logika tanggal relatif |

---

## 11. Cheat sheet

### 11.1 Entry point dan kerangka

| Kode | Fungsi | Contoh satu baris |
|---|---|---|
| `main()` | Titik mulai program | `void main() => runApp(const FinFamilyApp());` |
| `runApp()` | Pasang widget root ke layar | `runApp(const FinFamilyApp());` |
| `MaterialApp` | Wadah global: tema dan navigasi | `MaterialApp(home: const LoginScreen());` |
| `Scaffold` | Kerangka halaman | `Scaffold(body: ...)` |
| `ThemeData` | Tema global | `ThemeData(useMaterial3: true, fontFamily: 'PlusJakartaSans')` |

### 11.2 Visible widget

| Widget | Fungsi | Contoh satu baris |
|---|---|---|
| `Text` | Menampilkan teks | `Text('Halo, Budi!')` |
| `Icon` | Ikon Material | `Icon(Icons.home_rounded, size: 30)` |
| `Container` | Ukuran, padding, dekorasi | `Container(padding: EdgeInsets.all(16), child: ...)` |
| `TextFormField` | Input dan validasi | `TextFormField(validator: Validators.email)` |
| `TextButton` | Tombol teks | `TextButton(onPressed: _open, child: Text('Daftar'))` |
| `IconButton` | Tombol ikon | `IconButton(icon: Icon(Icons.visibility), onPressed: _toggle)` |
| `Slider` | Input rentang | `Slider(value: 70, min: 0, max: 100, onChanged: _ubah)` |
| `LinearProgressIndicator` | Progress horizontal | `LinearProgressIndicator(value: 0.7)` |
| `CircularProgressIndicator` | Loading bulat | `CircularProgressIndicator(strokeWidth: 2.4)` |
| `RichText` | Teks beda style dalam satu paragraf | `RichText(text: TextSpan(children: [...]))` |
| `Padding` | Jarak dalam | `Padding(padding: EdgeInsets.all(26), child: ...)` |
| `SizedBox` | Jarak atau ukuran tetap | `SizedBox(height: 20)` |

### 11.3 Layouting

| Widget | Fungsi | Contoh satu baris |
|---|---|---|
| `Column` | Susun vertikal | `Column(children: [Text('A'), Text('B')])` |
| `Row` | Susun horizontal | `Row(children: [Icon(...), Text('Halo')])` |
| `Stack` | Tumpuk (sumbu Z) | `Stack(children: [background, konten])` |
| `Positioned` | Posisi anak di dalam Stack | `Positioned(top: -170, right: -120, child: ...)` |
| `Positioned.fill` | Penuhi seluruh Stack | `Positioned.fill(child: AppBackground())` |
| `Center` | Tengah | `Center(child: Text('Hi'))` |
| `Align` | Posisi bebas | `Align(alignment: Alignment.centerLeft, child: ...)` |
| `Expanded` | Ambil sisa ruang | `Expanded(child: Text('judul'))` |
| `Flexible` | Ambil sisa ruang, boleh lebih kecil | `Flexible(child: Text('...'))` |
| `Spacer` | Ruang kosong fleksibel | `Row(children: [Text('A'), Spacer(), Text('B')])` |
| `ConstrainedBox` | Batasi ukuran | `ConstrainedBox(constraints: BoxConstraints(maxWidth: 430), child: ...)` |
| `SafeArea` | Hindari notch dan status bar | `SafeArea(child: ...)` |
| `SingleChildScrollView` | Bisa di-scroll | `SingleChildScrollView(child: Column(...))` |
| `Wrap` | Turun baris kalau sempit | `Wrap(children: [Text('Belum punya akun?'), TextButton(...)])` |
| `ClipRRect` | Potong sudut anak | `ClipRRect(borderRadius: BorderRadius.circular(10), child: ...)` |
| `IndexedStack` | Tumpuk layar, tampil satu | `IndexedStack(index: _index, children: [...])` |
| `LayoutBuilder` | Layout dari ukuran tersedia | `LayoutBuilder(builder: (context, c) => ...)` |
| `IgnorePointer` | Tidak menangkap sentuhan | `IgnorePointer(child: Stack(...))` |

### 11.4 Stateless vs Stateful

| Item | Stateless | Stateful |
|---|---|---|
| Punya state berubah? | Tidak | Ya |
| Cara update | parent rebuild | `setState()` |
| Class | `extends StatelessWidget` | `extends StatefulWidget` + `State<...>` |
| Contoh project | `HomeScreen`, `ErrorBanner` | `LoginScreen`, `MainShell`, `AppTextField` |

| Kode | Fungsi | Contoh |
|---|---|---|
| `StatelessWidget` | Widget tanpa state | `class HomeScreen extends StatelessWidget` |
| `StatefulWidget` | Widget dengan state | `class LoginScreen extends StatefulWidget` |
| `State` | Tempat data berubah | `class _LoginScreenState extends State<LoginScreen>` |
| `setState()` | Minta rebuild | `setState(() => _index = index);` |
| `initState()` | Sekali saat masuk tree | `initState() { super.initState(); ... }` |
| `dispose()` | Saat keluar tree | `dispose() { controller.dispose(); super.dispose(); }` |
| `mounted` | Widget masih ada? | `if (!mounted) return;` |
| `BuildContext` | Posisi widget di tree | `Navigator.of(context)` |
| `GlobalKey<FormState>` | Akses state Form | `_formKey.currentState?.validate()` |
| `TextEditingController` | Pegang isi input | `final _email = TextEditingController();` |
| `const` | Objek compile-time | `const SizedBox(height: 20)` |

### 11.5 Aturan cepat

1. **Column = vertikal, Row = horizontal.**
2. **`mainAxisAlignment`** = sumbu utama. **`crossAxisAlignment`** = sumbu silang.
   - Column: main = vertikal, cross = horizontal.
   - Row: main = horizontal, cross = vertikal.
3. **`stretch`** = anak melebar penuh.
4. **`Expanded`** = ambil sisa ruang, anti-overflow.
5. **`Stack`** = anak pertama paling belakang.
6. **`Positioned.fill`** = penuhi semua sisi.
7. **`SingleChildScrollView`** = obat overflow vertikal.
8. **`Wrap`** = obat overflow horizontal.
9. **`const`** = widget tidak berubah, hemat rebuild.
10. **`setState`** = cara memberi tahu UI bahwa state berubah pada StatefulWidget.

### 11.6 Anatomi layout FinFamily

```text
Stack                          → background di belakang
└── SafeArea                   → aman dari notch
    └── SingleChildScrollView  → bisa scroll
        └── Center             → tengah di layar lebar
            └── ConstrainedBox(maxWidth: 430)
                └── Column(stretch)
                    ├── header
                    ├── card
                    ├── form
                    └── button
```

### 11.7 Tiga snippet andalan

**A. Column + Row + Expanded**

```dart
Row(
  children: [
    Icon(Icons.home_rounded),
    const SizedBox(width: 14),
    Expanded(child: Text('Halo, Budi!')),
    PopupMenuButton<String>(itemBuilder: (_) => const []),
  ],
)
```

**B. Stack + background**

```dart
Stack(
  fit: StackFit.expand,
  children: [
    const Positioned.fill(child: AppBackground()),
    SafeArea(child: SingleChildScrollView(child: Column(...))),
  ],
)
```

**C. Stateful + setState**

```dart
class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: _go,
      destinations: const [...],
    );
  }
}
```

---

## 12. Bank pertanyaan dan jawaban

### 12.1 Dua puluh pertanyaan utama

**1. Apa itu widget?**

Widget adalah konfigurasi immutable yang membentuk UI. Semua elemen, baik terlihat maupun layout, adalah widget, dan disusun menjadi widget tree melalui `build()`.

**2. Apa perbedaan visible dan invisible widget?**

Visible widget terlihat langsung oleh user (Text, Icon, Container, tombol). Invisible widget tidak terlihat tetapi mengatur posisi dan struktur (Column, Row, Stack, Center, Padding). Keduanya tetap widget.

**3. Jelaskan perbedaan Column dan Row.**

Column menyusun anak vertikal dari atas ke bawah; sumbu utamanya Y. Row menyusun anak horizontal dari kiri ke kanan; sumbu utamanya X. Pada Column, `crossAxisAlignment` mengatur horizontal; pada Row mengatur vertikal.

**4. Kenapa `Expanded` penting? Apa yang terjadi tanpa `Expanded`?**

`Expanded` mengambil sisa ruang setelah widget berukuran tetap dihitung. Tanpa `Expanded`, teks panjang di dalam Row bisa melebihi lebar layar dan memunculkan error RenderFlex overflowed. Contohnya teks sapaan di header Home.

**5. Kenapa layar FinFamily memakai `Stack` di paling luar?**

Untuk menaruh background dekoratif di belakang konten. Anak pertama Stack adalah lapisan paling belakang. `Positioned.fill` membuat background memenuhi layar, dan `IgnorePointer` memastikan background tidak menangkap sentuhan.

**6. Kapan memakai `SingleChildScrollView`, dan kenapa bukan `ListView`?**

Dipakai saat satu halaman berisi campuran widget (header, card, form, tombol) dan tingginya bisa melebihi layar. ListView lebih tepat untuk daftar item yang homogen dan dinamis. SingleChildScrollView mencegah overflow saat layar kecil atau keyboard muncul.

**7. Apa perbedaan StatelessWidget dan StatefulWidget?**

StatelessWidget tidak punya state internal; tampilannya bergantung pada properti dari parent dan hanya berubah saat parent rebuild. Contoh: HomeScreen. StatefulWidget punya objek State berisi data yang bisa berubah; perubahan dilakukan dengan `setState()` yang memicu `build()` ulang. Contoh: LoginScreen dengan `_isLoading` dan `_loginError`.

**8. Kapan sebaiknya memakai StatefulWidget? Beri contoh dari project.**

Saat ada data yang berubah dan memengaruhi tampilan. Contoh: MainShell menyimpan `_index` untuk tab aktif; LoginScreen menyimpan status loading dan pesan error; AppTextField menyimpan `_hidden` untuk toggle password.

**9. Apa fungsi `setState`, `initState`, dan `dispose`?**

- `setState()` memberi tahu Flutter bahwa state berubah sehingga UI dibangun ulang.
- `initState()` dipanggil sekali saat widget masuk tree, tempat inisialisasi atau memasang listener.
- `dispose()` dipanggil saat widget keluar tree, tempat membuang controller dan listener agar tidak memory leak.

**10. Kenapa banyak widget memakai `const`? Apa bedanya dengan `final`?**

`const` membuat objek saat compile-time sehingga tidak dibuat ulang saat rebuild; dipakai untuk widget statis seperti `const SizedBox(height: 20)`. `final` hanya berarti nilainya ditetapkan sekali, tetapi bisa jadi saat runtime, misalnya `final user = AuthRepository.instance.currentUser;`.

**11. Apa fungsi `SafeArea`?**

Menghindari notch, status bar, dan gesture bar agar konten tidak terpotong.

**12. Kenapa ada `Center` + `ConstrainedBox(maxWidth: 430)`?**

Agar di tablet atau web konten tidak melar penuh. Di HP konten mengikuti lebar layar; di layar besar dibatasi 430 px dan diletakkan di tengah.

**13. Kenapa tombol utama tidak memakai `ElevatedButton`?**

Karena desain butuh gradient, shadow, dan spinner. GradientButton disusun dari Container + Material + Ink + InkWell agar tampilan bebas dan tetap punya ripple.

**14. Bagaimana state form dikelola?**

`TextEditingController` menyimpan isi field, `GlobalKey<FormState>` memberi akses ke Form, dan `validator` per field mengembalikan pesan error. Saat submit, `_formKey.currentState?.validate()` memvalidasi semua field.

**15. Bedanya `push`, `pushReplacement`, dan `pushAndRemoveUntil`?**

`push` menambah halaman di atas (bisa back). `pushReplacement` mengganti halaman sekarang (tidak bisa back ke halaman lama), dipakai Login ke MainShell. `pushAndRemoveUntil` menghapus seluruh riwayat, dipakai logout.

**16. Kenapa ada `if (!mounted) return;` setelah `await`?**

Karena widget bisa sudah di-dispose saat proses async selesai. Memanggil `setState` setelah dispose menyebabkan error.

**17. Di mana SQLite atau GetX?**

Belum dipakai. Project ini fokus pada UI, state, dan navigasi (Bab 4–5). Data masih dummy di memori. Struktur repository sengaja dibuat agar nanti bisa diganti SQLite atau API tanpa mengubah layar.

**18. Di mana penerapan OOP-nya?**

Class model, constructor, getter (`FinanceSetup.sisa`), enum dan extension (`Kategori.label`), abstract class (`RecommendationService`), dan singleton repository.

**19. Kenapa data contoh ada di repository, bukan di widget?**

Agar UI hanya menampilkan dan sumber data terpisah sehingga mudah diganti nanti. Ini separation of concerns.

**20. Kalau diminta demo, tunjukkan apa?**

Login, lalu Home (layout dan data), kemudian buka `main_shell.dart` dan tunjukkan `setState` saat pindah tab.

### 12.2 Sepuluh soal latihan dengan jawaban model

**1. Apa itu widget?**
Konfigurasi immutable pembentuk UI. Semua elemen, terlihat maupun layout, adalah widget yang disusun menjadi widget tree.

**2. Apa perbedaan visible dan invisible widget?**
Visible terlihat user (Text, Icon, Container). Invisible mengatur posisi (Column, Row, Stack, Center). Keduanya sama-sama widget.

**3. Jelaskan perbedaan `Column` dan `Row`.**
Column vertikal (sumbu utama Y), Row horizontal (sumbu utama X).

**4. Kenapa `Expanded` penting?**
Mengambil sisa ruang setelah widget tetap dihitung, mencegah overflow. Contoh: teks di header Home.

**5. Kenapa layar memakai `Stack` di paling luar?**
Untuk background di belakang konten; anak pertama adalah lapisan paling belakang.

**6. Kenapa memakai `SingleChildScrollView`?**
Agar konten panjang bisa digulir dan tidak overflow saat layar kecil atau keyboard muncul.

**7. Apa perbedaan Stateless dan Stateful?**
Stateless tidak punya state internal; tampil dari properti. Stateful punya State dan memakai `setState()` untuk rebuild. Contoh: HomeScreen vs LoginScreen.

**8. Kapan memakai Stateful?**
Saat ada data yang berubah dan memengaruhi tampilan: input form, tab aktif, loading, toggle password.

**9. Apa fungsi `setState`, `initState`, dan `dispose`?**
`setState` memicu rebuild; `initState` inisialisasi saat masuk tree; `dispose` membuang resource saat keluar tree.

**10. Kenapa memakai `const`?**
Widget tidak berubah, dibuat sekali saat compile-time, mengurangi rebuild.

### 12.3 Lima soal cek cepat

| Pertanyaan | Jawaban singkat |
|---|---|
| `Column` itu sumbu apa? | Vertikal (Y) |
| Anak pertama `Stack` posisinya? | Paling belakang |
| Widget untuk batasi lebar di tablet? | `ConstrainedBox(maxWidth: 430)` |
| Widget anti-notch? | `SafeArea` |
| Widget anti-overflow vertikal? | `SingleChildScrollView` |
| Widget anti-overflow horizontal? | `Wrap` |
| `setState` ada di class apa? | `State` |
| `build()` mengembalikan apa? | Widget |
| `validator` return `null` artinya? | Input valid |
| `GlobalKey<FormState>` untuk apa? | Memanggil `validate()` dari luar `build` |

### 12.4 Cara menghafal satu menit

> Widget = semua.
> Column vertikal, Row horizontal.
> Stack tumpuk, Positioned atur posisi.
> Expanded ambil sisa, SizedBox kasih jarak.
> Scroll kalau panjang, Wrap kalau sempit.
> Stateless diam, Stateful berubah lewat setState.
> initState masuk, dispose keluar.

---

## 13. Di luar cakupan

Sebutkan hanya kalau ditanya, jangan dijadikan slide.

| Topik modul | Status di FinFamily | Jawaban yang bisa dipakai |
|---|---|---|
| SQLite / `sqflite` (Bab 6) | Belum | Data masih dummy di `data/*_repository.dart`. Repository adalah lapisan abstraksi; nanti isinya bisa diganti sqflite tanpa mengubah layar. |
| GetX (kata pengantar) | Belum | State masih `setState` karena skala project kecil. Untuk project besar, state management bisa ditambahkan. |
| Media gambar/video/audio (Bab 7) | Belum | Ilustrasi dibuat dengan `CustomPainter`, jadi belum butuh aset gambar. |
| Deployment (Bab 8) | Belum | Bisa dibahas terpisah: `flutter build apk --release`. |
| `AppBar`, `Drawer`, `BottomSheet`, `TabBar`, `GridView` | Belum | Tidak sesuai desain. Navigasi bawah memakai NavigationBar Material 3; konten memakai Column dan Row. |

---

## 14. Rencana presentasi dan demo

### 14.1 Presentasi 5 menit

1. **30 detik** — FinFamily: catat keuangan keluarga, hitung sisa uang bebas belanja.
2. **45 detik** — struktur `lib/`: screens, widgets, models, data, utils.
3. **45 detik** — entry point: `main()` ke `runApp()` ke `MaterialApp` ke `LoginScreen`.
4. **1,5 menit** — layouting: buka `home_screen.dart`, tunjukkan resep Stack, SafeArea, SingleChildScrollView, Center, ConstrainedBox, Column, lalu Row dan Expanded.
5. **1 menit** — stateless vs stateful: HomeScreen vs LoginScreen atau MainShell, tunjukkan `setState` dan `dispose`.
6. **30 detik** — OOP singkat: model, getter, enum, abstract service.
7. **30 detik** — penutup: data dummy, siap dikembangkan.

### 14.2 Demo yang aman

1. Login akun lama, lihat Home dengan data terisi.
2. Login akun baru, isi angka di Setup, lihat sisa berubah otomatis, lalu Simpan.
3. Geser Slider, lihat persentase berubah.
4. Tekan menu cepat, lihat tab berpindah.
5. Logout, kembali ke Login.

### 14.3 Kalimat pembuka

> "FinFamily adalah aplikasi pengelola keuangan keluarga. Saya akan menjelaskan dari sisi struktur project, widget dan layouting, lalu state dan interaksinya."

---

## 15. Glosarium

| Istilah | Arti singkat |
|---|---|
| Widget tree | Susunan widget dari root sampai anak terdalam |
| Build | Proses menyusun widget |
| Rebuild | Menjalankan ulang `build()` setelah state berubah |
| Constraint | Batas ukuran yang diberikan parent ke child |
| Overflow | Konten melebihi ruang, muncul garis kuning-hitam |
| Route | Satu halaman dalam navigasi |
| Context | Posisi widget dalam tree |
| Immutable | Tidak bisa diubah setelah dibuat |
| Composition | Membuat widget baru dari gabungan widget lain |
| Repository | Lapisan akses data |
| Singleton | Satu instance global |
| Dependency injection | Mengganti implementasi dari luar, contoh `RecommendationService.instance` |

---

## 16. Tambahan: peta cepat dan pertanyaan singkat

### 16.1 Peta cepat: apa yang harus bisa dijelaskan

| Konsep | Harus bisa | Bukti di project |
|---|---|---|
| Entry point | Apa itu `main()` dan `runApp()` | `lib/main.dart` |
| Struktur project | Fungsi folder `lib/` | `lib/screens`, `widgets`, `models` |
| Widget | Semua adalah widget | seluruh `lib/` |
| Visible widget | Text, Icon, Container, tombol | semua layar |
| Layouting | Column, Row, Stack, Center, Expanded | `home_screen.dart`, `login_screen.dart` |
| Constraint dan overflow | Kenapa perlu `Expanded` atau scroll | `home_screen.dart` |
| Stateless | Widget tanpa state | `HomeScreen`, `ErrorBanner` |
| Stateful | Widget dengan `setState` | `LoginScreen`, `MainShell` |
| Lifecycle | `initState`, `dispose` | `setup_screen.dart` |
| Dart dasar | tipe data, `final/const`, function, null safety | `models/`, `utils/` |
| OOP | class, constructor, enum, getter, abstract | `models/`, `services/` |

### 16.2 Empat pertanyaan tambahan

**1. Apa fungsi `mainAxisAlignment` dan `crossAxisAlignment`?**

`mainAxisAlignment` mengatur distribusi anak di sumbu utama; `crossAxisAlignment` mengatur di sumbu silang. Pada Column, sumbu utama vertikal dan sumbu silang horizontal. Pada Row, sumbu utama horizontal dan sumbu silang vertikal.

**2. Apa itu `BuildContext`?**

Posisi widget di dalam widget tree. Dipakai untuk mengakses parent atau layanan di atasnya, misalnya `Navigator.of(context)`, `Theme.of(context)`, dan `ScaffoldMessenger.of(context)`.

**3. Apa itu `key` dan kenapa ada `super.key`?**

Key adalah identitas widget agar Flutter dapat mengenali widget yang sama saat rebuild. `super.key` meneruskan key dari parent ke constructor induk. `GlobalKey<FormState>` dipakai saat butuh mengakses state Form dari luar, yaitu untuk memanggil `validate()`.

**4. Apa kelebihan project ini?**

Pemisahan layer rapi (screens, widgets, models, data, utils), UI responsif (`ConstrainedBox`, `LayoutBuilder`, `SingleChildScrollView`), validasi terpusat, logika bisnis di model dan service (bukan di UI), serta sudah ada widget test.

### 16.3 Versi presentasi 7 menit

Kalau waktu presentasi lebih longgar, pakai urutan ini:

1. **Pembuka (30 detik)** — FinFamily: aplikasi pengelola keuangan keluarga; menghitung sisa uang bebas belanja dan memantau pemakaiannya.
2. **Struktur project (45 detik)** — tunjukkan folder `screens`, `widgets`, `models`, `data`, `utils` dan alasannya.
3. **Alur aplikasi (45 detik)** — Login, Register/Setup, MainShell, Home; jelaskan `setupDone`.
4. **Widget dan layout (2 menit)** — buka `home_screen.dart`, tunjukkan resep `Stack → SafeArea → SingleChildScrollView → Center → ConstrainedBox → Column`, lalu `Row` + `Expanded`.
5. **State (1 menit)** — bandingkan `HomeScreen` (Stateless) dengan `LoginScreen` dan `MainShell` (Stateful), tunjukkan `setState`.
6. **Navigasi (1 menit)** — `pushReplacement`, `pop(email)`, `pushAndRemoveUntil`, `IndexedStack`.
7. **Penutup (30 detik)** — data masih dummy dan siap diganti API/SQLite; widget test sudah ada.

---

## Lampiran: perintah yang berguna

```bash
# menjalankan aplikasi
flutter run

# cek error dan warning
flutter analyze

# menjalankan seluruh test
flutter test

# test file tertentu
flutter test test/widget_test.dart
```

Membuka catatan ini:

- VS Code: klik kanan file, **Open Preview** (Markdown Preview).
- GitHub: otomatis dirender.
- PDF: buka preview Markdown, klik kanan, **Print**, lalu pilih **Save as PDF**.

---

*Catatan ini dibuat untuk belajar dan presentasi. Tidak mengubah kode aplikasi.*
