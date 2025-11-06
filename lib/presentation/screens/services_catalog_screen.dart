import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/service.dart';
import '../../data/repositories/service_repository_impl.dart';

class ServicesCatalogScreen extends StatelessWidget {
  const ServicesCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ServiceRepositoryImpl();
    final yellow = const Color(0xFFF2B705);
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: yellow,
        elevation: 0,
      ),
      body: FutureBuilder<List<Service>>(
        future: repository.getServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final services = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                decoration: BoxDecoration(
                  color: yellow,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: const Text('Nuestros Servicios', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text(service.description, style: const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.schedule, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text('${service.durationMinutes} min', style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                Text(
                                  currencyFormatter.format(service.price),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}