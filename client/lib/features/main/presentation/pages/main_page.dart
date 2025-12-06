import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart'; // Import AuthBloc
import '../../../auth/presentation/bloc/auth_event.dart'; // Import AuthEvent
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../cubit/main_cubit.dart';
import '../widgets/trekka_bottom_bar.dart';

// Placeholder cho các trang chưa có
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.backgroundColor,
    body: Center(child: Text(title, style: const TextStyle(color: Colors.white))),
  );
}

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
    // 👇 GỌI API PROFILE NGAY KHI VÀO MÀN HÌNH CHÍNH
    // Việc này giúp dữ liệu User được cập nhật ngầm ngay lập tức
    // dù người dùng đang ở Tab Home.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(AuthGetProfileRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),      // Tab 0
      const PlaceholderPage("Khám phá"), // Tab 1
      const PlaceholderPage("Hành trình"), // Tab 2
      const PlaceholderPage("Yêu thích"), // Tab 3
      const ProfilePage(),   // Tab 4
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