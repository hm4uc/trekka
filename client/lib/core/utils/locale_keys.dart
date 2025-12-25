// lib/core/utils/locale_keys.dart
// This file provides type-safe access to translation keys
// Usage: LocaleKeys.home.tr() instead of "home".tr()

class LocaleKeys {
  // App general
  static const String appName = 'app_name';
  static const String welcome = 'welcome';
  static const String home = 'home';
  static const String explore = 'explore';
  static const String journey = 'journey';
  static const String favorites = 'favorites';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String logout = 'logout';
  static const String cancel = 'cancel';
  static const String save = 'save';
  static const String edit = 'edit';
  static const String delete = 'delete';
  static const String confirm = 'confirm';
  static const String back = 'back';
  static const String search = 'search';
  static const String filter = 'filter';
  static const String sort = 'sort';
  static const String retry = 'retry';

  // Settings
  static const String settingsGeneral = 'settings_general';
  static const String settingsLanguage = 'settings_language';
  static const String settingsCurrentLanguage = 'settings_current_language';
  static const String settingsLocation = 'settings_location';
  static const String settingsAllowLocation = 'settings_allow_location';
  static const String settingsAccount = 'settings_account';
  static const String settingsChangePassword = 'settings_change_password';
  static const String settingsPrivacy = 'settings_privacy';
  static const String settingsSupport = 'settings_support';
  static const String settingsContact = 'settings_contact';
  static const String settingsAbout = 'settings_about';
  static const String settingsVersion = 'settings_version';

  // Logout
  static const String logoutTitle = 'logout_title';
  static const String logoutMessage = 'logout_message';

  // Language
  static const String languageDialogTitle = 'language_dialog_title';
  static const String languageVietnamese = 'language_vietnamese';
  static const String languageEnglish = 'language_english';

  // Features
  static const String destinations = 'destinations';
  static const String events = 'events';
  static const String trips = 'trips';
  static const String reviews = 'reviews';

  // Journey/Trips
  static const String createTrip = 'create_trip';
  static const String tripTitle = 'trip_title';
  static const String tripDescription = 'trip_description';
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';
  static const String budget = 'budget';
  static const String participants = 'participants';
  static const String manageTrips = 'manage_trips';
  static const String createNewTrip = 'create_new_trip';
  static const String draft = 'draft';
  static const String active = 'active';
  static const String completed = 'completed';
  static const String noTrips = 'no_trips';
  static const String noActiveTips = 'no_active_trips';
  static const String noCompletedTrips = 'no_completed_trips';
  static const String tripDetails = 'trip_details';
  static const String editTrip = 'edit_trip';
  static const String shareTrip = 'share_trip';
  static const String deleteTrip = 'delete_trip';
  static const String addDestination = 'add_destination';
  static const String chooseDestination = 'choose_destination';
  static const String pleaseChooseDestination = 'please_choose_destination';
  static const String pleaseChooseDates = 'please_choose_dates';
  static const String searchDestinations = 'search_destinations';
  static const String searchDestinationsFeature = 'search_destinations_feature';
  static const String pleaseEnterTripName = 'please_enter_trip_name';
  static const String pleaseEnterDestination = 'please_enter_destination';

  // Profile
  static const String personalInfo = 'personal_info';
  static const String bio = 'bio';
  static const String activityStats = 'activity_stats';
  static const String destinationsVisited = 'destinations_visited';
  static const String eventsAttended = 'events_attended';
  static const String travelDna = 'travel_dna';
  static const String myTrips = 'my_trips';
  static const String favoriteDestinations = 'favorite_destinations';
  static const String visitedDestinations = 'visited_destinations';
  static const String favoriteEvents = 'favorite_events';
  static const String attendedEvents = 'attended_events';
  static const String myReviews = 'my_reviews';
  static const String editProfile = 'edit_profile';
  static const String accountCreated = 'account_created';
  static const String ageYears = 'age_years';
  static const String male = 'male';
  static const String female = 'female';
  static const String other = 'other';
  static const String notSelected = 'not_selected';
  static const String travelProfile = 'travel_profile';
  static const String expectedBudget = 'expected_budget';
  static const String notSetYet = 'not_set_yet';
  static const String preferencesStyle = 'preferences_style';
  static const String noPreferences = 'no_preferences';

  // Explore
  static const String exploreTitle = 'explore_title';
  static const String searchPlaces = 'search_places';
  static const String categories = 'categories';
  static const String category = 'category';
  static const String nearby = 'nearby';
  static const String popular = 'popular';
  static const String recommended = 'recommended';
  static const String exploreNow = 'explore_now';
  static const String times = 'times';
  static const String filters = 'filters';
  static const String sortBy = 'sort_by';
  static const String travelStyle = 'travel_style';
  static const String budgetFriendly = 'budget_friendly';
  static const String topRated = 'top_rated';
  static const String reset = 'reset';
  static const String applyFilters = 'apply_filters';
  static const String clearAll = 'clear_all';
  static const String allCategories = 'all_categories';
  static const String allStyles = 'all_styles';
  static const String nature = 'nature';
  static const String food = 'food';
  static const String culture = 'culture';
  static const String adventure = 'adventure';

  // Favorites
  static const String favoritesTitle = 'favorites_title';
  static const String liked = 'liked';
  static const String checkedIn = 'checked_in';
  static const String allItems = 'all_items';
  static const String noFavoriteDestinations = 'no_favorite_destinations';
  static const String noFavoriteEvents = 'no_favorite_events';
  static const String noVisitedDestinations = 'no_visited_destinations';
  static const String noAttendedEvents = 'no_attended_events';
  static const String startExploring = 'start_exploring';
  static const String checkInToDestinations = 'check_in_to_destinations';
  static const String attendEvents = 'attend_events';

  // Reviews
  static const String writeReview = 'write_review';
  static const String rating = 'rating';
  static const String comment = 'comment';
  static const String submitReview = 'submit_review';
  static const String pleaseEnterReview = 'please_enter_review';
  static const String noReviews = 'no_reviews';
  static const String reviewSubmittedSuccessfully = 'review_submitted_successfully';

  // Common Messages
  static const String loading = 'loading';
  static const String error = 'error';
  static const String success = 'success';
  static const String noData = 'no_data';
  static const String tryAgain = 'try_again';

  // Onboarding
  static const String skip = 'skip';
  static const String next = 'next';
  static const String finish = 'finish';
  static const String step = 'step';
  static const String selectPreferences = 'select_preferences';
  static const String budgetPerTrip = 'budget_per_trip';
  static const String economical = 'economical';
  static const String moderate = 'moderate';
  static const String comfortable = 'comfortable';
  static const String luxury = 'luxury';
  static const String loadDataError = 'load_data_error';
  static const String pleaseSelectStyle = 'please_select_style';
}

