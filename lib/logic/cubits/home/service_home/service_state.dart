import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/service_model.dart';

enum ServiceStatus { initial, loading, success, failure, updateSuccess }

class ServiceState extends Equatable {
  final ServiceStatus status;
  final List<ServiceModel>? data;
  final List<ServiceClosureModel>? dataClosureService;
  final DetailServiceModel? detailService;
  final String? error;

  const ServiceState({
    this.status = ServiceStatus.initial,
    this.data,
    this.dataClosureService,
    this.detailService,
    this.error,
  });

  ServiceState copyWith({
    ServiceStatus? status,
    List<ServiceModel>? data,
    List<ServiceClosureModel>? dataClosureService,
    DetailServiceModel? detailService,
    String? error,
  }) {
    return ServiceState(
      status: status ?? this.status,
      data: data ?? this.data,
      dataClosureService: dataClosureService ?? this.dataClosureService,
      detailService: detailService ?? this.detailService,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    data,
    dataClosureService,
    detailService,
    error,
  ];
}
