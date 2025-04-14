import 'dart:ui';

import 'package:contacts/public/variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactData extends StatefulWidget {
  const ContactData({super.key});

  @override
  State<ContactData> createState() => _ContactDataState();
}

class _ContactDataState extends State<ContactData> {

  // LOCAL DATA FOR EDIT
  List<dynamic> editedData = [];

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // backgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STACK CARD
            Stack(
              children: [
                // IMAGE
                SizedBox(
                  height: 450,
                  width: double.infinity,
                  child:Image.network(
                    selectedPhoto,
                    fit: BoxFit.cover,
                  ),
                ),
                // PSEUDO-NAVBAR
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoColors.darkBackgroundGray.withOpacity(0.4)
                            ),
                            child: Icon(CupertinoIcons.chevron_back, color: CupertinoColors.systemBackground,),
                          ),
                          onPressed: (){
                            // setState(() {
                            //   selectedName = '';
                            //   selectedPhoto = '';
                            //   selectedPhone = [''];
                            //   selectedEmail = [''];
                            //   selectedUrl = [''];
                            // });
                            // print('Selected variables set to blank.');
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: CupertinoColors.darkBackgroundGray.withOpacity(0.4)
                            ),
                            child: Text('Edit', style: TextStyle(color: CupertinoColors.systemBackground, fontSize: 16, fontWeight: FontWeight.w300),),
                          ),
                          onPressed: (){

                          },
                        ),
                      ],
                    ),
                  )
                ),
                // CONTACT ACTIONS
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5.0,
                        sigmaY: 5.0,
                      ),
                      child: Container(
                        margin: EdgeInsets.all(0),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          children: [
                            // LABEL
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('last used: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: CupertinoColors.systemBackground),),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4,),
                                  decoration: BoxDecoration(
                                      color: CupertinoColors.systemBackground,
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Text('P', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CupertinoColors.label),),
                                ),
                                Text(' Primary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: CupertinoColors.systemBackground),),
                                Icon(CupertinoIcons.chevron_forward, size: 15, color: CupertinoColors.systemBackground,),
                              ],
                            ),
                            Text(selectedName, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: CupertinoColors.systemBackground),),
                            SizedBox(height: 8,),
                            // BUTTONS
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: CupertinoButton(
                                      color: CupertinoColors.darkBackgroundGray.withOpacity(0.6),
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      onPressed: () async {
                                        final Uri uri = await Uri.parse('sms: ${selectedPhone[0]}');
                                        await launchUrl(uri);
                                        print('Messaging main number: ${selectedPhone[0]}');
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(CupertinoIcons.chat_bubble_fill, size: 20, color: CupertinoColors.systemBackground),
                                          const SizedBox(height: 4),
                                          const Text('message', style: TextStyle(fontSize: 12, color: CupertinoColors.systemBackground)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: CupertinoButton(
                                      color: CupertinoColors.darkBackgroundGray.withOpacity(0.6),
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      onPressed: () async {
                                        final Uri uri = await Uri.parse('tel: ${selectedPhone[0]}');
                                        await launchUrl(uri);
                                        print('Messaging main number: ${selectedPhone[0]}');
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(CupertinoIcons.phone_fill, size: 20, color: CupertinoColors.systemBackground),
                                          const SizedBox(height: 4),
                                          const Text('call', style: TextStyle(fontSize: 12, color: CupertinoColors.systemBackground)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: CupertinoButton(
                                      color: CupertinoColors.darkBackgroundGray.withOpacity(0.6),
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      onPressed: (){},
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(CupertinoIcons.videocam_fill, size: 20, color: CupertinoColors.systemBackground),
                                          const SizedBox(height: 4),
                                          const Text('video', style: TextStyle(fontSize: 12, color: CupertinoColors.systemBackground)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: CupertinoButton(
                                      color: CupertinoColors.darkBackgroundGray.withOpacity(0.6),
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      onPressed: () async {
                                        final Uri uri = await Uri.parse('mailto: ${selectedEmail[0]}');
                                        await launchUrl(uri);
                                        print('Mailing main email: ${selectedEmail[0]}');
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(CupertinoIcons.mail_solid, size: 20, color: CupertinoColors.systemBackground),
                                          const SizedBox(height: 4),
                                          const Text('mail', style: TextStyle(fontSize: 12, color: CupertinoColors.systemBackground)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // DATA
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // PROFILE ROW
                  Container(
                    padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: CupertinoColors.darkBackgroundGray,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(selectedPhoto),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contact Photo & Poster', style: TextStyle(fontSize: 14)),
                            Text('Contacts Only',style: TextStyle(fontSize: 13, color: CupertinoColors.inactiveGray))
                          ],
                        ),
                        Spacer(),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(CupertinoIcons.chevron_forward),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                  // PHONE LIST
                  SizedBox(height: 15,),
                  GestureDetector(
                    onTap: () async {
                      final Uri uri = await Uri.parse('tel: ${selectedPhone[0]}');
                      await launchUrl(uri);
                      print('Calling number: ${selectedPhone[0]}');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: CupertinoColors.darkBackgroundGray
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('phone', style: TextStyle(fontSize: 13),),
                          Text('${selectedPhone[0]}', style: TextStyle(fontSize: 14, color: CupertinoColors.systemBlue),)
                        ],
                      ),
                    ),
                  ),
                  // EMAIL LIST
                  SizedBox(height: 10,),
                  GestureDetector(
                    onTap: () async {
                      final Uri uri = await Uri.parse('mailto: ${selectedEmail[0]}');
                      await launchUrl(uri);
                      print('Mailing email: ${selectedEmail[0]}');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: CupertinoColors.darkBackgroundGray
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('email', style: TextStyle(fontSize: 13),),
                          Text('${selectedEmail[0]}', style: TextStyle(fontSize: 14, color: CupertinoColors.systemBlue),)
                        ],
                      ),
                    ),
                  ),
                  // URL LIST
                  SizedBox(height: 10,),
                  GestureDetector(
                    onTap: () async {
                      final Uri uri = await Uri.parse('${selectedUrl[0]}');
                      await launchUrl(uri);
                      print('Navigating to URL: ${selectedUrl[0]}');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: CupertinoColors.darkBackgroundGray
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('url', style: TextStyle(fontSize: 13),),
                          Text('${selectedUrl[0]}', style: TextStyle(fontSize: 14, color: CupertinoColors.systemBlue),)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
