import 'package:flutter/material.dart';

class CustomCarouselController {
  final PageController pageController;

  CustomCarouselController() : pageController = PageController();

  void nextPage({Duration? duration, Curve? curve}) {
    pageController.nextPage(
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
    );
  }

  void previousPage({Duration? duration, Curve? curve}) {
    pageController.previousPage(
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
    );
  }

  void animateToPage(int page, {Duration? duration, Curve? curve}) {
    pageController.animateToPage(
      page,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
    );
  }

  void dispose() {
    pageController.dispose();
  }
} 