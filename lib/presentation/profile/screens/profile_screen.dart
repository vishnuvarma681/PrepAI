import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = ApiConstants.baseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Developer User',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'developer@example.com',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Backend Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),

            // Toggle Mock Mode
            Card(
              child: SwitchListTile(
                title: const Text('Run in Mock Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Simulates analysis locally without calling Azure endpoints.', style: TextStyle(fontSize: 11)),
                value: ApiConstants.useMockData,
                activeColor: AppColors.primary,
                onChanged: (bool value) {
                  setState(() {
                    ApiConstants.useMockData = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? 'Switched to local simulation mode' : 'Switched to live backend connection'),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Base URL Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Azure Functions API URL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('The secure endpoint where your serverless app resides.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _urlController,
                      enabled: !ApiConstants.useMockData,
                      decoration: const InputDecoration(
                        hintText: 'https://your-function.azurewebsites.net',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: ApiConstants.useMockData
                          ? null
                          : () {
                              setState(() {
                                ApiConstants.baseUrl = _urlController.text.trim();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('API URL updated successfully!'), backgroundColor: AppColors.success),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.surfaceLight,
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('Save URL Configuration'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton.icon(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.12),
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.logout_outlined),
              label: const Text('Sign Out'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
