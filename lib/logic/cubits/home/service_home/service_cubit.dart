import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/home_repository/service_repository/service_home_repository.dart';
import 'package:motelapp/logic/cubits/home/service_home/service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServiceHomeRepository serviceHomeRepository;

  ServiceCubit({required this.serviceHomeRepository})
    : super(const ServiceState());

  Future<void> loadServices() async {
    emit(state.copyWith(status: ServiceStatus.loading));
    try {
      final services = await serviceHomeRepository.fetchServices();
      emit(
        state.copyWith(
          status: ServiceStatus.success,
          data: services,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ServiceStatus.failure, error: e.toString()));
    }
  }
}
