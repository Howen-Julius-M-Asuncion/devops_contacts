import 'dart:io';
import 'dart:ui';
import 'package:contacts/pages/edit_data.dart';
import 'package:contacts/public/variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactData extends StatefulWidget {
  const ContactData({super.key});

  @override
  State<ContactData> createState() => _ContactDataState();
}

class _ContactDataState extends State<ContactData> {
  String _getInitials(String name) {
    print('Getting initials for name: $name');
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0].toUpperCase()}${parts.last[0].toUpperCase()}';
  }

  Widget _buildPhotoWidget() {
    print('Building photo widget for contact: $selectedName');
    if (selectedPhoto.isEmpty) {
      print('No photo available, showing initials');
      return _buildInitialsContainer(selectedName);
    }

    if (selectedIsLocal) {
      print('Displaying local image: $selectedPhoto');
      return Image.file(
        File(selectedPhoto),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          print('Error loading local image, falling back to initials');
          return _buildInitialsContainer(selectedName);
        },
      );
    } else {
      print('Displaying network image: $selectedPhoto');
      return Image.network(
        selectedPhoto,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          print('Error loading network image, falling back to initials');
          return _buildInitialsContainer(selectedName);
        },
      );
    }
  }

  Widget _buildInitialsContainer(String name) {
    print('Building initials container for: $name');
    return Container(
      color: CupertinoColors.systemGrey,
      height: 450,
      width: double.infinity,
      alignment: Alignment.center,
      child: Text(
        _getInitials(name),
        style: TextStyle(
          fontSize: 120,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.systemBackground,
        ),
      ),
    );
  }

  Widget _buildSmallAvatar() {
    print('Building small avatar for contact: $selectedName');
    if (selectedPhoto.isEmpty) {
      print('No photo available for small avatar, showing initials');
      return Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CupertinoColors.systemGrey,
        ),
        child: Center(
          child: Text(
            _getInitials(selectedName),
            style: TextStyle(
              color: CupertinoColors.systemBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    print('Displaying ${selectedIsLocal ? 'local' : 'network'} image for small avatar');
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: selectedIsLocal
              ? FileImage(File(selectedPhoto))
              : NetworkImage(selectedPhoto) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building ContactData screen for: $selectedName');
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Main contact image with fallback to initials
                SizedBox(
                  height: 450,
                  width: double.infinity,
                  child: _buildPhotoWidget(),
                ),

                // PSEUDO-NAVBAR
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
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
                              color: CupertinoColors.darkBackgroundGray.withAlpha(40),
                            ),
                            child: Icon(
                              CupertinoIcons.chevron_back,
                              color: CupertinoColors.systemBackground,
                            ),
                          ),
                          onPressed: () {
                            print('Back button pressed');
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: CupertinoColors.darkBackgroundGray.withAlpha(40),
                            ),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: CupertinoColors.systemBackground,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            print('Edit button pressed for contact: $selectedName');
                            final result = await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => EditData(),
                              ),
                            );

                            if (result == true) {
                              // Delete case - notify parent to delete
                              print('Contact deleted, notifying parent');
                              Navigator.pop(context, true);
                            } else if (result != null) {
                              // Update case - refresh current view
                              print('Contact updated, refreshing view');
                              setState(() {
                                selectedName = result['name'];
                                selectedPhoto = result['photo'];
                                selectedIsLocal = result['isLocal'] ?? false;
                                selectedPhone = List.from(result['phone']);
                                selectedEmail = List.from(result['email']);
                                selectedUrl = List.from(result['url']);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // CONTACT ACTIONS
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          children: [
                            // LABEL
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'last used: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: CupertinoColors.systemBackground,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemBackground,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    'P',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.label,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' Primary',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: CupertinoColors.systemBackground,
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.chevron_forward,
                                  size: 15,
                                  color: CupertinoColors.systemBackground,
                                ),
                              ],
                            ),
                            Text(
                              selectedName,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.systemBackground,
                              ),
                            ),
                            SizedBox(height: 8),
                            // ACTION BUTTONS
                            Row(
                              children: [
                                _buildActionButton(
                                  icon: CupertinoIcons.chat_bubble_fill,
                                  label: 'message',
                                  onPressed: () => selectedPhone.isNotEmpty
                                      ? _launchSms(selectedPhone.first)
                                      : null,
                                ),
                                _buildActionButton(
                                  icon: CupertinoIcons.phone_fill,
                                  label: 'call',
                                  onPressed: () => selectedPhone.isNotEmpty
                                      ? _launchCall(selectedPhone.first)
                                      : null,
                                ),
                                _buildActionButton(
                                  icon: CupertinoIcons.videocam_fill,
                                  label: 'video',
                                  onPressed: () {
                                    print('Video call button pressed');
                                  },
                                ),
                                _buildActionButton(
                                  icon: CupertinoIcons.mail_solid,
                                  label: 'mail',
                                  onPressed: () => selectedEmail.isNotEmpty
                                      ? _launchEmail(selectedEmail.first)
                                      : null,
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
          ),

          // CONTACT DETAILS SECTION
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // PROFILE ROW
                Container(
                  padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: CupertinoColors.darkBackgroundGray,
                  ),
                  child: Row(
                    children: [
                      _buildSmallAvatar(),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Photo & Poster',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Contacts Only',
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.inactiveGray,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(CupertinoIcons.chevron_forward),
                        onPressed: () {
                          print('Contact photo details pressed');
                        },
                      ),
                    ],
                  ),
                ),

                // PHONE NUMBERS
                SizedBox(height: 15),
                ...selectedPhone.asMap().entries.map((entry) {
                  final index = entry.key;
                  final phone = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildInfoCard(
                      label: 'phone',
                      value: phone,
                      onTap: () => _launchCall(phone),
                      isPrimary: index == 0,
                    ),
                  );
                }).toList(),

                // EMAIL ADDRESSES
                SizedBox(height: 15),
                ...selectedEmail.asMap().entries.map((entry) {
                  final index = entry.key;
                  final email = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildInfoCard(
                      label: 'email',
                      value: email,
                      onTap: () => _launchEmail(email),
                      isPrimary: index == 0,
                    ),
                  );
                }).toList(),

                // WEBSITE LINKS
                SizedBox(height: 15),
                ...selectedUrl.asMap().entries.map((entry) {
                  final index = entry.key;
                  final url = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildInfoCard(
                      label: 'url',
                      value: url,
                      onTap: () => _launchUrl(url),
                      isPrimary: index == 0,
                    ),
                  );
                }).toList(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    print('Building action button: $label');
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CupertinoButton(
          color: CupertinoColors.darkBackgroundGray.withAlpha(40),
          padding: const EdgeInsets.symmetric(vertical: 20),
          onPressed: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: onPressed != null
                    ? CupertinoColors.systemBackground
                    : CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: onPressed != null
                      ? CupertinoColors.systemBackground
                      : CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    print('Building info card for: $label - $value');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: CupertinoColors.darkBackgroundGray,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.white,
                  ),
                ),
                SizedBox(width: 4),
                if (isPrimary)
                  Icon(
                    CupertinoIcons.star_fill,
                    size: 12,
                    color: CupertinoColors.inactiveGray.withOpacity(0.6),
                  ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchCall(String phone) async {
    print('Attempting to call: $phone');
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      print('Call initiated successfully');
    } else {
      print('Failed to initiate call');
    }
  }

  Future<void> _launchSms(String phone) async {
    print('Attempting to send SMS to: $phone');
    final Uri uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      print('SMS initiated successfully');
    } else {
      print('Failed to initiate SMS');
    }
  }

  Future<void> _launchEmail(String email) async {
    print('Attempting to email: $email');
    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      print('Email initiated successfully');
    } else {
      print('Failed to initiate email');
    }
  }

  Future<void> _launchUrl(String url) async {
    print('Attempting to launch URL: $url');
    if (!url.startsWith('http')) {
      url = 'https://$url';
      print('Modified URL to: $url');
    }
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      print('URL launched successfully');
    } else {
      print('Failed to launch URL');
    }
  }
}
