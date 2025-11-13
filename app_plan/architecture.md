# Application Architecture

This document describes the proposed architecture for the Knowledge Base application.

## Overview

The application will be built using the Flutter framework and will follow a clean, scalable architecture. We will separate concerns into three main layers:

1.  **Data Layer:** Responsible for fetching and parsing the knowledge base content.
2.  **Domain Layer:** Contains the business logic of the application.
3.  **Presentation Layer:** The UI of the application, built with Flutter widgets.

## Data Layer

*   **`KnowledgeBaseService`:** A class responsible for reading the markdown files and `.order` files from the `assets/knowledge_base` directory.
    *   It will use `rootBundle` to load the asset files.
    *   It will parse the `.order` files to determine the correct order of articles and directories.
    *   It will have methods to get the list of articles and directories, and to get the content of a specific article.
*   **Models:**
    *   **`Article`:** A class representing a single article. It will contain the title, content (as a string), and a list of `TocEntry` objects for the table of contents.
    *   **`Directory`:** A class representing a directory of articles. It will contain the directory name and a list of its children (articles or sub-directories).
    *   **`TocEntry`:** A class representing an entry in the table of contents. It will contain the title of the section and a key to jump to that section.

## Domain Layer

*   **`KnowledgeBaseRepository`:** This will be the single source of truth for the application's data. It will use the `KnowledgeBaseService` to fetch the data and will cache it in memory.
    *   It will expose streams of data that the presentation layer can listen to. For example, a `Stream<List<dynamic>>` for the navigation tree, and a `Stream<Article>` for the currently selected article.
*   **State Management:** We will use a `ChangeNotifier` or a similar state management solution (like Riverpod or BLoC, but starting with the simplest) to manage the application's state.
    *   **`AppState`:** A `ChangeNotifier` that will hold the application's state, such as the current theme mode, the search query, and the currently selected article.

## Presentation Layer

The UI will be composed of several main widgets:

*   **`HomePage`:** The main screen of the application. It will contain the three-panel layout.
*   **`NavigationPanel`:** The left panel, displaying the ordered list of articles and directories. It will be a `ListView` or a similar scrollable widget.
*   **`ArticlePanel`:** The center panel, displaying the content of the selected article. We will use the `flutter_markdown` package to render the markdown content.
*   **`TocPanel`:** The right panel, displaying the table of contents for the current article.
*   **`SearchBar`:** A widget at the top of the `HomePage` for user input.
*   **`ThemeToggleButton`:** A button to toggle between light and dark themes.

## Directory Structure

The `lib` directory will be organized as follows:

```
lib/
├── src/
│   ├── data/
│   │   ├── models/
│   │   │   ├── article.dart
│   │   │   ├── directory.dart
│   │   │   └── toc_entry.dart
│   │   └── services/
│   │       └── knowledge_base_service.dart
│   ├── domain/
│   │   ├── repositories/
│   │   │   └── knowledge_base_repository.dart
│   │   └── state/
│   │       └── app_state.dart
│   └── presentation/
│       ├── widgets/
│       │   ├── navigation_panel.dart
│       │   ├── article_panel.dart
│       │   ├── toc_panel.dart
│       │   ├── search_bar.dart
│       │   └── theme_toggle_button.dart
│       └── screens/
│           └── home_page.dart
└── main.dart
```
