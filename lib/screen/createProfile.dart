import 'package:flutter/material.dart';
import 'package:video_match/screen/homeScreen.dart';
import 'package:video_match/utils/colors.dart';

class CreateProfile extends StatefulWidget {
  @override
  _CreateProfileState createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  PageController _pageController = PageController();
  TextEditingController _textEditingControllerFirstName =
      TextEditingController();
  DateTime _age;
  bool _gender = true;
  bool _genderLockingFor = false;

  @override
  Widget build(BuildContext context) {
    return VMScaffold(
      colorfulBackground: true,
      child: Stack(
        children: <Widget>[
          PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              InnerPageUserData(
                children: <Widget>[
                  Text(
                    "Please enter your first name:",
                  ),
                  TextField(
                    controller: _textEditingControllerFirstName,
                    autofocus: true,
                    maxLength: 20,
                    style: TextStyle(color: Colors.white),
                    onSubmitted: (_) {
                      _pageController.nextPage(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.decelerate);
                    },
                  )
                ],
              ),
              InnerPageUserData(
                children: <Widget>[
                  Text(
                    "Please enter your age:",
                  ),
                  FlatButton(
                    child: Text(
                      "Select age",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: secondaryColor,
                    onPressed: () async {
                      _age = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().subtract(Duration(days: 356 * 18)),
                        firstDate:
                            DateTime.now().subtract(Duration(days: 356 * 80)),
                        lastDate:
                            DateTime.now().subtract(Duration(days: 356 * 18)),
                      );
                    },
                  )
                ],
              ),
              InnerPageUserData(
                children: <Widget>[
                  Text(
                    "Please select your gender:",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Male"),
                      Theme(
                        data: ThemeData(accentColor: Colors.white),
                        child: Switch(
                          value: !_gender,
                          onChanged: (newGender) {
                            setState(() {
                              _gender = !newGender;
                              _genderLockingFor = newGender;
                            });
                          },
                          inactiveTrackColor: mainColor,
                          activeTrackColor: secondaryColor,
                        ),
                      ),
                      Text("Female")
                    ],
                  )
                ],
              ),
              InnerPageUserData(
                children: <Widget>[
                  Text(
                    "Please select your gender you are looking for:",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Male"),
                      Theme(
                        data: ThemeData(accentColor: Colors.white),
                        child: Switch(
                          value: !_genderLockingFor,
                          onChanged: (newGender) {
                            setState(() {
                              _genderLockingFor = !newGender;
                            });
                          },
                          inactiveTrackColor: mainColor,
                          activeTrackColor: secondaryColor,
                        ),
                      ),
                      Text("Female")
                    ],
                  )
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment(-.9, .95),
            child: FloatingActionButton(
                child: Icon(Icons.navigate_before),
                onPressed: () {
                  _pageController.previousPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.decelerate);
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigate_next),
        backgroundColor: secondaryColor,
        onPressed: () {
          _pageController.nextPage(
              duration: Duration(milliseconds: 200), curve: Curves.decelerate);
        },
      ),
    );
  }
}

class InnerPageUserData extends StatelessWidget {
  InnerPageUserData({this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Material(
          color: Colors.transparent,
          textStyle: TextStyle(
              color: Colors.white, fontSize: 17.5, fontWeight: FontWeight.bold),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: children),
        ),
      ),
    );
  }
}
