// import 'package:flutter/material.dart';
//
// class LanguageDrawer extends StatelessWidget {
//   final List<Map<String, String>> languages = [
//     {'name': 'English', 'code': 'en'},
//     {'name': 'Spanish', 'code': 'es'},
//     {'name': 'French', 'code': 'fr'},
//     {'name': 'German', 'code': 'de'},
//     {'name': 'Chinese', 'code': 'zh'},
//     // Add more languages as needed
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Select Language',
//             style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
//           ),
//           Divider(),
//           ListView.builder(
//             shrinkWrap: true,
//             itemCount: languages.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(languages[index]['name']!),
//                 onTap: () {
//                   // Handle language selection
//                   _selectLanguage(context, languages[index]['code']!);
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _selectLanguage(BuildContext context, String languageCode) {
//     // Perform language change logic here, e.g., updating the app's locale
//     print("Language selected: $languageCode");
//
//     // Close the drawer after selection
//     Navigator.of(context).pop();
//   }
// }
