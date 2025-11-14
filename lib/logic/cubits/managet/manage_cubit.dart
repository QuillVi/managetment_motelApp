import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/manage_repository/manage_repository.dart';
import 'package:motelapp/logic/cubits/managet/manage_state.dart';

class ManageCubit extends Cubit<ManageState> {
  final ManageRepository manageRepository;
  ManageCubit({required this.manageRepository}) : super(const ManageState());

  Future<void> fetchManage() async {
    emit(state.copyWith(status: ManageStatus.loading));
    try {
      final manage = await manageRepository.fetchManage();
      emit(state.copyWith(status: ManageStatus.loaded, manage: manage));
    } catch (e) {
      emit(state.copyWith(status: ManageStatus.error, error: e.toString()));
    }
  }
}
