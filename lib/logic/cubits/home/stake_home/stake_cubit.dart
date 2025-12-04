import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/stake_repository/stake_repository.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_state.dart';

// --- Cubit Thống kê (Header Dashboard) ---
class StakeCubit extends Cubit<StakeState> {
  final StakeRepository stakeRepository;

  StakeCubit({required this.stakeRepository}) : super(const StakeState());

  Future<void> loadStake() async {
    if (state.status == StakeStatus.loading) return;

    // Reset trạng thái
    emit(const StakeState(status: StakeStatus.loading));

    try {
      final dataStake = await stakeRepository.fetchStake();
      emit(state.copyWith(status: StakeStatus.loaded, dataStake: dataStake));
    } catch (e) {
      emit(state.copyWith(status: StakeStatus.error, error: e.toString()));
    }
  }
}

// --- Cubit Nội dung & Chi tiết & Hủy & Tạo ---
class ContentStakeCubit extends Cubit<StakeState> {
  final StakeRepository stakeRepository;

  ContentStakeCubit({required this.stakeRepository})
    : super(const StakeState());

  // ==========================================================
  // 1. Load Danh Sách Cọc (Cho màn hình StakeHome)
  // ==========================================================
  // Future<void> loadContentStake() async {
  //   // RESET TRẠNG THÁI:
  //   // Dùng Constructor để ép message và error về null
  //   emit(
  //     StakeState(
  //       status: StakeStatus.loading,
  //       dataContentStake:
  //           state.dataContentStake, // Giữ lại data cũ để UI không bị nháy trắng
  //       detailStake: null, // Clear detail cũ
  //       message: null, // QUAN TRỌNG: Xóa sạch thông báo cũ
  //       error: null,
  //     ),
  //   );

  //   try {
  //     // Gọi API lấy danh sách (không cần tham số)
  //     final dataContentStake = await stakeRepository.fetchContentStakeCard();

  //     // Emit trạng thái Loaded với dữ liệu mới
  //     emit(
  //       StakeState(
  //         status: StakeStatus.loaded,
  //         dataContentStake: dataContentStake,
  //         detailStake: null,
  //         message: null,
  //         error: null,
  //       ),
  //     );
  //   } catch (e) {
  //     emit(state.copyWith(status: StakeStatus.error, error: e.toString()));
  //   }
  // }

  Future<void> loadContentStake() async {
    print("🟡 [CUBIT] 1. Bắt đầu hàm loadContentStake");

    // Emit Loading
    emit(state.copyWith(status: StakeStatus.loading));

    try {
      print("🟡 [CUBIT] 2. Đang gọi Repository...");

      // Gọi Repo
      final data = await stakeRepository.fetchContentStakeCard();

      print(
        "🟢 [CUBIT] 3. Repo trả về ${data.length} phần tử. Đang emit Loaded.",
      );

      emit(state.copyWith(status: StakeStatus.loaded, dataContentStake: data));
    } catch (e) {
      print("🔴 [CUBIT] LỖI: $e");
      emit(state.copyWith(status: StakeStatus.error, error: e.toString()));
    }
  }

  // ==========================================================
  // 2. Load Chi Tiết Cọc (Cho màn hình DetailStake)
  // ==========================================================
  Future<void> loadDetailStake(int idCoc) async {
    // RESET TRẠNG THÁI
    emit(
      StakeState(
        status: StakeStatus.loading,
        dataContentStake: state.dataContentStake, // Giữ list ở background
        detailStake: null,
        message: null, // Xóa message cũ
        error: null,
      ),
    );

    try {
      final detailData = await stakeRepository.fetchDetailStake(idCoc);

      emit(
        state.copyWith(
          status: StakeStatus.loaded,
          detailStake: detailData,
          // message và error tự động null vì copyWith không truyền vào (và state ở trên đã null)
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: StakeStatus.error, error: e.toString()));
    }
  }

