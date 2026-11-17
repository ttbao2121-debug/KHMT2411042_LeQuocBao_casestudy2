import 'package:flutter/material.dart';
import 'screens/assignment/assign_task_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/notifications/notification_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/sharing/task_sharing_screen.dart';
import 'screens/tasks/task_create_screen.dart';
import 'screens/tasks/task_detail_screen.dart';
import 'screens/tasks/task_edit_screen.dart';
import 'screens/tasks/task_list_screen.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/tasks': (context) => const TaskListScreen(),
        '/task-detail': (context) => const TaskDetailScreen(),
        '/task-create': (context) => const TaskCreateScreen(),
        '/task-edit': (context) => const TaskEditScreen(),
        '/assign-task': (context) => const AssignTaskScreen(),
        '/task-sharing': (context) => const TaskSharingScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
