import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/home_repository/service_repository/create_service_repository.dart';
import 'package:motelapp/logic/cubits/home/service_home/create_service_state.dart';

class CreateServiceCubit extends Cubit<CreateServiceState> {
  final CreateServiceRepository createServiceRepository;

  CreateServiceCubit({required this.createServiceRepository})
    : super(const CreateServiceState());

  Future<void> createService(Map<String, dynamic> payload) async {
    emit(state.copyWith(status: CreateServiceStatus.loading));

    try {
      final response = await createServiceRepository.createService(payload);
      emit(
        state.copyWith(
          status: CreateServiceStatus.success,
          payload: response,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CreateServiceStatus.error, error: e.toString()),
      );
    }
  }
}
