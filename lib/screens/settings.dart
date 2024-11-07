import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  String _selectedTheme = 'Light';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      _selectedTheme = prefs.getString('selectedTheme') ?? 'Light';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('selectedTheme', _selectedTheme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF19173D),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF19173D),
        elevation: 0,
        title: Text('Settings',style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Enable Notifications', style: TextStyle(color: Colors.white),),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings();
              },
            ),
            Divider(),
            Text(
              'Theme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            RadioListTile<String>(
              title: Text('Light',style: TextStyle(color: Colors.white),),
              value: 'Light',
              groupValue: _selectedTheme,
              onChanged: (String? value) {
                setState(() {
                  _selectedTheme = value!;
                });
                _saveSettings();
              },
            ),
            RadioListTile<String>(
              title: Text('Dark',style: TextStyle(color: Colors.white),),
              value: 'Dark',
              groupValue: _selectedTheme,
              onChanged: (String? value) {
                setState(() {
                  _selectedTheme = value!;
                });
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}
