import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motelapp/core/utils/thousands_formatter.dart';
import 'package:motelapp/data/models/service_model.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/home/bill_home/bill_cubit.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/bill_home.dart';
import 'package:motelapp/presentation/screens/home/functions/function_bill_home/make_bill/select_room_bill.dart';

import 'package:motelapp/router/app_router.dart';

class MakeBill extends StatefulWidget {
  final int idHoaDon;
  final int idNguoiThue;
  const MakeBill({
    super.key,
    required this.idHoaDon,
    required this.idNguoiThue,
  });

  @override
  State<MakeBill> createState() => _MakeBillState();
}

class _MakeBillState extends State<MakeBill> {
  Map<String, double> _calculatedServicePrices = {};
  int? _selectedRoomId;
  int? _selectedContractId;
  String _selectedRoomName = 'Chọn phòng'; // Giá trị mặc định
  bool _isRoomSelected = false;
  String selectedMonthYear =
      '${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}';
  DateTime? _paymentDate;
  DateTime? _dueDate;

  List<ServiceModel> _selectedRoomServices = [];
  List<TextEditingController> _serviceControllers = [];

  final _formatter = NumberFormat.decimalPattern('vi_VN');

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

  // hàm cập nhật tiền
  void _updateCalculatedPrice(String serviceName, double price) {
    // Gọi setState để thông báo cho Flutter rằng state đã thay đổi
    // và cần build lại UI (ví dụ: cập nhật tổng tiền)
    setState(() {
      _calculatedServicePrices[serviceName] = price;
    });

    // (Bạn có thể gọi hàm tính tổng tiền của mình ở đây)
    _calculateTotals();
    // In ra để kiểm tra
    print("Updated prices: $_calculatedServicePrices");
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
      String serviceName = entry.value.ten_dichvu.toLowerCase();
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

  // Future<void> _prepareAndSendPayment() async {
  //   final billCubit = context.read<BillCubit>();
  //   setState(() => _isLoading = true);

  //   try {
  //     // 1. Validate dữ liệu (Ví dụ)
  //     if (_selectedContractId == null) {
  //       _showError('Vui lòng chọn phòng để lấy ID Hợp đồng');
  //       return;
  //     }
  //     if (_dueDate == null) {
  //       _showError('Vui lòng chọn hạn thanh toán');
  //       return;
  //     }

  //     // 2. Chuẩn bị Payload (Gói dữ liệu)
  //     // (Đổi 'key' cho khớp với API/cột DB của bạn)
  //     final Map<String, dynamic> hoadonPayload = {
  //       // --- CÁC TRƯỜNG BẠN YÊU CẦU ---
  //       'id_hoadon': widget.idHoaDon,
  //       'ngay_thang':
  //           '${selectedMonthYear.split('-')[1]}-${selectedMonthYear.split('-')[0]}-01', // Định dạng YYYY-MM-01
  //       'ngay_thanh_toan': _formatDateForServer(_paymentDate), // Có thể null
  //       'han_thanh_toan': _formatDateForServer(_dueDate!), // Đã check null
  //       'tien_phong': _totalRoomPrice,
  //       'tong_tien_dich_vu': _totalServicePrice,
  //       'tong_hop_tien':
  //           _finalPayment, // Đây là tổng của (Tiền phòng + Dịch vụ)

  //       'ghi_chu_hoa_don': _noteController.text,

  //       'trang_thai_hoa_don': 'Chưa thanh toán',
  //     };

  //     // 4. Gói lại
  //     final Map<String, dynamic> finalPayload = {
  //       'hoa_don_details': hoadonPayload,
  //       // 'dich_vu_details': serviceDetailsPayload, //cần sẻ bật lên chi tiết dich vụ
  //     };

  //     // 5. Chuyển thành JSON
  //     final String jsonPayload = jsonEncode(finalPayload);

  //     // --- (IN RA ĐỂ KIỂM TRA) ---
  //     print('--- GỬI LÊN SERVER (PAYLOAD ĐÃ RÚT GỌN) ---');
  //     print(jsonPayload);
  //     // --- (KẾT THÚC KIỂM TRA) ---

  //     // --- (GIẢ LẬP MẠNG DELAY) ---
  //     await Future.delayed(const Duration(seconds: 1));
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Đã lập hóa đơn'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //     // --- (KẾT THÚC GIẢ LẬP) ---
  //     if (mounted) {
  //       getIt<AppRouter>().push(BillHome());
  //     }
  //   } catch (e) {
  //     _showError('Lỗi khi lập hóa đơn: $e');
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  Future<void> _prepareAndSendPayment() async {
    // --- THÊM DÒNG NÀY ĐỂ TRUY CẬP CUBIT ---
    final billCubit = context.read<BillCubit>();
    // ----------------------------------------

    setState(() => _isLoading = true);

    try {
      // 1. Validate dữ liệu
      if (_selectedContractId == null) {
        _showError('Vui lòng chọn phòng để lấy ID Hợp đồng');
        return;
      }
      if (_dueDate == null) {
        _showError('Vui lòng chọn hạn thanh toán');
        return;
      }
      // (Bỏ qua validation cho _paymentDate vì nó có thể null theo logic của bạn)

      // 2. Chuẩn bị Payload (Map dữ liệu)
      final Map<String, dynamic> hoadonPayload = {
        // --- CÁC TRƯỜNG BẠN YÊU CẦU ---
        'id_hoadon': widget.idHoaDon,
        'ngay_thang':
            '${selectedMonthYear.split('-')[1]}-${selectedMonthYear.split('-')[0]}-01', // Định dạng YYYY-MM-01
        'ngay_thanh_toan':
            _paymentDate != null
                ? _formatDateForServer(_paymentDate!)
                : null, // Xử lý null
        'han_thanh_toan': _formatDateForServer(_dueDate!), // Đã check null
        'tien_phong': _totalRoomPrice,
        'tong_tien_dich_vu': _totalServicePrice,
        'tong_hop_tien':
            _finalPayment, // Đây là tổng của (Tiền phòng + Dịch vụ + Phụ phí - Cọc - Phí đặt)

        'ghi_chu_hoa_don': _noteController.text,

        'trang_thai_hoa_don':
            'Chưa thanh toán', // Luôn set là "Chưa thanh toán" khi lập
      };

      // 3. Chuẩn bị payload cho dịch vụ (Nếu cần thiết - tạm thời bỏ qua nếu API updateInvoice không yêu cầu)
      // Bạn đã tạo logic trong repo chỉ nhận 'hoa_don_details'. Nếu API yêu cầu 'dich_vu_details',
      // bạn cần thêm logic tạo serviceDetailsPayload ở đây.

      // 4. Gói lại (theo format API /bill/updateInvoice)
      final Map<String, dynamic> finalPayload = {
        'hoa_don_details': hoadonPayload,
        // 'dich_vu_details': serviceDetailsPayload, // Bỏ qua nếu API hiện tại chưa xử lý
      };

      // 5. GỌI CUBIT ĐỂ GỬI LÊN SERVER
      print('--- GỌI CUBIT UPDATE BILL ---');
      await billCubit.updateBillData(hoadonPayload);

      // 6. Xử lý thành công
      if (mounted) {
        // Thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lập hóa đơn thành công!')),
        );

        // Điều hướng về màn hình BillHome
        getIt<AppRouter>().push(BillHome());
      }
    } catch (e) {
      // Bắt lỗi từ Cubit ném ra (thường là lỗi từ Server)
      _showError(
        'Lỗi khi lập hóa đơn: ${e.toString().replaceFirst('Exception: ', '')}',
      );
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Lập hoá đơn',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            dividerHeight: 0,
            tabs: [Tab(text: 'Theo chu kỳ'), Tab(text: 'Tuỳ chọn thời gian')],
          ),
        ),
        body: TabBarView(
          children: [
            _CreateCycleTab(
              isLoading: _isLoading,
              onPreparePayment: _prepareAndSendPayment,
              idHoaDon: widget.idHoaDon,
              idNguoiThue: widget.idNguoiThue,
              onPriceCalculated: _updateCalculatedPrice,
              selectedRoomName: _selectedRoomName,
              isRoomSelected: _selectedRoomServices.isNotEmpty,

              roomPriceController: _roomPriceController,
              depositController: _depositController,
              bookingFeeController: _bookingFeeController,
              noteController: _noteController,
              extraFeeController:
                  _extraFeeController, // (Cần cho 'Khách trả thêm')
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
                            service.phi_dichvu,
                          );
                          return TextEditingController(text: initialPrice);
                        }).toList();

