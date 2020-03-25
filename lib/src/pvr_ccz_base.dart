import 'dart:io';
import 'dart:typed_data'; 
import './pvr.dart';
//https://api.dart.dev/stable/2.7.2/dart-typed_data/dart-typed_data-library.html
//https://api.dart.dev/stable/2.7.2/dart-io/GZipCodec-class.html
// GZipCodec
// // https://api.dart.dev/stable/2.7.2/dart-io/BytesBuilder-class.html
// BytesBuilder
// // https://api.dart.dev/stable/2.7.2/dart-io/ZLibCodec-class.html
// ZLibCodec()

class _CompressType{
   static const zlib = 0;
   static const bzip2 = 1;
   static const gzip = 2;
}

int _switchEndian(int x) {
  // uint16
  var b0 = x & 0xff;
  var b1 = (x >> 8) & 0xff;
  return (b0 << 8) | b1;
}

BigInt _switchEndianBigInt(BigInt x) {
  var b0 = x & BigInt.from(0xff);
  var b1 = (x >> 8) & BigInt.from(0xff);
  var b2 = (x >> 16) & BigInt.from(0xff);
  var b3 = (x >> 24) & BigInt.from(0xff);
  return (b0 << 24) | (b1 << 16) | (b2 << 8) | b3;
}

class _Header {
  BigInt _size;
  int version() {
    return _switchEndian(ver);
  } // uint16

  int compression_type() {
    return _switchEndian(comp_type);
  } //uint16

  bool valid() {
    if (magic != BigInt.from(0x215a4343)) return false;
    if (compression_type() != _CompressType.zlib) return false;
    if (version() != 1 && version() != 2) return false;
    return true;
  }

  BigInt size() => _switchEndianBigInt(_size);
  BigInt magic;
  int comp_type;
  int ver;
  BigInt reserve;
}

class Ccz{
  Pvr _pvr;
  Ccz(Uint8List data){

  }
  bool valid() => _pvr !=null && _pvr.valid();

}
