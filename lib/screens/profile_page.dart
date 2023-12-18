import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_app/screens/auth_Screens/auth_screens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';

  final current = FirebaseAuth.instance;

  Future<void> fetchData() async {
    final firestore =
        FirebaseFirestore.instance.collection('users').doc(current.currentUser!.email);

    var data = await firestore.get();
    setState(() {
      name = data['name'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding:
                EdgeInsets.only(left: 16.0, right: 16.0, top: kToolbarHeight),
            child: FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    maxRadius: 48,
                    backgroundImage:
                        AssetImage('assets/profile_page_images/background.jpg'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.yellow,
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: Offset(0, 1))
                        ]),
                    height: 150,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                  icon: Image.asset(
                                      'assets/profile_page_images/wallet.png'),
                                  onPressed: () {}),
                              Text(
                                'Wallet',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                  icon: Image.asset(
                                      'assets/profile_page_images/truck.png'),
                                  onPressed: () {}),
                              Text(
                                'Shipped',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                  icon: Image.asset(
                                      'assets/profile_page_images/card.png'),
                                  onPressed: () {}),
                              Text(
                                'Payment',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                icon: Image.asset(
                                    'assets/profile_page_images/contact_us.png'),
                                onPressed: () {},
                              ),
                              Text(
                                'Support',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                      title: Text('Settings'),
                      subtitle: Text('Account Setting'),
                      leading: Image.asset(
                        'assets/profile_page_images/settings_icon.png',
                        fit: BoxFit.scaleDown,
                        width: 30,
                        height: 30,
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.yellow),
                      onTap: () {}),
                  Divider(),
                  ListTile(
                    title: Text('Help & Support'),
                    subtitle: Text('Help center and legal support'),
                    leading:
                        Image.asset('assets/profile_page_images/support.png'),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.yellow,
                    ),
                  ),
                  Divider(),
                  ListTile(
                      title: Text('FAQ'),
                      subtitle: Text('Questions and Answer'),
                      leading:
                          Image.asset('assets/profile_page_images/faq.png'),
                      trailing: Icon(Icons.chevron_right, color: Colors.yellow),
                      onTap: () {}),
                  Divider(),
                  ListTile(
                      title: Text('Log Out'),
                      subtitle: Text('Log out from current account'),
                      leading: Icon(FontAwesomeIcons.signOut),
                      trailing: Icon(Icons.chevron_right, color: Colors.yellow),
                      onTap: () async{
                        await current.signOut().then((value){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
                        });

                      }),
                  Divider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
