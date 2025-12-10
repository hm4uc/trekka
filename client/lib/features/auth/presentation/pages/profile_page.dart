import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../onboarding/domain/entities/travel_constants.dart';
import '../../../onboarding/presentation/bloc/preferences_bloc.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PreferencesBloc>().add(GetTravelConstantsEvent());
    });
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    context.read<AuthBloc>().add(AuthGetProfileRequested());
    context.read<PreferencesBloc>().add(GetTravelConstantsEvent());
    await Future.delayed(const Duration(seconds: 1));
  }

  void _handleItemTap(String title) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Tính năng '$title' đang phát triển!",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.surfaceColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        User? user = (authState is AuthSuccess) ? authState.user : null;
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
            title: Text("Hồ sơ", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // 1. THANH TIẾN ĐỘ HOÀN THÀNH (Đưa lên đầu)
                  _buildCompletionProgressBar(85),
                  const SizedBox(height: 24),

                  // 2. HEADER
                  _buildHeader(user),
                  const SizedBox(height: 24),

                  // 3. NÚT CHỈNH SỬA
                  _buildEditButton(context, user),
                  const SizedBox(height: 24),

                  // 4. THỐNG KÊ (Stats)
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("42", "Điểm đã đến")),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard("15", "Sự kiện tham gia")),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 5. NGÂN SÁCH (Hiển thị số to)
                  _buildSectionTitle("Thông tin du lịch"),
                  const SizedBox(height: 12),
                  _buildBudgetDisplay(user.budget),

                  const SizedBox(height: 24),

                  // 6. PHONG CÁCH DU LỊCH
                  _buildSectionTitle("Phong cách & Sở thích"),
                  const SizedBox(height: 12),
                  BlocBuilder<PreferencesBloc, PreferencesState>(
                    builder: (context, prefState) {
                      List<TravelStyle> styles =
                          (prefState is PreferencesLoaded) ? prefState.constants.styles : [];
                      return _buildPreferencesWrap(user.preferences, styles);
                    },
                  ),

                  // 7. BIO
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle("Giới thiệu"),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        user.bio!,
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.5),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // 8. MENU
                  _buildMenuItem(Icons.calendar_today, "Lịch trình của tôi",
                      () => _handleItemTap("Lịch trình")),
                  _buildMenuItem(
                      Icons.favorite, "Địa điểm yêu thích", () => _handleItemTap("Yêu thích")),
                  _buildMenuItem(
                      Icons.location_on, "Địa điểm đã đi", () => _handleItemTap("Check-in")),
                  _buildMenuItem(
                      Icons.celebration, "Sự kiện đã tham gia", () => _handleItemTap("Sự kiện")),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Sub-widgets ---

  Widget _buildHeader(User user) {
    final avatarUrl = (user.avatar != null && user.avatar!.startsWith("http"))
        ? user.avatar!
        : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.fullname)}&background=F3D6C6&color=333&size=256";

    String subtitle = "";
    if (user.age != null && user.age! > 0) subtitle += "${user.age} tuổi";
    if (user.job != null && user.job!.isNotEmpty) {
      if (subtitle.isNotEmpty) subtitle += "  •  "; // Dùng dấu chấm ngăn cách đẹp hơn
      subtitle += "${user.job![0].toUpperCase()}${user.job!.substring(1)}";
    }
    if (subtitle.isEmpty) subtitle = user.email;

    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: const Color(0xFFF3D6C6),
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(height: 16),
        Text(
          user.fullname,
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context, User user) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
          );
          if (context.mounted) {
            context.read<AuthBloc>().add(AuthGetProfileRequested());
          }
        },
        icon: const Icon(Icons.edit, size: 16, color: Colors.black),
        label: const Text("Chỉnh sửa hồ sơ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.white60)),
        ],
      ),
    );
  }

  // Mới: Progress Bar đẹp
  Widget _buildCompletionProgressBar(int percent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E3E36), const Color(0xFF1E3E36).withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Hoàn thành hồ sơ",
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              Text("$percent%",
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.black26,
              color: AppTheme.primaryColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text("Hoàn thiện hồ sơ để nhận gợi ý chính xác hơn từ Trekka AI.",
              style: GoogleFonts.inter(
                  fontSize: 11, color: Colors.white60, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // Mới: Hiển thị Ngân sách dạng số
  Widget _buildBudgetDisplay(double? budget) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final budgetText = budget != null ? currencyFormat.format(budget) : "Chưa thiết lập";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Ngân sách dự kiến mỗi chuyến đi",
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textGrey)),
          const SizedBox(height: 8),
          Text(
            budgetText,
            style: GoogleFonts.inter(
                fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesWrap(List<String>? preferences, List<TravelStyle> styles) {
    if (preferences == null || preferences.isEmpty) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text("Chưa chọn sở thích",
            style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: preferences.map((pid) {
          final label = styles
              .cast<TravelStyle>()
              .firstWhere((s) => s.id == pid,
                  orElse: () => TravelStyle(id: pid, label: pid, icon: "", description: ""))
              .label;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3E36),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "#$label",
              style: GoogleFonts.inter(
                  color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style:
                GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)));
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12), // Dùng Padding thay vì Container margin
      child: Material(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge, // 👇 QUAN TRỌNG: Cắt bỏ phần loang lổ ra ngoài bo góc
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(icon, color: Colors.white70),
          title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 15)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white24),
        ),
      ),
    );
  }
}