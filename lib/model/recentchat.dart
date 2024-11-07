class RecentChat {
  final String image;
  final String name;

  RecentChat({required this.image, required this.name});
}

List<RecentChat> recentChats = [
  RecentChat(image: 'assets/user1.jpg', name: 'Lexi Jone'),
  RecentChat(image: 'assets/user2.jpg', name: 'Jane Smith'),
  RecentChat(image: 'assets/user3.jpg', name: 'Sam Wilson'),
  RecentChat(image: 'assets/user4.jpg', name: 'Lucy Brown'),
  RecentChat(image: 'assets/user5.jpg', name: 'Mark Brown'),
];
