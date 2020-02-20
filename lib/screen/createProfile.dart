import 'package:flutter/material.dart';
import 'package:video_match/screen/homeScreen.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_match/utils/country_states.dart';

class CreateProfile extends StatefulWidget {
  @override
  _CreateProfileState createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  PageController _pageController = PageController();
  TextEditingController _textEditingControllerFirstName =
      TextEditingController();
  TextEditingController _textEditingControllerMinAge =
      TextEditingController(text: "18");
  TextEditingController _textEditingControllerMaxAge =
      TextEditingController(text: "80");
  DateTime _age;
  bool _gender = true;
  bool _genderLockingFor = false;
  String selectedCountry, selectedState;
  List<String> countries = List<String>();
  List<String> states = List<String>();

  List<String> statesOfCountrie(String country) {
    List<String> statesTemp = List<String>();

    country_states["countries"].forEach((c) {
      if (c["country"] == country) statesTemp = c["states"];
    });

    return statesTemp;
  }

  @override
  void initState() {
    super.initState();
    selectedCountry = "None";
    selectedState = "-";
    country_states["countries"].forEach((c) {
      countries.add(c["country"]);
    });
    states = statesOfCountrie(selectedCountry);
  }

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
                  Container(
                    width: 200,
                    child: TextField(
                      controller: _textEditingControllerFirstName,
                      maxLength: 20,
                      style: TextStyle(color: Colors.white),
                      onSubmitted: (_) {
                        _pageController.nextPage(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.decelerate);
                      },
                      textAlign: TextAlign.center,
                    ),
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
                    "Please select your country and staate:",
                  ),
                  DropdownButton<String>(
                    style: TextStyle(color: Colors.white),
                    value: selectedCountry,
                    onChanged: (String newCountry) {
                      setState(() {
                        selectedCountry = newCountry;
                        states = statesOfCountrie(newCountry);
                        selectedState = states.first;
                      });
                    },
                    items:
                        countries.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    style: TextStyle(color: Colors.white),
                    value: selectedState,
                    onChanged: (String newState) {
                      setState(() {
                        selectedState = newState;
                      });
                    },
                    items: states.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
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
              InnerPageUserData(
                children: <Widget>[
                  Text(
                    "Please enter the age range of the person you are looking for:",
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: TextField(
                            controller: _textEditingControllerMinAge,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text("-"),
                        Flexible(
                          child: TextField(
                            controller: _textEditingControllerMaxAge,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            style: TextStyle(color: Colors.white),
                            onSubmitted: (_) {
                              _pageController.nextPage(
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.decelerate);
                            },
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              InnerPageUserData(
                children: <Widget>[
                  FlatButton(
                    color: secondaryColor,
                    child: Text("Create Video", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    onPressed: () {},
                  )
                ],
              )
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
                  FocusScope.of(context).requestFocus(FocusNode());
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
          FocusScope.of(context).requestFocus(FocusNode());
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
