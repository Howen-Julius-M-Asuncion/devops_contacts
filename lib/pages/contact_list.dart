import 'dart:io';
import 'package:contacts/pages/contact_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts/public/variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> with WidgetsBindingObserver {
  final Box contactsBox = Hive.box('contacts');
  List<dynamic> contacts = [];
  List<dynamic> filteredContacts = [];
  String query = "";
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('Initializing ContactList');
    _loadContacts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('Disposing ContactList');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed - refreshing contacts');
      _loadContacts();
    }
  }

  void _loadContacts() {
    print('Loading contacts from Hive');
    setState(() {
      contacts = contactsBox.get('contacts', defaultValue: []);
      filteredContacts = List.from(contacts);
      print('Loaded ${contacts.length} contacts');
    });
  }

  void _saveContacts() {
    print('Saving ${contacts.length} contacts to Hive');
    contactsBox.put('contacts', contacts);
  }

  void filterContacts(String query) {
    print('Filtering contacts with query: $query');
    setState(() {
      this.query = query;
      filteredContacts = contacts.where((contact) {
        final name = contact['name'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) ||
            contact['phone'].any((phone) => phone.toString().toLowerCase().contains(searchLower)) ||
            contact['email'].any((email) => email.toString().toLowerCase().contains(searchLower));
      }).toList();
      print('Filtered to ${filteredContacts.length} contacts');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building ContactList widget');
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () {
            print('Add Contact button pressed');
            showCupertinoModalPopup(
              context: context,
              builder: (context) {
                File? modalImage;
                String? modalImagePath;
                final TextEditingController _fname = TextEditingController();
                final TextEditingController _lname = TextEditingController();
                List<TextEditingController> phoneControllers = [];
                List<TextEditingController> emailControllers = [];
                List<TextEditingController> urlControllers = [];

                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    Future<void> pickImage() async {
                      print('Attempting to pick image');
                      try {
                        final XFile? pickedFile = await _picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );
                        if (pickedFile != null) {
                          print('Image selected: ${pickedFile.path}');
                          setModalState(() {
                            modalImage = File(pickedFile.path);
                            modalImagePath = pickedFile.path;
                          });
                        }
                      } catch (e) {
                        print('Image pick error: $e');
                      }
                    }

                    Widget buildPhotoWidget() {
                      print('Building photo widget');
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          if (modalImage != null)
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoColors.systemGrey,
                              ),
                              child: ClipOval(
                                child: Image.file(
                                  modalImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Icon(
                              CupertinoIcons.person_circle_fill,
                              size: 220,
                              color: CupertinoColors.systemGrey,
                            ),
                          CupertinoButton(
                            onPressed: pickImage,
                            child: Text(
                              modalImage != null ? 'Change Photo' : 'Add Photo',
                              style: TextStyle(color: CupertinoColors.systemBlue),
                            ),
                          ),
                        ],
                      );
                    }

                    void addPhoneField() {
                      print('Adding phone field');
                      setModalState(() => phoneControllers.add(TextEditingController()));
                    }

                    void addEmailField() {
                      print('Adding email field');
                      setModalState(() => emailControllers.add(TextEditingController()));
                    }

                    void addUrlField() {
                      print('Adding URL field');
                      setModalState(() => urlControllers.add(TextEditingController()));
                    }

                    void removePhoneField(int index) {
                      print('Removing phone field $index');
                      setModalState(() {
                        phoneControllers[index].dispose();
                        phoneControllers.removeAt(index);
                      });
                    }

                    void removeEmailField(int index) {
                      print('Removing email field $index');
                      setModalState(() {
                        emailControllers[index].dispose();
                        emailControllers.removeAt(index);
                      });
                    }

                    void removeUrlField(int index) {
                      print('Removing URL field $index');
                      setModalState(() {
                        urlControllers[index].dispose();
                        urlControllers.removeAt(index);
                      });
                    }

                    void cleanup() {
                      print('Cleaning up controllers');
                      _fname.dispose();
                      _lname.dispose();
                      for (var c in phoneControllers) c.dispose();
                      for (var c in emailControllers) c.dispose();
                      for (var c in urlControllers) c.dispose();
                    }

                    return CupertinoActionSheet(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              print('Contact creation cancelled');
                              cleanup();
                              Navigator.pop(context);
                            },
                          ),
                          const Text('New Contact'),
                          CupertinoButton(
                            child: const Text('Done'),
                            onPressed: () {
                              print('Saving new contact');
                              if (_fname.text.trim().isEmpty) {
                                print('Validation failed - missing name');
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: const Text("Missing Information"),
                                    content: const Text("Please enter at least a first name"),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text("OK"),
                                        onPressed: () => Navigator.pop(context),
                                      )
                                    ],
                                  ),
                                );
                                return;
                              }

                              final newContact = {
                                "name": "${_fname.text.trim()} ${_lname.text.trim()}",
                                "phone": phoneControllers.map((c) => c.text.trim()).where((p) => p.isNotEmpty).toList(),
                                "email": emailControllers.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList(),
                                "url": urlControllers.map((c) => c.text.trim()).where((u) => u.isNotEmpty).toList(),
                                "photo": modalImagePath ?? "",
                                "isLocal": modalImagePath != null,
                              };

                              print('New contact created: ${newContact['name']}');
                              setState(() {
                                contacts.add(newContact);
                                _saveContacts();
                                filterContacts(query);
                              });
                              cleanup();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      message: SingleChildScrollView(
                        child: Column(
                          children: [
                            buildPhotoWidget(),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: CupertinoColors.systemFill,
                              ),
                              child: Column(
                                children: [
                                  CupertinoTextField(
                                    placeholder: 'First Name',
                                    controller: _fname,
                                    decoration: const BoxDecoration(),
                                  ),
                                  const Divider(height: 0),
                                  CupertinoTextField(
                                    placeholder: 'Last Name',
                                    controller: _lname,
                                    decoration: const BoxDecoration(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildFieldSection(
                              label: 'phone',
                              controllers: phoneControllers,
                              onAdd: addPhoneField,
                              onRemove: removePhoneField,
                              placeholder: 'phone',
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 15),
                            _buildFieldSection(
                              label: 'email',
                              controllers: emailControllers,
                              onAdd: addEmailField,
                              onRemove: removeEmailField,
                              placeholder: 'email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 15),
                            _buildFieldSection(
                              label: 'url',
                              controllers: urlControllers,
                              onAdd: addUrlField,
                              onRemove: removeUrlField,
                              placeholder: 'url',
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'Contacts',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  CupertinoSearchTextField(
                    onChanged: filterContacts,
                    suffixMode: OverlayVisibilityMode.never,
                  ),
                  const Positioned(
                    right: 4,
                    child: Icon(
                      CupertinoIcons.mic_slash_fill,
                      color: CupertinoColors.systemGrey,
                      size: 21,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
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
                    child: const Text(
                      'HA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: CupertinoColors.systemBackground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HGR AJS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'My Card',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: CupertinoColors.inactiveGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 0.5),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return GestureDetector(
                      onTap: () async {
                        print('Opening contact: ${contact['name']}');
                        setState(() {
                          selectedName = contact['name'];
                          selectedPhoto = contact['photo'];
                          selectedIsLocal = contact['isLocal'] ?? false;
                          selectedPhone = List.from(contact['phone']);
                          selectedEmail = List.from(contact['email']);
                          selectedUrl = List.from(contact['url']);
                        });

                        await Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => ContactData()),
                        );

                        // Refresh when returning from ContactData
                        print('Returned from ContactData - refreshing list');
                        _loadContacts();
                      },
                      child: Container(
                        color: CupertinoColors.secondarySystemFill.withOpacity(0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                              child: Text(' ${contact['name']}'),
                            ),
                            const Divider(thickness: 0.5),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldSection({
    required String label,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    String placeholder = '',
    TextInputType? keyboardType,
  }) {
    print('Building field section for: $label');
    return Column(
      children: [
        if (controllers.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: CupertinoColors.systemFill,
            ),
            child: Column(
              children: [
                for (int i = 0; i < controllers.length; i++)
                  Column(
                    children: [
                      Row(
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              CupertinoIcons.minus_circle_fill,
                              color: CupertinoColors.systemRed,
                              size: 20,
                            ),
                            onPressed: () => onRemove(i),
                          ),
                          Expanded(
                            child: CupertinoTextField(
                              controller: controllers[i],
                              placeholder: placeholder,
                              keyboardType: keyboardType,
                              decoration: const BoxDecoration(),
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                            ),
                          ),
                        ],
                      ),
                      if (i < controllers.length - 1)
                        const Divider(height: 0, indent: 0),
                    ],
                  ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        CupertinoButton(
          onPressed: onAdd,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: CupertinoColors.systemFill,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.add_circled_solid,
                  color: CupertinoColors.systemGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'add $label',
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemBackground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}