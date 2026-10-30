import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/core/util/emoji.dart';

void main() {
  test('zakupy: typowe produkty dostają emoji', () {
    expect(emojiFor('Mleko 3,2%'), '🥛');
    expect(emojiFor('chleb żytni'), '🍞');
    expect(emojiFor('Jajka 10 szt'), '🥚');
    expect(emojiFor('Pomidory'), '🍅');
    expect(emojiFor('Banany'), '🍌');
    expect(emojiFor('Papier toaletowy'), '🧻');
  });

  test('obowiązki i wydarzenia', () {
    expect(emojiFor('Wynieść śmieci', fallback: emojiChore), '🗑️');
    expect(emojiFor('Odkurzanie salonu', fallback: emojiChore), '🧹');
    expect(emojiFor('Podlać kwiaty', fallback: emojiChore), '🪴');
    expect(emojiFor('Wizyta u lekarza', fallback: emojiEvent), '❤️');
    expect(emojiFor('Urodziny Ani', fallback: emojiEvent), '🎂');
  });

  test('brak dopasowania daje emoji domyślne', () {
    expect(emojiFor('Xyzzy', fallback: emojiChore), emojiChore);
    expect(emojiFor(''), emojiOther);
  });

  test('wielkość liter nie ma znaczenia', () {
    expect(emojiFor('MLEKO'), '🥛');
  });
}
