class ArabicLetter {
  final String letter;
  final String name;
  final String transliteration;
  final String soundPath;

  const ArabicLetter({
    required this.letter,
    required this.name,
    required this.transliteration,
    this.soundPath = '',
  });

  String get isolated => letter;
  String get initial => _getForm(0);
  String get medial => _getForm(1);
  String get final_ => _getForm(2);

  String _getForm(int position) {
    return letter;
  }

  static const List<ArabicLetter> alphabet = [
    ArabicLetter(letter: 'ا', name: 'Alif', transliteration: 'a'),
    ArabicLetter(letter: 'ب', name: 'Ba', transliteration: 'b'),
    ArabicLetter(letter: 'ت', name: 'Ta', transliteration: 't'),
    ArabicLetter(letter: 'ث', name: 'Tha', transliteration: 'th'),
    ArabicLetter(letter: 'ج', name: 'Jim', transliteration: 'j'),
    ArabicLetter(letter: 'ح', name: 'Ha', transliteration: 'ḥ'),
    ArabicLetter(letter: 'خ', name: 'Kha', transliteration: 'kh'),
    ArabicLetter(letter: 'د', name: 'Dal', transliteration: 'd'),
    ArabicLetter(letter: 'ذ', name: 'Dhal', transliteration: 'dh'),
    ArabicLetter(letter: 'ر', name: 'Ra', transliteration: 'r'),
    ArabicLetter(letter: 'ز', name: 'Zay', transliteration: 'z'),
    ArabicLetter(letter: 'س', name: 'Sin', transliteration: 's'),
    ArabicLetter(letter: 'ش', name: 'Shin', transliteration: 'sh'),
    ArabicLetter(letter: 'ص', name: 'Sad', transliteration: 'ṣ'),
    ArabicLetter(letter: 'ض', name: 'Dad', transliteration: 'ḍ'),
    ArabicLetter(letter: 'ط', name: 'Ta', transliteration: 'ṭ'),
    ArabicLetter(letter: 'ظ', name: 'Za', transliteration: 'ẓ'),
    ArabicLetter(letter: 'ع', name: 'Ayn', transliteration: 'ʿ'),
    ArabicLetter(letter: 'غ', name: 'Ghayn', transliteration: 'gh'),
    ArabicLetter(letter: 'ف', name: 'Fa', transliteration: 'f'),
    ArabicLetter(letter: 'ق', name: 'Qaf', transliteration: 'q'),
    ArabicLetter(letter: 'ك', name: 'Kaf', transliteration: 'k'),
    ArabicLetter(letter: 'ل', name: 'Lam', transliteration: 'l'),
    ArabicLetter(letter: 'م', name: 'Mim', transliteration: 'm'),
    ArabicLetter(letter: 'ن', name: 'Nun', transliteration: 'n'),
    ArabicLetter(letter: 'ه', name: 'Ha', transliteration: 'h'),
    ArabicLetter(letter: 'و', name: 'Waw', transliteration: 'w'),
    ArabicLetter(letter: 'ي', name: 'Ya', transliteration: 'y'),
  ];
}
