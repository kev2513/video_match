import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_match/utils/server/server.dart';
import 'package:video_match/utils/colors.dart';
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

  String firstName = "", userAge = "";

  TextEditingController fNTec = TextEditingController(),
      uATec = TextEditingController(),
      mATec = TextEditingController(),
      maxATec = TextEditingController();

  bool gender = true;
  String isoCountryCode, administrativeArea, subAdministrativeArea, city;
  bool videoCreated = false;

  _createProfile() async {
    loadingDialog(context);

    await Server.instance.saveProfile(userData: {
      "name": firstName,
      "age": userAge,
      "gender": gender,
      "isoCountryCode": isoCountryCode,
      "administrativeArea": administrativeArea,
      "subAdministrativeArea": subAdministrativeArea,
      "city": city,
      "lastOnline": DateTime.now(),
      "seenUserDateOldest": DateTime.now(),
      "seenUserDateYoungest": DateTime.now(),
      "image":
          Base64Codec().encode(await File(await getSelfiePath()).readAsBytes()),
      "creationDate": DateTime.now()
    }, videoPath: await getSelfVideoPath());
    Navigator.of(context)
        .pushNamedAndRemoveUntil("homeScreen", ModalRoute.withName('/'));
  }

  _checkInput() {
    return (currentPage == 0 && firstName.isNotEmpty && firstName.length > 2 ||
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
        currentPage == 3 && isoCountryCode != null ||
        currentPage == 4 && videoCreated);
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
                    "Please enter your first name or nickname:",
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
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Text(
                    "Your name must have at least 3 characters.",
                    style: TextStyle(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Please allow access to your GPS\n(we only need it once)",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Divider(),
                      FlatButton(
                        child: Text(
                          (isoCountryCode == null) ? "Allow" : "✓",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.black,
                        onPressed: () async {
                          Position position = await Geolocator()
                              .getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high);
                          Placemark placemark = (await Geolocator()
                                  .placemarkFromPosition(position,
                                      localeIdentifier: "en_US"))
                              .first;
                          setState(() {
                            isoCountryCode = placemark.isoCountryCode;
                            administrativeArea = placemark.administrativeArea;
                            subAdministrativeArea =
                                placemark.subAdministrativeArea;
                            city = placemark.locality;
                          });
                        },
                      ),
                      Divider(
                        color: Colors.transparent,
                      ),
                      (isoCountryCode != null)
                          ? Text("You got located at: " +
                              isoCountryCode +
                              ", " +
                              administrativeArea +
                              ", " +
                              subAdministrativeArea +
                              ", " +
                              city)
                          : Container()
                    ],
                  ),
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
              )
            ],
          ),
          (currentPage >= 1 && currentPage < 4)
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
                        videoCreated = false;
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
      floatingActionButton: (_checkInput())
          ? FloatingActionButton(
              heroTag: null,
              child: Icon(
                (currentPage == 4) ? Icons.file_upload : Icons.navigate_next,
                color: mainColor,
              ),
              backgroundColor: Colors.white,
              onPressed: () async {
                if (currentPage == 4) {
                  _createProfile();
                } else if (!nextPageLock) {
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
