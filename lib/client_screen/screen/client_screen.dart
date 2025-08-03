import 'package:attendance_app/add_client/screen/screen.dart';
import 'package:attendance_app/client_screen/bloc/get_bloc/bloc.dart';
import 'package:attendance_app/client_screen/bloc/get_bloc/event.dart';
import 'package:attendance_app/client_screen/bloc/get_bloc/state.dart';
import 'package:attendance_app/client_screen/screen/widgets/card.dart';
import 'package:attendance_app/client_screen/screen/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';


class ClientScreen extends StatefulWidget {
  final String department;
  const ClientScreen({super.key , required this.department});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  String? selectedStatus;
  String? selectedService;


  final statusOptions = [
    'تجاهل العميل',
    'متابعة العميل',
    'مهتم',
    'محتاج متابعة',
    'منتظر عرض',
    'تم إرسال عرض',
    'فرصة تحت التفاوض',
    'تم التحويل لفرصة',
    'غير مهتم',
    'لا يرد',
    'بيانات خاطئة',
      'نشط',
      'غير نشط',
      'مغلق',
  ];
  final serviceOptions = [
    'تصميم اعلانات',
    'تصميم هوية بصرية',
    'تصميم فيديو  موشن',
    'إدارة سوشيال ميديا',
    'برمجة تطبيق',
    'تصميم موقع',
    'استشارة تسويقية',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClientBloc(Dio())..add(FetchClients()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
actions: widget.department == 'sales'
    ? [
        IconButton(
          icon: const Icon(Icons.add, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddClientScreen()),
            );
          },
        )
      ]
    : null,
          backgroundColor: Colors.blueAccent,
          title: const Text(
            'العملاء',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        hint: const Text('الحالة'),
                        items: [
                          const DropdownMenuItem<String>(value: null, child: Text('كل الحالات')),
                          ...statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedStatus = val;
                          });
                        },
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedService,
                        hint: const Text('الخدمة'),
                        items: [
                          const DropdownMenuItem<String>(value: null, child: Text('كل الخدمات')),
                          ...serviceOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedService = val;
                          });
                        },
                        isExpanded: true,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    BlocBuilder<ClientBloc, ClientState>(
                      builder: (context, state) {
                        if (state is ClientLoading) {
                          return const SliverToBoxAdapter(child: ClientShimmer());
                        } else if (state is ClientLoaded) {
                          var filteredClients = state.clients;
                          if (selectedStatus != null) {
                            filteredClients = filteredClients.where((c) => c.status == selectedStatus).toList();
                          }
                          if (selectedService != null) {
                            filteredClients = filteredClients.where((c) => c.serviceRequired == selectedService).toList();
                          }
                          if (filteredClients.isEmpty) {
                            return const SliverToBoxAdapter(
                              child: Center(child: Text('لا يوجد عملاء')),
                            );
                          }
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => ClientCard(client: filteredClients[index]),
                              childCount: filteredClients.length,
                            ),
                          );
                        } else if (state is ClientError) {
                          return SliverToBoxAdapter(
                            child: Center(child: Text(state.message)),
                          );
                        }
                        return const SliverToBoxAdapter(child: SizedBox.shrink());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
