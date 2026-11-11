import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Secure authenticated encryption (AES-256-CTR + HMAC-SHA256 + PBKDF2)
/// for Soul State backups and S3 cloud storage.
class BackupCrypto {
  const BackupCrypto._();

  static const List<int> magicHeader = [0x53, 0x53, 0x45, 0x4E, 0x43, 0x31]; // 'SSENC1'
  static const int saltLength = 16;
  static const int ivLength = 16;
  static const int macLength = 32;
  static const int pbkdf2Rounds = 10000;

  /// Returns true if the given data starts with the encryption magic header.
  static bool isEncrypted(List<int> bytes) {
    if (bytes.length < magicHeader.length + saltLength + ivLength + macLength) {
      return false;
    }
    for (var i = 0; i < magicHeader.length; i++) {
      if (bytes[i] != magicHeader[i]) return false;
    }
    return true;
  }

  /// Encrypts plaintext bytes using a password.
  static Uint8List encrypt(List<int> plainBytes, String password) {
    if (password.isEmpty) {
      throw ArgumentError('Encryption password cannot be empty');
    }

    final rand = Random.secure();
    final salt = Uint8List(saltLength);
    final iv = Uint8List(ivLength);
    for (var i = 0; i < saltLength; i++) {
      salt[i] = rand.nextInt(256);
    }
    for (var i = 0; i < ivLength; i++) {
      iv[i] = rand.nextInt(256);
    }

    // Derive 64 bytes: 32 bytes AES key, 32 bytes HMAC key
    final derived = _pbkdf2(utf8.encode(password), salt, pbkdf2Rounds, 64);
    final encKey = derived.sublist(0, 32);
    final macKey = derived.sublist(32, 64);

    // AES-256-CTR encryption
    final ciphertext = _aesCtr(Uint8List.fromList(plainBytes), encKey, iv);

    // Compute HMAC-SHA256 over magic + salt + iv + ciphertext
    final payloadToSign = Uint8List(magicHeader.length + saltLength + ivLength + ciphertext.length);
    payloadToSign.setAll(0, magicHeader);
    payloadToSign.setAll(magicHeader.length, salt);
    payloadToSign.setAll(magicHeader.length + saltLength, iv);
    payloadToSign.setAll(magicHeader.length + saltLength + ivLength, ciphertext);

    final hmac = Hmac(sha256, macKey);
    final mac = hmac.convert(payloadToSign).bytes;

    final result = Uint8List(payloadToSign.length + macLength);
    result.setAll(0, payloadToSign);
    result.setAll(payloadToSign.length, mac);
    return result;
  }

  /// Decrypts bytes using a password.
  /// If the data is not encrypted (plain zip/json), returns the input bytes as-is.
  static Uint8List decrypt(List<int> encryptedBytes, String password) {
    if (!isEncrypted(encryptedBytes)) {
      return Uint8List.fromList(encryptedBytes);
    }

    if (password.isEmpty) {
      throw const FormatException('Password is required to decrypt this backup');
    }

    final minLen = magicHeader.length + saltLength + ivLength + macLength;
    if (encryptedBytes.length < minLen) {
      throw const FormatException('Corrupted encrypted backup: file is too small');
    }

    var offset = magicHeader.length;
    final salt = Uint8List.fromList(encryptedBytes.sublist(offset, offset + saltLength));
    offset += saltLength;
    final iv = Uint8List.fromList(encryptedBytes.sublist(offset, offset + ivLength));
    offset += ivLength;

    final cipherEnd = encryptedBytes.length - macLength;
    final ciphertext = Uint8List.fromList(encryptedBytes.sublist(offset, cipherEnd));
    final expectedMac = encryptedBytes.sublist(cipherEnd);

    // Derive keys
    final derived = _pbkdf2(utf8.encode(password), salt, pbkdf2Rounds, 64);
    final encKey = derived.sublist(0, 32);
    final macKey = derived.sublist(32, 64);

    // Verify HMAC
    final payloadToSign = encryptedBytes.sublist(0, cipherEnd);
    final computedMac = Hmac(sha256, macKey).convert(payloadToSign).bytes;

    if (!_constantTimeEqual(expectedMac, computedMac)) {
      throw const FormatException('Invalid password or corrupted backup');
    }

    // AES-256-CTR decryption (CTR mode is symmetric)
    return _aesCtr(ciphertext, encKey, iv);
  }

