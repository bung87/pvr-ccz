A library for Dart developers.

decode `pvr.ccz` to `Image`.  

`pubspec.yaml`  

```
dependencies:
  pvr_ccz:
    git:
      url: git://github.com/bung87/pvr-ccz.git
```
## Usage

A simple usage example:

```dart
import 'package:pvr_ccz/pvr_ccz.dart';

main() {
  var filename = "your.pvr.ccz";
  var image = decodePvrCczSync(filename);
}
```

## Todo 

* decript encoded pvr

## References

pvrt:  
[cruiseliu/jn-decoder](https://github.com/cruiseliu/jn-decoder)  
[pvrt-header](https://github.com/nickworonekin/puyotools/wiki/PVR-Texture#pvrt-header)  
pvr:  
[cocos-creator/cocos2d-x-lite](https://github.com/cocos-creator/cocos2d-x-lite/)  
[PVR File Format Specification](http://cdn.imgtec.com/sdk-documentation/PVR+File+Format.Specification.pdf)