                    // 4. Đặt cờ đã chọn
                    // (Bạn đã set là 'false' ở code cũ, đây là logic đúng)
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
            ),

            const Center(child: Text('Tuỳ chọn thời gian')),
          ],
        ),
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
                String serviceName = service.ten_dichvu.toLowerCase();

                if (serviceName == "điện") {
                  return CalculatedServiceCard(
                    title: service.ten_dichvu,
                    iconPath: service.icon ?? 'default.png',
                    unit: "kWh",
                    pricePerUnit: 3000, // (Nên lấy từ service model)
                    // --- GỌI HÀM CỦA CHA TẠI ĐÂY ---
                    onPriceCalculated: (price) {
                      // 'onPriceCalculated' này chính là hàm '_updateCalculatedPrice' ở Cha
                      onPriceCalculated(service.ten_dichvu, price);
                    },
                  );
                } else {
                  // Dịch vụ cố định
                  final TextEditingController controller =
                      serviceControllers[index];
                  return FixedPriceServiceCard(
                    title: service.ten_dichvu,
                    iconPath: service.icon ?? 'default.png',
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
  final String unit; // Đơn vị tính (ví dụ: "kWh", "m³")
  final double pricePerUnit; // Giá mỗi đơn vị (ví dụ: 1700đ/kWh)
  final Function(double) onPriceCalculated; // Callback trả về giá đã tính

  const CalculatedServiceCard({
    super.key,
    required this.iconPath,
    required this.title,
    this.unit = "kWh",
    this.pricePerUnit = 1700, // Giá điện ví dụ
    required this.onPriceCalculated,
  });

  @override
  State<CalculatedServiceCard> createState() => _CalculatedServiceCardState();
}

class _CalculatedServiceCardState extends State<CalculatedServiceCard> {
  final _consumptionController = TextEditingController();
  double _calculatedPrice = 0.0;
  final _priceFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    _consumptionController.addListener(_calculatePrice);
  }

  @override
  void dispose() {
    _consumptionController.removeListener(_calculatePrice);
    _consumptionController.dispose();
    super.dispose();
  }

  void _calculatePrice() {
    // Lấy text và xoá dấu CHẤM (vì formatter mới dùng dấu chấm)
    String text = _consumptionController.text.replaceAll('.', '');
    int consumption = int.tryParse(text) ?? 0;

    // Logic tính tiền (ví dụ đơn giản)
    // Bạn có thể thay thế bằng logic tính tiền điện bậc thang phức tạp ở đây
    double price = consumption * widget.pricePerUnit;

    setState(() {
      _calculatedPrice = price;
    });

    // Gọi callback để thông báo cho widget cha
    widget.onPriceCalculated(price);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Height lớn hơn một chút để chứa 2 dòng
      height: 125,
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
                const SizedBox(height: 4),

                // TextField cho CHỈ SỐ TIÊU THỤ
                TextField(
                  controller: _consumptionController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    // ĐÃ XOÁ FilteringTextInputFormatter.digitsOnly
                    ThousandsSeparatorInputFormatter(), // Thêm dấu chấm
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.blue, // Màu khác để phân biệt
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    suffixText: " ${widget.unit}", // Hiển thị đơn vị
                    suffixStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ),

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
