import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String iconName;
  final String colorCode;

  CategoryModel({
    this.id,
    required this.name,
    required this.iconName,
    required this.colorCode,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'icon': iconName, 'color': colorCode};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconName: map['icon'] as String,
      colorCode: map['color'] as String,
    );
  }

  IconData get icon {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'receipt':
        return Icons.receipt;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.category;
    }
  }

  Color get color {
    return Color(int.parse(colorCode.substring(1), radix: 16) + 0xFF000000);
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? iconName,
    String? colorCode,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorCode: colorCode ?? this.colorCode,
    );
  }
}
