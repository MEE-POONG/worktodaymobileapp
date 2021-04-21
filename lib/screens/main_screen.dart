import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/profile/profile_page.dart';
import '../pages/history/history_page.dart';
import '../pages/user/user_page.dart';
import '../pages/report/report_page.dart';
import 'checkin_or_checkout.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String status = "USER";
  @override
  void initState() {
    super.initState();
    checkPrereferences();
  }

  Future<Null> checkPrereferences() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      setState(() {
        status = preferences.getString('status');
      });
    } catch (e) {}
  }

  int _selectedIndex = 0;
  List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];

  final nameTitleBar = ['CHECK IN', 'PROFILE', 'HISTORY', 'USER', 'REPORT'];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          final isFirstRouteInCurrentTab =
              !await _navigatorKeys[_selectedIndex].currentState.maybePop();
          // let system handle back button if we're on the first route
          return isFirstRouteInCurrentTab;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          floatingActionButton: FloatingActionButton(
            mini: true,
            onPressed: () => _logoutNavigate(context),
            child: Icon(Icons.logout),
            backgroundColor: Colors.blue,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: status != 'ADMIN'
                ? <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.photo_camera_front,
                        color: Colors.black,
                      ),
                      label: 'CAMERA',
                      activeIcon: Icon(
                        Icons.photo_camera_front,
                        size: 36,
                      ),
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        label: 'PROFILE',
                        activeIcon: Icon(
                          Icons.person,
                          size: 36,
                        )),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.history,
                          color: Colors.black,
                        ),
                        label: 'HISTORY',
                        activeIcon: Icon(
                          Icons.history,
                          size: 36,
                        )),
                  ]
                : const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.photo_camera_front,
                        color: Colors.black,
                      ),
                      label: 'CAMERA',
                      activeIcon: Icon(
                        Icons.photo_camera_front,
                        size: 36,
                      ),
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        label: 'PROFILE',
                        activeIcon: Icon(
                          Icons.person,
                          size: 36,
                        )),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.history,
                          color: Colors.black,
                        ),
                        label: 'HISTORY',
                        activeIcon: Icon(
                          Icons.history,
                          size: 36,
                        )),
                    BottomNavigationBarItem(
                        icon: Icon(
                          Icons.supervisor_account,
                          color: Colors.black,
                        ),
                        label: 'USER',
                        activeIcon: Icon(
                          Icons.supervisor_account,
                          size: 36,
                        )),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.list_alt, color: Colors.black),
                        label: 'REPORT',
                        activeIcon: Icon(
                          Icons.list_alt,
                          size: 36,
                        )),
                  ],
            selectedItemColor: Colors.amber[800],
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          body: Stack(
            children: [
              _buildOffstageNavigator(0),
              _buildOffstageNavigator(1),
              _buildOffstageNavigator(2),
              _buildOffstageNavigator(3),
              _buildOffstageNavigator(4),
            ],
          ),
        ));
  }

  Future _logoutNavigate(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await Navigator.push(context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
    // exit(0);
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {
        return [
          CheckinOrCheckout(),
          ProfilePage(),
          HistoryPage(),
          UserPage(),
          ReportPage(),
        ].elementAt(index);
      },
    };
  }

  Widget _buildOffstageNavigator(int index) {
    var routeBuilders = _routeBuilders(context, index);
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name](context),
          );
        },
      ),
    );
  }
}
