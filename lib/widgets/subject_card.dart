import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_strings.dart';

class SubjectCard extends StatelessWidget {
  final String subject;
  final IconData icon;
  final Color color;
  final String description;
  final double progress;
  final VoidCallback onTap;
  final VoidCallback? onUploadLecture;
  final VoidCallback? onAiHelper;
  final VoidCallback? onFlashcards;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.icon,
    required this.color,
    required this.description,
    required this.progress,
    required this.onTap,
    this.onUploadLecture,
    this.onAiHelper,
    this.onFlashcards,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final lang = settings.language;
    final isDark = settings.isDark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 380;

    return Card(
      elevation: 3,
      color: isDark ? const Color(0xFF1E2A3A) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(isDark ? 0.15 : 0.1),
                color.withOpacity(isDark ? 0.08 : 0.05),
              ],
            ),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                subject,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActionButton(
                    icon: Icons.upload_file_rounded,
                    label: AppStrings.get('lecture', lang),
                    color: color,
                    isDark: isDark,
                    onTap: onUploadLecture,
                  ),
                  _ActionButton(
                    icon: Icons.auto_awesome_rounded,
                    label: AppStrings.get('ai_help', lang),
                    color: color,
                    isDark: isDark,
                    onTap: onAiHelper,
                  ),
                  _ActionButton(
                    icon: Icons.style_rounded,
                    label: AppStrings.get('cards', lang),
                    color: color,
                    isDark: isDark,
                    onTap: onFlashcards,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
