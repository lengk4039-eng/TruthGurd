import 'package:flutter/material.dart';

enum InsuranceCategoryType {
  health,
  life,
  vehicle,
  home,
  travel;

  static InsuranceCategoryType fromJson(String value) =>
      values.byName(value.toLowerCase());
  String toJson() => name.toUpperCase();
}

extension InsuranceCategoryTypeX on InsuranceCategoryType {
  String get label {
    switch (this) {
      case InsuranceCategoryType.health:
        return 'Health';
      case InsuranceCategoryType.life:
        return 'Life';
      case InsuranceCategoryType.vehicle:
        return 'Vehicle';
      case InsuranceCategoryType.home:
        return 'Home';
      case InsuranceCategoryType.travel:
        return 'Travel';
    }
  }

  IconData get icon {
    switch (this) {
      case InsuranceCategoryType.health:
        return Icons.favorite_rounded;
      case InsuranceCategoryType.life:
        return Icons.shield_rounded;
      case InsuranceCategoryType.vehicle:
        return Icons.directions_car_rounded;
      case InsuranceCategoryType.home:
        return Icons.home_rounded;
      case InsuranceCategoryType.travel:
        return Icons.flight_takeoff_rounded;
    }
  }

  String get imageAsset {
    switch (this) {
      case InsuranceCategoryType.health:
        return 'assets/images/health.jpg';
      case InsuranceCategoryType.life:
        return 'assets/images/life.jpg';
      case InsuranceCategoryType.vehicle:
        return 'assets/images/auto.jpg';
      case InsuranceCategoryType.home:
        return 'assets/images/home.jpg';
      case InsuranceCategoryType.travel:
        return 'assets/images/travel.jpg';
    }
  }
}
