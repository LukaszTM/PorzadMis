import 'package:flutter_test/flutter_test.dart';
import 'package:porzadmis/features/notes/domain/note_models.dart';

Note n(String id, {String title = '', String body = '', bool pinned = false, bool private = false, int day = 1}) =>
    Note(
      id: id,
      title: title,
      body: body,
      pinned: pinned,
      updatedAt: DateTime(2026, 11, day),
      isPrivate: private,
      createdBy: private ? null : 'u1',
    );

void main() {
  final notes = [
    n('a', title: 'Zakupy na święta', day: 1),
    n('b', body: 'Zadzwonić do babci', day: 5, private: true),
    n('c', title: 'Przepis', body: 'mąka, jajka', pinned: true, day: 2),
    n('d', title: 'Wakacje', day: 4),
  ];

  test('sortNotes: przypięte pierwsze, potem od ostatnio zmienionej', () {
    expect(sortNotes(notes).map((x) => x.id), ['c', 'b', 'd', 'a']);
  });

  test('filterNotes: zakładki Wspólne / Tylko moje', () {
    expect(filterNotes(notes, filter: NotesFilter.shared).map((x) => x.id), ['c', 'd', 'a']);
    expect(filterNotes(notes, filter: NotesFilter.mine).map((x) => x.id), ['b']);
  });

  test('filterNotes: szukanie po tytule i treści, bez rozróżniania wielkości liter', () {
    expect(filterNotes(notes, filter: NotesFilter.all, query: 'BABCI').map((x) => x.id), ['b']);
    expect(filterNotes(notes, filter: NotesFilter.all, query: 'jajka').map((x) => x.id), ['c']);
    expect(filterNotes(notes, filter: NotesFilter.all, query: 'xyz'), isEmpty);
  });

  test('displayTitle: tytuł albo pierwszy wiersz treści; isEmpty dla pustej', () {
    expect(n('x', body: 'pierwszy\ndrugi').displayTitle, 'pierwszy');
    expect(n('x', title: ' T ').displayTitle, 'T');
    expect(n('x').isEmpty, isTrue);
    expect(n('x', body: ' ').isEmpty, isTrue);
  });
}
