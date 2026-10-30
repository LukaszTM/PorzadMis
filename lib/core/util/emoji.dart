/// Emoji dopasowane po słowach kluczowych (po polsku, po rdzeniach), żeby pozycje list
/// miały obrazek bez osobnych plików. Gdy nic nie pasuje, zwraca [fallback].
String emojiFor(String text, {String fallback = '🛒'}) {
  final t = text.toLowerCase();
  for (final entry in _rules) {
    if (entry.keys.any(t.contains)) return entry.emoji;
  }
  return fallback;
}

/// Domyślne emoji działu sklepowego i modułu.
const emojiProduce = '🥬';
const emojiBakery = '🍞';
const emojiDairy = '🧀';
const emojiMeat = '🥩';
const emojiDrinks = '🧃';
const emojiHousehold = '🧴';
const emojiOther = '🛒';
const emojiChore = '🧹';
const emojiEvent = '📅';

class _Rule {
  const _Rule(this.emoji, this.keys);

  final String emoji;
  final List<String> keys;
}

const _rules = <_Rule>[
  // Zakupy
  _Rule('🥛', ['mlek']),
  _Rule('🍞', ['chleb', 'bułk', 'piecz', 'bagiet']),
  _Rule('🥚', ['jaj']),
  _Rule('🍅', ['pomidor']),
  _Rule('🧀', ['ser ', 'ser', 'żółty']),
  _Rule('🥬', ['sałat', 'kapust', 'szpinak']),
  _Rule('🥣', ['jogurt', 'kefir', 'płatk']),
  _Rule('🍌', ['banan']),
  _Rule('🍎', ['jabł']),
  _Rule('🥕', ['marchew']),
  _Rule('🧅', ['cebul', 'czosn']),
  _Rule('🥔', ['ziemniak', 'kartofl']),
  _Rule('🍗', ['kurczak', 'drób', 'piersi']),
  _Rule('🥩', ['mięs', 'wołow', 'wieprz', 'schab', 'kiełbas', 'szynk']),
  _Rule('🐟', ['ryb', 'łosoś', 'tuńczyk']),
  _Rule('🧈', ['masł']),
  _Rule('🍚', ['ryż', 'kasz', 'makaron']),
  _Rule('🧂', ['sól', 'pieprz', 'przypraw']),
  _Rule('☕', ['kaw', 'herbat']),
  _Rule('🧃', ['sok', 'napój', 'woda', 'cola']),
  _Rule('🍫', ['czekolad', 'słodycz', 'ciast', 'cukier']),
  _Rule('🧻', ['papier toalet', 'ręcznik', 'chusteczk']),
  _Rule('🧴', ['płyn', 'szampon', 'mydł', 'żel', 'proszek', 'detergent']),
  _Rule('🧽', ['gąbk', 'ścierk']),
  _Rule('💊', ['lek ', 'leki', 'tablet', 'witamin', 'aptek']),
  _Rule('🐾', ['karm', 'pies', 'kot ', 'dla kota', 'dla psa']),
  _Rule('👶', ['pieluch', 'dzieck']),
  // Obowiązki
  _Rule('🗑️', ['śmie', 'kosz']),
  _Rule('🧹', ['odkurz', 'zamie', 'sprząt', 'porządk']),
  _Rule('🪴', ['kwiat', 'roślin', 'podle', 'ogr']),
  _Rule('🧺', ['pran', 'ubran', 'pościel', 'prasow']),
  _Rule('🍽️', ['zmywa', 'naczyn', 'obiad', 'kolac', 'gotow', 'śniadan']),
  _Rule('🛁', ['łazienk', 'wann', 'prysznic', 'toalet']),
  _Rule('🚗', ['samoch', 'auto', 'paliw', 'tankow']),
  _Rule('🛒', ['zakup', 'sklep', 'biedronk', 'lidl']),
  _Rule('🧼', ['umy', 'okn', 'podłog']),
  _Rule('📦', ['garaż', 'piwnic', 'paczk', 'przesył']),
  _Rule('💡', ['rachun', 'prąd', 'gaz', 'opłat', 'czynsz']),
  // Wydarzenia
  _Rule('❤️', ['lekarz', 'dentyst', 'przychodn', 'wizyt', 'szpital']),
  _Rule('🎂', ['urodzin', 'imienin', 'rocznic']),
  _Rule('👨‍👩‍👧', ['rodzin', 'rodzic', 'babci', 'dziadk']),
  _Rule('🏫', ['szkoł', 'przedszkol', 'wywiadówk', 'zebran']),
  _Rule('🎬', ['kino', 'film', 'teatr', 'koncert']),
  _Rule('⚽', ['trening', 'mecz', 'siłown', 'basen', 'bieg']),
  _Rule('✈️', ['wakacj', 'wyjazd', 'lot', 'podróż', 'urlop']),
  _Rule('📚', ['książk', 'nauk', 'egzamin', 'kurs']),
  _Rule('⭐', ['czas dla', 'relaks', 'spacer']),
];

/// Nazwa mini-ikony z paczki widżetów (drawable `mi_<nazwa>`) albo pusty tekst.
String miniIconFor(String text) {
  final t = text.toLowerCase();
  for (final entry in _miniIcons) {
    if (entry.keys.any(t.contains)) return entry.name;
  }
  return '';
}

class _MiniIcon {
  const _MiniIcon(this.name, this.keys);

  final String name;
  final List<String> keys;
}

const _miniIcons = <_MiniIcon>[
  _MiniIcon('milk', ['mlek']),
  _MiniIcon('bread', ['chleb', 'bułk', 'piecz']),
  _MiniIcon('eggs', ['jaj']),
  _MiniIcon('tomato', ['pomidor']),
  _MiniIcon('banana', ['banan']),
  _MiniIcon('broom', ['odkurz', 'zamie', 'sprząt', 'śmie']),
  _MiniIcon('laundry', ['pran', 'ubran', 'pościel']),
  _MiniIcon('plant_small', ['kwiat', 'roślin', 'podle']),
  _MiniIcon('cleaning_spray', ['umy', 'łazienk', 'okn', 'podłog', 'kuwet']),
  _MiniIcon('heart', ['lekarz', 'dentyst', 'wizyt', 'zdrow']),
  _MiniIcon('gift', ['urodzin', 'prezent', 'imienin']),
  _MiniIcon('alarm', ['przypomn', 'budzik', 'rano']),
  _MiniIcon('calendar_event', ['spotkan', 'zebran', 'termin']),
];
