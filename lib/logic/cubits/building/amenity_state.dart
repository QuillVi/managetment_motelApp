import 'package:equatable/equatable.dart';

enum AmenityStatus { initial, loading, success, failure }

class AmenityState extends Equatable {
  final AmenityStatus status;
  final List<String> amenities;

  final String? error;

  const AmenityState({
    this.status = AmenityStatus.initial,
    this.amenities = const [],
    this.error,
  });

  AmenityState copyWith({
    AmenityStatus? status,
    List<String>? amenities,
    String? error,
  }) {
    return AmenityState(
      status: status ?? this.status,
      amenities: amenities ?? this.amenities,
      error: error, // Khi gọi copyWith mà không truyền error, nó sẽ xóa lỗi cũ
    );
  }

  @override
  List<Object?> get props => [status, amenities, error];
}
