import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/User_repository/bill_user_repository/bill_user_repository.dart';
import 'package:motelapp/logic/cubits/User_cubit/bill_user/bill_user_state.dart';

class BillUserCubit extends Cubit<BillUserState> {
  final BillUserRepository billUserRepository;

  BillUserCubit({required this.billUserRepository})
    : super(const BillUserState());

  // Hàm load danh sách hóa đơn cho User
  Future<void> loadListBillUser() async {
    // 1. Phát trạng thái đang tải
    emit(state.copyWith(status: BillUserStatus.loading));

    try {
      // 2. Gọi Repository để lấy dữ liệu
      final listBill = await billUserRepository.fetchListBillUser();

      // 3. Nếu thành công, phát trạng thái loaded kèm dữ liệu
      emit(
        state.copyWith(
          status: BillUserStatus.loaded,
          billUserList: listBill,
          errorMessage: null, // Xóa lỗi cũ nếu có
        ),
      );
    } catch (e) {
      // 4. Nếu lỗi, phát trạng thái error kèm thông báo
      emit(
        state.copyWith(
          status: BillUserStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadDetailBillUser(int idHoaDon) async {
    // Emit loading để UI hiển thị vòng xoay
    emit(state.copyWith(status: BillUserStatus.loading));

    try {
      // Gọi Repo lấy dữ liệu chi tiết
      final detailBill = await billUserRepository.fetchDetailBillUser(idHoaDon);

      emit(
        state.copyWith(
          status: BillUserStatus.loaded,
          detailBillUser: detailBill, // Cập nhật dữ liệu chi tiết vào State
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BillUserStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
