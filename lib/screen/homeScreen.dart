import 'package:flutter/material.dart';
import 'package:video_match/screen/playVideo.dart';
import 'package:video_match/utils/colors.dart';

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

class VMScaffold extends StatefulWidget {
  VMScaffold(
      {this.body,
      this.bottomNavigationBar,
      this.floatingActionButton,
      this.colorfulBackground = false});
  final Widget body;
  final Widget floatingActionButton;
  final Widget bottomNavigationBar;

  final bool colorfulBackground;
  @override
  _VMScaffoldState createState() => _VMScaffoldState();
}

class _VMScaffoldState extends State<VMScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/app_lable.png",
          height: 40,
        ),
      ),
      body: Stack(children: <Widget>[
        (widget.colorfulBackground)
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(.75, .75),
                    colors: [mainColor, Colors.transparent],
                    tileMode: TileMode.repeated,
                  ),
                ),
              )
            : Container(),
        widget.body
      ]),
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
