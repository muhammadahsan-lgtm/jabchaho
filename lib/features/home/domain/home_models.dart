import 'package:flutter/material.dart';

@immutable
class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    required this.detail,
    required this.icon,
    this.isMore = false,
  });

  final String id;
  final String name;
  final String detail;
  final IconData icon;
  final bool isMore;
}

@immutable
class SmartSuggestion {
  const SmartSuggestion({
    required this.id,
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.icon,
    required this.isHighlighted,
  });

  final String id;
  final String eyebrow;
  final String title;
  final String detail;
  final IconData icon;
  final bool isHighlighted;
}

@immutable
class ActiveOrder {
  const ActiveOrder({
    required this.title,
    required this.status,
    required this.eta,
    required this.progress,
    required this.icon,
  });

  final String title;
  final String status;
  final String eta;
  final double progress;
  final IconData icon;
}

@immutable
class HomeDashboardData {
  const HomeDashboardData({
    required this.services,
    required this.suggestions,
    required this.activeOrder,
  });

  final List<ServiceCategory> services;
  final List<SmartSuggestion> suggestions;
  final ActiveOrder activeOrder;
}
