import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/core/utils/thousands_formatter.dart';
import 'package:motelapp/data/models/bill_model.dart';
import 'package:motelapp/data/models/service_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/bill_home/bill_cubit.dart';
import 'package:motelapp/logic/cubits/home/bill_home/bill_state.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/bill_home.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/make_bill/select_room_bill.dart';
import 'package:motelapp/router/app_router.dart';

class UpdateBill extends StatefulWidget {
  final int idHoaDon;
  final int idNguoiThue;
  const UpdateBill({
    super.key,
    required this.idHoaDon,
    required this.idNguoiThue,
  });

  @override
  State<UpdateBill> createState() => _UpdateBillState();
}

class _UpdateBillState extends State<UpdateBill> {
  final Map<String, double> _calculatedServicePrices = {};
  int? _selectedRoomId;
  int? _selectedContractId;
  String _selectedRoomName = 'Chọn phòng';
  bool _isRoomSelected = false;
  String selectedMonthYear =
      '${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}';
  DateTime? _paymentDate;
  DateTime? _dueDate;

  List<ServiceModel> _selectedRoomServices = [];
  List<TextEditingController> _serviceControllers = [];

  final _formatter = NumberFormat.decimalPattern('vi_VN');

  final Map<String, int> _serviceOldIndices = {};
  final Map<String, int?> _serviceNewIndices = {};

  final _roomPriceController = TextEditingController();
  final _depositController = TextEditingController(); // Cọc hợp đồng
  final _bookingFeeController = TextEditingController(); // Cọc giữ chỗ
  final _extraFeeController = TextEditingController(); // Khách trả thêm/phạt
  final _noteController = TextEditingController();

  double _totalRoomPrice = 0;
  double _totalServicePrice = 0;
  double _totalDeposit = 0;
  double _totalBookingFee = 0;
  double _totalExtraFee = 0;
  double _finalPayment = 0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Thêm listener cho tất cả các controller
    _roomPriceController.addListener(_calculateTotals);
    _depositController.addListener(_calculateTotals);
    _bookingFeeController.addListener(_calculateTotals);
    _extraFeeController.addListener(_calculateTotals);

    // Bạn cũng cần thêm listener cho các dịch vụ cố định (nếu có)
    for (var controller in _serviceControllers) {
      controller.addListener(_calculateTotals);
    }

