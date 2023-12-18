import 'package:animate_do/animate_do.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fashion_ecommerce_app/screens/order_history_screen.dart';
import 'package:fashion_ecommerce_app/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

import '../screens/cart.dart';
import '../screens/home.dart';
import '../screens/search.dart';
import '../utils/constants.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _index = 0;
  PageController _pageController = PageController();

  void _onTabTapped(int index) {
    setState(() {
      _index = index;
    });
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(
                LineIcons.shoppingBag,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Cart(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: [Home(), search(), Order_History(), ProfilePage()],
        onPageChanged: (int index) {
          setState(() {
            _index = index;
          });
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white, // Use 'Colors' for colors.
        animationDuration: Duration(milliseconds: 400),
        onTap: _onTabTapped,
        index: _index, // Pass the current index to control the selected item.
        items: [
          Icon(
            Icons.home, // Use 'Icons.pets' as an example.
            color: Colors.orange, // Change the color as desired.
          ),
          Icon(
            Icons.search,
            color: Colors.orange,
          ),
          Icon(
            Icons.check_box,
            color: Colors.orange,
          ),
          Icon(
            Icons.person,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}
