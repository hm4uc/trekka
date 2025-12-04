import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
          title: Text("Cài đặt", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Chung"),
              _buildSettingItem(
                icon: Icons.language,
                title: "Ngôn ngữ",
                subtitle: "Tiếng Việt",
                onTap: () {},
              ),
              _buildSwitchItem(
                icon: Icons.location_on,
                title: "Cho phép định vị",
                value: _locationEnabled,
                onChanged: (val) => setState(() => _locationEnabled = val),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader("Tài khoản & Bảo mật"),
              _buildSettingItem(
                icon: Icons.lock,
                title: "Đổi mật khẩu",
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.privacy_tip,
                title: "Quyền riêng tư",
                onTap: () {},
              ),

              const SizedBox(height: 24),
              _buildSectionHeader("Hỗ trợ"),
              _buildSettingItem(
                icon: Icons.headset_mic,
                title: "Liên hệ hỗ trợ",
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.info,
                title: "Về Trekka",
                subtitle: "Phiên bản 1.0.0",
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
                          title: const Text("Đăng xuất?"),
                          content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Hủy"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Đóng dialog
                                // 👇 Gọi sự kiện Logout
                                context.read<AuthBloc>().add(AuthLogoutRequested());
                              },
                              child: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                    );
                  },
                  child: Text("Đăng xuất",
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