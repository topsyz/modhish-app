import 'package:flutter/material.dart';
import 'package:untitled3/main.dart';
import 'package:untitled3/MyHomePage.dart';

import 'package:untitled3/BluetoothDeviceListEntry.dart';
class NavBar extends StatelessWidget {
  const NavBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text(''),
            accountEmail: Text("Connection",style:TextStyle(fontSize:25),),
            currentAccountPicture: CircleAvatar(backgroundColor: Color(0xFF0F94E3),
              child: ClipOval(child:Center(child: Icon(Icons.share_rounded,color: Colors.white))
              ),
            ),
            decoration: BoxDecoration(
              color: Color(0xFF0F94E3),
              image: DecorationImage(image: AssetImage('images/connection.jpg'),fit: BoxFit.cover),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bluetooth_audio_sharp),
            title: const Text('connect with Bluetooth'),
            onTap: () =>{Navigator.push(context, MaterialPageRoute(builder: (context)=>const  MyHomePage(title: '',)))},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.wifi_find_sharp),
            title: const Text('connect with WiFi'),
            onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context)=> const MyHomePage(title: '',)))},
          ),
        ],
      ),
    );
  }
}