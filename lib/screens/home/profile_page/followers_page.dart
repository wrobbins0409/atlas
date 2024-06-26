import 'package:atlas/screens/home/profile_page/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:atlas/services/database.dart';
import 'package:atlas/models/user.dart';

class FollowersPage extends StatefulWidget {
  final AtlasUser user;

  const FollowersPage({super.key, required this.user});

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  Future<List<AtlasUser>> _getFollowersUsers() async {
    List<String> userIds =
        await DatabaseService().getFollowerIDs(widget.user.uid);
    List<AtlasUser> users = [];
    for (String userId in userIds) {
      var user = await DatabaseService().getAtlasUser(userId);
      users.add(user);
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<AtlasUser>>(
        future: _getFollowersUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Consider customizing this message based on the error
            return const Center(
                child: Text('Something went wrong. Please try again later.'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var user = snapshot.data![index];
                return Card(
                  color: const Color.fromARGB(
                      255, 35, 35, 35), //CHANGE BACKGROUND COLOR HERE

                  child: ListTile(
                    leading: FutureBuilder<String>(
                      future: DatabaseService().getProfilePicture(user.uid),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            !snapshot.hasData) {
                          return const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                          );
                        } else {
                          return CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(snapshot.data!),
                          );
                        }
                      },
                    ),
                    title: Text('@${user.username}'),
                    subtitle: Text('${user.firstName} ${user.lastName}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileView(userID: user.uid),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No followers found'));
          }
        },
      ),
    );
  }
}
