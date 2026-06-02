import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:pdam_app/services/bill_service.dart';
import 'package:pdam_app/theme/app_theme.dart';

// Admin View Imports
import 'package:pdam_app/views/admin/customer_detail_view.dart';
import 'package:pdam_app/views/admin/edit_customer_view.dart';
import 'package:pdam_app/views/admin/profile_admin_edit_view.dart';
import 'package:pdam_app/views/admin/tambah_customer_view.dart';
import 'package:pdam_app/views/admin/tambah_service_view.dart';
import 'package:pdam_app/views/admin/dashboard_admin_view.dart';
import 'package:pdam_app/views/admin/service_view.dart';
import 'package:pdam_app/views/admin/customer_view.dart';
import 'package:pdam_app/views/admin/bill_view.dart';
import 'package:pdam_app/views/admin/bill_edit_view.dart';
import 'package:pdam_app/views/admin/bill_detail_view.dart';
import 'package:pdam_app/views/admin/profile_admin_view.dart';
import 'package:pdam_app/views/customer/bannerTips_view.dart';
import 'package:pdam_app/views/customer/bantuan_view.dart';

// Customer View Imports
import 'package:pdam_app/views/customer/dashboard_customer_view.dart';
import 'package:pdam_app/views/customer/bill_customer_view.dart';
import 'package:pdam_app/views/customer/profile_customer_edit_view.dart';
import 'package:pdam_app/views/customer/upload_payment_view.dart';
import 'package:pdam_app/views/customer/payment_view.dart';
import 'package:pdam_app/views/customer/payment_detail_view.dart';
import 'package:pdam_app/views/customer/profile_customer_view.dart';

// Auth & Splash Imports
import 'package:pdam_app/views/splash_view.dart';
import 'package:pdam_app/views/register_view.dart';
import 'package:pdam_app/views/login_view.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Menahan native splash screen agar tidak langsung hilang
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // PENTING: FlutterNativeSplash.remove() DIHAPUS dari sini
    // agar dipanggil di dalam SplashView untuk transisi yang mulus.

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDAM App',
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),

        // Admin routes
        '/admin/dashboard': (context) => const DashboardAdminView(),
        '/admin/services': (context) => const ServiceView(),
        '/admin/services/add': (context) => const TambahLayananView(),
        '/admin/customers': (context) => const CustomerView(),
        '/admin/customers/add': (context) => const AddCustomerView(),
        '/admin/customers/edit': (context) => const EditCustomerView(),
        '/admin/customers/detail': (context) => const CustomerDetailView(),
        '/admin/bills': (context) => const BillView(),
        '/admin/bills/edit': (context) => EditBillPage(
          existing: const {},
          billApi: BillService(),
          onSuccess: () {},
        ),
        '/admin/bills/detail': (context) => BillDetailScreen(
          bill: const {},
          status: "",
          onReject: (id, pid) {},
          onVerify: (pid) {},
        ),
        '/admin/profile': (context) => const ProfileAdminView(),
        '/admin/profile/edit': (context) => const EditAdminView(),

        // Customer routes
        '/customer/dashboard': (context) => const DashboardCustomerView(),
        '/customer/dashboard/tips': (context) => const BannerTipsView(),
        '/customer/dashboard/bantuan': (context) => const CallAdminView(),
        '/customer/bills': (context) => const CustomerBillView(),
        '/customer/uploadPayment': (context) =>
            const CustomerCreatePaymentView(bill: {}),
        '/customer/payments': (context) => const CustomerPaymentView(),
        '/customer/payments/detail': (context) =>
            const CustomerPaymentDetailView(payment: {}),
        '/customer/profile': (context) => const ProfileCustomerView(),
        '/customer/profile/edit': (context) => const EditProfileCustomerView(),
      },
    );
  }
}
