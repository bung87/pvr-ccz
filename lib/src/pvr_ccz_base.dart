import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';

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

List<int> inflateCCZFile(String filename) {
  var file = File(filename);
  var bytes = file.readAsBytesSync();
  return inflateCCZBuffer(bytes.buffer);
}

Image decodeCCZ(String filename){
  var pvr_data = inflateCCZFile(filename);
  return PvrtcDecoder().decodePvr(pvr_data);
}



// typed_data
// https://api.dart.dev/stable/2.7.2/dart-typed_data/dart-typed_data-library.html

// GZipCodec
// https://api.dart.dev/stable/2.7.2/dart-io/GZipCodec-class.html

// BytesBuilder
// https://api.dart.dev/stable/2.7.2/dart-io/BytesBuilder-class.html

// ZLibCodec()
// https://api.dart.dev/stable/2.7.2/dart-io/ZLibCodec-class.html
