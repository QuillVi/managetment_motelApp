import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/service_model.dart';

enum ServiceStatus { initial, loading, success, failure }

class ServiceState extends Equatable {
  final ServiceStatus status;
  final List<ServiceModel>? data;
  final List<ServiceClosureModel>? dataClosureService;
  final String? error;

  const ServiceState({
    this.status = ServiceStatus.initial,
    this.data,
    this.dataClosureService,
    this.error,
  });

  ServiceState copyWith({
    ServiceStatus? status,
    List<ServiceModel>? data,
    List<ServiceClosureModel>? dataClosureService,
    String? error,
  }) {
    return ServiceState(
      status: status ?? this.status,
      data: data ?? this.data,
      dataClosureService: dataClosureService ?? this.dataClosureService,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, dataClosureService, error];
}
