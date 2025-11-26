# Work Todo & Analyzer Notes

Date: 2025-11-25

## Todo List

- [in-progress] Get error output
  - Ask the user to paste the full error message, stack trace, or failing command (flutter run, build, test).
- [not-started] Search codebase for error indicators
  - Scan `lib/` for 'Exception', 'Error:', 'throw', and 'assert' occurrences to find likely failure points.
- [not-started] Run static analysis
  - Run `flutter analyze` to collect analyzer errors and warnings.
- [not-started] Reproduce and fix
  - Reproduce the error locally, modify code to fix root cause, and run analyzer/tests.
- [not-started] Verify and report
  - Run tests/build, summarize fix, and suggest next steps or PR commit.

## Recent Actions

- Created the todo list using the workspace manager tool.
- Searched `lib/` and found multiple `throw Exception(...)` occurrences, notably in `lib/services/api_service.dart`.
- Ran `flutter analyze` which resolved dependencies but reported a Windows requirement: Developer Mode (symlink support) is needed to build with plugins.

## Analyzer / Environment Notes

- Dependency resolution succeeded; many packages have newer versions available.
- Windows build with plugins requires Developer Mode. To enable it, open Settings > Update & Security > For developers and turn on "Developer Mode", or run:

```powershell
start ms-settings:developers
```

## Next Steps

1. Ask the user to paste the specific error/stack trace they want fixed (if different from analyzer warnings).
2. If you'd like, I can run `flutter analyze --no-pub` to get analyzer messages without triggering package downloads.
3. If you want builds with plugins on Windows, enable Developer Mode and re-run the build/analyze steps.
