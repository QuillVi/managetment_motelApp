import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/building_repository/create_building_repository.dart';
import 'package:motelapp/logic/cubits/building/create_building_state.dart';

class CreateBuildingCubit extends Cubit<CreateBuildingState> {
  final CreateBuildingRepository createBuildingRepository;

  CreateBuildingCubit({required this.createBuildingRepository})
    : super(const CreateBuildingState());

  Future<void> createBuilding(Map<String, dynamic> payload) async {
    emit(state.copyWith(status: CreateBuildingStatus.loading));

    try {
      final response = await createBuildingRepository.createBuilding(payload);
      emit(
        state.copyWith(
          status: CreateBuildingStatus.success,
          payload: response,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CreateBuildingStatus.error, error: e.toString()),
      );
    }
  }
}
