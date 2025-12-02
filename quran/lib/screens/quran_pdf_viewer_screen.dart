import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranPdfViewerScreen extends StatefulWidget {
  final String pdfAssetPath;
  final String title;

  const QuranPdfViewerScreen({
    super.key,
    required this.pdfAssetPath,
    required this.title,
  });

  @override
  State<QuranPdfViewerScreen> createState() => _QuranPdfViewerScreenState();
}

class _QuranPdfViewerScreenState extends State<QuranPdfViewerScreen> {
  String? localPdfPath;
  bool isLoading = true;
  int currentPage = 0;
  int totalPages = 0;
  PDFViewController? pdfViewController;
  List<int> bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadPdfFromAssets();
    _loadReadingState();
  }

  Future<void> _loadPdfFromAssets() async {
    try {
      final ByteData bytes = await rootBundle.load(widget.pdfAssetPath);
      final String dir = (await getApplicationDocumentsDirectory()).path;
      final String path = '$dir/${widget.pdfAssetPath.split('/').last}';
      final File file = File(path);

      await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );

      setState(() {
        localPdfPath = path;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading PDF: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a472a), Color(0xFF0d2818)],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFd4af37),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Color(0xFFd4af37),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4a7c5e),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Page ${totalPages == 0 ? '-' : (currentPage + 1)}/$totalPages',
                        style: const TextStyle(
                          color: Color(0xFFd4af37),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (totalPages > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: currentPage < totalPages - 1
                          ? () => pdfViewController?.setPage(currentPage + 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      color: currentPage < totalPages - 1
                          ? const Color(0xFFd4af37)
                          : Colors.grey,
                      iconSize: 32,
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton.icon(
                      onPressed: _showGoToPageDialog,
                      icon: const Icon(Icons.menu_book, size: 18),
                      label: const Text('Go to Page'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4a7c5e),
                        foregroundColor: const Color(0xFFd4af37),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      onPressed: currentPage > 0
                          ? () => pdfViewController?.setPage(currentPage - 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      color: currentPage > 0
                          ? const Color(0xFFd4af37)
                          : Colors.grey,
                      iconSize: 32,
                    ),
                  ],
                ),
              ),

            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(color: Color(0xFFd4af37)),
                          SizedBox(height: 16),
                          Text(
                            'Loading Quran PDF...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : localPdfPath != null
                  ? PDFView(
                      filePath: localPdfPath,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: true,
                      pageFling: true,
                      pageSnap: true,
                      defaultPage: currentPage,
                      fitPolicy: FitPolicy.WIDTH,
                      preventLinkNavigation: false,
                      backgroundColor: const Color(0xFF0d2818),
                      nightMode: false,
                      onRender: (pages) {
                        setState(() {
                          totalPages = pages ?? 0;
                        });
                      },
                      onViewCreated: (PDFViewController vc) {
                        pdfViewController = vc;
                        if (currentPage > 0) {
                          pdfViewController?.setPage(currentPage);
                        }
                      },
                      onPageChanged: (int? page, int? total) async {
                        setState(() {
                          currentPage = page ?? 0;
                          totalPages = total ?? 0;
                        });
                        await _persistReadingState();
                      },
                      onError: (error) {
                        debugPrint('PDF Error: $error');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      onPageError: (page, error) {
                        debugPrint('Page $page Error: $error');
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 64,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please make sure the PDF file exists',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            _bookmarkBar(),
          ],
        ),
      ),
    );
  }

  void _showGoToPageDialog() {
    final TextEditingController pageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a472a),
        title: const Text('Go to Page', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter page number',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFd4af37)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFd4af37)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final pageNum = int.tryParse(pageController.text);
              if (pageNum != null && pageNum > 0 && pageNum <= totalPages) {
                pdfViewController?.setPage(pageNum - 1);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid page number'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4a7c5e),
              foregroundColor: const Color(0xFFd4af37),
            ),
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadReadingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keyPage = 'pdf_last_page_${widget.pdfAssetPath}';
      final keyMarks = 'pdf_bookmarks_${widget.pdfAssetPath}';
      final last = prefs.getInt(keyPage);
      final marks =
          prefs.getStringList(keyMarks)?.map(int.parse).toList() ?? [];
      setState(() {
        if (last != null) {
          currentPage = last;
        }
        bookmarks = marks;
      });
    } catch (_) {}
  }

  Future<void> _persistReadingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keyPage = 'pdf_last_page_${widget.pdfAssetPath}';
      final keyMarks = 'pdf_bookmarks_${widget.pdfAssetPath}';
      await prefs.setInt(keyPage, currentPage);
      await prefs.setStringList(
        keyMarks,
        bookmarks.map((e) => e.toString()).toList(),
      );
    } catch (_) {}
  }

  Widget _bookmarkBar() {
    if (isLoading) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1a472a).withOpacity(0.8),
        border: const Border(
          top: BorderSide(color: Color(0xFF4a7c5e), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              if (!bookmarks.contains(currentPage)) {
                setState(() => bookmarks.add(currentPage));
                await _persistReadingState();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4a7c5e),
              foregroundColor: const Color(0xFFd4af37),
            ),
            icon: const Icon(Icons.bookmark_add, size: 18),
            label: const Text('Bookmark page'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: bookmarks.map((p) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: OutlinedButton(
                      onPressed: () {
                        pdfViewController?.setPage(p);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFd4af37)),
                      ),
                      child: Text(
                        'Pg ${p + 1}',
                        style: const TextStyle(color: Color(0xFFd4af37)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
