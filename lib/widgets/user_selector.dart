import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class UserSelector extends StatelessWidget {
  final List<User> users;
  final String? selectedUserId;
  final ValueChanged<String?> onChanged;

  const UserSelector({
    super.key,
    required this.users,
    this.selectedUserId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedUserId,
      decoration: InputDecoration(
        labelText: 'Giao cho thành viên',
        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Chưa phân công', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ...users.map((u) => DropdownMenuItem<String>(
              value: u.id,
              child: Text(u.name, style: const TextStyle(color: AppColors.textPrimary)),
            )),
      ],
      onChanged: onChanged,
    );
  }
}
