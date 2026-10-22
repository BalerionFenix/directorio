import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../data/models/contact.dart';

/// Burbuja de contacto: iniciales sobre el color del departamento y un punto
/// de estado (verde activo / gris inactivo) en la esquina.
class ContactAvatar extends StatelessWidget {
  final Contact contact;
  final double size;

  const ContactAvatar({
    super.key,
    required this.contact,
    this.size = AppDimens.avatarMd,
  });

  @override
  Widget build(BuildContext context) {
    final dot = size >= AppDimens.avatarLg
        ? AppDimens.statusDot + 4
        : AppDimens.statusDot;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.forDepartment(contact.department),
              shape: BoxShape.circle,
            ),
            child: Text(
              contact.initials,
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.34,
              ),
            ),
          ),
          Positioned(
            right: size * 0.02,
            bottom: size * 0.02,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: contact.active ? AppColors.active : AppColors.inactive,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
