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

  Future<void> loadDetailService(int idDichVu) async {
    emit(state.copyWith(status: ServiceStatus.loading));
    try {
      final detailService = await serviceHomeRepository.fetchDetailService(
        idDichVu,
      );
      emit(
        state.copyWith(
          status: ServiceStatus.success,
          detailService: detailService,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ServiceStatus.failure, error: e.toString()));
    }
  }

  // Hàm gọi API Cập nhật dịch vụ
  Future<void> updateService({required Map<String, dynamic> data}) async {
    // Bật trạng thái loading để UI hiện vòng quay hoặc vô hiệu hóa nút bấm
    emit(state.copyWith(status: ServiceStatus.loading));

    try {
      // Gọi Repository để bắn API
      await serviceHomeRepository.updateService(data);

      // Nếu thành công:
      //  Emit success luôn
      emit(state.copyWith(status: ServiceStatus.updateSuccess));
    } catch (e) {
      // Nếu lỗi: Emit failure kèm thông báo lỗi
      emit(state.copyWith(status: ServiceStatus.failure, error: e.toString()));
    }
  }

  // Thêm hàm xóa vào ServiceCubit
  Future<void> deleteService(int idDichVu) async {
    // 1. Bật trạng thái Loading
    emit(state.copyWith(status: ServiceStatus.loading));

    try {
      // 2. Gọi Repository
      await serviceHomeRepository.deleteService(idDichVu);

      // 3. Nếu thành công: Load lại danh sách dịch vụ mới nhất
      // (Để UI tự động mất đi dòng vừa xóa)
      await loadServices();

      // Hoặc nếu muốn hiện thông báo thành công riêng biệt, bạn có thể tạo thêm status deleteSuccess
      // emit(state.copyWith(status: ServiceStatus.success));
    } catch (e) {
      // 4. Nếu lỗi: Thông báo lỗi (ví dụ: đang có hóa đơn không xóa được)
      emit(state.copyWith(status: ServiceStatus.failure, error: e.toString()));
    }
  }
}

class ClosureServiceCubit extends Cubit<ServiceState> {
  final ServiceHomeRepository serviceHomeRepository;

  ClosureServiceCubit({required this.serviceHomeRepository})
    : super(const ServiceState());

  Future<void> loadClosureServices() async {
    emit(state.copyWith(status: ServiceStatus.loading));
    try {
      final dataClosureService =
          await serviceHomeRepository.fetchClosureServices();
      emit(
        state.copyWith(
          status: ServiceStatus.success,
          dataClosureService: dataClosureService,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ServiceStatus.failure, error: e.toString()));
    }
  }
}
