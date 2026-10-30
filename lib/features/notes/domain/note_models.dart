class Note {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.pinned,
    required this.updatedAt,
    required this.isPrivate,
    this.createdBy,
  });

  final String id;
  final String title;
  final String body;
  final bool pinned;
  final DateTime updatedAt;

  /// Prywatna leży w `users/{uid}/privateNotes`, wspólna w `households/{hid}/notes`.
  final bool isPrivate;

  /// Autor; tylko dla wspólnych.
  final String? createdBy;

  /// Tytuł do pokazania: pierwszy wiersz treści, gdy tytułu brak.
  String get displayTitle {
    if (title.trim().isNotEmpty) return title.trim();
    final firstLine = body.trim().split('\n').first.trim();
    return firstLine;
  }

  bool get isEmpty => title.trim().isEmpty && body.trim().isEmpty;

  Note copyWith({String? title, String? body, bool? pinned, bool? isPrivate}) => Note(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
        pinned: pinned ?? this.pinned,
        updatedAt: updatedAt,
        isPrivate: isPrivate ?? this.isPrivate,
        createdBy: createdBy,
      );
}

enum NotesFilter { all, shared, mine }

/// Przypięte pierwsze, potem od ostatnio zmienionej.
List<Note> sortNotes(List<Note> notes) {
  final sorted = List.of(notes)
    ..sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
  return sorted;
}

/// Filtr zakładki i wyszukiwanie po tytule i treści (bez rozróżniania wielkości liter).
List<Note> filterNotes(List<Note> notes, {required NotesFilter filter, String query = ''}) {
  final q = query.trim().toLowerCase();
  return sortNotes(notes.where((n) {
    final byFilter = switch (filter) {
      NotesFilter.all => true,
      NotesFilter.shared => !n.isPrivate,
      NotesFilter.mine => n.isPrivate,
    };
    if (!byFilter) return false;
    if (q.isEmpty) return true;
    return n.title.toLowerCase().contains(q) || n.body.toLowerCase().contains(q);
  }).toList());
}
