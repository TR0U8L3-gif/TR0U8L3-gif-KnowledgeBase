# Implementation Plan

This document breaks down the development process into actionable steps.

## Phase 1: Core Structure and Data Loading

1.  **Project Setup:**
    *   [x] Create the `app_plan` directory and initial planning documents.
    *   [ ] Add necessary dependencies to `pubspec.yaml`:
        *   `flutter_markdown` for rendering markdown.
        *   `provider` for state management (or a similar solution).
        *   `google_fonts` for custom fonts if needed.

2.  **Data Layer:**
    *   [ ] Create the data models: `Article`, `Directory`, `TocEntry`.
    *   [ ] Implement the `KnowledgeBaseService` to:
        *   [ ] Read the `.order` file in a given directory.
        *   [ ] Recursively scan the `assets/knowledge_base` directory.
        *   [ ] Load the content of markdown files.
        *   [ ] Parse the table of contents from the markdown content.

3.  **Domain Layer:**
    *   [ ] Implement the `KnowledgeBaseRepository` to:
        *   [ ] Use the `KnowledgeBaseService` to fetch the knowledge base structure.
        *   [ ] Provide a method to get the navigation tree.
        *   [ ] Provide a method to get a specific article by its path.
    *   [ ] Create the `AppState` `ChangeNotifier` to manage:
        *   [ ] The currently selected article.
        *   [ ] The current theme mode.

## Phase 2: UI Implementation

1.  **Basic Layout:**
    *   [ ] Create the `HomePage` widget with a three-panel layout. Use `Row` and `Expanded` widgets to create the panels.
    *   [ ] Set up the `MaterialApp` in `main.dart` to use the `AppState` provider.

2.  **Navigation Panel:**
    *   [ ] Create the `NavigationPanel` widget.
    *   [ ] It should get the navigation tree from the `KnowledgeBaseRepository`.
    *   [ ] Display the articles and directories in a `ListView`.
    *   [ ] When an article is tapped, update the `AppState` with the selected article.

3.  **Article Panel:**
    *   [ ] Create the `ArticlePanel` widget.
    *   [ ] It should listen to changes in the `AppState` for the currently selected article.
    *   [ ] Use the `flutter_markdown` widget to render the article's content.

4.  **Table of Contents Panel:**
    *   [ ] Create the `TocPanel` widget.
    *   [ ] It should display the `TocEntry` list from the current `Article`.
    *   [ ] When a `TocEntry` is tapped, the `ArticlePanel` should scroll to the corresponding section. This will require a `ScrollController`.

## Phase 3: Features

1.  **Theme Toggle:**
    *   [ ] Create the `ThemeToggleButton` widget.
    *   [ ] Add it to the `HomePage`'s app bar.
    *   [ ] When tapped, it should call a method in `AppState` to toggle the theme.
    *   [ ] The `MaterialApp`'s `theme` and `darkTheme` properties should be configured to respond to the `AppState`.

2.  **Search Bar:**
    *   [ ] Create the `SearchBar` widget.
    *   [ ] Add it to the `HomePage`'s app bar.
    *   [ ] As the user types, update a search query property in `AppState`.
    *   [ ] The `NavigationPanel` should filter its contents based on the search query.

## Phase 4: Refinement and Testing

1.  **Styling:**
    *   [ ] Apply a consistent and visually appealing theme to the application.
    *   [ ] Use `google_fonts` to improve typography.
    *   [ ] Ensure the dark theme is well-implemented.

2.  **Testing:**
    *   [ ] Write unit tests for the `KnowledgeBaseService` and `KnowledgeBaseRepository`.
    *   [ ] Write widget tests for the main UI components.

3.  **Final Touches:**
    *   [ ] Add loading indicators for asynchronous operations.
    *   [ ] Handle potential errors, such as missing files.
    *   [ ] Ensure the application is responsive and works well on different screen sizes (web and macOS).
