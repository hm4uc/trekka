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
    // ✅ CHỈ GỌI API CONSTANTS ĐỂ LẤY TỪ ĐIỂN MAP ID -> LABEL
    // ❌ KHÔNG GỌI API PROFILE Ở ĐÂY NỮA (VÌ MAIN_PAGE ĐÃ GỌI)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PreferencesBloc>().add(GetTravelConstantsEvent());
    });
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    // Chỉ gọi lại khi người dùng chủ động kéo
    context.read<AuthBloc>().add(AuthGetProfileRequested());
    context.read<PreferencesBloc>().add(GetTravelConstantsEvent());
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        User? user;
        if (authState is AuthSuccess) {
          user = authState.user;
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                children: [
                  // 1. Header (Avatar, Name, Email)
                  _buildHeader(user),
                  const SizedBox(height: 20),

                  _buildEditButton(context, user),
                  const SizedBox(height: 30),

                  // 2. IMPORTANT INFO: Ngân sách & Sở thích (Đưa lên đầu)
                  _buildSectionTitle("Thông tin du lịch"),
                  const SizedBox(height: 16),
                  _buildBudgetCard(user.budget),
                  const SizedBox(height: 16),

                  // Lấy danh sách style từ Bloc để map ID -> Label
                  BlocBuilder<PreferencesBloc, PreferencesState>(
                    builder: (context, prefState) {
                      List<TravelStyle> availableStyles = [];
                      if (prefState is PreferencesLoaded) {
                        availableStyles = prefState.constants.styles;
                      }
                      return _buildPreferencesWrap(user!.preferences, availableStyles);
                    },
                  ),
                  const SizedBox(height: 30),

                  // 3. SECONDARY INFO: Bio, Gender, Age
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    _buildBioSection(user.bio!),
                    const SizedBox(height: 16),
                  ],

                  // Row thông tin phụ (Giới tính, Tuổi)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSmallInfoChip(Icons.person_outline, _formatGender(user.gender)),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 20, color: Colors.white24),
                      const SizedBox(width: 12),
                      _buildSmallInfoChip(Icons.cake_outlined, user.ageGroup ?? "Chưa chọn tuổi"),
                    ],
                  ),

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
    // Logic fallback Avatar
    final avatarUrl = (user.avatar != null && user.avatar!.isNotEmpty)
        ? user.avatar!
        : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.fullname)}&background=random&size=256";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 2),
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundImage: NetworkImage(avatarUrl),
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
      height: 36,
      child: OutlinedButton.icon(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
          );
          if (context.mounted) {
            context.read<AuthBloc>().add(AuthGetProfileRequested());
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.edit, size: 14),
        label: const Text("Chỉnh sửa hồ sơ", style: TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget _buildBudgetCard(double? budget) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final budgetText = budget != null ? currencyFormat.format(budget) : "Chưa thiết lập";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text("Ngân sách dự kiến mỗi ngày",
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textGrey)),
          const SizedBox(height: 4),
          Text(
            budgetText,
            style: GoogleFonts.inter(
                fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesWrap(List<String>? preferences, List<TravelStyle> availableStyles) {
    if (preferences == null || preferences.isEmpty) {
      return Center(
          child: Text("Chưa chọn sở thích",
              style: GoogleFonts.inter(color: AppTheme.textGrey, fontStyle: FontStyle.italic)));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: preferences.map((prefId) {
        final style = availableStyles.cast<TravelStyle>().firstWhere(
              (s) => s.id == prefId,
              orElse: () => TravelStyle(id: prefId, label: prefId, icon: "", description: ""),
            );

        return Chip(
          label: Text(style.label),
          backgroundColor: AppTheme.surfaceColor,
          side: BorderSide(color: Colors.white12),
          labelStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        );
      }).toList(),
    );
  }

  Widget _buildBioSection(String bio) {
    return Text(
      bio,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
          fontSize: 14, color: AppTheme.textGrey, height: 1.4, fontStyle: FontStyle.italic),
    );
  }

  Widget _buildSmallInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textGrey),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textGrey)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
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