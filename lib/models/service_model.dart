// lib/models/service.dart

import 'package:flutter/material.dart';

class ServiceModel {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  const ServiceModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}