import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_themes.dart';

class AITripPlannerPage extends StatefulWidget {
  const AITripPlannerPage({super.key});

  @override
  State<AITripPlannerPage> createState() => _AITripPlannerPageState();
}

class _AITripPlannerPageState extends State<AITripPlannerPage> {
  final _formKey = GlobalKey<FormState>();
  final _tripNameController = TextEditingController();
  final _destinationController = TextEditingController();

  String _selectedDuration = '1 ngày';
  final List<String> _selectedStyles = [];
  double _budget = 500000;
  String _transport = 'Xe máy';
  int _groupSize = 1;

  final _durations = ['Nửa ngày', '1 ngày', '2 ngày', '3 ngày'];
  final _travelStyles = [
    {'id': 'nature', 'name': 'Thiên nhiên', 'icon': Icons.forest},
    {'id': 'food_drink', 'name': 'Ẩm thực', 'icon': Icons.restaurant},
    {'id': 'culture', 'name': 'Văn hóa', 'icon': Icons.museum},
    {'id': 'adventure', 'name': 'Phiêu lưu', 'icon': Icons.hiking},
    {'id': 'relax', 'name': 'Thư giãn', 'icon': Icons.spa},
    {'id': 'shopping', 'name': 'Mua sắm', 'icon': Icons.shopping_bag},
  ];
  final _transports = ['Đi bộ', 'Xe máy', 'Ô tô', 'Xe buýt'];

  @override
  void dispose() {
    _tripNameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ai_trip_planner'.tr(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 32),

            // Trip Name
            _buildInputField(
              label: 'trip_title'.tr(),
              controller: _tripNameController,
              hint: 'trip_name_hint'.tr(),
              icon: Icons.edit_outlined,
            ),
            const SizedBox(height: 20),

            // Destination
            _buildInputField(
              label: 'destination_city'.tr(),
              controller: _destinationController,
              hint: 'enter_destination'.tr(),
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 24),

            // Duration
            _buildLabel('number_of_days'.tr()),
            _buildDurationPicker(),
            const SizedBox(height: 24),

            // Travel Style
            _buildLabel('travel_style'.tr()),
            const SizedBox(height: 8),
            Text(
              'please_select_style'.tr(),
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textGrey),
            ),
            const SizedBox(height: 12),
            _buildTravelStyleGrid(),
            const SizedBox(height: 24),

            // Budget
            _buildLabel('budget'.tr()),
            _buildBudgetSlider(),
            const SizedBox(height: 24),

            // Transport
            _buildLabel('transport_method'.tr()),
            _buildTransportPicker(),
            const SizedBox(height: 24),

            // Group Size
            _buildLabel('participants'.tr()),
            _buildGroupSizePicker(),
            const SizedBox(height: 32),

            // Generate Button
            _buildGenerateButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.2),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ai_creation'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ai_creation_desc'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppTheme.textGrey),
            prefixIcon: Icon(icon, color: AppTheme.primaryColor),
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDurationPicker() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _durations.length,
        itemBuilder: (context, index) {
          final duration = _durations[index];
          final isSelected = _selectedDuration == duration;

          return GestureDetector(
            onTap: () => setState(() => _selectedDuration = duration),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.white10,
                ),
              ),
              child: Center(
                child: Text(
                  duration,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTravelStyleGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _travelStyles.map((style) {
        final isSelected = _selectedStyles.contains(style['id']);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedStyles.remove(style['id']);
              } else {
                _selectedStyles.add(style['id'] as String);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.white10,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  style['icon'] as IconData,
                  color: isSelected ? AppTheme.primaryColor : Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  style['name'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBudgetSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(_budget / 1000).toStringAsFixed(0)}K VNĐ',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              'mỗi người / ngày',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: AppTheme.surfaceColor,
            thumbColor: AppTheme.primaryColor,
            overlayColor: AppTheme.primaryColor.withOpacity(0.2),
          ),
          child: Slider(
            value: _budget,
            min: 100000,
            max: 2000000,
            divisions: 38,
            onChanged: (value) => setState(() => _budget = value),
          ),
        ),
      ],
    );
  }

  Widget _buildTransportPicker() {
    return Wrap(
      spacing: 12,
      children: _transports.map((transport) {
        final isSelected = _transport == transport;

        return ChoiceChip(
          label: Text(transport),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (selected) {
            if (selected) setState(() => _transport = transport);
          },
          selectedColor: AppTheme.primaryColor,
          backgroundColor: AppTheme.surfaceColor,
          labelStyle: GoogleFonts.inter(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : Colors.white10,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGroupSizePicker() {
    return Row(
      children: [
        IconButton(
          onPressed: _groupSize > 1 ? () => setState(() => _groupSize--) : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppTheme.primaryColor,
          disabledColor: Colors.white30,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Center(
              child: Text(
                '$_groupSize người',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: _groupSize < 10 ? () => setState(() => _groupSize++) : null,
          icon: const Icon(Icons.add_circle_outline),
          color: AppTheme.primaryColor,
          disabledColor: Colors.white30,
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: _selectedStyles.isEmpty ? null : _generateTrip,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        disabledBackgroundColor: AppTheme.surfaceColor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 20),
          const SizedBox(width: 8),
          Text(
            'Tạo lịch trình với AI',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _generateTrip() {
    if (_formKey.currentState!.validate()) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildLoadingDialog(),
      );

      // Simulate AI processing (replace with actual API call)
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close form

        // Navigate to timeline with generated trip
        // TODO: Replace '1' with actual trip ID from API response
        context.push('/trip-timeline/1');
      });
    }
  }

  Widget _buildLoadingDialog() {
    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'AI đang tạo lịch trình...',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đang phân tích sở thích và tối ưu hóa tuyến đường',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

