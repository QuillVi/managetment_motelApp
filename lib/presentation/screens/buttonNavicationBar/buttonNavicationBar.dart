import 'package:flutter/material.dart';
import 'package:motelapp/presentation/screens/building/building_screen.dart';
import 'package:motelapp/presentation/screens/cost/cost_screen.dart';
import 'package:motelapp/presentation/screens/home/home_screen.dart';
import 'package:motelapp/presentation/screens/manage/manage_screen.dart';
import 'package:motelapp/presentation/screens/message/message_screen.dart';

class Buttonnavicationbar extends StatefulWidget {
  final int index;
  const Buttonnavicationbar({super.key, this.index = 0});

  static _ButtonnavicationbarState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ButtonnavicationbarState>();

  @override
  State<Buttonnavicationbar> createState() => _ButtonnavicationbarState();
}

class _ButtonnavicationbarState extends State<Buttonnavicationbar> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.index;

    _widgetOptions = <Widget>[
      HomeScreen(),
      BuildingScreen(),
      MessageScreen(),
      CostScreen(),
      ManageScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                children: [
                  Icon(Icons.home_outlined),
                  SizedBox(height: 2),
                  Text(
                    'Home',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                children: [
                  Icon(Icons.apartment_outlined),
                  SizedBox(height: 2),
                  Text(
                    'Building',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                children: [
                  Icon(Icons.message_outlined),
                  SizedBox(height: 2),
                  Text(
                    'Message',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                children: [
                  Icon(Icons.attach_money_outlined),
                  SizedBox(height: 2),
                  Text(
                    'Cost',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                children: [
                  Icon(Icons.person_outlined),
                  SizedBox(height: 2),
                  Text(
                    'Manage',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            label: '',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        iconSize: 26,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        backgroundColor: Colors.white,
      ),
    );
  }
}
