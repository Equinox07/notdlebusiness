// lib/models/service_model.dart

import 'package:flutter/material.dart';

class ServiceModel {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool isComingSoon;

  const ServiceModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.isComingSoon = false,
  });
}
