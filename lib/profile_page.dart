import 'package:calorie_budget/buttons/sign_out.dart';
import 'package:calorie_budget/loading.dart';
import 'package:calorie_budget/models/profile.dart';
import 'package:calorie_budget/profile_form.dart';
import 'package:calorie_budget/server_error.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late final Stream<Profile?> _profileStream;

  @override
  void initState() {
    super.initState();
    _profileStream = Profile.getStream(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [SignOutButton()],
      ),
      body: SafeArea(
        child: StreamBuilder<Profile?>(
            stream: _profileStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) return const ServerError();
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loading();
              }
              Profile profile =
                  snapshot.hasData ? snapshot.data as Profile : Profile();
              return ProfileForm(uid: widget.uid, profile: profile);
            }),
      ),
    );
  }
}
