import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'notification_service.dart';

class BibleProvider with ChangeNotifier {
  List<BibleBook> _books = [];
  bool _isLoading = true;
  bool _isKjv = true;

  List<BibleBook> get books => _books;
  bool get isLoading => _isLoading;
  bool get isKjv => _isKjv;
  static List<String> get bookNames => _bookNames;

  final Set<String> _favorites = {};
  final Set<String> _highlights = {};
  final Set<String> _readingPlans = {};
  final List<String> _history = [];

  Set<String> get favorites => _favorites;
  Set<String> get highlights => _highlights;
  Set<String> get readingPlans => _readingPlans;
  List<String> get history => _history;

  bool _isDarkMode = false;
  double _fontSize = 18.0;
  bool _keepScreenOn = false;
  bool _dailyVerseNotification = false;

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  bool get keepScreenOn => _keepScreenOn;
  bool get dailyVerseNotification => _dailyVerseNotification;

  BibleProvider() {
    _initPrefsAndLoad();
  }

  Future<void> _initPrefsAndLoad() async {
    try {
      // Safely try init notification service early
      try {
        await NotificationService().init();
      } catch (e) {
        if (kDebugMode) print('Notification Init Error: $e');
      }

      final prefs = await SharedPreferences.getInstance();
      
      // Load saved preferences
      _isKjv = prefs.getBool('isKjv') ?? true;
      
      final favs = prefs.getStringList('favorites') ?? [];
      _favorites.addAll(favs);

      final highs = prefs.getStringList('highlights') ?? [];
      _highlights.addAll(highs);

      final plans = prefs.getStringList('readingPlans') ?? [];
      _readingPlans.addAll(plans);

      final hist = prefs.getStringList('history') ?? [];
      _history.addAll(hist);

      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 18.0;
      _keepScreenOn = prefs.getBool('keepScreenOn') ?? false;
      _dailyVerseNotification = prefs.getBool('dailyVerseNotification') ?? false;

      if (_keepScreenOn) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }

      await loadBible();
    } catch (e) {
      if (kDebugMode) print("Critical initialization error: $e");
      // If everything failed, try a last-resort basic load
      try {
        await loadBible();
      } catch (_) {}
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  void updateFontSize(double size) async {
    _fontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
  }

  void toggleVersion() async {
    _isKjv = !_isKjv;
    // Notify immediately so the AppBar subtitle and switch button update right away
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isKjv', _isKjv);
    await loadBible();
  }

  void toggleKeepScreenOn(bool value) async {
    _keepScreenOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepScreenOn', value);
    if (value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void toggleDailyVerseNotification(bool value) async {
    _dailyVerseNotification = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyVerseNotification', value);
    
    if (value) {
      final granted = await NotificationService().requestPermissions();
      if (granted && _books.isNotEmpty) {
        await NotificationService().scheduleDailyVerses(this);
      } else if (!granted) {
        // Revert toggle if permission denied
        _dailyVerseNotification = false;
        notifyListeners();
        await prefs.setBool('dailyVerseNotification', false);
      }
    } else {
      await NotificationService().cancelDailyVerses();
    }
  }

  // Interaction Methods
  bool isFavorite(String ref) => _favorites.contains(ref);
  bool isHighlighted(String ref) => _highlights.contains(ref);

  Future<void> toggleFavorite(String ref) async {
    if (_favorites.contains(ref)) {
      _favorites.remove(ref);
    } else {
      _favorites.add(ref);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites.toList());
  }

  Future<void> toggleHighlight(String ref) async {
    if (_highlights.contains(ref)) {
      _highlights.remove(ref);
    } else {
      _highlights.add(ref);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('highlights', _highlights.toList());
  }

  Future<void> addToReadingPlan(String ref) async {
    if (!_readingPlans.contains(ref)) {
      _readingPlans.add(ref);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('readingPlans', _readingPlans.toList());
    }
  }

  Future<void> removeFromReadingPlan(String ref) async {
    if (_readingPlans.contains(ref)) {
      _readingPlans.remove(ref);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('readingPlans', _readingPlans.toList());
    }
  }

  Future<void> addToHistory(String ref) async {
    _history.remove(ref); // Remove if exists to bring to top
    _history.insert(0, ref); // Add to beginning
    if (_history.length > 50) _history.removeLast(); // Keep latest 50
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', _history);
    // don't necessarily need to notifyListeners for history to prevent over-rebuilds
  }

  SearchResult? getVerseByRef(String ref) {
    if (ref.trim().isEmpty) return null;
    
    final refRegex = RegExp(r'^(.+?)\s+(\d+)[\s:]+(\d+)$');
    final match = refRegex.firstMatch(ref.trim());
    if (match == null) return null;

    String bookName = match.group(1)!.trim();
    String chapNum = match.group(2)!;
    String verseNum = match.group(3)!;

    for (var book in _books) {
      if (book.name.toLowerCase() == bookName.toLowerCase()) {
        try {
          var chapter = book.chapters.firstWhere((c) => c.chapter == chapNum);
          var verse = chapter.verses.firstWhere((v) => v.verse == verseNum);
          return SearchResult(book: book, chapter: chapter, verse: verse);
        } catch (e) {
          return null; // Chapter or verse not found
        }
      }
    }
    return null;
  }

  List<SearchResult> search(String query) {
    if (query.trim().isEmpty) return [];

    final results = <SearchResult>[];
    final q = query.toLowerCase().trim();

    // 1. Try to parse as reference (e.g., "John 3:16", "1 John 3 16")
    final refRegex = RegExp(r'^(.+?)\s+(\d+)[\s:]+(\d+)$');
    final refMatch = refRegex.firstMatch(q);

    if (refMatch != null) {
      String possibleBook = refMatch.group(1)!.trim();
      String possibleChap = refMatch.group(2)!;
      String possibleVerse = refMatch.group(3)!;

      for (var book in _books) {
        if (book.name.toLowerCase() == possibleBook || book.name.toLowerCase().startsWith(possibleBook)) {
          var chapMatch = book.chapters.where((c) => c.chapter == possibleChap).toList();
          if (chapMatch.isNotEmpty) {
            var vMatch = chapMatch.first.verses.where((v) => v.verse == possibleVerse).toList();
            if (vMatch.isNotEmpty) {
               results.add(SearchResult(book: book, chapter: chapMatch.first, verse: vMatch.first));
               return results; // Return early for exact reference match
            }
          }
        }
      }
    }

    // 2. Try to parse as chapter (e.g., "John 3")
    final chapRegex = RegExp(r'^(.+?)\s+(\d+)$');
    final chapMatch = chapRegex.firstMatch(q);
    
    if (chapMatch != null) {
      String possibleBook = chapMatch.group(1)!.trim();
      String possibleChap = chapMatch.group(2)!;
      
      for (var book in _books) {
        if (book.name.toLowerCase() == possibleBook || book.name.toLowerCase().startsWith(possibleBook)) {
          var chapMatchResult = book.chapters.where((c) => c.chapter == possibleChap).toList();
          if (chapMatchResult.isNotEmpty) {
             for (var v in chapMatchResult.first.verses) {
               results.add(SearchResult(book: book, chapter: chapMatchResult.first, verse: v));
             }
             return results; 
          }
        }
      }
    }

    // 3. Fallback to full text search
    int count = 0;
    // Normalize query by removing punctuation and extra spaces
    final normalizedQuery = q.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    final queryWords = normalizedQuery.split(' ').where((w) => w.isNotEmpty).toList();
    
    for (var book in _books) {
      for (var chapter in book.chapters) {
        for (var verse in chapter.verses) {
          // Normalizing verse text same way for comparisons
          final normalizedVerse = verse.text.toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(RegExp(r'\s+'), ' ');
          
          bool allWordsMatch = false;
          if (queryWords.isNotEmpty) {
            allWordsMatch = true;
            for (var word in queryWords) {
              if (!normalizedVerse.contains(word)) {
                allWordsMatch = false;
                break;
              }
            }
          }
          
          if (verse.text.toLowerCase().contains(q) || allWordsMatch) {
            results.add(SearchResult(book: book, chapter: chapter, verse: verse));
            count++;
            if (count > 200) return results; // Limit to 200 results
          }
        }
      }
    }

    return results;
  }

  Future<void> loadBible() async {
    try {
      _isLoading = true;
      _books = []; // Clear stale data immediately so old version doesn't show while loading
      notifyListeners();

      final String assetPath = _isKjv ? 'assets/kjv.json' : 'assets/asv.json';
      final String response = await rootBundle.loadString(assetPath);
      
      // Use compute to parse JSON in a background isolate to keep UI smooth
      _books = await compute(_parseBible, response);
      
      if (_dailyVerseNotification && _books.isNotEmpty) {
        await NotificationService().scheduleDailyVerses(this);
      }
      
    } catch (e) {
      if (kDebugMode) print("Error loading bible: $e");
      // If ASV fails, revert to KJV — persist & notify so UI reflects the change
      if (!_isKjv) {
        _isKjv = true;
        if (kDebugMode) print("Reverting to KJV due to load error.");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isKjv', true);
        // Try loading KJV as recovery (won't loop since _isKjv is now true)
        try {
          final String response = await rootBundle.loadString('assets/kjv.json');
          _books = await compute(_parseBible, response);
        } catch (e2) {
          if (kDebugMode) print("KJV recovery also failed: $e2");
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static const List<String> _bookNames = [
    "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel",
    "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs",
    "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos",
    "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah", "Haggai", "Zechariah", "Malachi",
    "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians", "Philippians",
    "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James",
    "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation"
  ];

  static List<BibleBook> _parseBible(String jsonString) {
    final dynamic decoded = json.decode(jsonString);
    
    // Structure: BookName -> { ChapterNum -> List<BibleVerse> }
    final Map<String, Map<String, List<BibleVerse>>> tempBooks = {};

    // Check for ASV structure (resultset -> row -> field)
    if (decoded is Map<String, dynamic> && decoded.containsKey('resultset')) {
      final rows = decoded['resultset']['row'] as List<dynamic>;
      for (var row in rows) {
        final fields = row['field'] as List<dynamic>;
        // [VerseID, BookNum, ChapterNum, VerseNum, Text]
        // Example: [1001001, 1, 1, 1, "In the beginning..."]
        
        final int bookNum = fields[1] as int;
        final int chapterNum = fields[2] as int;
        final int verseNum = fields[3] as int;
        final String text = fields[4] as String;

        // Map bookNum (1-based) to Name
        if (bookNum < 1 || bookNum > _bookNames.length) continue;
        final String bookName = _bookNames[bookNum - 1];
        
        if (!tempBooks.containsKey(bookName)) {
          tempBooks[bookName] = {};
        }
        
        final String chapterKey = chapterNum.toString();
        if (!tempBooks[bookName]!.containsKey(chapterKey)) {
          tempBooks[bookName]![chapterKey] = [];
        }
        
        tempBooks[bookName]![chapterKey]!.add(
          BibleVerse(verse: verseNum.toString(), text: text),
        );
      }
    } else if (decoded is Map<String, dynamic>) {
      // KJV Flat Format: {"Genesis 1:1": "Text", ...}
      decoded.forEach((key, value) {
        final int lastSpace = key.lastIndexOf(' ');
        if (lastSpace == -1) return;

        final String bookName = key.substring(0, lastSpace);
        final String refPart = key.substring(lastSpace + 1);
        
        final List<String> refParts = refPart.split(':');
        if (refParts.length != 2) return;
        
        final String chapterNum = refParts[0];
        final String verseNum = refParts[1];
        String text = value.toString();

        // Clean text formatting specific to this KJV version
        if (text.trimLeft().startsWith('#')) {
          text = text.trimLeft().substring(1);
        }
        text = text.replaceAll('[', '').replaceAll(']', '').trim();

        if (!tempBooks.containsKey(bookName)) {
          tempBooks[bookName] = {};
        }
        
        if (!tempBooks[bookName]!.containsKey(chapterNum)) {
          tempBooks[bookName]![chapterNum] = [];
        }

        tempBooks[bookName]![chapterNum]!.add(
          BibleVerse(verse: verseNum, text: text),
        );
      });
    }

    // Convert map structure to List<BibleBook>
    final List<BibleBook> books = [];
    
    // We want to maintain standard order.
    // Use _bookNames to iterate if present in tempBooks, otherwise iterate keys
    for (String name in _bookNames) {
      if (tempBooks.containsKey(name)) {
        final chaptersMap = tempBooks[name]!;
        final List<BibleChapter> chapters = [];
        
        // Sort chapters numerically
        final List<String> sortedChapters = chaptersMap.keys.toList()
          ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
          
        for (String chapNum in sortedChapters) {
          chapters.add(BibleChapter(chapter: chapNum, verses: chaptersMap[chapNum]!));
        }

        books.add(BibleBook(name: name, chapters: chapters));
      }
    }
    
    // Fallback: if mapping failed or names didn't match, add any remaining
    // (This handles the case where KJV keys might slightly differ from our list if not careful,
    // but standard list should work. If KJV uses "Psalm" vs "Psalms", we might miss it.
    // Let's safe-guard by checking KJV specifics or just iterating tempBooks if empty.)
    if (books.isEmpty && tempBooks.isNotEmpty) {
       tempBooks.forEach((bookName, chaptersMap) {
        final List<BibleChapter> chapters = [];
        chaptersMap.forEach((chapterNum, verses) {
          chapters.add(BibleChapter(chapter: chapterNum, verses: verses));
        });
        books.add(BibleBook(name: bookName, chapters: chapters));
      });
    }

    return books;
  }
}
