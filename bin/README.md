# Knowledge Base Documentation Generator

A command-line tool for scanning documentation directories, generating structured metadata, and deploying documentation assets to Flutter projects.

## Overview

This tool helps you manage documentation by:
1. **Scanning** your docs directory and extracting metadata from frontmatter
2. **Copying** files to your Flutter assets folder
3. **Declaring** assets in `pubspec.yaml` automatically
4. **Generating** a structured JSON index for programmatic access

## Quick Start

### The Easy Way: Generate Everything

Run all steps at once with the `generate` command:

```bash
dart run bin/run.dart generate --source docs --assets doc_assets
```

This will:
- ✓ Scan your `docs` directory
- ✓ Copy all files to `doc_assets`
- ✓ Update `pubspec.yaml` with asset paths
- ✓ Create an `index.json` with full metadata

### Step-by-Step Tutorial

#### Step 1: Prepare Your Documentation

Create documentation files with YAML frontmatter. Here's an example:

**docs/api/auth.md:**
```markdown
---
name: Authentication API
description: Authentication endpoints including login, refresh, logout and user information
display: true
tags: ["api", "authentication", "security", "jwt"]
image: null
last_modified: 04.01.2026
created: 03.01.2026
---

# Authentication API

Your documentation content here...
```

#### Step 2: Add Directory Metadata (Optional)

Create `_directory.md` files to control folder display and ordering:

**docs/api/_directory.md:**
```markdown
---
name: API Documentation
description: API documentation files
display: true
icon: api
order:
  - auth.md
  - payments.md
---
```

The `order` field controls the sequence of files and subdirectories.

#### Step 3: Generate Your Knowledge Base

Choose your approach:

**Option A: All-in-One (Recommended)**
```bash
dart run bin/run.dart generate --source docs --assets doc_assets
```

**Option B: Step-by-Step**
```bash
# 1. Generate structure JSON
dart run bin/run.dart structure --source docs --output structure.json

# 2. Copy files to assets
dart run bin/run.dart move --structure structure.json --source docs --assets doc_assets

# 3. Declare in pubspec.yaml
dart run bin/run.dart declare --assets doc_assets --pubspec pubspec.yaml
```

## Commands Reference

### `generate` - Complete Pipeline

Runs all steps: structure generation, file copying, and pubspec declaration.

**Usage:**
```bash
dart run bin/run.dart generate [options]
```

**Options:**
- `--source, -s` (required): Source directory to scan
- `--assets, -a`: Assets output directory (default: `doc_assets`)
- `--pubspec, -p`: Path to pubspec.yaml (default: `pubspec.yaml`)
- `--structure, -o`: Keep structure JSON at this path (deleted by default)
- `--max-depth, -d`: Maximum directory depth (default: `16`)

**Example:**
```bash
dart run bin/run.dart generate --source docs --assets assets/docs --structure docs.json
```

---

### `structure` - Generate JSON Index

Scans a directory and generates a JSON file with metadata from frontmatter.

**Usage:**
```bash
dart run bin/run.dart structure --source <path> [--output <path>]
```

**Options:**
- `--source, -s` (required): Source directory to scan
- `--output, -o`: Output JSON file path
- `--max-depth, -d`: Maximum directory depth (default: `16`)

**Example:**
```bash
dart run bin/run.dart structure --source docs --output structure.json
```

**Output Format:**
```json
{
  "generated": "2026-01-04T15:37:15.355687",
  "directory": {
    "type": "directory",
    "name": "docs",
    "path": ".",
    "description": null,
    "icon": null,
    "items": [
      {
        "type": "file",
        "name": "Authentication API",
        "path": "api/auth.md",
        "description": "Authentication endpoints...",
        "tags": ["api", "authentication"],
        "image": null,
        "last_modified": "2026-01-04T00:00:00.000Z",
        "created": "2026-01-03T00:00:00.000Z",
        "extension": "md"
      }
    ]
  }
}
```

---

### `move` - Copy Files to Assets

Copies files described in a structure JSON to your assets folder.

**Usage:**
```bash
dart run bin/run.dart move --structure <json> --source <path> --assets <path>
```

**Options:**
- `--structure, -i` (required): Input structure JSON file
- `--source, -s` (required): Root directory containing the files
- `--assets, -a`: Assets output directory (default: `doc_assets`)

**Example:**
```bash
dart run bin/run.dart move --structure structure.json --source docs --assets assets/docs
```

This also creates `assets/docs/index.json` with the full structure.

---

