import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'bible_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'models.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BibleProvider(),
      child: Consumer<BibleProvider>(
        builder: (context, bible, child) {
          return MaterialApp(
            title: 'KJV Study Bible',
            debugShowCheckedModeBanner: false,
            themeMode: bible.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter', // Ensuring consistent typography if available
          scaffoldBackgroundColor: const Color(0xFFFFF8F6), // Light Mode Background
          splashFactory: InkRipple.splashFactory, // Instant ripple effect
          highlightColor: const Color(0xFF795649).withOpacity(0.1), // Immediate highlight
          splashColor: const Color(0xFF795649).withOpacity(0.1), // Ripple color
          listTileTheme: const ListTileThemeData(
            enableFeedback: true,
            selectedTileColor: Color(0x1A795649),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.resolveWith((states) {
                 if (states.contains(MaterialState.pressed)) return const Color(0xFF795649).withOpacity(0.2);
                 return null;
              }),
            ),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF795649),
            surface: const Color(0xFFFFF8F6),
            onSurface: const Color(0xFF1E293B),
            primary: const Color(0xFF795649),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xCCFFF8F6), // matching bg/80
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Color(0xFF795649),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            iconTheme: IconThemeData(color: Color(0xFF795649)),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0x1A795649)), // primary/10
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFF1C1816), // Dark Mode Background (approx #1A110F adjusted per css)
          splashFactory: InkRipple.splashFactory,
          highlightColor: const Color(0xFF795649).withOpacity(0.2), // More visible on dark
          splashColor: const Color(0xFF795649).withOpacity(0.2),
          listTileTheme: const ListTileThemeData(
            enableFeedback: true,
            selectedTileColor: Color(0x33795649),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
               overlayColor: MaterialStateProperty.resolveWith((states) {
                 if (states.contains(MaterialState.pressed)) return const Color(0xFF795649).withOpacity(0.3);
                 return null;
               }),
            ),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF795649),
            surface: const Color(0xFF1C1816),
            onSurface: const Color(0xFFF1F5F9), // Slate-100 equivalent
            primary: const Color(0xFF795649),
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xCC1C1816),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Color(0xFF795649),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
             iconTheme: IconThemeData(color: Color(0xFF795649)),
          ),
           cardTheme: CardThemeData(
            color: const Color(0xFF18181B), // Zinc-900
            elevation: 0,
             shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0x1A795649)),
            ),
          ),
        ),
        home: bible.isLoading ? const SplashScreen() : const MainScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(35),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.asset(
                    'assets/app_icon.png',
                    width: 150,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                       return Icon(Icons.menu_book, size: 150, color: Theme.of(context).colorScheme.primary);
                    }
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Preparing the Word...",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Custom Bottom Navigation Bar to match design
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: const Border(top: BorderSide(color: Color(0x1A795649))), // primary/10
          color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.menu_book, "Bible"),
                _buildNavItem(1, Icons.search, "Search"),
                _buildNavItem(2, Icons.favorite_border, "Favorites", activeIcon: Icons.favorite),
                _buildNavItem(3, Icons.settings, "Settings"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {IconData? activeIcon}) {
    final isSelected = _selectedIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = Colors.grey.shade400;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? (activeIcon ?? icon) : icon,
              color: isSelected ? primaryColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: isSelected ? primaryColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (isSelected && label == "Settings") // Example dot for settings if needed, or removing per layout
               Container(), 
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final bible = Provider.of<BibleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Holy Bible',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            Text(
              '${bible.isKjv ? "King James" : "American Standard"} Version',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: () => bible.toggleVersion(),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: Icon(Icons.sync_alt, size: 16, color: Theme.of(context).colorScheme.primary),
              label: Text(
                bible.isKjv ? "Switch to ASV" : "Switch to KJV",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<BibleProvider>(
        builder: (context, bible, child) {
          if (bible.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _BookList(books: bible.books);
        },
      ),
    );
  }
}

class _BookList extends StatelessWidget {
  final List<BibleBook> books;
  const _BookList({required this.books});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
           margin: EdgeInsets.zero,
           child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              book.name, 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChapterGridScreen(book: book)),
            ),
          ),
        );
      },
    );
  }
}