  // ==========================================================
  // 3. Hủy Cọc (Hủy xong -> Tự động load lại danh sách)
  // ==========================================================
  Future<void> cancelStake(int idCoc) async {
    // 1. Emit Loading
    emit(
      StakeState(
        status: StakeStatus.loading,
        dataContentStake: state.dataContentStake,
        detailStake: state.detailStake,
        message: null, // Reset message để chuẩn bị đón message mới
        error: null,
      ),
    );

    try {
      // 2. Gọi API Hủy cọc
      final successMessage = await stakeRepository.cancelStake(idCoc);

      // 3. Gọi API lấy lại DANH SÁCH mới ngay lập tức
      // Để đảm bảo dữ liệu trong App đồng bộ với Server
      final updatedList = await stakeRepository.fetchContentStakeCard();

      // 4. Emit Loaded + Message Thành công + Danh sách mới
      emit(
        StakeState(
          status: StakeStatus.loaded,

          // Cập nhật danh sách mới vào State
          dataContentStake: updatedList,

          // Giữ nguyên detail (để UI không bị lỗi khi chưa kịp pop)
          detailStake: state.detailStake,

          // Message này sẽ kích hoạt SnackBar & Navigator.pop bên UI
          message: successMessage,

          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: StakeStatus.error, error: e.toString()));
    }
  }

  // ==========================================================
  // 4. Tạo Cọc Mới
  // ==========================================================
  Future<void> createStake(Map<String, dynamic> payload) async {
    // Emit Loading
    emit(
      StakeState(
        status: StakeStatus.loading,
        dataContentStake: state.dataContentStake, // Giữ list cũ
        detailStake: state.detailStake,
        message: null,
        error: null,
      ),
    );

    try {
      final successMessage = await stakeRepository.createStake(payload);

      // (Tùy chọn) Load lại danh sách cọc mới nhất để màn hình List cập nhật luôn
      final updatedList = await stakeRepository.fetchContentStakeCard();

      emit(
        StakeState(
          status: StakeStatus.loaded,
          dataContentStake: updatedList, // Cập nhật list mới
          detailStake: state.detailStake,
          message: successMessage, // Báo thành công
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: StakeStatus.error, error: e.toString()));
    }
  }

  // ==========================================================
  // 5. Load Danh Sách Phòng Chọn Cọc (Mới thêm)
  // ==========================================================
  Future<void> loadSelectRoomStake() async {
    // Reset state selectRoomStake về null hoặc giữ loading
    emit(
      StakeState(
        status: StakeStatus.loading,
        dataContentStake: state.dataContentStake,
        // selectRoomStake: null, // Mặc định null trong constructor
        message: null,
        error: null,
      ),
    );

    try {
      final data = await stakeRepository.fetchRoomsByDepositStatus();
      emit(state.copyWith(status: StakeStatus.loaded, selectRoomStake: data));
    } catch (e) {
      emit(state.copyWith(status: StakeStatus.error, error: e.toString()));
    }
  }

  // --- GỌI API UPDATE ---
  Future<void> updateStake(int idCoc, Map<String, dynamic> payload) async {
    // 1. Emit trạng thái Loading (để hiện vòng xoay xoay)
    emit(
      state.copyWith(status: StakeStatus.loading, error: null, message: null),
    );

    try {
      // 2. Gọi Repo
      final isSuccess = await stakeRepository.updateStake(idCoc, payload);

      if (isSuccess) {
        // 3. Nếu thành công -> Emit Loaded + Message
        emit(
          state.copyWith(
            status: StakeStatus.updateSuccess,
            message: "Cập nhật cọc thành công!",
          ),
        );
      }
    } catch (e) {
      // 4. Nếu lỗi -> Emit Error
      emit(state.copyWith(status: StakeStatus.error, error: e.toString()));
    }
  }

  // --- XÓA CỌC ---
  Future<void> deleteStake(int idCoc) async {
    // 1. Emit trạng thái Loading (để UI hiện vòng xoay hoặc disable nút)
    emit(state.copyWith(status: StakeStatus.loading));

    try {
      // 2. Gọi Repo xóa
      final isSuccess = await stakeRepository.deleteStake(idCoc);

      if (isSuccess) {
        // 3. Nếu thành công -> Emit Loaded + Message đặc biệt
        // Lưu ý: Không gọi loadDetail lại vì dữ liệu đã mất
        emit(
          state.copyWith(
            status: StakeStatus.deleteSuccess,
            message: "DELETE_SUCCESS", // Cờ hiệu quan trọng
          ),
        );
      } else {
        // Trường hợp server trả về 200 nhưng success: false (ít gặp nếu backend chuẩn)
        emit(
          state.copyWith(
            status: StakeStatus.error,
            error: "Xóa thất bại. Vui lòng thử lại.",
          ),
        );
      }
    } catch (e) {
      // 4. Bắt lỗi (Server lỗi, mạng rớt...)
      // Bạn có thể format lỗi đẹp hơn tùy response từ server
      emit(
        state.copyWith(
          status: StakeStatus.error,
          error: "Đã xảy ra lỗi: ${e.toString()}",
        ),
      );
    }
  }
}
