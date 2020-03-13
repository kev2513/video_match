import 'package:flutter/material.dart';
import 'package:video_match/screen/chatListScreen.dart';
import 'package:video_match/screen/otherUserVideo.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_match/utils/ui/VMScaffold.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  PageController _pageController = PageController();
  String dropdownValue = 'One';

  @override
  Widget build(BuildContext context) {
    return VMScaffold(
      action: (_currentPage == 1)
          ? FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(
                Icons.settings,
                color: mainColor,
              ),
              mini: true,
              onPressed: () {
                Navigator.of(context).pushNamed("settings");
              },
            )
          : null,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: <Widget>[OtherUserVideo(), ChatsList()],
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
        currentIndex: _currentPage,
        onTap: (newSelected) {
          setState(() {
            _currentPage = newSelected;
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
