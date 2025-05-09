import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  
  factory NavigationService() => _instance;
  
  NavigationService._internal();
  
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  PageController? homePageController;

  Function(int)? updateSelectedIndex;

  void navigateToPageIndex(int index) {
    if (homePageController != null) {
      homePageController!.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      if (updateSelectedIndex != null) {
        updateSelectedIndex!(index);
      }
    }
  }
}