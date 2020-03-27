import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'dart:async';

class UnsupportedCCZHeader implements Exception {
  final String message = 'Unsupported CCZ header format';
}

class UnsupportedCCZCompression implements Exception {
  final String message = 'Unsupported CCZ compression method';
}

class InvalidCCZFile implements Exception {
  final String message = 'Invalid CCZ file';
}

class _CompressType {
  static const zlib = 0;
  static const bzip2 = 1;
  static const gzip = 2;
}

class _Header {
  String sig; // Signature. Should be 'CCZ!' 4 bytes.
  int compression_type; // unsigned short 2 bytes, Should be 0.
  int version; // unsigned short 2 bytes, Should be 2 (although version type==1 is also supported)
  int reserved; // uint 4 bytes
  int len; //uint 4bytes
  static const size = 16; // total: 16 bytes
  static _Header fromBytes(Uint8List bytes) {
    return fromBuffer(bytes.buffer);
  }

  static _Header fromBuffer(ByteBuffer buffer) {
    var h = _Header();
    var sig = Uint8List.view(buffer, 0, 4);
    h.sig = String.fromCharCodes(sig);
    h.compression_type = ByteData.view(buffer, 4, 2).getUint16(0, Endian.big);
    h.version = ByteData.view(buffer, 6, 2).getUint16(0, Endian.big);
    h.len = ByteData.view(buffer, 12, 4).getUint32(0, Endian.big);
    h.reserved = ByteData.view(buffer, 8, 4).getUint32(0, Endian.big);

    return h;
  }

  @override
  String toString() {
    return {
      'sig': sig,
      'version': version,
      'len': len,
      'compression_type': compression_type,
      'reserved': reserved
    }.toString();
  }
}

List<int> inflateCCZBuffer(ByteBuffer buffer) {
  var header = _Header.fromBuffer(buffer);
  if (header.sig == 'CCZ!') {
    if (header.version > 2) {
      throw UnsupportedCCZHeader();
    }
    if (header.compression_type != _CompressType.zlib) {
      throw UnsupportedCCZCompression();
    }
  } else if (header.sig == 'CCZp') {
    // TODO decript encoded pvr
    throw UnimplementedError();
  } else {
    throw InvalidCCZFile();
  }

  var pvr_data = zlib.decode(Uint8List.view(buffer, _Header.size));
  return pvr_data;
}

List<int> inflateCCZFileSync(String filename) {
  var file = File(filename);
  var bytes = file.readAsBytesSync();
  return inflateCCZBuffer(bytes.buffer);
}

Future<List<int>> inflateCCZFile(String filename) async {
  var file = File(filename);
  var bytes = await file.readAsBytes();
  return inflateCCZBuffer(bytes.buffer);
}

Image decodePvrCczSync(String filename) {
  var pvr_data = inflateCCZFileSync(filename);
  return PvrtcDecoder().decodePvr(pvr_data);
}

Future<Image> decodePvrCcz(String filename) async {
  var pvr_data = await inflateCCZFile(filename);
  return PvrtcDecoder().decodePvr(pvr_data);
}

Future<Uint8List> toPngBytes(dynamic filenameOrByteData) async {
  var pvr_data;
  if (filenameOrByteData is String) {
    pvr_data = pvr_data = await inflateCCZFile(filenameOrByteData);
  } else {
    pvr_data = inflateCCZBuffer(filenameOrByteData.buffer);
  }
  var img = PvrtcDecoder().decodePvr(pvr_data);
  return imageAsPngUintList(img);
}

Uint8List toPngBytesSync(dynamic filenameOrByteData) {
  var pvr_data;
  if (filenameOrByteData is String) {
    pvr_data = inflateCCZFileSync(filenameOrByteData);
  } else {
    pvr_data = inflateCCZBuffer(filenameOrByteData.buffer);
  }
  var img = PvrtcDecoder().decodePvr(pvr_data);
  return imageAsPngUintList(img);
}

/// work with Flame.bundle.load the bundle type is flutter's AssetBundle
Image decodePvrCczWithByteData(ByteData data) {
  var pvr_data = inflateCCZBuffer(data.buffer);
  return PvrtcDecoder().decodePvr(pvr_data);
}

Uint8List imageAsPngUintList(Image image) {
  var bb = BytesBuilder();
  bb.add(encodePng(image));
  return bb.takeBytes();
}

// extension Image2PngUint8List on Image{
//   /// encode as png ,then call dart:ui's decodeImageFromList convert to dart:ui's Image
//   Uint8List asPngUintList(){
//     var bb = BytesBuilder();
//     bb.add(encodePng(this));
//     return bb.takeBytes();
//   }
// }

// typed_data
// https://api.dart.dev/stable/2.7.2/dart-typed_data/dart-typed_data-library.html

// GZipCodec
// https://api.dart.dev/stable/2.7.2/dart-io/GZipCodec-class.html

// BytesBuilder
// https://api.dart.dev/stable/2.7.2/dart-io/BytesBuilder-class.html

// ZLibCodec()
// https://api.dart.dev/stable/2.7.2/dart-io/ZLibCodec-class.html
