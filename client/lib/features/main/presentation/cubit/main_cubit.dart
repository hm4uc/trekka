import 'package:flutter_bloc/flutter_bloc.dart';

class MainCubit extends Cubit<int> {
  MainCubit() : super(0); // Mặc định tab 0 (Trang chủ)

  void changeTab(int index) => emit(index);
}