void handleShareScripture(BuildContext context, SearchResult v) {
  showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Share Scripture',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.text_snippet_outlined, color: Theme.of(context).colorScheme.primary),
                title: const Text('Share as Text'),
                onTap: () {
                  Navigator.pop(ctx);
                  Share.share('"${v.verse.text}"\n— ${v.book.name} ${v.chapter.chapter}:${v.verse.verse}\n\nBible by RityxTech');
                },
              ),
              ListTile(
                leading: Icon(Icons.image_outlined, color: Theme.of(context).colorScheme.primary),
                title: const Text('Share as Image'),
                onTap: () async {
                  Navigator.pop(ctx);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generating image...'), duration: Duration(milliseconds: 1000)),
                  );

                  final primaryColor = Theme.of(context).colorScheme.primary;
                  final onSurface = Theme.of(context).colorScheme.onSurface;
                  
                  try {
                    final controller = ScreenshotController();
                    final bytes = await controller.captureFromWidget(
                      Material(
                        child: Container(
                          width: 800,
                          height: 800, // 1:1 format
                          padding: const EdgeInsets.all(40),
                          color: const Color(0xFFF8F5F2), // subtle warm background
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.format_quote_rounded, size: 80, color: primaryColor.withOpacity(0.3)),
                              const SizedBox(height: 32),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '"${v.verse.text}"',
                                    style: TextStyle(
                                      fontSize: 34,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(width: 60, height: 2, color: primaryColor.withOpacity(0.5)),
                              const SizedBox(height: 24),
                              Text(
                                '${v.book.name} ${v.chapter.chapter}:${v.verse.verse}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 48),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.menu_book, size: 20, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bible by RityxTech',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      context: context,
                      delay: const Duration(milliseconds: 50),
                    );
                    
                    final directory = await getTemporaryDirectory();
                    final imagePath = await File('${directory.path}/share_${v.book.name}_${v.chapter.chapter}_${v.verse.verse.replaceAll(':', '_')}.png').create();
                    await imagePath.writeAsBytes(bytes);
                    
                    await Share.shareXFiles([XFile(imagePath.path)], text: 'Bible by RityxTech');
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error generating image.')));
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (context, bible, child) {
        final primaryColor = Theme.of(context).colorScheme.primary;
        
        // Fetch actual favorites
        final List<SearchResult> verses = [];
        for (var ref in bible.favorites) {
          final res = bible.getVerseByRef(ref);
          if (res != null) verses.add(res);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Favorites'),
            leading: Container(
               margin: const EdgeInsets.all(8),
               decoration: const BoxDecoration(
                 color: Colors.transparent, 
                 shape: BoxShape.circle,
               ),
               child: InkWell(
                 onTap: (){}, 
                 borderRadius: BorderRadius.circular(20),
                 child: Icon(Icons.arrow_back, color: primaryColor)
               ),
            ),
          ),
          body: verses.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_outline, size: 80, color: primaryColor.withOpacity(0.2)),
                        const SizedBox(height: 24),
                        Text(
                          'No Favorites Yet',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap the heart icon when reading a verse to save it here for quick access later.\n\nYour favorite scriptures will be safely stored and ready for you to meditate on anytime.',
                          style: TextStyle(fontSize: 15, height: 1.5, color: Theme.of(context).colorScheme.onSurfaceOf(context).withOpacity(0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Saved Verses",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceOf(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${verses.length} Verses",
                      style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...verses.map((v) {
                final refStr = '${v.book.name} ${v.chapter.chapter}:${v.verse.verse}';
                return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              refStr,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                            ),
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 20,
                                icon: const Icon(Icons.favorite, color: Colors.red),
                                onPressed: () {
                                  bible.toggleFavorite(refStr);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Removed $refStr from favorites"),
                                      action: SnackBarAction(
                                        label: 'UNDO',
                                        onPressed: () {
                                          bible.toggleFavorite(refStr);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"${v.verse.text}"',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.onSurfaceOf(context).withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                             _ActionButton(
                               icon: Icons.share, 
                               label: "Share", 
                               isPrimary: true,
                               onTap: () => handleShareScripture(context, v),
                             ),
                             const SizedBox(width: 8),
                             _ActionButton(
                               icon: Icons.menu_book, 
                               label: "Read", 
                               isPrimary: false,
                               onTap: () {
                                 Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReadingScreen(
                                        book: v.book,
                                        initialChapterIndex: v.book.chapters.indexOf(v.chapter),
                                        initialVerseIndex: v.chapter.verses.indexOf(v.verse),
                                      ),
                                    ),
                                 );
                               },
                             ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
              }).toList(),
          const SizedBox(height: 32),
          Opacity(
            opacity: 0.2,
            child: Column(
              children: [
                Icon(Icons.auto_awesome, size: 60, color: primaryColor),
                const SizedBox(height: 8),
                Text(
                  "Thy word is a lamp unto my feet",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
      },
    );
  }
}

class SavedVersesScreen extends StatelessWidget {
  final String title;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final Iterable<String> Function(BibleProvider) getItems;
  final void Function(BibleProvider, String)? onRemove;
  final IconData? removeIcon;

  const SavedVersesScreen({
    super.key,
    required this.title,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.getItems,
    this.onRemove,
    this.removeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (context, bible, child) {
        final primaryColor = Theme.of(context).colorScheme.primary;
        
        final List<SearchResult> verses = [];
        for (var ref in getItems(bible)) {
          final res = bible.getVerseByRef(ref);
          if (res != null) verses.add(res);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: verses.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(emptyIcon, size: 80, color: primaryColor.withOpacity(0.2)),
                        const SizedBox(height: 24),
                        Text(
                          emptyTitle,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          emptyMessage,
                          style: TextStyle(fontSize: 15, height: 1.5, color: Theme.of(context).colorScheme.onSurfaceOf(context).withOpacity(0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Saved Verses",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurfaceOf(context),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${verses.length} Verses",
                            style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...verses.map((v) {
                      final refStr = '${v.book.name} ${v.chapter.chapter}:${v.verse.verse}';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      refStr,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                                    ),
                                    if (onRemove != null && removeIcon != null)
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 20,
                                          icon: Icon(removeIcon, color: Colors.red),
                                          onPressed: () {
                                            onRemove!(bible, refStr);
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Removed from $title"),
                                                action: SnackBarAction(
                                                  label: 'UNDO',
                                                  onPressed: () {
                                                    // Reverse the removal depending on title context
                                                    if (title.contains("Reading")) {
                                                      bible.addToReadingPlan(refStr);
                                                    } else if (title.contains("Highlights")) {
                                                      bible.toggleHighlight(refStr);
                                                    }
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '"${v.verse.text}"',
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(context).colorScheme.onSurfaceOf(context).withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                     _ActionButton(
                                       icon: Icons.share, 
                                       label: "Share", 
                                       isPrimary: true,
                                       onTap: () => handleShareScripture(context, v),
                                     ),
                                     const SizedBox(width: 8),
                                     _ActionButton(
                                       icon: Icons.menu_book, 
                                       label: "Read", 
                                       isPrimary: false,
                                       onTap: () {
                                         // Update history if reading from another page
                                         bible.addToHistory('${v.book.name} ${v.chapter.chapter}:${v.verse.verse}');
                                         Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ReadingScreen(
                                                book: v.book,
                                                initialChapterIndex: v.book.chapters.indexOf(v.chapter),
                                                initialVerseIndex: v.chapter.verses.indexOf(v.verse),
                                              ),
                                            ),
                                         );
                                       },
                                     ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (context, bible, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
             leading: Padding(
               padding: const EdgeInsets.all(8.0),
               child: InkWell(
                 onTap: (){}, 
                 borderRadius: BorderRadius.circular(20),
                 child: const Center(child: Icon(Icons.arrow_back)),
               ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
          _SectionHeader(title: "Bible Usage"),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.history, 
                  title: "History",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SavedVersesScreen(
                    title: "History",
                    emptyIcon: Icons.history,
                    emptyTitle: "No History Yet",
                    emptyMessage: "Your recently read scriptures will appear here.",
                    getItems: (b) => b.history,
                  ))),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _SettingsTile(
                  icon: Icons.event_note, 
                  title: "Reading Plans",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SavedVersesScreen(
                    title: "Reading Plans",
                    emptyIcon: Icons.event_note,
                    emptyTitle: "No Reading Plans",
                    emptyMessage: "Add scriptures to your reading plan to see them here.",
                    getItems: (b) => b.readingPlans,
                    onRemove: (b, ref) => b.removeFromReadingPlan(ref),
                    removeIcon: Icons.remove_circle_outline,
                  ))),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _SettingsTile(
                  icon: Icons.highlight, 
                  title: "Notes & Highlights",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SavedVersesScreen(
                    title: "Highlights",
                    emptyIcon: Icons.highlight,
                    emptyTitle: "No Highlights",
                    emptyMessage: "Your highlighted scriptures will be stored securely here.",
                    getItems: (b) => b.highlights,
                    onRemove: (b, ref) => b.toggleHighlight(ref),
                    removeIcon: Icons.highlight_remove,
                  ))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: "Display"),
          Card(
             clipBehavior: Clip.antiAlias,
             child: Column(
               children: [
                 _SwitchTile(
                   icon: Icons.dark_mode, 
                   title: "Dark Mode",
                   value: bible.isDarkMode,
                   onChanged: (val) => bible.toggleDarkMode(val),
                 ),
                 const Divider(height: 1, indent: 16, endIndent: 16),
                 _SettingsTile(
                   icon: Icons.format_size, 
                   title: "Font Size", 
                   trailing: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Text("${bible.fontSize.toInt()}pt", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                       Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                     ],
                   ),
                   onTap: () {
                     showModalBottomSheet(
                       context: context,
                       builder: (ctx) => StatefulBuilder(
                         builder: (context, setState) {
                           return Container(
                             padding: const EdgeInsets.all(24),
                             child: Column(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 const Text("Adjust Font Size", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                 const SizedBox(height: 24),
                                 Row(
                                   children: [
                                     const Text("A", style: TextStyle(fontSize: 14)),
                                     Expanded(
                                       child: Slider(
                                         value: bible.fontSize,
                                         min: 12.0,
                                         max: 30.0,
                                         divisions: 18,
                                         label: bible.fontSize.toInt().toString(),
                                         onChanged: (val) {
                                            setState((){});
                                            bible.updateFontSize(val);
                                         },
                                       ),
                                     ),
                                     const Text("A", style: TextStyle(fontSize: 24)),
                                   ]
                                 ),
                                 const SizedBox(height: 16),
                               ],
                             )
                           );
                         }
                       ),
                     );
                   }
                ),
               ],
             ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: "Application"),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                 _SwitchTile(
                   icon: Icons.screen_lock_portrait, 
                   title: "Keep Screen On",
                   value: bible.keepScreenOn,
                   onChanged: (val) => bible.toggleKeepScreenOn(val),
                 ),
                 const Divider(height: 1, indent: 16, endIndent: 16),
                 _SwitchTile(
                   icon: Icons.notifications, 
                   title: "Daily Verse Notification",
                   value: bible.dailyVerseNotification,
                   onChanged: (val) {
                     bible.toggleDailyVerseNotification(val);
                     if (val) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("Daily verses scheduled for 6:00 AM local time.")),
                       );
                     } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("Daily verse notifications disabled.")),
                       );
                     }
                   },
                 ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ad integration coming soon! Thanks for your support.")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.favorite, size: 18),
            label: const Text("Support Us (Watch Ad)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(height: 16),
          Text(
            "Version 2.4.0 (Build 102)",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
      },
    );
  }
}

// Reusable Components matching CSS classes

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, required this.isPrimary, this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: isPrimary ? primary : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isPrimary ? BorderSide.none : BorderSide(color: primary.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isPrimary ? Colors.white : primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(
      tileColor: Colors.transparent,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primary, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
      onTap: onTap ?? () {},
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(
      tileColor: Colors.transparent,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primary, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: primary,
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
       body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('$title Coming Soon', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];
  List<String> _suggestions = [];
  bool _isSearching = false;
  Timer? _debounce;
  
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (val) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice recognition failed. Check your internet connection.')));
          setState(() => _isListening = false);
        }
      },
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  void _startListening() async {
    // 1. Check Internet Connection First
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw const SocketException('No internet');
      }
    } on SocketException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No internet connection. Please turn on data to use voice search.'),
          duration: Duration(seconds: 4),
        ));
      }
      return;
    }

    // 2. Check Permissions
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Microphone permission permanently denied. Please enable it in Settings.'),
            action: SnackBarAction(label: 'Settings', onPressed: () => openAppSettings()),
          ));
        }
        return;
      }
      if (!status.isGranted) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission required.')));
        return;
      }
    }
    
    // 3. Attempt re-initialize if it wasn't enabled initially
    if (!_speechEnabled) {
      _speechEnabled = await _speechToText.initialize(
        onError: (val) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice recognition error. Check connection.')));
            setState(() => _isListening = false);
          }
        },
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
    }
    
    if (_speechEnabled) {
      if (mounted) setState(() => _isListening = true);
      await _speechToText.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _searchController.text = result.recognizedWords;
              // Set the cursor to end of text
              _searchController.selection = TextSelection.fromPosition(TextPosition(offset: _searchController.text.length));
              _onSearchChanged(result.recognizedWords);
              
              if (result.finalResult) {
                _isListening = false;
              }
            });
          }
        }
      );
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    if (mounted) setState(() => _isListening = false);
  }

  void _updateSuggestions(String query) {
    if (query.trim().isEmpty) {
      if (mounted) setState(() => _suggestions = []);
      return;
    }
    
    final q = query.toLowerCase();

    // Clear suggestions if they already typed an exact book followed by space (e.g., "Luke ")
    final exactBookMatch = BibleProvider.bookNames.any((b) => b.toLowerCase() == q.trim());
    if (exactBookMatch && query.endsWith(' ')) {
      if (mounted) setState(() => _suggestions = []);
      return;
    }

    // Stop suggesting if they've clearly moved on to chapters (e.g. "Luke 3")
    final chapRegex = RegExp(r'^.+?\s+\d+');
    if (chapRegex.hasMatch(q)) {
      if (mounted) setState(() => _suggestions = []);
      return;
    }

    List<String> matches = BibleProvider.bookNames
        .where((book) => book.toLowerCase().contains(q))
        .toList();

    matches.sort((a, b) {
      bool aStarts = a.toLowerCase().startsWith(q);
      bool bStarts = b.toLowerCase().startsWith(q);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;
      return a.compareTo(b);
    });

    if (mounted) {
      setState(() {
        _suggestions = matches.take(5).toList();
      });
    }
  }

  void _onSuggestionTap(String suggestion) {
    final newText = '$suggestion ';
    _searchController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    if (mounted) {
      setState(() {
        _suggestions = [];
      });
    }
    _onSearchChanged(newText);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _updateSuggestions(query);

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
      }
      return;
    }

    // Wait 1 second after typing stops to start the search and show loader
    _debounce = Timer(const Duration(seconds: 1), () async {
      if (mounted) {
        setState(() {
          _isSearching = true;
        });
      }

      // Allow UI to render the loading indicator
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) return;
      final bible = Provider.of<BibleProvider>(context, listen: false);
      final results = bible.search(query);
      
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search "John 3:16" or "faith"...',
                prefixIcon: Icon(Icons.search, color: primaryColor),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : primaryColor,
                      ),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
                      const SizedBox(width: 4),
                  ],
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
          ),
          if (_suggestions.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: _suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _AnimatedSuggestionChip(
                    label: s,
                    primaryColor: primaryColor,
                    onTap: () => _onSuggestionTap(s),
                  ),
                )).toList(),
              ),
            ),
          if (_isSearching)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_results.isEmpty && _searchController.text.isNotEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No results found',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ),
            )
          else if (_results.isEmpty && _searchController.text.isEmpty)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book, size: 80, color: primaryColor.withOpacity(0.2)),
                      const SizedBox(height: 24),
                      Text(
                        'Search the Scriptures',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Type a book followed by chapter and verse\n(e.g., "John 3:16" or "Luke 1")\n\nor\n\nEnter any statement or keyword to search the entire Bible\n(e.g., "faith" or "lamp unto my feet")',
                        style: TextStyle(fontSize: 15, height: 1.5, color: Theme.of(context).colorScheme.onSurfaceOf(context).withOpacity(0.7)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '${result.book.name} ${result.chapter.chapter}:${result.verse.verse}',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      result.verse.text,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceOf(context).withOpacity(0.8),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      final chapterIndex = result.book.chapters.indexOf(result.chapter);
                      final verseIndex = result.chapter.verses.indexOf(result.verse);
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReadingScreen(
                            book: result.book,
                            initialChapterIndex: chapterIndex,
                            initialVerseIndex: verseIndex,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedSuggestionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color primaryColor;

  const _AnimatedSuggestionChip({
    required this.label,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  State<_AnimatedSuggestionChip> createState() => _AnimatedSuggestionChipState();
}

class _AnimatedSuggestionChipState extends State<_AnimatedSuggestionChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // A gentle 1 second breathing animation
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    // Scale slightly from 1x to 1.08x
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ActionChip(
        label: Text(widget.label, style: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: widget.primaryColor.withOpacity(0.15),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: widget.onTap,
      ),
    );
  }
}

// Existing Chapter/Verse screens adapted to style
class ChapterGridScreen extends StatelessWidget {
  final BibleBook book;
  const ChapterGridScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.name)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80,
          childAspectRatio: 1.0,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: book.chapters.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerseSelectionScreen(
                  book: book,
                  chapterIndex: index,
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}', 
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class VerseSelectionScreen extends StatelessWidget {
  final BibleBook book;
  final int chapterIndex;

  const VerseSelectionScreen({
    super.key,
    required this.book,
    required this.chapterIndex,
  });

  @override
  Widget build(BuildContext context) {
    final chapter = book.chapters[chapterIndex];
    
    return Scaffold(
      appBar: AppBar(title: Text('${book.name} ${chapter.chapter}')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80,
          childAspectRatio: 1.0,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: chapter.verses.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReadingScreen(
                  book: book,
                  initialChapterIndex: chapterIndex,
                  initialVerseIndex: index,
                ),
              ),
            ),
             borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
                 color: Colors.white,
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}', 
                style: TextStyle(
                  fontSize: 18, 
                   fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReadingScreen extends StatefulWidget {
  final BibleBook book;
  final int initialChapterIndex;
  final int initialVerseIndex;

  const ReadingScreen({
    super.key,
    required this.book,
    required this.initialChapterIndex,
    this.initialVerseIndex = 0,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late final ItemScrollController _itemScrollController;
  late final ItemPositionsListener _itemPositionsListener;
  
  late BibleBook _currentBook;
  late int _currentChapterIndex;
  bool _isAnnouncingTransition = false;

  FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  bool isPaused = false;
  int currentPlayingVerseIndex = -1;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
    _currentChapterIndex = widget.initialChapterIndex;
    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final chapter = _currentBook.chapters[_currentChapterIndex];
        final verse = chapter.verses[widget.initialVerseIndex];
        final refStr = '${_currentBook.name} ${chapter.chapter}:${verse.verse}';
        Provider.of<BibleProvider>(context, listen: false).addToHistory(refStr);
      }
    });

    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-GB");
    // 0.35 is a very calm, slow, and measured pace ideal for scripture reading.
    await flutterTts.setSpeechRate(0.35);
    // Keep pitch exactly at 1.0 — any change uses DSP pitch shifting which sounds unnatural.
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);

    // --- Smart Voice Selector ---
    // Priority (highest → lowest):
    //   1. Premium named voices (Daniel, Serena, Oliver, Kate, Arthur, Amy, Emma, Brian, etc.)
    //   2. Network / cloud-enhanced voices (very human on Android)
    //   3. Any female-labelled en-GB voice
    //   4. Any en-GB voice
    //   5. Any English voice
    try {
      final List<dynamic> voices = await flutterTts.getVoices;

      // Sorted priority keywords for premium British female human-like TTS voices
      const premiumFemaleNames = [
        "serena", "kate", "amy", "emma", "hazel", "martha", "stephanie"
      ];
      Map<String, String>? tier1; // Premium named (British Female)
      Map<String, String>? tier2; // network/cloud female en-GB
      Map<String, String>? tier3; // basic female en-GB
      Map<String, String>? tier4; // any female English
      Map<String, String>? tier5; // any en-GB
      Map<String, String>? tier6; // any English

      for (final voice in voices) {
        final locale = voice["locale"]?.toString() ?? "";
        final rawName = voice["name"]?.toString() ?? "";
        final name = rawName.toLowerCase();

        if (!locale.startsWith("en")) continue;

        final Map<String, String> voiceEntry = {"name": rawName, "locale": locale};
        final isUkLocale = locale.startsWith("en-GB") || locale.startsWith("en_GB");
        final isNetwork = name.contains("network");
        final isFemale = name.contains("female") || name.contains("woman");
        final isPremiumFemale = premiumFemaleNames.any((p) => name.contains(p));

        if (isPremiumFemale && tier1 == null) {
          tier1 = voiceEntry;
        } else if (isNetwork && isFemale && isUkLocale && tier2 == null) {
          tier2 = voiceEntry;
        } else if (isFemale && isUkLocale && tier3 == null) {
          tier3 = voiceEntry;
        } else if (isFemale && tier4 == null) {
          tier4 = voiceEntry;
        } else if (isUkLocale && tier5 == null) {
          tier5 = voiceEntry;
        } else if (tier6 == null) {
          tier6 = voiceEntry;
        }
      }

      final chosenVoice = tier1 ?? tier2 ?? tier3 ?? tier4 ?? tier5 ?? tier6;
      if (chosenVoice != null) {
        await flutterTts.setVoice(chosenVoice);
      }
    } catch (_) {
      // Voice selection failed — default TTS voice will be used
    }

    flutterTts.setCompletionHandler(() {
      if (mounted) {
        _playNextVerse();
      }
    });
    flutterTts.setCancelHandler(() {
      if (mounted) {
        setState(() {
          isPlaying = false;
          isPaused = false;
          currentPlayingVerseIndex = -1;
        });
      }
    });
  }

  Future<void> _playVerse(int index) async {
    if (!mounted) return;
    final chapter = _currentBook.chapters[_currentChapterIndex];
    if (index >= chapter.verses.length) {
      _stopTts();
      return;
    }
    setState(() {
      currentPlayingVerseIndex = index;
      isPlaying = true;
      isPaused = false;
    });
    
    _itemScrollController.scrollTo(
      index: index, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeInOut
    );
    
    final verse = chapter.verses[index];
    await flutterTts.speak(verse.text);
  }

  void _playNextVerse() {
    if (!isPlaying && !isPaused) return;

    if (_isAnnouncingTransition) {
      _isAnnouncingTransition = false;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted && (isPlaying || isPaused)) {
          _playVerse(0); // Start the new chapter
        }
      });
      return;
    }

    final chapter = _currentBook.chapters[_currentChapterIndex];
    if (currentPlayingVerseIndex + 1 < chapter.verses.length) {
      // Natural 900ms breath-pause between verses for a gentle, slow reading rhythm
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted && (isPlaying || isPaused)) {
          _playVerse(currentPlayingVerseIndex + 1);
        }
      });
    } else {
      // Reached the end of the chapter, transition to the next chapter
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && (isPlaying || isPaused)) {
          _advanceToNextChapter();
        }
      });
    }
  }

  void _advanceToNextChapter() {
    final bible = Provider.of<BibleProvider>(context, listen: false);
    
    int nextChapterIndex = _currentChapterIndex + 1;
    BibleBook nextBook = _currentBook;
    bool newBook = false;

    if (nextChapterIndex >= nextBook.chapters.length) {
      int currentBookIdx = bible.books.indexWhere((b) => b.name == _currentBook.name);
      if (currentBookIdx == -1 || currentBookIdx + 1 >= bible.books.length) {
        _stopTts(); // End of the Bible
        return;
      }
      nextBook = bible.books[currentBookIdx + 1];
      nextChapterIndex = 0;
      newBook = true;
    }

    setState(() {
      _currentBook = nextBook;
      _currentChapterIndex = nextChapterIndex;
      _isAnnouncingTransition = true;
      currentPlayingVerseIndex = 0;
    });

    _itemScrollController.jumpTo(index: 0);

    final String chapterName = nextBook.chapters[nextChapterIndex].chapter;
    String announcement = newBook 
        ? "${nextBook.name} chapter $chapterName, verse 1" 
        : "Chapter $chapterName, verse 1";

    flutterTts.speak(announcement);
  }

  Future<void> _pauseTts() async {
    await flutterTts.pause();
    setState(() {
      isPaused = true;
      isPlaying = false;
    });
  }

  Future<void> _stopTts() async {
    await flutterTts.stop();
    setState(() {
      isPlaying = false;
      isPaused = false;
      _isAnnouncingTransition = false;
      currentPlayingVerseIndex = -1;
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapter = _currentBook.chapters[_currentChapterIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentBook.name} ${chapter.chapter}'),
        backgroundColor: Theme.of(context).colorScheme.surface, // Clean look
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              if (isPlaying) return;
              int startIdx = widget.initialVerseIndex;
              if (_itemPositionsListener.itemPositions.value.isNotEmpty) {
                final positions = _itemPositionsListener.itemPositions.value.toList()
                  ..sort((a, b) => a.index.compareTo(b.index));
                final firstVisible = positions.firstWhere((p) => p.itemTrailingEdge > 0, orElse: () => positions.first);
                startIdx = firstVisible.index;
              }
              _playVerse(startIdx);
            },
          ),
        ],
         bottom: PreferredSize(
           preferredSize: const Size.fromHeight(1.0),
           child: Container(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), height: 1.0),
         ),
      ),
      bottomNavigationBar: (isPlaying || isPaused) 
        ? Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 32,
                  icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    if (isPaused) {
                      _playVerse(currentPlayingVerseIndex);
                    } else {
                      _pauseTts();
                    }
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  iconSize: 32,
                  icon: Icon(Icons.stop, color: Theme.of(context).colorScheme.error),
                  onPressed: _stopTts,
                ),
              ],
            ),
          )
        : null,
      body: ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        initialScrollIndex: widget.initialVerseIndex,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
        itemCount: chapter.verses.length,
        itemBuilder: (context, index) {
          final verse = chapter.verses[index];
          final refStr = '${_currentBook.name} ${chapter.chapter}:${verse.verse}';
          
          return Consumer<BibleProvider>(
            builder: (context, bible, child) {
              final isFav = bible.isFavorite(refStr);
              final isHigh = bible.isHighlighted(refStr);
              
              return InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),
                            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Theme.of(context).colorScheme.primary),
                              title: Text(isFav ? 'Remove from Favorites' : 'Add to Favorites'),
                              onTap: () {
                                bible.toggleFavorite(refStr);
                                Navigator.pop(context);
                                if (isFav) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Removed $refStr from favorites"),
                                      action: SnackBarAction(
                                        label: 'UNDO',
                                        onPressed: () {
                                          bible.toggleFavorite(refStr);
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            ListTile(
                              leading: Icon(isHigh ? Icons.highlight : Icons.highlight_alt, color: Theme.of(context).colorScheme.primary),
                              title: Text(isHigh ? 'Remove Highlight' : 'Highlight Verse'),
                              onTap: () {
                                bible.toggleHighlight(refStr);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.event_note, color: Theme.of(context).colorScheme.primary),
                              title: const Text('Add to Reading Plan'),
                              onTap: () {
                                bible.addToReadingPlan(refStr);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Reading Plan')));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.share, color: Theme.of(context).colorScheme.primary),
                              title: const Text('Share Scripture'),
                              onTap: () {
                                Navigator.pop(context);
                                handleShareScripture(context, SearchResult(
                                  book: _currentBook,
                                  chapter: chapter,
                                  verse: verse,
                                ));
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: index == currentPlayingVerseIndex 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : (isHigh ? Colors.lightGreenAccent.withOpacity(0.3) : Colors.transparent),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${verse.verse}  ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: bible.fontSize - 3,
                                ),
                              ),
                              TextSpan(
                                text: verse.text,
                                style: TextStyle(
                                  fontSize: bible.fontSize, 
                                  height: 1.6,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isFav)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.favorite, color: Colors.red, size: 16),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

}

// Extensions for convenient color usage
extension ColorSchemeExt on ColorScheme {
  Color onSurfaceOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFFF1F5F9) 
        : const Color(0xFF1E293B);
  }
}
