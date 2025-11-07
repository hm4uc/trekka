import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trekka/features/travel_preferences/presentation/bloc/travel_preferences_bloc.dart';
import 'package:trekka/features/travel_preferences/presentation/widgets/travel_styles_tab.dart';
import 'package:trekka/features/travel_preferences/presentation/widgets/budget_tab.dart';
import 'package:trekka/config/app_routes.dart';

class TravelPreferencesScreen extends StatefulWidget {
  const TravelPreferencesScreen({super.key});

  @override
  State<TravelPreferencesScreen> createState() => _TravelPreferencesScreenState();
}

class _TravelPreferencesScreenState extends State<TravelPreferencesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TravelPreferencesBloc(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's your travel style?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select all that apply to personalize your recommendations.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF4F6EF7),
                  ),
                  tabs: const [
                    Tab(text: 'Travel Styles'),
                    Tab(text: 'Budget'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    TravelStylesTab(),
                    BudgetTab(),
                  ],
                ),
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: BlocBuilder<TravelPreferencesBloc, TravelPreferencesState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.selectedStyles.isNotEmpty && state.selectedBudget != null
                            ? () {
                          // Convert budget level to actual budget value
                          final budgetLevel = state.budgetLevels[state.selectedBudget!];
                          final budgetValue = budgetLevel != null ? budgetLevel['max'].toDouble() : 0.0;

                          context.read<TravelPreferencesBloc>().add(
                            SaveTravelPreferences(
                              styles: state.selectedStyles,
                              budget: budgetValue,
                            ),
                          );
                          Navigator.pushReplacementNamed(context, AppRoutes.home);
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F6EF7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}