  static bool _constantTimeEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  /// PBKDF2-HMAC-SHA256 key derivation.
  static Uint8List _pbkdf2(List<int> password, List<int> salt, int iterations, int keyLen) {
    final hmac = Hmac(sha256, password);
    final numBlocks = (keyLen + 31) ~/ 32;
    final out = Uint8List(numBlocks * 32);

    for (var block = 1; block <= numBlocks; block++) {
      // U_1 = HMAC(password, salt || INT(block))
      final saltBlock = Uint8List(salt.length + 4);
      saltBlock.setAll(0, salt);
      saltBlock[salt.length] = (block >> 24) & 0xff;
      saltBlock[salt.length + 1] = (block >> 16) & 0xff;
      saltBlock[salt.length + 2] = (block >> 8) & 0xff;
      saltBlock[salt.length + 3] = block & 0xff;

      var u = hmac.convert(saltBlock).bytes;
      final t = Uint8List.fromList(u);

      for (var iter = 1; iter < iterations; iter++) {
        u = hmac.convert(u).bytes;
        for (var i = 0; i < 32; i++) {
          t[i] ^= u[i];
        }
      }

      out.setAll((block - 1) * 32, t);
    }

    return out.sublist(0, keyLen);
  }

  /// AES-256-CTR stream cipher.
  static Uint8List _aesCtr(Uint8List data, Uint8List key, Uint8List iv) {
    final cipher = _AesCore(key);
    final output = Uint8List(data.length);
    final counter = Uint8List.fromList(iv);
    final streamBlock = Uint8List(16);

    for (var i = 0; i < data.length; i += 16) {
      cipher.encryptBlock(counter, streamBlock);
      final blockSize = min(16, data.length - i);
      for (var j = 0; j < blockSize; j++) {
        output[i + j] = data[i + j] ^ streamBlock[j];
      }
      _incrementCounter(counter);
    }

    return output;
  }

  static void _incrementCounter(Uint8List counter) {
    for (var i = 15; i >= 0; i--) {
      counter[i] = (counter[i] + 1) & 0xff;
      if (counter[i] != 0) break;
    }
  }
}

/// Minimal, high-performance AES core (supports 128, 192, and 256-bit keys).
class _AesCore {
  _AesCore(Uint8List key) {
    _expandKey(key);
  }

  late final Uint32List _expandedKey;
  late final int _rounds;

  static const List<int> _sBox = [
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16,
  ];

  static const List<int> _rCon = [
    0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36,
  ];

  static int _xt(int x) => ((x << 1) ^ (((x >> 7) & 1) * 0x11b)) & 0xff;

  void _expandKey(Uint8List key) {
    final nk = key.length ~/ 4; // 8 for 256-bit
    _rounds = nk + 6; // 14 for 256-bit
    _expandedKey = Uint32List(4 * (_rounds + 1));

    for (var i = 0; i < nk; i++) {
      _expandedKey[i] = (key[4 * i] << 24) |
          (key[4 * i + 1] << 16) |
          (key[4 * i + 2] << 8) |
          key[4 * i + 3];
    }

    for (var i = nk; i < 4 * (_rounds + 1); i++) {
      var temp = _expandedKey[i - 1];
      if (i % nk == 0) {
        // RotWord & SubWord & Rcon
        temp = ((_sBox[(temp >> 16) & 0xff] << 24) |
                (_sBox[(temp >> 8) & 0xff] << 16) |
                (_sBox[temp & 0xff] << 8) |
                _sBox[(temp >> 24) & 0xff]) ^
            (_rCon[i ~/ nk] << 24);
      } else if (nk > 6 && i % nk == 4) {
        // SubWord for 256-bit
        temp = (_sBox[(temp >> 24) & 0xff] << 24) |
            (_sBox[(temp >> 16) & 0xff] << 16) |
            (_sBox[(temp >> 8) & 0xff] << 8) |
            _sBox[temp & 0xff];
      }
      _expandedKey[i] = _expandedKey[i - nk] ^ temp;
    }
  }

