import 'package:flutter/foundation.dart';
import 'package:swipeshare_app/components/onboarding/swipes_marketplace_mockup.dart';

class OnboardingPage2Controller extends ChangeNotifier {
  final Set<String> _activeLocationFilters = {'Lenoir', 'Chase'};
  int? _selectedListingIndex;

  static const Set<String> _allowedLocations = {'Lenoir', 'Chase'};

  Set<String> get activeLocationFilters => _activeLocationFilters;
  int? get selectedListingIndex => _selectedListingIndex;

  void toggleLocation(String location) {
    if (!_allowedLocations.contains(location)) return;

    if (_activeLocationFilters.contains(location)) {
      if (_activeLocationFilters.length > 1) {
        _activeLocationFilters.remove(location);
      }
    } else {
      _activeLocationFilters.add(location);
    }

    _clampSelectedListing();
    notifyListeners();
  }

  void selectListing(int index) {
    if (index < 0) return;
    _selectedListingIndex = index;
    _clampSelectedListing();
    notifyListeners();
  }

  void _clampSelectedListing() {
    final filteredLength =
        OnboardingSwipesMarketplaceMockup.filteredCountForFilters(
          _activeLocationFilters,
        );
    if (_selectedListingIndex != null &&
        _selectedListingIndex! >= filteredLength) {
      _selectedListingIndex = null;
    }
  }
}

class OnboardingPage3Controller extends ChangeNotifier {
  bool _showForm = false;

  bool get showForm => _showForm;

  void toggleForm() {
    _showForm = !_showForm;
    notifyListeners();
  }
}

class OnboardingPage4Controller extends ChangeNotifier {
  int? _selectedCard;

  int? get selectedCard => _selectedCard;

  String get title {
    switch (_selectedCard) {
      case 0:
        return 'Active Orders';
      case 1:
        return 'Your Listings';
      default:
        return 'Dashboard';
    }
  }

  String get description {
    switch (_selectedCard) {
      case 0:
        return "These are swipes you're buying.\nTap an order to view details or chat with the seller!";
      case 1:
        return "These are swipes you're selling.\nTap to edit or remove a listing!";
      default:
        return 'View your current orders and active listings.\nTap them to see details or make edits!';
    }
  }

  void selectCard(int index) {
    if (index < 0 || index > 1) return;
    _selectedCard = index;
    notifyListeners();
  }
}
