import 'package:contacts/pages/contact_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:contacts/public/variables.dart';

import 'package:hive/hive.dart';

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {

  // LOCAL DB PLACEHOLDER
  List<dynamic> contacts = [
    {
      "name" : "John Doe",
      "phone" : [
        "09695136467",
        "0923456789",
        "0945678901",
        "0956789012",
      ],
      "email" : [
        "hjasuncion1903@gmail.com"
      ],
      "url" : [
        "https://facebook.com/johndoeisjohndoe",
        "https://youtube.com/johndoeisjohn"
      ],
      "photo" : "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/John_Doe%2C_born_John_Nommensen_Duchac.jpg/1200px-John_Doe%2C_born_John_Nommensen_Duchac.jpg",
    },
    {
      "name" : "Jane Doe",
      "phone" : [
        "09695136467",
        "0923456789",
        "0945678901",
        "0956789012",
      ],
      "email" : [
        "hjasuncion1903@gmail.com"
      ],
      "url" : [
        "https://facebook.com/janedoeee",
        "https://instagram.com/jdoe_"
      ],
      "photo" : "https://cdn.goenhance.ai/user/2024/07/19/c0c1400b-abc2-4541-a849-a7e4f361d28d_0.jpg",
    },
  ];

  // SEARCH FUNCTION VARIABLES
  String query = "";
  List<dynamic> filteredContacts = [];

  @override
  void initState() {
    super.initState();
    filteredContacts = contacts;
  }

  // SEARCH FUNCTION
  void filterContacts(String query) {
    setState(() {
      this.query = query;
      filteredContacts = contacts.where((contact) {
        final name = contact['name'].toString().toLowerCase();
        final searchLower = query.toLowerCase();

        // Search in name, phone numbers, and emails
        return name.contains(searchLower) ||
            contact['phone'].any((phone) => phone.toString().toLowerCase().contains(searchLower)) ||
            contact['email'].any((email) => email.toString().toLowerCase().contains(searchLower));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: (){
            showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return CupertinoActionSheet(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text('New Contact'),
                      CupertinoButton(
                        child: Text('Done'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),

                  message: Column(
                    children: [

                      Icon(CupertinoIcons.person_circle_fill, color: CupertinoColors.systemGrey, size: 200,),
                      CupertinoButton(
                        child: Text('Add Photo'),
                        onPressed: () async {

                        },
                      ),
                      // SizedBox(height: 50,),

                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                            color: CupertinoColors.systemFill
                        ),
                        child: Column(
                          children: [
                            CupertinoTextField(
                              placeholder: 'First Name',
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                                  color: null
                              ),
                            ),
                            Divider(height: 0,),
                            CupertinoTextField(
                              placeholder: 'Last Name',
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                                  color: null
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15,),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                          color: CupertinoColors.systemFill
                        ),
                        child: CupertinoTextField(
                          prefix: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Icon(CupertinoIcons.add_circled_solid, color: CupertinoColors.systemGreen,),
                            onPressed: () async {

                            },
                          ),
                          placeholder: 'add phone',
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                              color: null
                          ),
                        ),
                      ),
                      SizedBox(height: 15,),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                          color: CupertinoColors.systemFill
                        ),
                        child: CupertinoTextField(
                          prefix: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Icon(CupertinoIcons.add_circled_solid, color: CupertinoColors.systemGreen,),
                            onPressed: () async {

                            },
                          ),
                          placeholder: 'add email',
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                              color: null
                          ),
                        ),
                      ),
                      SizedBox(height: 15,),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                          color: CupertinoColors.systemFill
                        ),
                        child: CupertinoTextField(
                          prefix: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Icon(CupertinoIcons.add_circled_solid, color: CupertinoColors.systemGreen,),
                            onPressed: () async {

                            },
                          ),
                          placeholder: 'add url',
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                              color: null
                          ),
                        ),
                      ),





                      SizedBox(height: double.maxFinite,),


                    ],
                  ),

                ); 
              }
            );
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [

              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15,),
                    child: const Text('Contacts',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 15,),
              //   child: CupertinoSearchTextField(
              //     borderRadius: BorderRadius.circular(18),
              //     suffixIcon: Icon(CupertinoIcons.mic),
              //     suffixMode: OverlayVisibilityMode.always,
              //   ),
              // ),

              Stack(
                alignment: Alignment.centerRight,
                children: [
                  CupertinoSearchTextField(
                    // borderRadius: BorderRadius.circular(18),
                    onChanged: (value) => filterContacts(value),
                    suffixMode: OverlayVisibilityMode.never,
                  ),
                  Positioned(
                    right: 4,
                    child: Icon(
                      CupertinoIcons.mic_slash_fill,
                      color: CupertinoColors.systemGrey,
                      size: 21,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15,),

              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 10),
              //   child: const Divider(
              //     thickness: 0.5,
              //   ),
              // ),

              // PROFILE CARD
              Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Text('HA',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: CupertinoColors.systemBackground),
                    ),
                  ),
                  SizedBox(width: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Howen Julius Asuncion',
                        style: TextStyle(fontWeight: FontWeight.bold,),
                      ),
                      Text('My Card',
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: CupertinoColors.inactiveGray)
                      )
                    ],
                  )
                ],
              ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 10),
              //   child: const Divider(
              //     thickness: 0.5,
              //   ),
              // ),

              SizedBox(height: 10,),
              Divider(thickness: 0.5,),

              // LIST
              Expanded(
                child: ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, int index) {
                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          selectedName = filteredContacts[index]['name'];
                          selectedPhoto = filteredContacts[index]['photo'];
                          selectedPhone = filteredContacts[index]['phone'];
                          selectedEmail = filteredContacts[index]['email'];
                          selectedUrl = filteredContacts[index]['url'];
                        });
                        print('Selected Contact: $selectedName\n${selectedPhone.length} Phone: $selectedPhone\n${selectedEmail.length} Email: $selectedEmail\n${selectedUrl.length} Url:$selectedUrl\nPhoto: $selectedPhoto\n-------------------');
                        Navigator.push(context, CupertinoPageRoute(builder: (context) => ContactData()));
                      },
                      child: Container(
                        color: CupertinoColors.secondarySystemFill.withOpacity(0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                              child: Text(' ${filteredContacts[index]['name']}'),
                            ),
                            const Divider(thickness: 0.5),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )



            ],
          ),
        ),
      )
    );
  }
}
