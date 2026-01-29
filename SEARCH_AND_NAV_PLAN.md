# Universal Search & Navigation Implementation Plan

## Overview
This document outlines the plan to implement a fully functional top navigation bar with a robust, universal search feature for the Kejapin application. The search will be context-aware, visually rich, and provide seamless navigation to various content types (Listings, Landlords, Locations, Coordinates).

## 1. Architecture & Data Layer

### 1.1 Search Data Models
We will define a unified search result model to handle different data types.

```dart
enum SearchResultType { listing, landlord, location, coordinate }

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final SearchResultType type;
  final Map<String, dynamic> metadata; // Extra data (lat/long, price, etc.)

  SearchResult({required this.id, required this.title, required this.type, ...});
}
```

### 1.2 Search Repository
A `SearchRepository` will be responsible for aggregating results from multiple sources (Listings API, Users API, Geocoding API).

*   **`searchUniversal(String query)`**: Returns a mix of all types.
*   **`searchListings(String query)`**: Returns only listings (for Marketplace).
*   **`searchLocations(String query)`**: Returns locations/coordinates.

### 1.3 State Management (BLoC/Cubit)
*   **`SearchBloc`**: Manages the state of the search overlay.
    *   `SearchInitial`: Empty state.
    *   `SearchLoading`: Showing skeletons/spinners.
    *   `SearchLoaded`: Displaying grouped results.
    *   `SearchError`: Error state.

## 2. UI Components

### 2.1 Enhanced Top Navigation Bar (`TopNavBar`)
*   **Layout**:
    *   Left: Logo/Menu Icon.
    *   Center: `UniversalSearchBar` (Expanded).
    *   Right: Notification/Profile Icons.
*   **Styling**: Glassmorphism effect, sticky positioning.

### 2.2 Universal Search Bar (`UniversalSearchBar`)
*   **Interaction**:
    *   On tap: Expands or opens the `SearchResultsOverlay`.
    *   On type: Debounced API call to `searchUniversal`.
*   **Visuals**: Rounded corners, search icon, clear button.

### 2.3 Search Results Overlay (`SearchResultsOverlay`)
*   **Behavior**: Appears *under* the search bar (like a dropdown or modal).
*   **Structure**:
    *   **Categorized Sections**:
        *   "Locations" (Map icons).
        *   "Apartments/Buildings" (Thumbnail images).
        *   "Landlords" (Avatars).
    *   **Section Headers**: Title + "View All" button.
    *   **"View All Results"**: Button at the bottom to see everything in a full screen.

### 2.4 Result Items (`ResultTile`)
*   **Design**:
    *   **Listings**: Thumbnail, Title (Price), Subtitle (Address).
    *   **Landlords**: Circular Avatar, Name, Rating.
    *   **Locations**: Map Pin Icon, Address/Name, Distance.
*   **Animations**: Staggered entrance animation (fade + slide up).

## 3. Navigation Logic

### 3.1 Routing Strategy
*   **Coordinates/Location** -> `MapScreen`:
    *   Focuses on the specific coordinate.
    *   Shows nearby amenities/listings.
*   **Apartment/Listing** -> `ListingDetailsScreen`:
    *   Full details, gallery, booking options.
*   **Landlord** -> `LandlordDetailsScreen`:
    *   Profile, other listings, reviews.

### 3.2 "View All" Screens
*   **`AllResultsScreen`**: A dedicated page with tabs for each category (All, Listings, People, Places).
*   **`CategoryResultsScreen`**: When clicking "View All" on a specific section.

## 4. Marketplace Specifics

### 4.1 Marketplace Search Behavior
*   **Default**: List view of listings matching the query.
*   **Location Query**:
    *   Detects if query is a place.
    *   Opens `MapScreen` centered on that location.
    *   User can toggle back to List View.
*   **Filters**: Price range, amenities, type (Studio, 1BR, etc.).

## 5. Visuals & Animations
*   **Glassmorphism**: Use `glassmorphism` package for the search overlay background.
*   **Looped Animations**: Subtle pulsing or glowing effects on "Featured" results.
*   **Hero Animations**: Smooth transition from search result thumbnail to details page image.
*   **Micro-interactions**: Ripple effects on tap, smooth expansion of the search bar.

## 6. Implementation Steps

1.  **Setup Models & Repos**: Create `SearchResult` model and `SearchRepository`.
2.  **Bloc Setup**: Implement `SearchBloc`.
3.  **UI - Search Bar**: Build the `UniversalSearchBar` widget.
4.  **UI - Overlay**: Build the `SearchResultsOverlay` with grouped lists.
5.  **Screens**: Skeleton implementations of `ListingDetails`, `LandlordDetails`, `MapScreen` (if not existing).
6.  **Integration**: Connect Search UI to Bloc and Navigation.
7.  **Polish**: Add animations, glassmorphism, and error handling.

## 7. Dependencies
*   `flutter_bloc`
*   `go_router`
*   `glassmorphism`
*   `animate_do` (or manual animations)
*   `flutter_map` (for map views)
