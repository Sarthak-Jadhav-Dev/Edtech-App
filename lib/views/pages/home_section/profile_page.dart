import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 260,
            width: 360,
            decoration: BoxDecoration(
              color: Colors.purple.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade200,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white70,
                  ),
                ),
                Text("Sarthak Jadhav",style: TextStyle(fontSize: 20,fontFamily: "Sans"),),
                Text("sarthak.jadhav241@vit.edu",style: TextStyle(fontSize: 13,fontFamily: "Sans"),),
                Icon(Icons.badge),
                Text("Learner",style: TextStyle(fontSize: 13,fontFamily: "Sans"),),
              ],
            ),
          ),
          SizedBox(height: 10,),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings",style: TextStyle(fontFamily: "Poppins"),),
            trailing: Icon(Icons.arrow_forward_ios),
            style: ListTileStyle.list,
            onTap: (){},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings",style: TextStyle(fontFamily: "Poppins"),),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: (){},
          ),
          ListTile(
            leading: Icon(Icons.password),
            title: Text("Change Password",style: TextStyle(fontFamily: "Poppins"),),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: (){},
          ),
          SizedBox(
            height: 70,
            width: 360,
            child: Column(
              children: [
                OutlinedButton(
                    onPressed: (){},
                    child:Text("Log Out",style: TextStyle(fontFamily: "Sans"),),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
