import 'package:flutter/material.dart';

import '../domain/home_models.dart';
import '../domain/home_repository.dart';

final class StaticHomeRepository implements HomeRepository {
  const StaticHomeRepository();

  @override
  HomeDashboardData loadDashboard() => const HomeDashboardData(
    services: [
      ServiceCategory(
        id: 'food',
        name: 'Food',
        detail: '25–35 min',
        icon: Icons.restaurant_rounded,
      ),
      ServiceCategory(
        id: 'grocery',
        name: 'Grocery',
        detail: '20–30 min',
        icon: Icons.shopping_basket_rounded,
      ),
      ServiceCategory(
        id: 'laundry',
        name: 'Laundry',
        detail: 'Pickup in 15',
        icon: Icons.local_laundry_service_rounded,
      ),
      ServiceCategory(
        id: 'pharmacy',
        name: 'Pharmacy',
        detail: 'From 18 min',
        icon: Icons.medication_rounded,
      ),
      ServiceCategory(
        id: 'ride',
        name: 'Ride',
        detail: '2 min away',
        icon: Icons.local_taxi_rounded,
      ),
      ServiceCategory(
        id: 'home',
        name: 'Home care',
        detail: 'Book today',
        icon: Icons.home_repair_service_rounded,
      ),
      ServiceCategory(
        id: 'courier',
        name: 'Courier',
        detail: 'Send now',
        icon: Icons.local_shipping_rounded,
      ),
      ServiceCategory(
        id: 'more',
        name: 'More',
        detail: 'See all 18',
        icon: Icons.add_rounded,
        isMore: true,
      ),
    ],
    suggestions: [
      SmartSuggestion(
        id: 'repeat',
        eyebrow: 'SMART REPEAT',
        title: 'Running low on\nyour weekly staples?',
        detail: '8 usual items · Rs 2,840',
        icon: Icons.shopping_bag_rounded,
        isHighlighted: true,
      ),
      SmartSuggestion(
        id: 'routine',
        eyebrow: 'RIGHT ON TIME',
        title: 'Laundry pickup\nat 6:30 PM?',
        detail: 'Based on your routine',
        icon: Icons.local_laundry_service_rounded,
        isHighlighted: false,
      ),
    ],
    activeOrder: ActiveOrder(
      title: 'Dinner is on the way',
      status: 'Rider is picking up your order',
      eta: '12 min',
      progress: 0.67,
      icon: Icons.restaurant_rounded,
    ),
  );
}
