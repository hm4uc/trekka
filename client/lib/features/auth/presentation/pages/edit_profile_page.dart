import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../onboarding/domain/entities/travel_constants.dart';
import '../../../onboarding/presentation/bloc/preferences_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  // Thay _ageController bằng biến int để lưu giá trị chọn
  int? _selectedAge;

  String _selectedGender = 'other';
  String? _selectedJob;
  double _currentBudget = 0;
  bool _isBudgetSkipped = false;
  final Set<String> _selectedPreferences = {};

  List<String> _jobs = [];
  List<TravelStyle> _travelStyles = [];
  BudgetConfig? _budgetConfig;
  int _ageMin = 15;
  int _ageMax = 100;

  @override
  void initState() {
    super.initState();
    context.read<PreferencesBloc>().add(GetTravelConstantsEvent());
    _initUserData();
  }

  void _initUserData() {
    _nameController = TextEditingController(text: widget.user.fullname);
    _bioController = TextEditingController(text: widget.user.bio ?? "");

    // Init Age
    _selectedAge = widget.user.age; // int?

    _selectedGender = widget.user.gender ?? 'other';
    _selectedJob = widget.user.job;

    if (widget.user.preferences != null) _selectedPreferences.addAll(widget.user.preferences!);

    if (widget.user.budget != null && widget.user.budget! > 0) {
      _currentBudget = widget.user.budget!;
      _isBudgetSkipped = false;
    } else {
      _currentBudget = 1000000;
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
    String avatarUrl = widget.user.avatar ?? "";
    if (avatarUrl.isEmpty || !avatarUrl.startsWith("http")) {
      avatarUrl =
          "https://ui-avatars.com/api/?name=${Uri.encodeComponent(_nameController.text)}&background=F3D6C6&color=333&size=256";
    }

    context.read<AuthBloc>().add(AuthUpdateProfileSubmitted(
          fullname: _nameController.text.trim(),
          gender: _selectedGender,
          age: _selectedAge,
          // Gửi int trực tiếp
          job: _selectedJob ?? "",
          bio: _bioController.text.trim(),
          avatar: avatarUrl,
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

  // --- SHOW PICKERS (Bottom Sheet) ---

  // Picker chọn Nghề nghiệp
  void _showJobPicker() {
    _showSelectionSheet(
      title: "job".tr(),
      items: _jobs,
      selectedItem: _selectedJob,
      itemLabelBuilder: (item) => "${item[0].toUpperCase()}${item.substring(1)}",
      onSelected: (val) => setState(() => _selectedJob = val),
    );
  }

  // Picker chọn Tuổi (Tạo list số từ min->max)
  void _showAgePicker() {
    final List<int> ages = List.generate(_ageMax - _ageMin + 1, (index) => _ageMin + index);

    _showSelectionSheet<int>(
      title: "age".tr(),
      items: ages,
      selectedItem: _selectedAge,
      itemLabelBuilder: (item) => "$item ${"age_years".tr()}",
      onSelected: (val) => setState(() => _selectedAge = val),
    );
  }

  // Hàm hiển thị BottomSheet chung (Clean Code)
  void _showSelectionSheet<T>({
    required String title,
    required List<T> items,
    required T? selectedItem,
    required String Function(T) itemLabelBuilder,
    required Function(T) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final label = itemLabelBuilder(item);
                    final isSelected = selectedItem == item;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onSelected(item);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(label,
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: isSelected ? AppTheme.primaryColor : Colors.white)),
                              if (isSelected)
                                const Icon(Icons.check, color: AppTheme.primaryColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("changes_saved".tr()), backgroundColor: Colors.green));
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text("edit_profile".tr(), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocConsumer<PreferencesBloc, PreferencesState>(
          listener: (context, state) {
            if (state is PreferencesLoaded) {
              setState(() {
                _travelStyles = state.constants.styles;
                _budgetConfig = state.constants.budgetConfig;
                _jobs = state.constants.jobs;
                _ageMin = state.constants.ageMin;
                _ageMax = state.constants.ageMax;
                if (widget.user.budget == null) _currentBudget = _budgetConfig!.defaultValue;
              });
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarEdit(),
                  const SizedBox(height: 30),

                  _buildLabel("display_name".tr()),
                  _buildCustomTextField(_nameController, "your_name".tr()),
                  const SizedBox(height: 20),

                  // SELECTOR: Tuổi & Nghề nghiệp
                  Row(
                    children: [
                      // Tuổi (Dạng Selector)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("age".tr()),
                            _buildSelectorField(
                              text: _selectedAge != null ? "$_selectedAge" : "choose".tr(),
                              onTap: _showAgePicker,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Nghề nghiệp (Dạng Selector)
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("job".tr()),
                            _buildSelectorField(
                              text: _selectedJob != null
                                  ? "${_selectedJob![0].toUpperCase()}${_selectedJob!.substring(1)}"
                                  : "choose_job".tr(),
                              onTap: _showJobPicker,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // GENDER SELECTION (Giao diện mới: Cards)
                  _buildLabel("gender".tr()),
                  _buildGenderSelector(),
                  const SizedBox(height: 20),

                  _buildLabel("bio_intro".tr()),
                  _buildCustomTextField(_bioController, "write_about_yourself".tr(), maxLines: 3),
                  const SizedBox(height: 30),

                  // BUDGET VỚI NÚT +/- (Đã fix UI)
                  if (_budgetConfig != null) _buildBudgetControl(),

                  const SizedBox(height: 20),
                  _buildLabel("your_preferences".tr()),
                  _buildPreferencesChips(),
                  const SizedBox(height: 40),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) => PrimaryButton(
                        text: "save_changes".tr(),
                        isLoading: authState is AuthLoading,
                        onPressed: _onSubmit),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Components ---

  // Widget chọn (giống Dropdown nhưng đẹp hơn, dùng cho Age & Job)
  Widget _buildSelectorField({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16), // Bo góc mềm mại hơn (24 -> 16)
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: GoogleFonts.inter(fontSize: 15, color: Colors.white)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }

  // Widget chọn giới tính mới (3 Cards ngang)
  Widget _buildGenderSelector() {
    return Row(
      children: [
        _buildGenderCard('male', 'male'.tr(), Icons.male),
        const SizedBox(width: 12),
        _buildGenderCard('female', 'female'.tr(), Icons.female),
        const SizedBox(width: 12),
        _buildGenderCard('other', 'other'.tr(), Icons.transgender),
      ],
    );
  }

  Widget _buildGenderCard(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: Material(
        color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => setState(() => _selectedGender = value),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.white12,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppTheme.backgroundColor : Colors.white54,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.backgroundColor : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetControl() {
    return Column(
      children: [
        _buildLabel("expected_budget_per_trip".tr()),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _isBudgetSkipped
                ? "not_determined".tr()
                : NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(_currentBudget),
            style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _isBudgetSkipped ? AppTheme.textGrey : AppTheme.primaryColor),
          ),
        ),
        const SizedBox(height: 10),
        IgnorePointer(
          ignoring: _isBudgetSkipped,
          child: Opacity(
            opacity: _isBudgetSkipped ? 0.4 : 1.0,
            child: Row(
              children: [
                // Nút (-)
                _buildBudgetBtn(Icons.remove, () => _updateBudget(false)),
                // Slider
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primaryColor,
                      inactiveTrackColor: AppTheme.surfaceColor,
                      thumbColor: AppTheme.primaryColor,
                      overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _currentBudget,
                      min: _budgetConfig!.min,
                      max: _budgetConfig!.max,
                      divisions:
                          ((_budgetConfig!.max - _budgetConfig!.min) / _budgetConfig!.step).round(),
                      onChanged: (v) => setState(() => _currentBudget = v),
                    ),
                  ),
                ),
                // Nút (+)
                _buildBudgetBtn(Icons.add, () => _updateBudget(true)),
              ],
            ),
          ),
        ),

        // Toggle Budget
        GestureDetector(
          onTap: () => setState(() => _isBudgetSkipped = !_isBudgetSkipped),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_isBudgetSkipped ? Icons.check_circle : Icons.circle_outlined,
                    color: _isBudgetSkipped ? AppTheme.primaryColor : AppTheme.textGrey, size: 20),
                const SizedBox(width: 8),
                Text("not_determined_budget".tr(),
                    style: GoogleFonts.inter(
                        fontSize: 14, color: _isBudgetSkipped ? Colors.white : AppTheme.textGrey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetBtn(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarEdit() {
    final avatarUrl = (widget.user.avatar != null && widget.user.avatar!.startsWith("http"))
        ? widget.user.avatar!
        : "https://ui-avatars.com/api/?background=F3D6C6&color=333&size=256";

    return Center(
      child: Column(
        children: [
          CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: AppTheme.surfaceColor),
          const SizedBox(height: 12),
          Text("change_avatar".tr(),
              style: const TextStyle(
                  color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildCustomTextField(TextEditingController controller, String hint,
      {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16), // Bo góc đồng bộ
          border: Border.all(color: Colors.white24)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          isDense: false,
        ),
      ),
    );
  }

  Widget _buildPreferencesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _travelStyles.map((s) {
        final isSelected = _selectedPreferences.contains(s.id);
        return FilterChip(
          label: Text(s.label),
          selected: isSelected,
          onSelected: (v) => setState(
              () => v ? _selectedPreferences.add(s.id) : _selectedPreferences.remove(s.id)),
          backgroundColor: const Color(0xFF1E3E36),
          selectedColor: const Color(0xFF2E7D68),
          labelStyle: const TextStyle(color: Colors.white),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), side: BorderSide.none),
          deleteIcon: isSelected ? const Icon(Icons.close, size: 14, color: Colors.white) : null,
          onDeleted: isSelected ? () => setState(() => _selectedPreferences.remove(s.id)) : null,
        );
      }).toList(),
    );
  }

  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)));
}
