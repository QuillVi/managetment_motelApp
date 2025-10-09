import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/service_model.dart';

enum ServiceStatus { initial, loading, success, failure }

class ServiceState extends Equatable {
  final ServiceStatus status;
  final List<ServiceModel>? data;
  final String? error;

  const ServiceState({
    this.status = ServiceStatus.initial,
    this.data,
    this.error,
  });

  ServiceState copyWith({
    ServiceStatus? status,
    List<ServiceModel>? data,
    String? error,
  }) {
    return ServiceState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
