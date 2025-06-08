class User {
  final int? id;
  final String namaLengkap;
  final String email;
  final String password;
  final String alamat;
  final String noTelepon;
  final String role;
  final String? gambar;

  User({
    this.id,
    required this.namaLengkap,
    required this.email,
    required this.password,
    required this.alamat,
    required this.noTelepon,
    this.role = 'user',
    this.gambar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'email': email,
      'password': password,
      'alamat': alamat,
      'no_telepon': noTelepon,
      'role': role,
      'gambar': gambar,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      namaLengkap: map['nama_lengkap'],
      email: map['email'],
      password: map['password'],
      alamat: map['alamat'],
      noTelepon: map['no_telepon'],
      role: map['role'] ?? 'user',
      gambar: map['gambar'],
    );
  }
}

class Mobil {
  final int? id;
  final String nama;
  final String merek;
  final String tahunProduksi;
  final String harga;

  Mobil({
    this.id,
    required this.nama,
    required this.merek,
    required this.tahunProduksi,
    required this.harga,
  });

  factory Mobil.fromJson(Map<String, dynamic> json) {
    return Mobil(
      id: json['id'],
      nama: json['nama'],
      merek: json['merek'],
      tahunProduksi: json['tahun_produksi'],
      harga: json['harga'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'merek': merek,
      'tahun_produksi': tahunProduksi,
      'harga': harga,
    };
  }
}

class Order {
  final int? id;
  final int userId;
  final int mobilId;
  final String metodePembayaran;
  final String tanggalPesan;

  Order({
    this.id,
    required this.userId,
    required this.mobilId,
    required this.metodePembayaran,
    required this.tanggalPesan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'mobil_id': mobilId,
      'metode_pembayaran': metodePembayaran,
      'tanggal_pesan': tanggalPesan,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['user_id'],
      mobilId: map['mobil_id'],
      metodePembayaran: map['metode_pembayaran'],
      tanggalPesan: map['tanggal_pesan'],
    );
  }
}
