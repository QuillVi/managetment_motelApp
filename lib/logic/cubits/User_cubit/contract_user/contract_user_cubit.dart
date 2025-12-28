import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/User_repository/contract_user_repository/contract_user_repository.dart';

import 'package:motelapp/logic/cubits/User_cubit/contract_user/contract_user_state.dart';

class ContractUserCubit extends Cubit<ContractUserState> {
  final DetailContractUserRepository contractUserRepository;

  ContractUserCubit({required this.contractUserRepository})
    : super(const ContractUserState());

  /// Hàm lấy chi tiết hợp đồng của User đang đăng nhập
  Future<void> loadDetailContractUser() async {
    // 1. Phát trạng thái đang tải
    emit(state.copyWith(status: ContractUserStatus.loading));

    try {
      // 2. Gọi Repository
      // Lưu ý: Không cần truyền ID vì server tự lấy từ Token
      final result = await contractUserRepository.fetchDetailContractUser();

      // 3. Nếu thành công, cập nhật data vào State
      emit(
        state.copyWith(
          status: ContractUserStatus.loaded,
          detailContractUser: result,
          errorMessage: null, // Xóa lỗi cũ
        ),
      );
    } catch (e) {
      // 4. Xử lý lỗi
      emit(
        state.copyWith(
          status: ContractUserStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
