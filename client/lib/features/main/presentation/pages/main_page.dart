import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../destinations/presentation/bloc/destination_bloc.dart';
import '../../../discovery/presentation/pages/explore_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../trips/presentation/pages/favorites_page.dart';
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

class _MainViewState extends State<MainView> {

  @override
  void initState() {
    super.initState();
    // Fetch user profile when entering main screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(AuthGetProfileRequested());
    });
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
        child: const FavoritesPage(),
      ), // Tab 3
      const ProfilePage(), // Tab 4
    ];

    return BlocBuilder<MainCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          extendBody: true, // Cho nội dung tràn xuống dưới bottom bar
          body: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
          bottomNavigationBar: TrekkaBottomBar(
            currentIndex: currentIndex,
            onTap: (index) {
              context.read<MainCubit>().changeTab(index);
            },
          ),
        );
      },
    );
  }
}