# Quran PDF Files

## 📖 How to Add Your Quran PDF

This folder should contain your Quran PDF file for reading in the app.

### Steps:

1. **Download or Place Your Quran PDF**
   - Name it: `Quran.pdf`
   - Place it in this folder: `assets/quran_pdfs/Quran.pdf`

2. **Recommended Sources for Tajweed Quran PDFs:**
   - [Quran.com](https://quran.com) - Download Mushaf Madinah
   - [Tanzil.net](https://tanzil.net/docs/download)
   - Your own Tajweed Quran PDF

3. **File Size Note:**
   - ⚠️ **PDFs are NOT included in Git** due to GitHub's 100 MB file size limit
   - Each developer must add their own PDF locally
   - The app expects a file at: `assets/quran_pdfs/Quran.pdf`

### After Adding the PDF:

```bash
cd "c:\Users\shazaib\Desktop\mad project\quran\quran"
flutter clean
flutter pub get
flutter run
```

## 📖 PDF Features

The app includes:
- ✅ Resume reading (remembers last page)
- ✅ Bookmarks (save and jump to pages)
- ✅ Page navigation (Next/Previous/Go to Page)
- ✅ Page counter display
- ✅ Swipe gestures
- ✅ Full-screen reading

## ⚠️ Important Notes

1. **Not in Git:** PDF files are ignored by Git (see `.gitignore`)
2. **Local Only:** Each developer needs to add the PDF to their local workspace
3. **File Name:** Must be exactly `Quran.pdf` (case-sensitive)
4. **Format:** Standard PDF format (not password-protected)

---

**Need help?** Check `INSTRUCTIONS.txt` in this folder.

