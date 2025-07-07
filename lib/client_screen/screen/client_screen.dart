import 'package:attendance_app/add_client/screen/screen.dart';
import 'package:attendance_app/client_screen/bloc/get_bloc/bloc.dart';
import 'package:attendance_app/client_screen/bloc/get_bloc/event.dart';
import 'package:attendance_app/client_screen/bloc/get_bloc/state.dart';
import 'package:attendance_app/client_screen/screen/widgets/card.dart';
import 'package:attendance_app/client_screen/screen/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';


class ClientScreen extends StatelessWidget {
  const ClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClientBloc(Dio())..add(FetchClients()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.add, size: 30),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const AddClientScreen(),
                ));}
                
                )
          ],
          backgroundColor: Colors.blueAccent,
          title: const Text('العملاء', style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )),
          centerTitle: true,
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              BlocBuilder<ClientBloc, ClientState>(
                builder: (context, state) {
                  if (state is ClientLoading) {
                    return const SliverToBoxAdapter(child: ClientShimmer());
                  } else if (state is ClientLoaded) {
                    if (state.clients.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(child: Text('لا يوجد عملاء')),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => ClientCard(client: state.clients[index]),
                        childCount: state.clients.length,
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
      ),
    );
  }
}