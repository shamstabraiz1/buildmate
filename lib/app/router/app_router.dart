import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/labour/presentation/screens/labour_screen.dart';
import '../../features/materials/presentation/screens/add_material_screen.dart';
import '../../features/materials/presentation/screens/material_details_screen.dart';
import '../../features/materials/presentation/screens/materials_screen.dart';
import '../../features/projects/presentation/screens/project_details_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/dev/presentation/screens/developer_screen.dart';
import '../../features/vendors/presentation/screens/add_vendor_screen.dart';
import '../../features/vendors/presentation/screens/vendors_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/payments/presentation/screens/payment_details_screen.dart';
import '../../features/payments/presentation/screens/add_payment_screen.dart';
import 'app_routes.dart';

const bool isDevelopmentMode = true;

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: isDevelopmentMode ? AppRoutes.dev : AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.dev,
        name: AppRouteNames.dev,
        builder: (context, state) => const DeveloperScreen(),
      ),
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRouteNames.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.projects,
        name: AppRouteNames.projects,
        builder: (context, state) => const ProjectsScreen(),
      ),
      GoRoute(
        path: AppRoutes.projectDetails,
        name: AppRouteNames.projectDetails,
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          return ProjectDetailsScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.expenses,
        name: AppRouteNames.expenses,
        builder: (context, state) => const ExpensesScreen(),
      ),
      GoRoute(
        path: AppRoutes.labour,
        name: AppRouteNames.labour,
        builder: (context, state) => const LabourScreen(),
      ),
      GoRoute(
        path: AppRoutes.materials,
        name: AppRouteNames.materials,
        builder: (context, state) => const MaterialsScreen(),
      ),
      GoRoute(
        path: AppRoutes.materialDetails,
        name: AppRouteNames.materialDetails,
        builder: (context, state) {
          final materialId = state.pathParameters['materialId'] ?? '';
          return MaterialDetailsScreen(materialId: materialId);
        },
      ),
      GoRoute(
        path: AppRoutes.addMaterial,
        name: AppRouteNames.addMaterial,
        builder: (context, state) => const AddMaterialScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendors,
        name: AppRouteNames.vendors,
        builder: (context, state) => const VendorsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addVendor,
        name: AppRouteNames.addVendor,
        builder: (context, state) => const AddVendorScreen(),
      ),
      GoRoute(
        path: AppRoutes.payments,
        name: AppRouteNames.payments,
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addPayment,
        name: AppRouteNames.addPayment,
        builder: (context, state) => const AddPaymentScreen(),
      ),
      GoRoute(
        path: AppRoutes.paymentDetails,
        name: AppRouteNames.paymentDetails,
        builder: (context, state) {
          final paymentId = state.pathParameters['paymentId'] ?? '';
          return PaymentDetailsScreen(paymentId: paymentId);
        },
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: AppRouteNames.reports,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
