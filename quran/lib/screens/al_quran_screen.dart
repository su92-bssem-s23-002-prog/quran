import 'package:flutter/material.dart';
import '../screens/quran_pdf_viewer_screen.dart';
import '../services/zip_pdf_extractor.dart';

class AlQuranScreen extends StatefulWidget {
  const AlQuranScreen({super.key});

  @override
  State<AlQuranScreen> createState() => _AlQuranScreenState();
}

class _AlQuranScreenState extends State<AlQuranScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a472a), Color(0xFF0d2818)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xFFd4af37),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Al-Quran',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Selection cards
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeCard(
                        title: 'Tajweed Quran',
                        subtitle: 'Read the complete Quran with Tajweed',
                        icon: Icons.menu_book,
                        color: Color(0xFF1db854),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuranPdfViewerScreen(
                                pdfAssetPath: 'assets/quran_pdfs/Quran.pdf',
                                title: 'Tajweed Quran',
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      _buildModeCard(
                        title: 'Quran with Translation',
                        subtitle: 'Read Quran with Urdu/English translation',
                        icon: Icons.translate,
                        color: Color(0xFFd4af37),
                        onTap: () async {
                          // Use bundled asset ZIP path
                          const assetZipPath =
                              'assets/quran_pdfs/quran-shareef-with-urdu-translation.zip';

                          // Show simple progress dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                          try {
                            final pdfPaths =
                                await ZipPdfExtractor.extractFromAsset(
                                  assetZipPath: assetZipPath,
                                );
                            Navigator.of(context).pop(); // close progress

                            if (pdfPaths.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No PDFs found in ZIP.'),
                                ),
                              );
                              return;
                            }

                            // Prefer first PDF; could add file selection if multiple
                            final firstPdf = pdfPaths.first;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuranPdfViewerScreen(
                                  pdfAssetPath: firstPdf,
                                  title: 'Quran with Translation',
                                ),
                              ),
                            );
                          } catch (e) {
                            Navigator.of(context).pop(); // close progress
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to extract ZIP: $e'),
                                action: SnackBarAction(
                                  label: 'Retry',
                                  onPressed: () async {
                                    // simple retry
                                    try {
                                      final pdfPaths =
                                          await ZipPdfExtractor.extractFromAsset(
                                            assetZipPath: assetZipPath,
                                          );
                                      if (pdfPaths.isNotEmpty) {
                                        final firstPdf = pdfPaths.first;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                QuranPdfViewerScreen(
                                                  pdfAssetPath: firstPdf,
                                                  title:
                                                      'Quran with Translation',
                                                ),
                                          ),
                                        );
                                      }
                                    } catch (_) {}
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(color: Color(0xFFb0b0b0), fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
