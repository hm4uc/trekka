import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_themes.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Gọi API lấy thông tin mới nhất ngay khi vào màn hình (đã gọi ở MainPage)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<AuthBloc>().add(AuthGetProfileRequested());
    // });
  }

  // Hàm pull to refresh
  Future<void> _onRefresh() async {
    if (!mounted) return;
    context.read<AuthBloc>().add(AuthGetProfileRequested());
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        User? user;
        if (state is AuthSuccess) {
          user = state.user;
        }

        if (user == null) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text("Hồ sơ cá nhân", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.surfaceColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 1. Header (Avatar, Name, Email)
                  _buildHeader(user),
                  const SizedBox(height: 24),

                  // 2. Nút Edit
                  _buildEditButton(context, user),
                  const SizedBox(height: 32),

                  // 3. Bio Section
                  if (user.bio != null && user.bio!.isNotEmpty) _buildBioSection(user.bio!),

                  const SizedBox(height: 24),

                  // 4. Thông tin cơ bản (Giới tính, Tuổi)
                  Row(
                    children: [
                      Expanded(
                          child: _buildInfoCard(
                              "Giới tính", _formatGender(user.gender), Icons.person)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildInfoCard("Độ tuổi", user.ageGroup ?? "N/A", Icons.cake)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. Ngân sách
                  _buildBudgetCard(user.budget),
                  const SizedBox(height: 24),

                  // 6. Sở thích
                  _buildSectionTitle("Sở thích & Phong cách"),
                  const SizedBox(height: 12),
                  _buildPreferencesWrap(user.preferences),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS ---

  Widget _buildHeader(User user) {
    final imageProvider = (user.avatar != null && user.avatar!.isNotEmpty)
        ? NetworkImage(user.avatar!) as ImageProvider
        : const AssetImage('assets/images/welcome.jpg');

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 2),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: imageProvider,
            backgroundColor: AppTheme.surfaceColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.fullname.isNotEmpty ? user.fullname : "Trekker",
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textGrey),
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context, User user) {
    return SizedBox(
      width: 160,
      height: 40,
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
          );
          if (context.mounted) {
            context.read<AuthBloc>().add(AuthGetProfileRequested());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: const Text("Chỉnh sửa", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBioSection(String bio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Giới thiệu",
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            bio,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textGrey)),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(double? budget) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final budgetText = budget != null ? currencyFormat.format(budget) : "Chưa thiết lập";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.surfaceColor, AppTheme.surfaceColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text("Ngân sách dự kiến",
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textGrey)),
          const SizedBox(height: 8),
          Text(
            budgetText,
            style: GoogleFonts.inter(
                fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesWrap(List<String>? preferences) {
    if (preferences == null || preferences.isEmpty) {
      return Center(
          child: Text("Chưa chọn sở thích",
              style: GoogleFonts.inter(color: AppTheme.textGrey, fontStyle: FontStyle.italic)));
    }

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: preferences.map((pref) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
            ),
            child: Text(
              // Viết hoa chữ cái đầu
              "${pref[0].toUpperCase()}${pref.substring(1)}",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  String _formatGender(String? gender) {
    if (gender == 'male') return "Nam";
    if (gender == 'female') return "Nữ";
    if (gender == 'other') return "Khác";
    return "Chưa chọn";
  }
}
