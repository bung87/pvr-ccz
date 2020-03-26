import 'package:pvr_ccz/pvr_ccz.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('A group of tests', () {
    test('First Test', () {
      var bytes = inflateCCZFile(p.join( p.current, 'test' ,'SmlMap0.pvr.ccz'));
      expect(bytes, isList);
    });
  });
}
