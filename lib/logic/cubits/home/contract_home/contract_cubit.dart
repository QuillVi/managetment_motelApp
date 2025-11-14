import 'package:flutter_bloc/flutter_bloc.dart';
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
}
