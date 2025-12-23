import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_themes.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../../auth/presentation/bloc/auth_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          // Khi state về Initial (đã logout) -> Chuyển về màn Auth
          // Dùng context.go để xóa stack, không cho back lại
          context.go('/auth');
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text("settings".tr(), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("settings_general".tr()),
              _buildSettingItem(
                icon: Icons.language,
                title: "settings_language".tr(),
                subtitle: context.locale.languageCode == 'vi'
                    ? "language_vietnamese".tr()
                    : "language_english".tr(),
                onTap: () => _showLanguageDialog(context),
              ),
              _buildSwitchItem(
                icon: Icons.location_on,
                title: "settings_allow_location".tr(),
                value: _locationEnabled,
                onChanged: (val) => setState(() => _locationEnabled = val),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader("settings_account".tr()),
              _buildSettingItem(
                icon: Icons.lock,
                title: "settings_change_password".tr(),
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.privacy_tip,
                title: "settings_privacy".tr(),
                onTap: () {},
              ),

              const SizedBox(height: 24),
              _buildSectionHeader("settings_support".tr()),
              _buildSettingItem(
                icon: Icons.headset_mic,
                title: "settings_contact".tr(),
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.info,
                title: "settings_about".tr(),
                subtitle: "settings_version".tr(),
                onTap: () {},
              ),

              const SizedBox(height: 32),
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("logout_title".tr()),
                          content: Text("logout_message".tr()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("cancel".tr()),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Đóng dialog
                                // 👇 Gọi sự kiện Logout
                                context.read<AuthBloc>().add(AuthLogoutRequested());
                              },
                              child: Text("logout".tr(), style: const TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                    );
                  },
                  child: Text("logout".tr(),
                      style: GoogleFonts.inter(
                          color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(
            "language_dialog_title".tr(),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                dialogContext,
                "language_vietnamese".tr(),
                const Locale('vi', 'VN'),
                context.locale.languageCode == 'vi',
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                dialogContext,
                "language_english".tr(),
                const Locale('en', 'US'),
                context.locale.languageCode == 'en',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext dialogContext,
    String title,
    Locale locale,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () async {
        await dialogContext.setLocale(locale);
        // Update the parent context's locale as well
        if (mounted) {
          await context.setLocale(locale);
          setState(() {}); // Rebuild to update the subtitle
        }
        Navigator.of(dialogContext).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.2)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textGrey,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 15)),
        subtitle: subtitle != null
            ? Text(subtitle, style: GoogleFonts.inter(color: AppTheme.textGrey, fontSize: 13))
            : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textGrey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        activeColor: AppTheme.primaryColor,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 15)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}