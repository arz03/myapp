
# Tuition Tracker App Blueprint

## Overview

A simple and intuitive Flutter application for tuition teachers to track their classes, students, and topics. The app will feature a calendar view to visualize class schedules and provide an easy way to add new class details.

## Style and Design

*   **Theme:** Modern and clean design with a professional color palette.
*   **Fonts:** Use of `google_fonts` for clear and readable typography.
*   **Layout:** A single-screen layout with a calendar at the top and a list of classes for the selected day below.
*   **Interactivity:** A floating action button to add new classes and interactive calendar elements.

## Features

*   **Calendar View:** A calendar to display the dates on which classes were held.
*   **Class Tracking:** Ability to add and view classes for each day, including the student's name and the topic taught.
*   **State Management:** Use of the `provider` package to manage the app's state.

## Current Plan

1.  **Setup Dependencies:** Add `provider`, `google_fonts`, and `table_calendar` to the `pubspec.yaml` file.
2.  **Create Data Model:** Define a `Class` model to store information about each class (student name, topic, and date).
3.  **Implement State Management:** Create a `TuitionProvider` class to manage the list of classes.
4.  **Build the UI:**
    *   Create the main screen with a `TableCalendar` widget.
    *   Display the list of classes for the selected day.
    *   Add a `FloatingActionButton` to trigger an "Add Class" dialog.
5.  **"Add Class" Dialog:** Create a dialog with text fields for student name and topic, and a button to add the new class.
