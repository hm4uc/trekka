// lib/features/preferences/presentation/pages/preferences_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/travel_constants.dart';
import '../bloc/preferences_bloc.dart'; // Import Bloc

// Import helper icon data của bạn
import '../../../../core/utils/icon_data.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  int _currentStep = 1;
  final Set<String> _selectedStyles = {};
  double _currentBudget = 0;

  // Biến lưu config để dùng cho slider
  BudgetConfig? _budgetConfig;

  @override
  void initState() {
    super.initState();
    // Gọi event lấy dữ liệu ngay khi vào màn hình
    context.read<PreferencesBloc>().add(GetTravelConstantsEvent());
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(value);
  }

  void _updateBudget(bool increase) {
    if (_budgetConfig == null) return;

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

  void _onContinue() {
    if (_currentStep == 1) {
      if (_selectedStyles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng chọn ít nhất 1 sở thích!")),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else {
      // Step 2: Hoàn tất
      print("Final Data: Styles: $_selectedStyles, Budget: $_currentBudget");
      context.go('/location-permission');
    }
  }

  void _onBack() {
    if (_currentStep == 2) setState(() => _currentStep = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep == 2
            ? IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: _onBack)
            : null,
        title: Text("Bước $_currentStep/2", style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textGrey)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go('/location-permission'),
            child: Text("Bỏ qua", style: GoogleFonts.inter(color: AppTheme.primaryColor)),
          )
        ],
      ),
      body: BlocConsumer<PreferencesBloc, PreferencesState>(
        listener: (context, state) {
          if (state is PreferencesError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is PreferencesLoaded && _currentBudget == 0) {
            // Set giá trị mặc định lần đầu tiên load thành công
            setState(() {
              _budgetConfig = state.constants.budgetConfig;
              _currentBudget = state.constants.budgetConfig.defaultValue;
            });
          }
        },
        builder: (context, state) {
          if (state is PreferencesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }

          if (state is PreferencesLoaded) {
            return Column(
              children: [
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(child: _buildProgressIndicator(active: _currentStep >= 1)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildProgressIndicator(active: _currentStep >= 2)),
                    ],
                  ),
                ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentStep == 1
                        ? _buildStep1Interests(state.constants.styles)
                        : _buildStep2Budget(),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: PrimaryButton(
                    text: _currentStep == 1 ? "Tiếp tục" : "Hoàn tất",
                    onPressed: _onContinue,
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text("Không tải được dữ liệu", style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }

  Widget _buildProgressIndicator({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryColor : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStep1Interests(List<TravelStyle> styles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text("Sở thích du lịch của\nbạn là gì?", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text("Hãy chọn ít nhất một mục để Trekka cá nhân hóa gợi ý cho bạn.", style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textGrey)),
          const SizedBox(height: 24),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: styles.length,
            itemBuilder: (context, index) {
              final item = styles[index];
              final isSelected = _selectedStyles.contains(item.id);

              return GestureDetector(
                onTap: () => setState(() => isSelected ? _selectedStyles.remove(item.id) : _selectedStyles.add(item.id)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent, width: 2),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(getIconData(item.icon), color: isSelected ? AppTheme.primaryColor : Colors.white, size: 24),
                            ),
                            const Spacer(),
                            Text(item.label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      if (isSelected) Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle), child: const Icon(Icons.check, size: 12, color: Colors.black))),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStep2Budget() {
    if (_budgetConfig == null) return const SizedBox.shrink();

    final int divisions = ((_budgetConfig!.max - _budgetConfig!.min) / _budgetConfig!.step).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text("Tùy chỉnh chuyến đi\ncủa bạn", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 60),

          Center(
            child: Column(
              children: [
                Text("Ngân sách dự kiến", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Text(_formatCurrency(_currentBudget), style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
          ),

          const SizedBox(height: 40),

          Row(
            children: [
              IconButton(onPressed: () => _updateBudget(false), icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.remove, color: Colors.white))),

              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.primaryColor,
                    inactiveTrackColor: AppTheme.surfaceColor,
                    thumbColor: AppTheme.primaryColor,
                    overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                    trackHeight: 6.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
                  ),
                  child: Slider(
                    value: _currentBudget,
                    min: _budgetConfig!.min,
                    max: _budgetConfig!.max,
                    divisions: divisions > 0 ? divisions : 1,
                    onChanged: (value) => setState(() => _currentBudget = value),
                  ),
                ),
              ),

              IconButton(onPressed: () => _updateBudget(true), icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, color: Colors.white))),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Tiết kiệm", style: GoogleFonts.inter(color: AppTheme.textGrey, fontSize: 12)), Text("Sang trọng", style: GoogleFonts.inter(color: AppTheme.textGrey, fontSize: 12))]),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}