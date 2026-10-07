import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../config/app_constants.dart';
import '../config/app_theme.dart';
import '../repositories/auth_repository.dart';
import '../repositories/movie_repository.dart';

/// Settings and API Configuration screen allowing evaluators to switch data modes
/// and test custom TMDB API keys without code modification.
class SettingsScreen extends StatefulWidget {
  final MovieRepository repository;
  final AuthRepository? authRepository;

  const SettingsScreen({
    Key? key,
    required this.repository,
    this.authRepository,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _apiKeyController;
  late DataSourceMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: ApiConfig.apiKey);
    _selectedMode = widget.repository.currentMode;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final key = _apiKeyController.text.trim();
    widget.repository.updateApiKey(key);
    widget.repository.setMode(_selectedMode);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.surfaceCard,
        content: Text(
          'Settings saved successfully!',
          style: TextStyle(color: AppTheme.successColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('App & API Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          // User Account & Session Card
          if (widget.authRepository?.currentUser != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF222638), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primary.withOpacity(0.2),
                        child: Text(
                          widget.authRepository!.currentUser!.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.authRepository!.currentUser!.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.authRepository!.currentUser!.email,
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'Active Session',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.authRepository!.logout();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor, size: 18),
                      label: const Text(
                        'Sign Out of FlickVault',
                        style: TextStyle(color: AppTheme.errorColor, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.errorColor.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Data Mode Toggle Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF222638), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storage_rounded, color: AppTheme.primary, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Data Source Mode',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RadioListTile<DataSourceMode>(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primary,
                  title: const Text(
                    'Local Sample Movies (Offline)',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Instant load of 10+ preloaded blockbuster movies without needing an API key.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  value: DataSourceMode.sampleData,
                  groupValue: _selectedMode,
                  onChanged: (mode) {
                    if (mode != null) {
                      setState(() => _selectedMode = mode);
                    }
                  },
                ),
                const Divider(),
                RadioListTile<DataSourceMode>(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primary,
                  title: const Text(
                    'Live TMDB API Mode',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Real-time network requests to TMDB endpoints (requires valid API key).',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  value: DataSourceMode.tmdbLive,
                  groupValue: _selectedMode,
                  onChanged: (mode) {
                    if (mode != null) {
                      setState(() => _selectedMode = mode);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // TMDB API Key Config Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF222638), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.vpn_key_rounded, color: AppTheme.primary, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'TMDB API Key Configuration',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your TMDB API key is kept secure and never embedded in UI files.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiKeyController,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'TMDB v3 API Key',
                    hintText: 'e.g. 8a2f1b4c90e3d5...',
                    prefixIcon: const Icon(Icons.key, color: AppTheme.textSecondary, size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.textMuted, size: 18),
                      onPressed: () => _apiKeyController.clear(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('Save & Apply Settings'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // About Task & Evaluation Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF222638), width: 1),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppTheme.accent, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'About This Project',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Created for DCS & GDG Recruitment Task.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                SizedBox(height: 6),
                Text(
                  '• Tech Stack: Flutter & Dart (Cross-Platform)\n'
                  '• Architecture: Clean Repository Pattern\n'
                  '• State: Responsive ChangeNotifier\n'
                  '• UI Design: Cinema Dark Mode inspired by Dribbble 6444124\n'
                  '• Dual Mode: Offline Sample JSON + Live TMDB Endpoints',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
