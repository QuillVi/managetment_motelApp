import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/room_model.dart';
import 'package:motelapp/data/models/tanent_model.dart';
import 'package:motelapp/data/repositories/room_repository/add_tanent_room_repository.dart';
import 'package:motelapp/data/repositories/room_repository/tanent_room_repository.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/tanent_room_state.dart';

class TanentRoomCubit extends Cubit<TanentRoomState> {
  final TanentRoomRepository tanentRoomRepository;
  final AddTanentRoomRepository addTanentRoomRepository;

  TanentRoomCubit({
    required this.tanentRoomRepository,
    required this.addTanentRoomRepository,
  }) : super(const TanentRoomState());

  Future<void> loadTanentRoom(int roomId) async {
    emit(state.copyWith(status: TanentRoomStatus.loading));
    try {
      final List<TenantModel> tanents = await tanentRoomRepository
          .fetchTenantsByRoom(roomId);

      emit(
        state.copyWith(
          status: TanentRoomStatus.loaded,
          tanent: tanents,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TanentRoomStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadNameRoomBuilding(int roomId) async {
    emit(state.copyWith(status: TanentRoomStatus.loading));
    try {
      final List<NameRoomBuildingModel> nameRoomBuilding =
          await tanentRoomRepository.fetchNameRoomBuilding(roomId);

      emit(
        state.copyWith(
          status: TanentRoomStatus.loaded,
          nameRoomBuilding: nameRoomBuilding,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TanentRoomStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadSelectRoomIDManager() async {
    // 1. Báo trạng thái đang tải
    emit(state.copyWith(status: TanentRoomStatus.loading));

    try {
      // 2. Gọi Repo lấy dữ liệu
      // Lưu ý: Đảm bảo hàm fetchListRoomByIDManager() đã được khai báo trong TanentRoomRepository
      final List<SelectRoomIDManagetModel> rooms =
          await addTanentRoomRepository.fetchListRoomByIDManager();

      // 3. Cập nhật State thành công
      emit(
        state.copyWith(
          status: TanentRoomStatus.loaded,
          selectRoomIDManaget: rooms, // Cập nhật list phòng vào state
          errorMessage: null,
        ),
      );
    } catch (e) {
      // 4. Báo lỗi
      emit(
        state.copyWith(
          status: TanentRoomStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
