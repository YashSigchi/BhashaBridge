import 'package:flutter/material.dart';
import 'package:myapp/pages/home_page.dart';
import 'package:myapp/pages/image_translate.dart';
import 'package:myapp/pages/settings_page.dart';
import 'package:myapp/pages/translator_page.dart';
import 'package:myapp/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

    void logout() {
      //get auth service
      final auth = AuthService();
      auth.signOut();
    }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            //logo
            DrawerHeader(
              child: Center(
                child: Icon(
                  Icons.message,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
              ),
            ),

            //home list title
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: ListTile(
                title: Text("H O M E"),
                leading: Icon(Icons.home),
                onTap: () {
                  //pop the drawer
                  Navigator.pop(context);

                  //naigate to settings page
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>HomePage(),
                    ),
                  );
                },
              ),
            ),

            //Image-translate list title
            // Padding(
            //   padding: const EdgeInsets.only(left: 25.0),
            //   child: ListTile(
            //     title: Text("I M A G E"),
            //     leading: Icon(Icons.photo),
            //     onTap: () {
            //       //pop the drawer
            //       Navigator.pop(context);

            //       //naigate to settings page
            //       Navigator.push(context, MaterialPageRoute(
            //           builder: (context)=>ImageTranslatePage(),
            //         ),
            //       );
            //     },
            //   ),
            // ),

            //translator list title
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: ListTile(
                title: Text("T R A N S L A T O R"),
                leading: Icon(Icons.translate),
                onTap: () {
                  //pop the drawer
                  Navigator.pop(context);

                  //naigate to settings page
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>TranslatorPage(),
                    ),
                  );
                },
              ),
            ),

            //settings list title
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: ListTile(
                title: Text("S E T T I N G S"),
                leading: Icon(Icons.settings),
                onTap: () {
                  //pop the drawer
                  Navigator.pop(context);

                  //naigate to settings page
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context)=>SettingsPage(),
                  ),
                );
              },
            ),
          ),
        ],
        ),
          
          //logout list title
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
            child: ListTile(
              title: Text("L O G O U T"),
              leading: Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}