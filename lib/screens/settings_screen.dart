import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final lang = settings.language;
        final isDark = settings.isDark;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: Text(
              AppStrings.get('settings', lang),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            backgroundColor:
                isDark ? const Color(0xFF16213E) : Colors.deepPurple[50],
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : Colors.deepPurple,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Appearance ──────────────────────────────────────────
              _SectionHeader(
                title: AppStrings.get('appearance', lang),
                isDark: isDark,
              ),
              _SettingsCard(
                isDark: isDark,
                child: SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.deepPurple.withOpacity(0.3)
                          : Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: Colors.deepPurple,
                    ),
                  ),
                  title: Text(
                    AppStrings.get('dark_mode', lang),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    AppStrings.get('dark_mode_subtitle', lang),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                  value: isDark,
                  activeColor: Colors.deepPurple,
                  onChanged: (val) {
                    settings.setThemeMode(
                      val ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Language ─────────────────────────────────────────────
              _SectionHeader(
                title: AppStrings.get('language', lang),
                isDark: isDark,
              ),
              _SettingsCard(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        AppStrings.get('language_subtitle', lang),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    _LanguageTile(
                      flag: '🇺🇸',
                      label: AppStrings.get('english', lang),
                      langCode: 'en',
                      selectedLang: lang,
                      isDark: isDark,
                      onTap: () => settings.setLanguage('en'),
                    ),
                    const Divider(height: 1, indent: 64),
                    _LanguageTile(
                      flag: '🇦🇲',
                      label: AppStrings.get('armenian', lang),
                      langCode: 'hy',
                      selectedLang: lang,
                      isDark: isDark,
                      onTap: () => settings.setLanguage('hy'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── About ─────────────────────────────────────────────────
              _SectionHeader(
                title: AppStrings.get('about', lang),
                isDark: isDark,
              ),
              _SettingsCard(
                isDark: isDark,
                child: Column(
                  children: [
                    _AboutTile(
                      icon: Icons.info_outline,
                      title: AppStrings.get('app_version', lang),
                      trailing: '1.0.0',
                      isDark: isDark,
                    ),
                    const Divider(height: 1, indent: 64),
                    _AboutTile(
                      icon: Icons.feedback_outlined,
                      title: AppStrings.get('feedback', lang),
                      isDark: isDark,
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 64),
                    _AboutTile(
                      icon: Icons.privacy_tip_outlined,
                      title: AppStrings.get('privacy', lang),
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Colors.deepPurple[isDark ? 200 : 400],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _SettingsCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String label;
  final String langCode;
  final String selectedLang;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.langCode,
    required this.selectedLang,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedLang == langCode;
    return ListTile(
      onTap: onTap,
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          color: isSelected
              ? Colors.deepPurple
              : (isDark ? Colors.white : Colors.black87),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.deepPurple)
          : Icon(Icons.circle_outlined,
              color: isDark ? Colors.white24 : Colors.grey[300]),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final bool isDark;
  final VoidCallback? onTap;

  const _AboutTile({
    required this.icon,
    required this.title,
    required this.isDark,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.deepPurple.withOpacity(0.3)
              : Colors.deepPurple[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.deepPurple, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing != null
          ? Text(trailing!,
              style:
                  TextStyle(color: isDark ? Colors.white54 : Colors.grey[500]))
          : onTap != null
              ? Icon(Icons.chevron_right,
                  color: isDark ? Colors.white38 : Colors.grey[400])
              : null,
    );
  }
}
