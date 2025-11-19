import 'package:flutter/material.dart';
import 'package:mrz/models/models_class.dart';
import 'package:mrz/services/api_services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> _usersFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService().fetchAllUsers();
  }

  // পুল-টু-রিফ্রেশ মেথড
  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = ApiService().fetchAllUsers();
    });
    await _usersFuture;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search users...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color.fromARGB(137, 62, 4, 236)),
                ),
                style: const TextStyle(color: Color.fromARGB(255, 242, 5, 5), fontSize: 16),
                onChanged: (value) => setState(() {}),
              )
            : const Text('All Users'),
        centerTitle: !_isSearching,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _usersFuture = ApiService().fetchAllUsers()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData) {
            final users = snapshot.data!;
            final filteredUsers = _searchController.text.isEmpty
                ? users
                : users.where((user) {
                    final query = _searchController.text.toLowerCase();
                    final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.toLowerCase();
                    final email = (user.email ?? '').toLowerCase();
                    final username = (user.username ?? '').toLowerCase();
                    return fullName.contains(query) || email.contains(query) || username.contains(query);
                  }).toList();

            if (filteredUsers.isEmpty) {
              return const Center(child: Text('No users found', style: TextStyle(fontSize: 16)));
            }

            // ============= RefreshIndicator যোগ করা হয়েছে =============
            return RefreshIndicator(
              color: const Color.fromARGB(255, 232, 4, 182),
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              strokeWidth: 3,
              backgroundColor: Colors.yellow,
              onRefresh: _refreshUsers,
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Text('${user.id}', style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(
                        '${user.firstName ?? ''} ${user.lastName ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email ?? 'No email'),
                          if (user.phone != null) Text('Phone: ${user.phone}'),
                          if (user.address?.city != null) Text('City: ${user.address?.city}'),
                        ],
                      ),
                      trailing: _buildRoleBadge(user.role ?? 'user'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserDetailScreen(user: user)),
                        );
                      },
                    ),
                  );
                },
              ),
            );
            // =========================================================
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color = role == 'admin' ? Colors.red : role == 'moderator' ? Colors.orange : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(role.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// ==================== ডিটেইল স্ক্রিন ====================

class UserDetailScreen extends StatelessWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${user.firstName} ${user.lastName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('বেসিক তথ্য', [
              _buildInfoRow('নাম', '${user.firstName} ${user.lastName}'),
              _buildInfoRow('ইমেইল', user.email ?? 'N/A'),
              _buildInfoRow('ফোন', user.phone ?? 'N/A'),
              _buildInfoRow('রোল', user.role ?? 'user'),
            ]),
            const SizedBox(height: 16),
            if (user.address != null) ...[
              _buildSection('ঠিকানা', [
                _buildInfoRow('সড়ক', user.address?.address ?? 'N/A'),
                _buildInfoRow('শহর', user.address?.city ?? 'N/A'),
                _buildInfoRow('রাজ্য', user.address?.state ?? 'N/A'),
                _buildInfoRow('দেশ', user.address?.country ?? 'N/A'),
              ]),
            ],
            const SizedBox(height: 16),
            if (user.hair != null) ...[
              _buildSection('চুল', [
                _buildInfoRow('রঙ', user.hair?.color ?? 'N/A'),
                _buildInfoRow('টাইপ', user.hair?.type ?? 'N/A'),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
        const Divider(),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}