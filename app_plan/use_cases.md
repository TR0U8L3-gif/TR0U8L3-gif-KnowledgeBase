# Use Cases

This document outlines the key use cases for the Knowledge Base application.

## 1. Reading Articles

**Actor:** User

**Goal:** To read an article from the knowledge base.

**Scenario:**

1.  The user opens the application.
2.  The user sees a list of articles and directories in the navigation panel on the left.
3.  The user clicks on an article title.
4.  The content of the article is displayed in the center panel.
5.  The user can scroll through the article to read it.

## 2. Navigating the Knowledge Base

**Actor:** User

**Goal:** To navigate between different articles and directories.

**Scenario:**

1.  The user is viewing an article.
2.  The user clicks on a different article or directory in the navigation panel.
3.  The center panel updates to show the content of the newly selected article.

## 3. Using the Table of Contents

**Actor:** User

**Goal:** To quickly navigate to a specific section of an article.

**Scenario:**

1.  The user is viewing a long article with multiple sections.
2.  The user looks at the Table of Contents panel on the right.
3.  The user clicks on a section title in the Table of Contents.
4.  The center panel scrolls to the corresponding section of the article.

## 4. Searching for Articles

**Actor:** User

**Goal:** To find articles related to a specific topic.

**Scenario:**

1.  The user types a keyword into the search bar at the top of the application.
2.  The navigation panel on the left is updated to show a list of articles that match the search query.
3.  The user clicks on one of the search results.
4.  The selected article is displayed in the center panel, with the search term potentially highlighted.

## 5. Changing the Theme

**Actor:** User

**Goal:** To switch between light and dark mode.

**Scenario:**

1.  The user clicks on the theme toggle button in the application's header.
2.  The application's color scheme switches from light to dark, or vice-versa.
3.  The user's preference is saved for future sessions.

## 6. Ordered Articles and Directories

**Actor:** Content Creator

**Goal:** To define a custom order for articles and directories.

**Scenario:**

1.  The content creator adds a `.order` file to a directory within the `assets/knowledge_base`.
2.  The `.order` file contains a list of filenames and directory names, one per line.
3.  The application reads the `.order` file and displays the articles and directories in the specified order in the navigation panel.
4.  If an `.order` file is not present, the application will default to alphabetical order.
