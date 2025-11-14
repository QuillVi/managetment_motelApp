import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/core/utils/exceptions.dart';
import 'package:motelapp/data/repositories/home_repository/statistical_home_repo.dart';
import 'statistical_state.dart';

class StatisticalCubit extends Cubit<StatisticalState> {
  final StatisticalHomeRepository statisticalHomeRepository;

  StatisticalCubit({required this.statisticalHomeRepository})
    : super(const StatisticalState());

  Future<void> loadStatistics() async {
    // Chỉ thực hiện load nếu không phải đang trong trạng thái loading
    if (state.status == StatisticalStatus.loading) return;

    emit(
      state.copyWith(status: StatisticalStatus.loading, error: null),
    ); // Reset error

    try {
      final data = await statisticalHomeRepository.fetchStatistics();
      print("Fetched data: $data");

      emit(
        state.copyWith(
          status: StatisticalStatus.loaded,
          data: data,
          error: null,
        ),
      );
    }
    // !!! Bắt SessionExpiredException. Logic gọi AuthCubit đã nằm trong Repository/Interceptor.
    on SessionExpiredException catch (_) {
      print(' Lỗi hết phiên được bắt trong StatisticalCubit.');

      // Emit lỗi để UI có thể hiển thị thông báo ngắn gọn
      // trước khi AppWidget tự động chuyển hướng.
      emit(
        state.copyWith(
          status: StatisticalStatus.error,
          error: 'Phiên đăng nhập đã hết hạn.',
        ),
      );
      // KHÔNG CẦN 'return' vì đã bị ngắt bởi Exception.
    } catch (e) {
      // Bắt tất cả các lỗi khác (lỗi mạng, lỗi server 500, lỗi parsing,...)
      final err = e.toString();
      emit(state.copyWith(status: StatisticalStatus.error, error: err));
    }
  }
}
