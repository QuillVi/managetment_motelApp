import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/room_repository/detail_tanent_reposittory.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_tanent_state.dart';

class DetailTanentCubit extends Cubit<DetailTanentState> {
  final DetailTanentReposittory detailTanentReposittory;
  DetailTanentCubit({required this.detailTanentReposittory})
    : super((DetailTanentState()));

  Future<void> loadTanentDetail(int idNguoiDung) async {
    emit(state.copyWith(status: DetailTanentStatus.loading));
    try {
      final tanentDetail = await detailTanentReposittory.fetchDetailTanent(
        idNguoiDung,
      );
      emit(
        state.copyWith(
          status: DetailTanentStatus.loaded,
          detailTanent: tanentDetail,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DetailTanentStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
