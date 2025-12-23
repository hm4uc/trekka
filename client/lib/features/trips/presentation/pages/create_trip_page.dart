import 'package:easy_localization/easy_localization.dart' hide DateFormat;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../injection_container.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  String _tripType = 'solo';
  int _participantCount = 1;
  String _transport = 'walking';
  String _visibility = 'private';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TripBloc>(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          title: Text(
            'Tạo lịch trình mới',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<TripBloc, TripState>(
          listener: (context, state) {
            if (state is TripCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tạo lịch trình thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else if (state is TripError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<TripBloc, TripState>(
            builder: (context, state) {
              final isLoading = state is TripLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _buildSectionTitle('Tên chuyến đi'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: _buildInputDecoration('VD: Một ngày khám phá Hà Nội'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên chuyến đi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Description
                      _buildSectionTitle('Mô tả (không bắt buộc)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: _buildInputDecoration('Mô tả chi tiết về chuyến đi...'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Date Range
                      _buildSectionTitle('Thời gian'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              'Ngày bắt đầu',
                              _startDate,
                              (date) => setState(() => _startDate = date),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDateField(
                              'Ngày kết thúc',
                              _endDate,
                              (date) => setState(() => _endDate = date),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Trip Type
                      _buildSectionTitle('trip_type'.tr()),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChoiceChip('solo', 'solo'.tr(), Icons.person),
                          _buildChoiceChip('couple', 'couple'.tr(), Icons.people),
                          _buildChoiceChip('family', 'family'.tr(), Icons.family_restroom),
                          _buildChoiceChip('friends', 'friends'.tr(), Icons.group),
                          _buildChoiceChip('group', 'group'.tr(), Icons.groups),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Participant Count
                      if (_tripType != 'solo') ...[
                        _buildSectionTitle('participants'.tr()),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_participantCount > 2) {
                                  setState(() => _participantCount--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryColor),
                            ),
                            Text(
                              '$_participantCount người',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() => _participantCount++);
                              },
                              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Transport
                      _buildSectionTitle('transport_method'.tr()),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTransportChip('walking', 'walking'.tr(), Icons.directions_walk),
                          _buildTransportChip('bicycle', 'bike'.tr(), Icons.directions_bike),
                          _buildTransportChip('motorbike', 'motorbike'.tr(), Icons.two_wheeler),
                          _buildTransportChip('car', 'car'.tr(), Icons.directions_car),
                          _buildTransportChip('bus', 'public_transport'.tr(), Icons.directions_bus),
                          _buildTransportChip('train', 'public_transport'.tr(), Icons.train),
                          _buildTransportChip('plane', 'public_transport'.tr(), Icons.flight),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Budget
                      _buildSectionTitle('${'budget'.tr()} (${'vnd'.tr()})'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _budgetController,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: _buildInputDecoration('enter_amount'.tr()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),

                      // Visibility
                      _buildSectionTitle('visibility'.tr()),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildVisibilityChip('private', 'private'.tr(), Icons.lock),
                          _buildVisibilityChip('friends', 'friends'.tr(), Icons.people),
                          _buildVisibilityChip('public', 'public'.tr(), Icons.public),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Create Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleCreateTrip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : Text(
                                  'Tạo lịch trình',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppTheme.textGrey),
      filled: true,
      fillColor: AppTheme.surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textGrey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(date),
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String value, String label, IconData icon) {
    final isSelected = _tripType == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.black : AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _tripType = value;
          if (value == 'solo') {
            _participantCount = 1;
          } else if (_participantCount == 1) {
            _participantCount = 2;
          }
        });
      },
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: AppTheme.primaryColor,
      labelStyle: GoogleFonts.inter(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTransportChip(String value, String label, IconData icon) {
    final isSelected = _transport == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.black : AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() => _transport = value);
      },
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: AppTheme.primaryColor,
      labelStyle: GoogleFonts.inter(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildVisibilityChip(String value, String label, IconData icon) {
    final isSelected = _visibility == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.black : AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() => _visibility = value);
      },
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: AppTheme.primaryColor,
      labelStyle: GoogleFonts.inter(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      return intl.DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
    } catch (e) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  String _formatDateForApi(DateTime date) {
    try {
      return intl.DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  void _handleCreateTrip() {
    if (_formKey.currentState!.validate()) {
      final tripData = {
        'trip_title': _titleController.text,
        'trip_description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
        'trip_start_date': _formatDateForApi(_startDate),
        'trip_end_date': _formatDateForApi(_endDate),
        'trip_budget': double.tryParse(_budgetController.text) ?? 0,
        'trip_transport': _transport,
        'trip_type': _tripType,
        'participant_count': _participantCount,
        'visibility': _visibility,
      };

      context.read<TripBloc>().add(CreateTripEvent(tripData));
    }
  }
}

