import 'package:flutter/material.dart';
import 'package:pdam_app/models/user_login.dart';

class BottomNav extends StatefulWidget {
  final int activePage;

  const BottomNav(this.activePage, {super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  UserLogin userLogin = UserLogin();

  String role = "CUSTOMER";

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      var user = await userLogin.getUserLogin();

      if (mounted && user != null) {
        setState(() {
          role = user.role?.toUpperCase() ?? "CUSTOMER";
        });
      }
    } catch (_) {}
  }

  void getLink(int index) {
    if (role == "ADMIN") {
      final routes = [
        '/admin/dashboard',
        '/admin/services',
        '/admin/customers',
        '/admin/bills',
        '/admin/profile',
      ];

      if (widget.activePage != index) {
        Navigator.pushReplacementNamed(
          context,
          routes[index],
        );
      }
    } else {
      final routes = [
        '/customer/dashboard',
        '/customer/bills',
        '/customer/payments',
        '/customer/profile',
      ];

      if (widget.activePage != index) {
        Navigator.pushReplacementNamed(
          context,
          routes[index],
        );
      }
    }
  }

  Widget navItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bool active = widget.activePage == index;

    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => getLink(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: active
                  ? const Color(0xff2563EB)
                  : Colors.black87,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w500,
                color: active
                    ? const Color(0xff2563EB)
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = role == "ADMIN"
        ? [
            navItem(
              index: 0,
              icon: Icons.home_outlined,
              title: "Dashboard",
            ),
            navItem(
              index: 1,
              icon: Icons.settings_outlined,
              title: "Layanan",
            ),
            navItem(
              index: 2,
              icon: Icons.people_outline,
              title: "Customer",
            ),
            navItem(
              index: 3,
              icon: Icons.receipt_long_outlined,
              title: "Tagihan",
            ),
            navItem(
              index: 4,
              icon: Icons.person_outline,
              title: "Profil",
            ),
          ]
        : [
            navItem(
              index: 0,
              icon: Icons.home_outlined,
              title: "Dashboard",
            ),
            navItem(
              index: 1,
              icon: Icons.receipt_long_outlined,
              title: "Tagihan",
            ),
            navItem(
              index: 2,
              icon: Icons.credit_card_outlined,
              title: "Pembayaran",
            ),
            navItem(
              index: 3,
              icon: Icons.person_outline,
              title: "Profil",
            ),
          ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, -2),
                  color: Colors.black12,
                ),
              ],
            ),
            child: Row(
              children: items,
            ),
          ),
        ),
      ),
    );
  }
}