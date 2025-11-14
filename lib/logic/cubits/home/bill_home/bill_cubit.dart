import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/bill_repository/bill_repository.dart';
import 'package:motelapp/logic/cubits/home/bill_home/bill_state.dart';

class BillCubit extends Cubit<BillState> {
  final BillRepository billRepository;
  BillCubit({required this.billRepository}) : super(const BillState());

  Future<void> LoadListBill() async {
    emit(state.copyWith(status: BillStatus.loading));
    try {
      final listBill = await billRepository.fetchListBill();
      emit(
        state.copyWith(
          status: BillStatus.loaded,
          billModel: listBill,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: BillStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> LoadDetailBill(int idHoaDon) async {
    emit(state.copyWith(status: BillStatus.loading));
    try {
      final detailBill = await billRepository.fetchDetailBill(idHoaDon);
      emit(
        state.copyWith(
          status: BillStatus.loaded,
          detailBillModel: detailBill,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: BillStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> updateBillData(Map<String, dynamic> billDetails) async {
    // Không cần emit loading/loaded cho hành động này, chỉ cần ném lỗi nếu thất bại.
    try {
      // 1. Gọi Repository để thực hiện cập nhật
      await billRepository.updateBill(billDetails);

      // 2. Lấy id_hoadon để tải lại chi tiết
      final int? idHoaDon = billDetails['id_hoadon'];

      if (idHoaDon != null) {
        // 3. Nếu thành công, tải lại chi tiết hóa đơn để cập nhật UI
        await LoadDetailBill(idHoaDon);
      }
    } catch (e) {
      // 4. Nếu thất bại, ném lỗi ra để UI xử lý (thường là hiển thị SnackBar)
      throw Exception(e.toString());
    }
  }

  // ...
  Future<void> processPayment(int idHoaDon, String phuongThuc) async {
    // <-- THÊM tham số
    try {
      // 1. Gọi Repository với 2 tham số
      await billRepository.updateBillStatusToPaid(
        idHoaDon,
        phuongThuc,
      ); // <-- SỬA ở đây

      // 2. Tải lại dữ liệu chi tiết
      await LoadDetailBill(idHoaDon);
    } catch (e) {
      // 3. Ném lỗi ra để UI (SnackBar) bắt
      throw Exception(e.toString());
    }
  }

  /// Hoàn tác hóa đơn về 'Chưa tạo hợp đồng'
  Future<void> revertPayment(int idHoaDon) async {
    try {
      // 1. Gọi Repository để hoàn tác trạng thái
      await billRepository.revertBillStatus(idHoaDon);

      // 2. Nếu hoàn tác thành công, tải lại dữ liệu chi tiết
      // Thao tác này sẽ tự động cập nhật UI
      await LoadDetailBill(idHoaDon);
    } catch (e) {
      // 3. Nếu thất bại, ném lỗi ra để UI (SnackBar) bắt
      throw Exception(e.toString());
    }
  }
}
