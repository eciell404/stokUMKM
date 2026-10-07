import 'package:flutter/material.dart';

void main() => runApp(const StokApp());

const ink = Color(0xFF12263A);
const tagYellow = Color(0xFFF6C945);
const alertRed = Color(0xFFC8372D);

// ---------- Data (dummy, disimpan di memori) ----------
class Produk {
  final String nama;
  int stok;
  final int min;
  Produk(this.nama, this.stok, this.min);
  bool get menipis => stok <= min;
}

class Catatan {
  final String produk, jenis, waktu;
  final int jumlah;
  Catatan(this.produk, this.jenis, this.jumlah, this.waktu);
}

class Store extends ChangeNotifier {
  final produk = <Produk>[
    Produk('Beras Premium 4kg', 24, 10),
    Produk('Minyak Goreng 2L', 6, 12),
    Produk('Gula Pasir 1kg', 18, 10),
    Produk('Air Mineral 600ml', 9, 24),
    Produk('Mi Instan Goreng', 62, 30),
    Produk('Telur Ayam 1kg', 4, 8),
  ];
  final riwayat = <Catatan>[];

  void catat(Produk p, String jenis, int jumlah) {
    p.stok += jenis == 'Masuk' ? jumlah : -jumlah;
    final t = TimeOfDay.now();
    final waktu =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    riwayat.insert(0, Catatan(p.nama, jenis, jumlah, waktu));
    notifyListeners();
  }
}

final store = Store();

// ---------- App ----------
class StokApp extends StatelessWidget {
  const StokApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Stok Toko Maju',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: ink),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      );
}

// ---------- Login (simulasi) ----------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _sandi = TextEditingController();

  void _masuk() {
    if (!_form.currentState!.validate()) return;
    if (_email.text != 'kasir@tokomaju.id' || _sandi.text != 'kasir123') {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email atau kata sandi salah')));
      return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Stok Toko Maju',
                        style:
                            TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text('Akun demo: kasir@tokomaju.id / kasir123'),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Isi email dengan format nama@domain.com'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sandi,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Kata sandi', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Kata sandi minimal 6 karakter'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(onPressed: _masuk, child: const Text('Masuk')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

// ---------- Halaman utama ----------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final menipis = store.produk.where((p) => p.menipis).toList();
          return Scaffold(
            appBar: AppBar(
              title: const Text('Stok Toko Maju'),
              actions: [
                IconButton(
                  tooltip: 'Riwayat',
                  icon: const Icon(Icons.history),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RiwayatPage())),
                ),
                IconButton(
                  tooltip: 'Keluar',
                  icon: const Icon(Icons.logout),
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginPage())),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FormPage())),
              icon: const Icon(Icons.add),
              label: const Text('Catat stok'),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Row(children: [
                  _Ringkasan('Jenis produk', '${store.produk.length}'),
                  const SizedBox(width: 12),
                  _Ringkasan('Perlu restok', '${menipis.length}',
                      warna: menipis.isEmpty ? null : alertRed),
                ]),
                const SizedBox(height: 20),
                const Text('Semua produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                for (final p in store.produk)
                  Card(
                    color: p.menipis ? tagYellow : null,
                    child: ListTile(
                      title: Text(p.nama),
                      subtitle: Text(p.menipis
                          ? 'Perlu restok, minimum ${p.min}'
                          : 'Minimum ${p.min}'),
                      trailing: Text('${p.stok}',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                    ),
                  ),
              ],
            ),
          );
        },
      );
}

class _Ringkasan extends StatelessWidget {
  final String label, nilai;
  final Color? warna;
  const _Ringkasan(this.label, this.nilai, {this.warna});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label),
              Text(nilai,
                  style: TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800, color: warna)),
            ]),
          ),
        ),
      );
}

// ---------- Form input ----------
class FormPage extends StatefulWidget {
  const FormPage({super.key});
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _form = GlobalKey<FormState>();
  final _jumlah = TextEditingController();
  Produk? _produk;
  String _jenis = 'Masuk';

  void _simpan() {
    if (!_form.currentState!.validate()) return;
    store.catat(_produk!, _jenis, int.parse(_jumlah.text));
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Catatan tersimpan')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Catat stok')),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<Produk>(
                value: _produk,
                decoration: const InputDecoration(
                    labelText: 'Produk', border: OutlineInputBorder()),
                items: [
                  for (final p in store.produk)
                    DropdownMenuItem(value: p, child: Text(p.nama)),
                ],
                onChanged: (p) => setState(() => _produk = p),
                validator: (p) => p == null ? 'Pilih produk dulu' : null,
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Masuk', label: Text('Barang masuk')),
                  ButtonSegment(value: 'Keluar', label: Text('Barang keluar')),
                ],
                selected: {_jenis},
                onSelectionChanged: (s) => setState(() => _jenis = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlah,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Jumlah', border: OutlineInputBorder()),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Isi angka bulat lebih dari 0';
                  if (_jenis == 'Keluar' && _produk != null && n > _produk!.stok) {
                    return 'Stok hanya tersisa ${_produk!.stok}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _simpan, child: const Text('Simpan catatan')),
            ],
          ),
        ),
      );
}

// ---------- Halaman data hasil input ----------
class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Riwayat stok')),
        body: store.riwayat.isEmpty
            ? const Center(
                child: Text('Belum ada catatan. Ketuk "Catat stok" di beranda.'))
            : ListView(
                children: [
                  for (final c in store.riwayat)
                    ListTile(
                      leading: Icon(
                          c.jenis == 'Masuk' ? Icons.south_west : Icons.north_east,
                          color: c.jenis == 'Masuk' ? Colors.green : alertRed),
                      title: Text(c.produk),
                      subtitle: Text('${c.jenis} • ${c.waktu}'),
                      trailing: Text(
                          '${c.jenis == 'Masuk' ? '+' : '-'}${c.jumlah}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
      );
}
