import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_match/server/server.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_match/utils/country_states.dart';
import 'package:video_match/screen/createVideo.dart';
import 'package:video_match/utils/ui/VMScaffold.dart';
import 'package:video_match/utils/ui/div.dart';

class CreateProfile extends StatefulWidget {
  @override
  _CreateProfileState createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  PageController _pageController = PageController();
  int currentPage = 0;
  bool nextPageLock = false;

  String firstName = "", userAge = "", minAge = "", maxAge = "";

  TextEditingController fNTec = TextEditingController(),
      uATec = TextEditingController(),
      mATec = TextEditingController(),
      maxATec = TextEditingController();

  bool gender = true;
  String selectedCountry, selectedState;
  List<String> countries = List<String>();
  List<String> states = List<String>();
  bool videoCreated = false;

  List<String> statesOfCountrie(String country) {
    List<String> statesTemp = List<String>();

    country_states["countries"].forEach((c) {
      if (c["country"] == country) statesTemp = c["states"];
    });

    return statesTemp;
  }

  _createProfile() async {
    String message = "";
    if (firstName.isEmpty) message += " \n • your name is missing";

    if (userAge.isEmpty)
      message += " \n • your age is not set";
    else {
      if (int.parse(userAge) > 80 || (int.parse(userAge) < 18))
        message += "\n • you must be between 18 and 80 years old";
    }

    if (selectedCountry == "None")
      message += "\n • our country is not selected";

    if (minAge.isEmpty || minAge.isEmpty)
      message +=
          " \n • set the min and max age of the user you are looking for";
    else {
      if (int.parse(minAge) > 80 || (int.parse(maxAge) > 80))
        message += "\n • users can max be 80 years old";

      if (int.parse(minAge) < 18 || (int.parse(maxAge) < 18))
        message += "\n • users must be at least 18 years old";

      if (int.parse(minAge) > int.parse(maxAge))
        message +=
            "\n • the min age of the user you are looking for is not higher than the max age";
    }

    if (message != "") {
      await showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text(
                  "Sorry",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ));
      return;
    }

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text(
                  "Uploading...",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: VMLoadingCircle(),
              ),
            ));

    await Server.instance.createProfile({
      "name": firstName,
      "age": userAge,
      "gender": gender,
      "state": selectedState,
      "country": selectedCountry,
      "image":
          Base64Codec().encode(await File(await getSelfiePath()).readAsBytes()),
      "minAge": minAge,
      "maxAge": maxAge,
    }, await getSelfVideoPath());
    Navigator.of(context)
        .pushNamedAndRemoveUntil("homeScreen", ModalRoute.withName('/'));
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
      body: Stack(
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
                      autofocus: true,
                      controller: fNTec,
                      maxLength: 20,
                      textAlign: TextAlign.center,
                      onChanged: (input) {
                        setState(() {
                          firstName = input;
                        });
                      },
                    ),
                  )
                ],
              ),
              InnerPageUserData(
                children: <Widget>[
                  Text(
                    "Please enter your age:",
                  ),
                  Container(
                    width: 40,
                    child: TextField(
                      controller: uATec,
                      maxLength: 2,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (input) {
                        setState(() {
                          userAge = input;
                        });
                      },
                    ),
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Text(
                    "Your age must be between 18 - 80 years",
                    style: TextStyle(fontStyle: FontStyle.italic),
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
                          value: !gender,
                          onChanged: (newGender) {
                            setState(() {
                              gender = !newGender;
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
                  Divider(
                    color: Colors.transparent,
                  ),
                  Text(
                    "We respect the data privacy of our users that's why we wont use GPS.",
                    style: TextStyle(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
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
                            controller: mATec,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            textAlign: TextAlign.center,
                            onChanged: (input) {
                              setState(() {
                                minAge = input;
                              });
                            },
                          ),
                        ),
                        Text("-"),
                        Flexible(
                          child: TextField(
                            controller: maxATec,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            onSubmitted: (_) {
                              _pageController.nextPage(
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.decelerate);
                            },
                            textAlign: TextAlign.center,
                            onChanged: (input) {
                              setState(() {
                                maxAge = input;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Text(
                    "The age must be between 18 - 80 years",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                ],
              ),
              CreateVideo(
                onVideoCreated: () {
                  setState(() {
                    videoCreated = true;
                  });
                },
                onVideoDeleted: () {
                  setState(() {
                    videoCreated = false;
                  });
                },
              ),
              InnerPageUserData(
                children: <Widget>[
                  VMButton(
                    text: "Upload Profile",
                    onPressed: () => _createProfile(),
                  ),
                ],
              )
            ],
          ),
          (currentPage >= 1 && currentPage < 5)
              ? Align(
                  alignment: Alignment(-.9, .95),
                  child: FloatingActionButton(
                      heroTag: null,
                      child: Icon(
                        Icons.navigate_before,
                        color: secondaryColor,
                      ),
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        await _pageController.previousPage(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.decelerate);
                        FocusScope.of(context).requestFocus(FocusNode());
                        setState(() {
                          currentPage = _pageController.page.toInt();
                        });
                      }),
                )
              : Container(),
        ],
      ),
      floatingActionButton:
          (currentPage == 0 && firstName.isNotEmpty && firstName.length > 2 ||
                  currentPage == 1 &&
                      (int.parse(userAge, onError: (_) {
                                return 100;
                              }) <=
                              80 &&
                          (int.parse(userAge, onError: (_) {
                                return 0;
                              }) >=
                              18)) ||
                  currentPage == 2 ||
                  currentPage == 3 && selectedCountry != "None" ||
                  currentPage == 4 &&
                      (int.parse(minAge, onError: (_) {
                                return 100;
                              }) <=
                              80 &&
                          (int.parse(minAge, onError: (_) {
                                return 0;
                              }) >=
                              18)) &&
                      (int.parse(maxAge, onError: (_) {
                                return 100;
                              }) <=
                              80 &&
                          (int.parse(maxAge, onError: (_) {
                                return 0;
                              }) >=
                              18)) &&
                      int.parse(minAge, onError: (_) {
                            return 0;
                          }) <=
                          int.parse(maxAge, onError: (_) {
                            return 0;
                          }) ||
                  currentPage == 5 && videoCreated)
              ? FloatingActionButton(
                  heroTag: null,
                  child: Icon(
                    Icons.navigate_next,
                    color: mainColor,
                  ),
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    if (!nextPageLock) {
                      nextPageLock = true;
                      setState(() {
                        currentPage = _pageController.page.toInt() + 1;
                      });
                      await _pageController.nextPage(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.decelerate);
                      FocusScope.of(context).requestFocus(FocusNode());
                      nextPageLock = false;
                    }
                  },
                )
              : null,
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: children),
      ),
    );
  }
}
