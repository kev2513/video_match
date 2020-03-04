import 'package:flutter/material.dart';
import 'package:video_match/screen/playVideo.dart';
import 'package:video_match/utils/ui/VMScaffold.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return VMScaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: <Widget>[PlayVideo(), Text("chats")],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            title: Text('People'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            title: Text('Chat'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (newSelected) {
          setState(() {
            _selectedIndex = newSelected;
            if (_pageController.page == 0 && newSelected == 1)
              _pageController.nextPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.decelerate);
            if (_pageController.page == 1 && newSelected == 0)
              _pageController.previousPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.decelerate);
          });
        },
      ),
    );
  }
}