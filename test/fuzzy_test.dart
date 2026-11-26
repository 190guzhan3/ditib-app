import 'package:flutter_test/flutter_test.dart';
import 'package:moschee_app/shared/fuzzy.dart';

void main() {
  test('searchKey entfernt Groß/klein und Akzente', () {
    expect(searchKey('  Çanakkale '), 'canakkale');
    expect(searchKey('Straße'), 'strasse');
    expect(searchKey('Şanlıurfa'), 'sanliurfa');
  });

  test('fuzzyScore: genau, Wortanfang, Tippfehler, kein Treffer', () {
    expect(fuzzyScore('berlin', 'Berlin'), 3);
    expect(fuzzyScore('main', 'Frankfurt am Main'), 2.5);
    expect(fuzzyScore('frank main', 'Frankfurt am Main'), 2);
    expect(fuzzyScore('munchn', 'München'), 1);
    expect(fuzzyScore('hamburg', 'Bremen'), 0);
    expect(fuzzyScore('', 'Bremen'), 0);
  });
}
