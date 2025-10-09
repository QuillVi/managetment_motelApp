import 'package:equatable/equatable.dart';

enum CreateServiceStatus { initial, loading, success, error }

class CreateServiceState extends Equatable {
  final CreateServiceStatus status;
  final Map<String, dynamic>? payload;
  final String? error;

  const CreateServiceState({
    this.status = CreateServiceStatus.initial,
    this.error,
    this.payload,
  });

  CreateServiceState copyWith({
    CreateServiceStatus? status,
    Map<String, dynamic>? payload,
    String? error,
  }) {
    return CreateServiceState(
      status: status ?? this.status,
      error: error ?? this.error,
      payload: payload ?? this.payload,
    );
  }

  @override
  List<Object?> get props => [status, error, payload];
}
