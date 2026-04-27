# Project Learnings

## Windows Batch Scripting
- **Comments inside blocks**: Never use `::` for comments inside parenthesized blocks (like `if` or `for`). Use `REM` instead. `::` is interpreted as a label and causes immediate syntax errors in blocks.
- **Parentheses in comments**: Avoid unbalanced parentheses in `echo` or comments inside blocks, as they can break the Batch parser.
- **UV Path**: On new Windows machines, `uv` is typically installed to `%APPDATA%\uv\bin` or `%USERPROFILE%\.cargo\bin`. Scripts should check these paths manually if `where uv` fails, as the system PATH might not refresh instantly.
- **Playwright Browsers**: The user prefers only Chromium/Chrome to avoid "bloat" from Firefox or WebKit. Use `playwright install chromium` instead of a full install.
- **DLL Load Failures (Windows)**: If a Python package with C extensions (like `greenlet`, used by Playwright) fails with `ImportError: DLL load failed`, it's usually due to a missing **Microsoft Visual C++ Redistributable**. Always check for `vcruntime140.dll` and provide an auto-install step in the bootstrap script if missing.
