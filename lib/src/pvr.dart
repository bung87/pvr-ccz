import 'dart:typed_data'; 
class Pvr{
  Pvr(Uint8List data,int len){

  }
  // Image _img; 
  bool valid(){}
  // bool valid => _img != null;

}

class PvrHeader {
    BigInt hdr_size;
    BigInt h;
    BigInt w;
    BigInt mipmap_cnt;
    BigInt format_flags;
    BigInt surface_size;
    BigInt pixel_bits;
    BigInt r_mask;
    BigInt g_mask;
    BigInt b_mask;
    BigInt a_mask;
    BigInt magic;
    BigInt surface_cnt;

  
    BigInt format()  { return format_flags & BigInt.from(0xff); }
    BigInt flags()  { return format_flags & BigInt.from(0xffffff00); }

    bool valid(){
      if (hdr_size != BigInt.from(52)) return false;

      if (mipmap_cnt != BigInt.from(0)) return false;
      if (format() != BigInt.from(0x12)) return false;
      if (flags() != BigInt.from(0x8000)) return false;

      if (surface_size != w * h * BigInt.from(4)) return false;
      if (pixel_bits != BigInt.from(32)) return false;

      if (r_mask != BigInt.from(0x000000ff)) return false;
      if (g_mask != BigInt.from(0x0000ff00)) return false;
      if (b_mask != BigInt.from(0x00ff0000)) return false;
      if (a_mask != BigInt.from(0xff000000)) return false;
      
      if (magic != BigInt.from(0x21525650)) return false;
      if (surface_cnt != BigInt.from(1)) return false;

      return true;
    }
}