  void encryptBlock(Uint8List input, Uint8List output) {
    var s0 = input[0];
    var s1 = input[1];
    var s2 = input[2];
    var s3 = input[3];
    var s4 = input[4];
    var s5 = input[5];
    var s6 = input[6];
    var s7 = input[7];
    var s8 = input[8];
    var s9 = input[9];
    var s10 = input[10];
    var s11 = input[11];
    var s12 = input[12];
    var s13 = input[13];
    var s14 = input[14];
    var s15 = input[15];

    // Initial round key
    s0 ^= (_expandedKey[0] >> 24) & 0xff;
    s1 ^= (_expandedKey[0] >> 16) & 0xff;
    s2 ^= (_expandedKey[0] >> 8) & 0xff;
    s3 ^= _expandedKey[0] & 0xff;

    s4 ^= (_expandedKey[1] >> 24) & 0xff;
    s5 ^= (_expandedKey[1] >> 16) & 0xff;
    s6 ^= (_expandedKey[1] >> 8) & 0xff;
    s7 ^= _expandedKey[1] & 0xff;

    s8 ^= (_expandedKey[2] >> 24) & 0xff;
    s9 ^= (_expandedKey[2] >> 16) & 0xff;
    s10 ^= (_expandedKey[2] >> 8) & 0xff;
    s11 ^= _expandedKey[2] & 0xff;

    s12 ^= (_expandedKey[3] >> 24) & 0xff;
    s13 ^= (_expandedKey[3] >> 16) & 0xff;
    s14 ^= (_expandedKey[3] >> 8) & 0xff;
    s15 ^= _expandedKey[3] & 0xff;

    for (var r = 1; r < _rounds; r++) {
      // SubBytes & ShiftRows
      final b0 = _sBox[s0];
      final b1 = _sBox[s5];
      final b2 = _sBox[s10];
      final b3 = _sBox[s15];

      final b4 = _sBox[s4];
      final b5 = _sBox[s9];
      final b6 = _sBox[s14];
      final b7 = _sBox[s3];

      final b8 = _sBox[s8];
      final b9 = _sBox[s13];
      final b10 = _sBox[s2];
      final b11 = _sBox[s7];

      final b12 = _sBox[s12];
      final b13 = _sBox[s1];
      final b14 = _sBox[s6];
      final b15 = _sBox[s11];

      // MixColumns
      final k0 = _expandedKey[4 * r];
      final k1 = _expandedKey[4 * r + 1];
      final k2 = _expandedKey[4 * r + 2];
      final k3 = _expandedKey[4 * r + 3];

      s0 = _xt(b0 ^ b1) ^ b1 ^ b2 ^ b3 ^ ((k0 >> 24) & 0xff);
      s1 = _xt(b1 ^ b2) ^ b2 ^ b3 ^ b0 ^ ((k0 >> 16) & 0xff);
      s2 = _xt(b2 ^ b3) ^ b3 ^ b0 ^ b1 ^ ((k0 >> 8) & 0xff);
      s3 = _xt(b3 ^ b0) ^ b0 ^ b1 ^ b2 ^ (k0 & 0xff);

      s4 = _xt(b4 ^ b5) ^ b5 ^ b6 ^ b7 ^ ((k1 >> 24) & 0xff);
      s5 = _xt(b5 ^ b6) ^ b6 ^ b7 ^ b4 ^ ((k1 >> 16) & 0xff);
      s6 = _xt(b6 ^ b7) ^ b7 ^ b4 ^ b5 ^ ((k1 >> 8) & 0xff);
      s7 = _xt(b7 ^ b4) ^ b4 ^ b5 ^ b6 ^ (k1 & 0xff);

      s8 = _xt(b8 ^ b9) ^ b9 ^ b10 ^ b11 ^ ((k2 >> 24) & 0xff);
      s9 = _xt(b9 ^ b10) ^ b10 ^ b11 ^ b8 ^ ((k2 >> 16) & 0xff);
      s10 = _xt(b10 ^ b11) ^ b11 ^ b8 ^ b9 ^ ((k2 >> 8) & 0xff);
      s11 = _xt(b11 ^ b8) ^ b8 ^ b9 ^ b10 ^ (k2 & 0xff);

      s12 = _xt(b12 ^ b13) ^ b13 ^ b14 ^ b15 ^ ((k3 >> 24) & 0xff);
      s13 = _xt(b13 ^ b14) ^ b14 ^ b15 ^ b12 ^ ((k3 >> 16) & 0xff);
      s14 = _xt(b14 ^ b15) ^ b15 ^ b12 ^ b13 ^ ((k3 >> 8) & 0xff);
      s15 = _xt(b15 ^ b12) ^ b12 ^ b13 ^ b14 ^ (k3 & 0xff);
    }

    // Final round (no MixColumns)
    final k0 = _expandedKey[4 * _rounds];
    final k1 = _expandedKey[4 * _rounds + 1];
    final k2 = _expandedKey[4 * _rounds + 2];
    final k3 = _expandedKey[4 * _rounds + 3];

    output[0] = _sBox[s0] ^ ((k0 >> 24) & 0xff);
    output[1] = _sBox[s5] ^ ((k0 >> 16) & 0xff);
    output[2] = _sBox[s10] ^ ((k0 >> 8) & 0xff);
    output[3] = _sBox[s15] ^ (k0 & 0xff);

    output[4] = _sBox[s4] ^ ((k1 >> 24) & 0xff);
    output[5] = _sBox[s9] ^ ((k1 >> 16) & 0xff);
    output[6] = _sBox[s14] ^ ((k1 >> 8) & 0xff);
    output[7] = _sBox[s3] ^ (k1 & 0xff);

    output[8] = _sBox[s8] ^ ((k2 >> 24) & 0xff);
    output[9] = _sBox[s13] ^ ((k2 >> 16) & 0xff);
    output[10] = _sBox[s2] ^ ((k2 >> 8) & 0xff);
    output[11] = _sBox[s7] ^ (k2 & 0xff);

    output[12] = _sBox[s12] ^ ((k3 >> 24) & 0xff);
    output[13] = _sBox[s1] ^ ((k3 >> 16) & 0xff);
    output[14] = _sBox[s6] ^ ((k3 >> 8) & 0xff);
    output[15] = _sBox[s11] ^ (k3 & 0xff);
  }
}
