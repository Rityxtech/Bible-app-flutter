class BibleBook {
  final String name;
  final List<BibleChapter> chapters;

  BibleBook({required this.name, required this.chapters});

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      name: json['name'],
      chapters: (json['chapters'] as List)
          .map((c) => BibleChapter.fromJson(c))
          .toList(),
    );
  }
}

class BibleChapter {
  final String chapter;
  final List<BibleVerse> verses;

  BibleChapter({required this.chapter, required this.verses});

  factory BibleChapter.fromJson(Map<String, dynamic> json) {
    return BibleChapter(
      chapter: json['chapter'],
      verses: (json['verses'] as List)
          .map((v) => BibleVerse.fromJson(v))
          .toList(),
    );
  }
}

class BibleVerse {
  final String verse;
  final String text;

  BibleVerse({required this.verse, required this.text});

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      verse: json['verse'],
      text: json['text'],
    );
  }
}

class SearchResult {
  final BibleBook book;
  final BibleChapter chapter;
  final BibleVerse verse;

  SearchResult({
    required this.book,
    required this.chapter,
    required this.verse,
  });
}
