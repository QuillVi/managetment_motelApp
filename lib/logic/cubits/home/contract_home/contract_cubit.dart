import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/contract_model.dart';
import 'package:motelapp/data/repositories/home_repository/contract_repository/contract_home_repository.dart';
import 'package:motelapp/logic/cubits/home/contract_home/contract_state.dart';

class ListContractCubit extends Cubit<ListContractState> {
  final ListContractRepository listContractRepository;
  ListContractCubit({required this.listContractRepository})
    : super(const ListContractState());

  Future<void> LoadListContract() async {
    emit(state.copyWith(status: ListContractIsActiveStatus.loading));
    try {
      final contractList = await listContractRepository.fetchListContract();
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.loaded,
          listContractModel: contractList,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> LoadDetailContract(int idHopDong) async {
    emit(state.copyWith(status: ListContractIsActiveStatus.loading));
    try {
      final detailContract = await listContractRepository.getDetailContract(
        idHopDong,
      );
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.loaded,
          detailContractModel: detailContract,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> LoadListUserContractSelected() async {
    emit(state.copyWith(status: ListContractIsActiveStatus.loading));
    try {
      final userList =
          await listContractRepository.fetchListUserContractSelected();
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.loaded,
          listUserContractSelected: userList,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Trong ListContractCubit
  Future<void> createContract(Map<String, dynamic> payload) async {
    try {
      // 1. Emit trạng thái đang tạo (để hiện Loading Dialog)
      emit(state.copyWith(status: ListContractIsActiveStatus.creating));

      // 2. Gọi API (Giả sử bạn có repository)
      final response = await listContractRepository.createContract(payload);

      // 3. Emit thành công
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.createSuccess,
          // Có thể cập nhật lại list nếu backend trả về list mới, hoặc giữ nguyên
        ),
      );

      // Mẹo: Sau khi success, bạn có thể gọi lại getListContract()
      // để làm mới dữ liệu nền nếu cần, nhưng cẩn thận logic UI.
    } catch (e) {
      // 4. Emit thất bại
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.createFailure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Trong file list_contract_cubit.dart

  Future<void> deleteContract(int idHopDong) async {
    // 1. Emit trạng thái đang xóa
    emit(state.copyWith(status: ListContractIsActiveStatus.deleting));

    try {
      // 2. Gọi API xóa
      await listContractRepository.deleteContract(idHopDong);

      // --- PHẦN QUAN TRỌNG MỚI THÊM VÀO ---
      // 3. Xóa nóng ngay lập tức trong danh sách hiện tại của App (không cần chờ load lại API)
      List<ListContractModel> currentList = List.from(
        state.listContractModel ?? [],
      );

      // Lọc bỏ hợp đồng vừa xóa ra khỏi danh sách
      currentList.removeWhere((contract) => contract.id_hopdong == idHopDong);

      // ------------------------------------

      // 4. Emit trạng thái thành công KÈM THEO DANH SÁCH ĐÃ ĐƯỢC CẬP NHẬT
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.deleteSuccess,
          listContractModel: currentList, // <--- Cập nhật danh sách mới vào đây
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.deleteFailure,
          errorMessage: e.toString().replaceAll("Exception: ", ""),
        ),
      );
    }
  }

  Future<void> liquidateContract(int idHopDong) async {
    // 1. Emit loading
    emit(state.copyWith(status: ListContractIsActiveStatus.liquidating));

    try {
      // 2. Gọi API
      await listContractRepository.liquidateContract(idHopDong);

      // 3. Cập nhật Local State (Sửa trạng thái trong danh sách)

      // Lấy danh sách hiện tại ra (đây là List<ListContractModel>)
      List<ListContractModel> currentList = List.from(
        state.listContractModel ?? [],
      );

      final updatedList =
          currentList.map((contract) {
            // Tìm đúng hợp đồng đang thanh lý
            if (contract.id_hopdong == idHopDong) {
              // Sử dụng copyWith của ListContractModel để đổi trạng thái
              return contract.copyWith(trang_thai: 'DaThanhLy');
            }
            return contract;
          }).toList();

      // 4. Emit thành công với danh sách mới
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.liquidateSuccess,
          listContractModel: updatedList, // UI danh sách sẽ tự cập nhật ngay
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.liquidateFailure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateContract(
    int idHopDong,
    Map<String, dynamic> payload,
  ) async {
    // 1. Emit trạng thái đang cập nhật (để hiện Loading Dialog)
    emit(state.copyWith(status: ListContractIsActiveStatus.updating));

    try {
      // 2. Gọi Repository
      await listContractRepository.updateContract(idHopDong, payload);

      // 3. Emit thành công
      // Lưu ý: Chúng ta emit success trước để UI đóng màn hình edit hoặc hiện thông báo
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.updateSuccess,
          errorMessage: null,
        ),
      );

      // 4. (Tùy chọn) Tải lại danh sách hợp đồng để dữ liệu ngoài màn hình chính được làm mới
      // Gọi lại hàm load danh sách có sẵn
      await LoadListContract();
    } catch (e) {
      // 5. Emit thất bại
      emit(
        state.copyWith(
          status: ListContractIsActiveStatus.updateFailure,
          errorMessage: e.toString().replaceAll("Exception: ", ""),
        ),
      );
    }
  }
}
