## Tajweed Juz PDFs

- Place 30 Tajweed PDFs under `assets/quran_pdfs/juz/` named:
	- `juz01.pdf` … `juz30.pdf` (two-digit numbering).
- The app lists Juz 1–30 under “Tajweed Quran (Juz 1–30)” and opens the matching PDF.
- Large PDFs are ignored by Git; they won’t be pushed. Keep them locally or host externally.

### Quick copy script (Windows PowerShell)

```
$src = "C:\Users\shazaib\Downloads"
$dst = "C:\Users\shazaib\Desktop\mad project\quran\quran\assets\quran_pdfs\juz"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
$files = Get-ChildItem $src -Filter "Colour Coded Quran Juz *.pdf"
foreach ($f in $files) {
	if ($f.Name -match "Juz\s+(\d{2})\.pdf") {
		$num = $Matches[1]
		Copy-Item $f.FullName (Join-Path $dst ("juz" + $num + ".pdf")) -Force
	} elseif ($f.Name -match "Juz\s+(\d)\.pdf") {
		$num = $Matches[1]
		Copy-Item $f.FullName (Join-Path $dst ("juz" + $num.PadLeft(2,'0') + ".pdf")) -Force
	}
}
```

If a Juz is missing, add the file and name it accordingly; the viewer will load it directly from assets.
# quran

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
