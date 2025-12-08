import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../onboarding/domain/entities/travel_constants.dart';
import '../../../onboarding/presentation/bloc/preferences_bloc.dart'; // Import PreferencesBloc

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  String _selectedGender = 'male';
  String _selectedAgeGroup = '15-25';

  // Budget Variables
  double _currentBudget = 0;
  bool _isBudgetSkipped = false;

  // Preferences Variables
  final Set<String> _selectedPreferences = {};

  final List<String> _genders = ['male', 'female', 'other'];

  // Dữ liệu từ API Constants
  List<String> _ageGroups = ['15-25', '26-35', '36-50', '50+']; // Default fallback
  List<TravelStyle> _travelStyles = [];
  BudgetConfig? _budgetConfig;

  @override
  void initState() {
    super.initState();
    // 1. Gọi API lấy Constants để có danh sách sở thích & config budget
    context.read<PreferencesBloc>().add(GetTravelConstantsEvent());

    // 2. Fill User Data
    _nameController = TextEditingController(text: widget.user.fullname);
    _bioController = TextEditingController(text: widget.user.bio ?? "");

    if (widget.user.gender != null && _genders.contains(widget.user.gender)) {
      _selectedGender = widget.user.gender!;
    }
    if (widget.user.ageGroup != null) {
      _selectedAgeGroup = widget.user.ageGroup!;
    }

    if (widget.user.preferences != null) {
      _selectedPreferences.addAll(widget.user.preferences!);
    }

    if (widget.user.budget != null) {
      _currentBudget = widget.user.budget!;
      _isBudgetSkipped = false;
    } else {
      _isBudgetSkipped = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    context.read<AuthBloc>().add(AuthUpdateProfileSubmitted(
          fullname: _nameController.text.trim(),
          gender: _selectedGender,
          ageGroup: _selectedAgeGroup,
          bio: _bioController.text.trim(),
          avatar: widget.user.avatar ?? "",
          // Giữ nguyên avatar cũ
          budget: _isBudgetSkipped ? null : _currentBudget,
          preferences: _selectedPreferences.toList(),
        ));
  }

  void _updateBudget(bool increase) {
    if (_budgetConfig == null || _isBudgetSkipped) return;

    final step = _budgetConfig!.step;
    final min = _budgetConfig!.min;
    final max = _budgetConfig!.max;

    setState(() {
      if (increase) {
        if (_currentBudget + step <= max) _currentBudget += step;
      } else {
        if (_currentBudget - step >= min) _currentBudget -= step;
      }
    });
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cập nhật thành công!"), backgroundColor: Colors.green));
          context.pop();
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
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
          title: Text("Chỉnh sửa Hồ sơ", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        // Lắng nghe PreferencesBloc để lấy Constants
        body: BlocConsumer<PreferencesBloc, PreferencesState>(
          listener: (context, prefState) {
            if (prefState is PreferencesLoaded) {
              setState(() {
                _ageGroups = prefState.constants.ageGroup;
                _travelStyles = prefState.constants.styles;
                _budgetConfig = prefState.constants.budgetConfig;

                // Nếu User chưa có budget, set default từ config
                if (widget.user.budget == null) {
                  _currentBudget = _budgetConfig!.defaultValue;
                }
              });
            }
          },
          builder: (context, prefState) {
            // Nếu đang load constants thì hiện loading nhẹ hoặc vẫn hiện UI cũ
            // Ở đây ta cứ render UI, nếu chưa có data constants thì các widget bên dưới sẽ dùng fallback

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Avatar (Chỉ hiện ảnh, nút bấm giả lập upload)
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              (widget.user.avatar != null && widget.user.avatar!.isNotEmpty)
                                  ? NetworkImage(widget.user.avatar!)
                                  : const AssetImage('assets/images/welcome.jpg') as ImageProvider,
                          backgroundColor: AppTheme.surfaceColor,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: AppTheme.primaryColor, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 2. Info Fields
                  _buildLabel("Tên hiển thị"),
                  AuthTextField(controller: _nameController, hintText: "Tên của bạn"),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Độ tuổi"),
                            _buildDropdown(_ageGroups, _selectedAgeGroup,
                                (val) => setState(() => _selectedAgeGroup = val!)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Giới tính"),
                            _buildDropdown(_genders, _selectedGender,
                                (val) => setState(() => _selectedGender = val!)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Giới thiệu (Bio)"),
                  AuthTextField(controller: _bioController, hintText: "Mô tả ngắn..."),
                  const SizedBox(height: 30),

                  // 3. BUDGET SLIDER (Giống Onboarding)
                  if (_budgetConfig != null) ...[
                    _buildLabel("Ngân sách dự kiến"),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        _isBudgetSkipped ? "Chưa xác định" : _formatCurrency(_currentBudget),
                        style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _isBudgetSkipped ? AppTheme.textGrey : AppTheme.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 20),
                    IgnorePointer(
                      ignoring: _isBudgetSkipped,
                      child: Opacity(
                        opacity: _isBudgetSkipped ? 0.3 : 1.0,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () => _updateBudget(false),
                                icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: AppTheme.surfaceColor,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.remove, color: Colors.white))),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppTheme.primaryColor,
                                  inactiveTrackColor: AppTheme.surfaceColor,
                                  thumbColor: AppTheme.primaryColor,
                                  overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: _currentBudget,
                                  min: _budgetConfig!.min,
                                  max: _budgetConfig!.max,
                                  divisions: ((_budgetConfig!.max - _budgetConfig!.min) /
                                          _budgetConfig!.step)
                                      .round(),
                                  onChanged: (value) => setState(() => _currentBudget = value),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () => _updateBudget(true),
                                icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: AppTheme.surfaceColor,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.add, color: Colors.white))),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isBudgetSkipped = !_isBudgetSkipped),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_isBudgetSkipped ? Icons.check_circle : Icons.circle_outlined,
                              color: _isBudgetSkipped ? AppTheme.primaryColor : AppTheme.textGrey,
                              size: 20),
                          const SizedBox(width: 8),
                          Text("Chưa xác định ngân sách",
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: _isBudgetSkipped ? Colors.white : AppTheme.textGrey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // 4. PREFERENCES (Chips)
                  if (_travelStyles.isNotEmpty) ...[
                    _buildLabel("Sở thích du lịch"),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _travelStyles.map((pref) {
                        final isSelected = _selectedPreferences.contains(pref.id);
                        return FilterChip(
                          label: Text(pref.label),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedPreferences.add(pref.id);
                              } else {
                                _selectedPreferences.remove(pref.id);
                              }
                            });
                          },
                          backgroundColor: AppTheme.surfaceColor,
                          selectedColor: AppTheme.primaryColor,
                          checkmarkColor: Colors.black,
                          labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white, fontSize: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                  color: isSelected ? Colors.transparent : Colors.white24)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],

                  // Save Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: "Lưu thay đổi",
                        isLoading: state is AuthLoading,
                        onPressed: _onSubmit,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textGrey)));

  Widget _buildDropdown(List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          // Tránh lỗi value not in items
          hint: Text(value, style: const TextStyle(color: Colors.white)),
          isExpanded: true,
          dropdownColor: AppTheme.surfaceColor,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textGrey),
          items: items
              .map((String item) => DropdownMenuItem<String>(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
