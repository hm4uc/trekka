import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../destinations/presentation/bloc/destination_bloc.dart';
import '../../../discovery/presentation/pages/explore_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../trips/presentation/pages/favorites_page_wrapper.dart';
import '../../../trips/presentation/pages/journey_page.dart';
import '../cubit/main_cubit.dart';
import '../widgets/trekka_bottom_bar.dart';


class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MainCubit(),
      child: const MainView(),
    );
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  bool _isBottomBarVisible = true;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for bottom bar
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Fetch user profile when entering main screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(AuthGetProfileRequested());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final scrollPosition = notification.metrics.pixels;
      final scrollDelta = notification.scrollDelta ?? 0;

      // Always show bottom bar when near the top (increased threshold to handle bounce)
      if (scrollPosition < 100) {
        if (!_isBottomBarVisible) {
          setState(() {
            _isBottomBarVisible = true;
          });
          _animationController.reverse();
        }
        return;
      }

      // Only hide/show when there's significant scroll movement
      if (scrollDelta.abs() > 2) {
        // User is scrolling down (hiding bottom bar)
        if (scrollDelta > 0) {
          if (_isBottomBarVisible) {
            setState(() {
              _isBottomBarVisible = false;
            });
            _animationController.forward();
          }
        }
        // User is scrolling up (showing bottom bar)
        else if (scrollDelta < 0) {
          if (!_isBottomBarVisible) {
            setState(() {
              _isBottomBarVisible = true;
            });
            _animationController.reverse();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap destination-dependent pages with BlocProvider
    final List<Widget> pages = [
      const HomePage(), // Tab 0
      BlocProvider(
        create: (_) => sl<DestinationBloc>(),
        child: const ExplorePage(),
      ), // Tab 1
      const JourneyPage(), // Tab 2
      BlocProvider(
        create: (_) => sl<DestinationBloc>(),
        child: const FavoritesPageWrapper(),
      ), // Tab 3
      const ProfilePage(), // Tab 4
    ];

    return BlocBuilder<MainCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          extendBody: true,
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _onScrollNotification(notification);
              return false;
            },
            child: IndexedStack(
              index: currentIndex,
              children: pages,
            ),
          ),
          bottomNavigationBar: SlideTransition(
            position: _offsetAnimation,
            child: TrekkaBottomBar(
              currentIndex: currentIndex,
              onTap: (index) {
                context.read<MainCubit>().changeTab(index);
                // Show bottom bar when user taps
                if (!_isBottomBarVisible) {
                  setState(() {
                    _isBottomBarVisible = true;
                  });
                  _animationController.reverse();
                }
              },
            ),
          ),
        );
      },
    );
  }
}