### `declare` - Update pubspec.yaml

Scans an assets directory and adds all files to `pubspec.yaml` under `flutter: assets:`.

**Usage:**
```bash
dart run bin/run.dart declare [--assets <path>] [--pubspec <path>]
```

**Options:**
- `--assets, -a`: Assets directory to scan (default: `doc_assets`)
- `--pubspec, -p`: Path to pubspec.yaml (default: `pubspec.yaml`)

**Example:**
```bash
dart run bin/run.dart declare --assets assets/docs
```

**Result in pubspec.yaml:**
```yaml
flutter:
  assets:
    - assets/docs/api/auth.md
    - assets/docs/api/payments.md
    - assets/docs/index.json
```

---

## Frontmatter Reference

### File Frontmatter

All fields are optional. If not provided, defaults will be used.

```yaml
---
name: Display Name           # Defaults to filename
description: Brief summary   # Defaults to null
display: true                # Defaults to null
tags: ["tag1", "tag2"]      # Defaults to null
image: path/to/image.png    # Defaults to null
last_modified: 04.01.2026   # Defaults to file modification time
created: 03.01.2026         # Defaults to file creation time
---
```

**Date Formats Supported:**
- `DD.MM.YYYY` (e.g., `04.01.2026`)
- ISO 8601 (e.g., `2026-01-04T15:37:15Z`)

### Directory Frontmatter

Create `_directory.md` in any folder to customize its metadata.

```yaml
---
name: Folder Display Name    # Defaults to folder name
description: Folder purpose  # Defaults to null
display: true                # Defaults to null
icon: folder-icon           # Defaults to null
order:                       # Control file/folder sequence
  - important-file.md
  - subfolder
  - another-file.md
---
```

The `order` array determines the display sequence. Unlisted items appear after ordered ones (directories first, then files, alphabetically).

---

## Advanced Usage

### Keep Structure JSON for Inspection

```bash
dart run bin/run.dart generate --source docs --structure output/docs.json
```

The structure file won't be deleted and you can inspect it.

### Custom Assets Directory

```bash
dart run bin/run.dart generate --source docs --assets custom/path/docs
```

### Limit Scan Depth

```bash
dart run bin/run.dart structure --source docs --max-depth 5
```

### Multiple Documentation Sets

```bash
# API docs
dart run bin/run.dart generate --source api-docs --assets assets/api

# User guides
dart run bin/run.dart generate --source guides --assets assets/guides
```

---

## Tips & Best Practices

### 1. Use Frontmatter Consistently

Always include at least `name` and `description` for better organization:

```yaml
---
name: Clear, descriptive title
description: One-sentence summary
tags: ["relevant", "searchable", "tags"]
---
```

### 2. Organize with _directory.md

Use `_directory.md` files to:
- Give folders meaningful names
- Control display order
- Add folder descriptions

### 3. Tag Your Content

Use tags for filtering and searching:

```yaml
tags: ["api", "authentication", "security", "rest"]
```

### 4. Version Control Your Structure

Keep the structure JSON in git to track changes:

```bash
dart run bin/run.dart generate --source docs --structure version_control/structure.json
```

### 5. Automate with Scripts

Create a shell script for common operations:

```bash
#!/bin/bash
# rebuild-docs.sh
dart run bin/run.dart generate --source docs --assets assets/docs
flutter pub get
```

---

## Troubleshooting

### Assets not appearing in Flutter?

1. Check `pubspec.yaml` has the correct paths
2. Run `flutter clean && flutter pub get`
3. Restart your IDE/editor

### Files not being copied?

- Verify the source paths in your structure JSON
- Check file permissions
- Ensure no hidden/build directories are interfering

### Frontmatter not parsing?

- Ensure `---` delimiters are on their own lines
- Check YAML syntax (use proper indentation)
- Verify no special characters in values

---

## Project Structure

```
bin/
├── run.dart              # Main CLI entry point
├── commands/             # Command implementations
│   ├── structure_command.dart
│   ├── move_command.dart
│   ├── declare_command.dart
│   └── generate_command.dart
├── core/                 # Core scanning logic
│   ├── directory_scanner.dart
│   ├── file_scanner.dart
│   └── frontmatter.dart
└── utils/                # Utilities
    └── convert.dart
```

---

## Contributing

When adding new features:
1. Add frontmatter fields to `core/frontmatter.dart`
2. Update scanners in `core/` if needed
3. Add command in `commands/` directory
4. Register in `run.dart`
5. Update this README

---

## License

Part of the Knowledge Base project.