    //gọi cubit hiển thị thông tin chi tiết
    context.read<BillCubit>().loadInvoiceDetail(widget.idHoaDon);
  }

  @override
  void dispose() {
    // Đừng quên gỡ bỏ listener khi widget bị hủy
    _roomPriceController.removeListener(_calculateTotals);
    _depositController.removeListener(_calculateTotals);
    _bookingFeeController.removeListener(_calculateTotals);
    _extraFeeController.removeListener(_calculateTotals);

    for (var controller in _serviceControllers) {
      controller.removeListener(_calculateTotals);
    }

    // Hủy các controller
    _roomPriceController.dispose();
    _depositController.dispose();
    _bookingFeeController.dispose();
    _extraFeeController.dispose();

    super.dispose();
  }

  // Hàm cập nhật tiền
  void _updateCalculatedPrice(String serviceName, double price) {
    // KHẮC PHỤC LỖI: Bọc trong addPostFrameCallback
    // Ý nghĩa: "Đợi vẽ xong giao diện hiện tại rồi hãy chạy đoạn code này"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Kiểm tra xem màn hình còn hiển thị không để tránh lỗi
        setState(() {
          _calculatedServicePrices[serviceName] = price;

          // Gọi hàm tính tổng (vì hàm này cũng có setState bên trong nên cần nằm trong đây)
          _calculateTotals();
        });

        // In ra để kiểm tra
        print("Updated prices: $_calculatedServicePrices");
      }
    });
  }

  double _parsePrice(String text) {
    return double.tryParse(text.replaceAll('.', '')) ?? 0;
  }

  void _calculateTotals() {
    // 1. Lấy giá trị từ các TextField
    double roomPrice = _parsePrice(_roomPriceController.text);
    double deposit = _parsePrice(_depositController.text);
    double bookingFee = _parsePrice(_bookingFeeController.text);
    double extraFee = _parsePrice(_extraFeeController.text);

    // 2. Tính tổng tiền dịch vụ (bao gồm cả CỐ ĐỊNH và TÍNH TOÁN)
    double calculatedServices = _calculatedServicePrices.values.fold(
      0,
      (a, b) => a + b,
    );
    double fixedServices = 0;
    for (var controller in _serviceControllers) {}

    double totalCalculatedServices = _calculatedServicePrices.values.fold(
      0,
      (sum, price) => sum + price,
    );

    double totalFixedServices = 0;
    for (var entry in _selectedRoomServices.asMap().entries) {
      String serviceName = entry.value.tenDichVu.toLowerCase();
      if (serviceName != "điện") {
        // Đây là dịch vụ cố định
        totalFixedServices += _parsePrice(_serviceControllers[entry.key].text);
      }
    }

    double totalService = totalCalculatedServices + totalFixedServices;

    // 3. Tính toán tổng cuối cùng
    // Tổng = Tiền phòng + Dịch vụ + Phạt
    double total = roomPrice + totalService + extraFee;
    // Thanh toán = Tổng
    double finalPayment = total;

    // 4. Cập nhật State để UI build lại
    setState(() {
      _totalRoomPrice = roomPrice;
      _totalServicePrice = totalService;
      _totalDeposit = deposit;
      _totalBookingFee = bookingFee;
      _totalExtraFee = extraFee;
      _finalPayment = finalPayment;
    });
  }

  void _showDatePicker({
    required DateTime? initialDate,
    required Function(DateTime) onDateSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Chọn ngày', style: TextStyle(fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Xong',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate ?? DateTime.now(),
                  maximumDate: DateTime(2100),
                  minimumYear: 2000,
                  onDateTimeChanged: onDateSelected,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMonthYearPicker() {
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    final monthController = FixedExtentScrollController(
      initialItem: currentMonth - 1,
    );
    final yearList = List.generate(10, (index) => 2020 + index);
    final yearController = FixedExtentScrollController(initialItem: 4);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chọn thời gian',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        final selected =
                            '${(monthController.selectedItem + 1).toString().padLeft(2, '0')}-${yearList[yearController.selectedItem]}';
                        Navigator.pop(context);
                        setState(() {
                          selectedMonthYear = selected;
                        });
                      },
                      child: const Text(
                        'Chọn',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: monthController,
                        itemExtent: 40,
                        children: List.generate(
                          12,
                          (index) => Center(child: Text('Tháng ${index + 1}')),
                        ),
                        onSelectedItemChanged: (_) {},
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: yearController,
                        itemExtent: 40,
                        children:
                            yearList
                                .map((y) => Center(child: Text('$y')))
                                .toList(),
                        onSelectedItemChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onUpdateBill() async {
    final billCubit = context.read<BillCubit>();
    setState(() => _isLoading = true);

    try {
      // 1. LẤY CHỈ SỐ ĐIỆN MỚI TỪ MAP
      // Tìm dịch vụ nào có tên chứa chữ "điện" để lấy index
      int? chiSoDienMoi;
      _serviceNewIndices.forEach((key, value) {
        if (key.toLowerCase().contains('điện')) {
          chiSoDienMoi = value;
        }
      });

      // 2. CHUẨN BỊ PAYLOAD (GÓI TIN JSON)
      final Map<String, dynamic> updateData = {
        'id_hoadon': widget.idHoaDon,

        // Cập nhật thông tin chung
        'ngay_thanh_toan': _formatDateForServer(_paymentDate), // Có thể null
        'han_thanh_toan': _formatDateForServer(_dueDate),
        'ghi_chu_hoa_don': _noteController.text,

        // Cập nhật tiền (Quan trọng: Lấy số tiền đã tính toán lại ở Client)
        'tien_phong': _totalRoomPrice,
        'tong_tien_dich_vu': _totalServicePrice,
        'tong_hop_tien': _finalPayment, // Tổng thanh toán cuối cùng
        // Cập nhật Chỉ số điện (Quan trọng để tính tháng sau)
        // Nếu không sửa gì thì gửi null, server sẽ giữ nguyên
        'chi_so_dien_moi': chiSoDienMoi,
      };

      print("\n===================================================");
      print("🚀 [CLIENT UPDATE] Dữ liệu CHUẨN BỊ gửi đi (FULL):");
      print("   📦 ID Hóa đơn:      ${updateData['id_hoadon']}");
      print(
        "   📅 Ngày thanh toán: ${updateData['ngay_thanh_toan']} (Null nếu chưa trả)",
      );
      print("   ⏳ Hạn thanh toán:  ${updateData['han_thanh_toan']}");
      print("   📝 Ghi chú:         '${updateData['ghi_chu_hoa_don']}'");
      print(
        "   🏠 Tiền phòng:      ${_formatter.format(updateData['tien_phong'])}",
      );
      print(
        "   🛠 Tổng dịch vụ:    ${_formatter.format(updateData['tong_tien_dich_vu'])}",
      );
      print(
        "   💵 TỔNG CỘNG:       ${_formatter.format(updateData['tong_hop_tien'])}",
      );
      print(
        "   ⚡️ Chỉ số điện mới: ${updateData['chi_so_dien_moi']} (Null nếu không có điện)",
      );
      print("===================================================\n");

      // 4. GỌI API (Chúng ta sẽ viết hàm này ở bước sau)
      await billCubit.updateBill(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hóa đơn thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        getIt<AppRouter>().push(const BillHome());
      }
    } catch (e) {
      _showError('Lỗi cập nhật: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Hàm hiển thị lỗi
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Hàm định dạng ngày cho server
  String? _formatDateForServer(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date); // Định dạng YYYY-MM-DD
  }

  void _populateDataToUI(UpdateDetailBillModel billData) {
    // 1. Cập nhật thông tin thời gian
    // Giả sử server trả về YYYY-MM-DD, ta cắt lấy MM-YYYY để hiển thị
    if (billData.ngayThang.contains('-')) {
      var parts = billData.ngayThang.split('-');
      if (parts.length >= 2) {
        selectedMonthYear = '${parts[1]}-${parts[0]}';
      }
    }

    // Parse ngày thanh toán và hạn (Kiểm tra null kỹ lưỡng)
    if (billData.hanThanhToan != null && billData.hanThanhToan!.isNotEmpty) {
      _dueDate = DateTime.tryParse(billData.hanThanhToan!);
    }
    if (billData.ngayThanhToan != null && billData.ngayThanhToan!.isNotEmpty) {
      _paymentDate = DateTime.tryParse(billData.ngayThanhToan!);
    } else {
      // NẾU NULL -> GÁN MẶC ĐỊNH LÀ HÔM NAY (Để khớp với UI đang hiển thị)
      _paymentDate = DateTime.now();
    }

    // Điền ghi chú
    _noteController.text = billData.ghiChu ?? '';

    // 2. Cập nhật thông tin phòng
    _selectedRoomId = billData.phong.idPhong;
    _selectedRoomName = billData.phong.tenPhong;
    // _selectedRoomName = billData.phong.tenPhong; // Mở comment nếu model có tên phòng
    _roomPriceController.text = _formatter.format(billData.phong.giaPhong);

    // Đánh dấu là đã chọn phòng để UI hiển thị màu đen thay vì xám
    _isRoomSelected = true;

    // 3. XỬ LÝ DANH SÁCH DỊCH VỤ

    // Bước quan trọng: Clear sạch dữ liệu cũ để tránh trùng lặp
    for (var controller in _serviceControllers) {
      controller.dispose();
    }
    _serviceControllers.clear();
    _selectedRoomServices.clear();
    _calculatedServicePrices.clear();
    _serviceOldIndices.clear(); // Clear map mới
    _serviceNewIndices.clear(); // Clear map mới

    for (var invoiceService in billData.listDichVu) {
      final serviceModel = ServiceModel(
        idDichVu: invoiceService.idDichVu,
        tenDichVu: invoiceService.tenDichVu,
        icon: invoiceService.icon ?? "N/N",
        phiDichVu: invoiceService.giaDichVu,
      );
      _selectedRoomServices.add(serviceModel);

      String serviceName = invoiceService.tenDichVu.toLowerCase();

      if (serviceName.contains('điện')) {
        _serviceControllers.add(TextEditingController()); // Placeholder

        // 1. LƯU GIÁ TRỊ TÍNH TOÁN BAN ĐẦU (ĐỂ TỔNG KHÔNG BỊ SAI KHI MỚI LOAD)
        _calculatedServicePrices[invoiceService.tenDichVu] =
            invoiceService.giaDichVu;

        // 2. LƯU CHỈ SỐ CŨ VÀ MỚI VÀO MAP ĐỂ TRUYỀN CHO UI
        _serviceOldIndices[invoiceService.tenDichVu] =
            invoiceService.chiSoCu ?? 0;
        _serviceNewIndices[invoiceService.tenDichVu] = invoiceService.chiSoMoi;
      } else {
        // Dịch vụ cố định
        _serviceControllers.add(
          TextEditingController(
            text: _formatter.format(invoiceService.giaDichVu),
          ),
        );
      }
    }

    // C. Gán listener cho các controller mới tạo để khi sửa tiền thì tổng tự nhảy
    for (var controller in _serviceControllers) {
      controller.addListener(_calculateTotals);
    }

    // 4. Refresh UI và Tính tổng tiền lại
    setState(() {});
    _calculateTotals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Cập nhật hoá đơn',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // BỌC BODY BẰNG BLOCCONSUMER
      body: BlocConsumer<BillCubit, BillState>(
        listener: (context, state) {
          if (state.status == BillStatus.loading) {
            setState(() => _isLoading = true);
          } else if (state.status == BillStatus.loaded &&
              state.updateDetailBillModel != null) {
            setState(() => _isLoading = false);
            // KHI CÓ DỮ LIỆU -> GỌI HÀM ĐỔ DỮ LIỆU RA UI
            _populateDataToUI(state.updateDetailBillModel!);
          } else if (state.status == BillStatus.error) {
            setState(() => _isLoading = false);
            _showError(state.errorMessage ?? 'Có lỗi xảy ra');
          }
        },
        builder: (context, state) {
          // Nếu đang load lần đầu và chưa có dữ liệu thì hiện loading
          if (state.status == BillStatus.loading &&
              state.updateDetailBillModel == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _CreateCycleTab(
            isLoading: _isLoading,
            onPreparePayment: _onUpdateBill,
            idHoaDon: widget.idHoaDon,
            idNguoiThue: widget.idNguoiThue,
            onPriceCalculated: _updateCalculatedPrice,
            selectedRoomName: _selectedRoomName,
            isRoomSelected: _isRoomSelected,

            roomPriceController: _roomPriceController,
            depositController: _depositController,
            bookingFeeController: _bookingFeeController,
            noteController: _noteController,
            extraFeeController: _extraFeeController,

            // --- TRUYỀN CÁC TỔNG ĐÃ ĐỊNH DẠNG XUỐNG ---
            totalRoomPriceString: _formatter.format(_totalRoomPrice),
            totalServicePriceString: _formatter.format(_totalServicePrice),
            totalString: _formatter.format(
              _totalRoomPrice + _totalServicePrice + _totalExtraFee,
            ),
            totalExtraFeeString: _formatter.format(_totalExtraFee),
            totalDepositString: _formatter.format(_totalDeposit),
            totalBookingFeeString: _formatter.format(_totalBookingFee),
            finalPaymentString: '${_formatter.format(_finalPayment)} đ',

            onRoomTap: () async {
              // Logic async nằm ở đây
              final result = await getIt<AppRouter>().push(
                SelectRoomBill(
                  idHoaDon: widget.idHoaDon,
                  idNguoiThue: widget.idNguoiThue,
                ),
              );

              if (result != null && result is Map<String, dynamic>) {
                // Lấy dữ liệu từ màn hình chọn phòng
                final int? roomId = result['id'] as int?;
                final int? contractId = result['id_hopdong'] as int?;
                final String roomName = result['name'] as String;
                final double roomPrice = (result['price'] ?? 0.0) as double;
                final List<ServiceModel> services =
                    result['services'] as List<ServiceModel>;

                setState(() {
                  _selectedRoomId = roomId;
                  _selectedRoomName = roomName;
                  _selectedContractId = contractId;

                  _roomPriceController.text = _formatter.format(roomPrice);
                  _totalRoomPrice = roomPrice;

                  // 1. Hủy các controller CŨ (nếu có)
                  for (var controller in _serviceControllers) {
                    controller.dispose();
                  }

                  // 2. Cập nhật danh sách dịch vụ MỚI
                  _selectedRoomServices = services;

                  // 3. Tạo các controller MỚI
                  _serviceControllers =
                      services.map((service) {
                        // Định dạng giá ban đầu (phi_dichvu)
                        final initialPrice = _formatter.format(
                          service.phiDichVu,
                        );
                        return TextEditingController(text: initialPrice);
                      }).toList();

                  // 4. Đặt cờ đã chọn
                  _isRoomSelected = true;
                });
              }
            },

            selectedMonthYear: selectedMonthYear,
            onMonthTap: _showMonthYearPicker,
            paymentDate: _paymentDate,
            dueDate: _dueDate,
            onPickPaymentDate: (date) {
              setState(() {
                _paymentDate = date;
              });
            },
            onPickDueDate: (date) {
              setState(() {
                _dueDate = date;
              });
            },
            showDatePicker: _showDatePicker,

            selectedRoomServices: _selectedRoomServices,
            serviceControllers: _serviceControllers,

            serviceOldIndices: _serviceOldIndices,
            serviceNewIndices: _serviceNewIndices,
          );
        },
      ),
    );
  }
}

class _CreateCycleTab extends StatelessWidget {
  final String selectedMonthYear;
  final VoidCallback onMonthTap;
  final DateTime? paymentDate;
  final DateTime? dueDate;
  final Function(DateTime) onPickPaymentDate;
  final Function(DateTime) onPickDueDate;
  final void Function({
    required DateTime? initialDate,
    required Function(DateTime) onDateSelected,
  })
  showDatePicker;

  final int idHoaDon;
  final int idNguoiThue;
  final String selectedRoomName;
  final bool isRoomSelected;
  final VoidCallback onRoomTap;

  final List<ServiceModel> selectedRoomServices;
  final List<TextEditingController> serviceControllers;

  final Function(String serviceName, double price) onPriceCalculated;

  final TextEditingController roomPriceController;
  final TextEditingController depositController;
  final TextEditingController bookingFeeController;
  final TextEditingController extraFeeController;
  final TextEditingController noteController;

  // --- THÊM CÁC BIẾN TỔNG NÀY VÀO ---
  final String totalRoomPriceString;
  final String totalServicePriceString;
  final String totalString;
  final String totalExtraFeeString;
  final String totalDepositString;
  final String totalBookingFeeString;
  final String finalPaymentString;

  //khai báo biến gửi lên server
  final bool isLoading;
  final VoidCallback onPreparePayment;

  final Map<String, int> serviceOldIndices;
  final Map<String, int?> serviceNewIndices;

  const _CreateCycleTab({
    required this.selectedMonthYear,
    required this.onMonthTap,
    required this.paymentDate,
    required this.dueDate,
    required this.onPickPaymentDate,
    required this.onPickDueDate,
    required this.showDatePicker,

    required this.idHoaDon,
    required this.idNguoiThue,

    required this.selectedRoomName,
    required this.isRoomSelected,
    required this.onRoomTap,

    required this.selectedRoomServices,
    required this.serviceControllers,
    required this.noteController,

    required this.onPriceCalculated,

    required this.roomPriceController,
    required this.depositController,
    required this.bookingFeeController,
    required this.extraFeeController,
    required this.totalRoomPriceString,
    required this.totalServicePriceString,
    required this.totalString,
    required this.totalExtraFeeString,
    required this.totalDepositString,
    required this.totalBookingFeeString,
    required this.finalPaymentString,

    required this.isLoading,
    required this.onPreparePayment,

    required this.serviceOldIndices,
    required this.serviceNewIndices,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Thông tin'),
        _formField(
          'Hoá đơn tiền nhà tháng *',
          selectedMonthYear,
          onTap: onMonthTap,
        ),
        _formFieldSelectRoom(
          'Chọn phòng *',
          selectedRoomName,
          isGray: !isRoomSelected,
          onTap: onRoomTap,
        ),
        Row(
          children: [
            Expanded(
              child: _formField(
                'Ngày thanh toán *',

                // SỬA Ở ĐÂY: Thay 'Chọn ngày' bằng ngày hiện tại đã format
                paymentDate != null
                    ? _formatDate(paymentDate!)
                    : _formatDate(DateTime.now()), // <-- ĐÃ SỬA

                onTap:
                    () => showDatePicker(
                      onDateSelected: onPickPaymentDate,
                      initialDate: paymentDate,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _formField(
                'Hạn thanh toán *',

                // SỬA Ở ĐÂY: Thay 'Chọn ngày' bằng ngày hiện tại đã format
                dueDate != null
                    ? _formatDate(dueDate!)
                    : _formatDate(DateTime.now()), // <-- ĐÃ SỬA

                onTap:
                    () => showDatePicker(
                      initialDate: dueDate,
                      onDateSelected: onPickDueDate,
                    ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _sectionTitle('Tiền phòng'),

        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Text('Tiền Phòng')),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: roomPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle('Dịch vụ'),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children:
              selectedRoomServices.asMap().entries.map((entry) {
                final int index = entry.key;
                final ServiceModel service = entry.value;
                String serviceName = service.tenDichVu.toLowerCase();

                // KIỂM TRA ĐIỆN
                if (serviceName.contains("điện")) {
                  // Lấy chỉ số từ Map đã lưu ở cha
                  int oldIndex = serviceOldIndices[service.tenDichVu] ?? 0;
                  int? newIndex = serviceNewIndices[service.tenDichVu];

                  return CalculatedServiceCard(
                    title: service.tenDichVu,
                    iconPath: service.icon ?? 'default.png',
                    unit: "kWh",
                    // Lấy giá trên 1 đơn vị (Ví dụ: Lấy tổng tiền chia tiêu thụ, hoặc fix cứng 3000)
                    // Ở đây tạm để 3000 hoặc bạn cần thêm logic lấy đơn giá từ DB
                    pricePerUnit: service.phiDichVu,

                    // TRUYỀN CHỈ SỐ
                    initialNewIndex: newIndex, // Nếu null, widget con sẽ hiện 0
                    oldIndex: oldIndex,

                    onPriceCalculated: (price) {
                      onPriceCalculated(service.tenDichVu, price);
                    },

                    // 3. HỨNG DỮ LIỆU TẠI ĐÂY
                    onIndexChanged: (updatedIndex) {
                      // Cập nhật trực tiếp vào Map serviceNewIndices của cha
                      serviceNewIndices[service.tenDichVu] = updatedIndex;
                    },
                  );
                } else {
                  // Dịch vụ thường
                  final TextEditingController controller =
                      serviceControllers[index];
                  return FixedPriceServiceCard(
                    iconPath: service.icon ?? 'default.png',
                    title: service.tenDichVu,
                    priceController: controller,
                  );
                }
              }).toList(),
        ),
        const SizedBox(height: 16),
        _sectionTitle('Tổng hợp'),
        const SizedBox(height: 12),

        _summaryRow('Tiền phòng', totalRoomPriceString),

        _summaryRow('Dịch vụ', totalServicePriceString),
        _summaryRow('Tổng', totalString),
        // _summaryRow('Cọc hợp đồng', totalDepositString),
        // _summaryRow('Cọc giữ chỗ', totalBookingFeeString),
        const Divider(height: 32, thickness: 1),
        _summaryRow('Thanh toán', finalPaymentString, isTotal: true),
        const SizedBox(height: 16),
        const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: 'Nhập ghi chú cho hoá đơn',
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              // ✨ Thêm dòng này để vô hiệu hóa nút khi đang tải
              disabledBackgroundColor: Colors.grey,
            ),

            // thao tác bấm
            onPressed: isLoading ? null : onPreparePayment,

            //  hiển thị loadding
            child:
                isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                    : const Text(
                      'Lập hoá đơn',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.year}';
}

Widget _sectionTitle(String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.green.shade400,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
    child: Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _formField(
  String label,
  String value, {
  bool showCalendar = false,
  bool isGray = false,
  VoidCallback? onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isGray ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(color: isGray ? Colors.grey : Colors.black),
              ),
              if (showCalendar)
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              if (!showCalendar && onTap != null)
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _formFieldSelectRoom(
  String label,
  String value, {

  bool isGray = false,
  VoidCallback? onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            // color: isGray ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(color: Colors.black)),
              Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _summaryRow(
  String label,
  String value, {
  Color? color,
  bool isTotal = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    ),
  );
}

class FixedPriceServiceCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final TextEditingController priceController;

  const FixedPriceServiceCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.priceController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "lib/assets/icons/$iconPath",
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "lib/assets/icons/default.png", // Icon mặc định
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // TextField cho giá cố định
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    ThousandsSeparatorInputFormatter(), // Dùng formatter mới
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Tháng",
                style: TextStyle(color: Colors.white, fontSize: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///
/// WIDGET MỚI: THẺ DỊCH VỤ TÍNH TOÁN (CHO ĐIỆN, NƯỚC...)
///
class CalculatedServiceCard extends StatefulWidget {
  final String iconPath;
  final String title;
  final String unit;
  final double pricePerUnit;
  final Function(double) onPriceCalculated;

  // --- THAY ĐỔI: NHẬN CHỈ SỐ THAY VÌ TỔNG TIỀN ---
  final int? initialNewIndex; // Chỉ số mới (Có thể null)
  final int oldIndex; // Chỉ số cũ (Bắt buộc để tính toán)

  // 1. THÊM CALLBACK NÀY
  final Function(int) onIndexChanged;

  const CalculatedServiceCard({
    super.key,
    required this.iconPath,
    required this.title,
    this.unit = "kWh",
    this.pricePerUnit = 3000,
    required this.onPriceCalculated,
    required this.onIndexChanged,

    this.initialNewIndex,
    required this.oldIndex, // <-- Thêm tham số này
  });

  @override
  State<CalculatedServiceCard> createState() => _CalculatedServiceCardState();
}

class _CalculatedServiceCardState extends State<CalculatedServiceCard> {
  late final TextEditingController _indexController; // Đổi tên cho rõ nghĩa
  double _calculatedPrice = 0.0;
  final _priceFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();

    // 1. HIỂN THỊ CHỈ SỐ MỚI (NẾU NULL THÌ LÀ 0)
    int displayIndex = widget.initialNewIndex ?? 0;
    _indexController = TextEditingController(text: displayIndex.toString());

    _indexController.addListener(_calculatePrice);

    // Tính toán giá tiền ngay lần đầu khởi tạo
    _calculatePrice();
  }

  @override
  void dispose() {
    _indexController.removeListener(_calculatePrice);
    _indexController.dispose();
    super.dispose();
  }

  void _calculatePrice() {
    // Lấy chỉ số mới từ input
    String text = _indexController.text.replaceAll('.', '');
    int newIndex = int.tryParse(text) ?? 0;

    // 2. GỌI CALLBACK ĐỂ BÁO RA NGOÀI
    widget.onIndexChanged(newIndex);

    // 2. LOGIC TÍNH TIỀN: (MỚI - CŨ) * ĐƠN GIÁ
    int consumption = newIndex - widget.oldIndex;

    // Nếu chỉ số mới nhỏ hơn cũ (nhập sai) -> Tiêu thụ = 0
    if (consumption < 0) consumption = 0;

    double price = consumption * widget.pricePerUnit;

    setState(() {
      _calculatedPrice = price;
    });

    // Gọi callback trả tiền về widget cha
    widget.onPriceCalculated(price);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Height lớn hơn một chút để chứa 2 dòng
      height: 145,
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "lib/assets/icons/${widget.iconPath}",
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "lib/assets/icons/default.png", // Icon mặc định
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),

                // --- HIỂN THỊ CHỈ SỐ CŨ ---
                Text(
                  "(Cũ: ${widget.oldIndex})",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 4),

                // TextField NHẬP CHỈ SỐ MỚI
                TextField(
                  controller: _indexController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    ThousandsSeparatorInputFormatter(), // Thêm dấu chấm
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.blue, // Màu xanh cho chỉ số
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    // labelText: "Mới", // Có thể thêm label nếu muốn
                    hintText: "Nhập mới",
                    hintStyle: TextStyle(fontSize: 10, color: Colors.grey[300]),
                  ),
                ),

                const SizedBox(height: 4),
                const Divider(height: 1, thickness: 0.5), // Đường kẻ mờ
                const SizedBox(height: 4),

                // Text hiển thị GIÁ ĐÃ TÍNH
                Text(
                  _priceFormatter.format(_calculatedPrice),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Tháng",
                style: TextStyle(color: Colors.white, fontSize: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
