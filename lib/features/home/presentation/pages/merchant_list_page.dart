import 'package:arjan_startup/core/enums/store_type.dart';
import 'package:arjan_startup/features/home/data/models/merchant_dto.dart';
import 'package:arjan_startup/features/home/presentation/widgets/merchant_card.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class MerchantListPage extends StatefulWidget {
  final Future<List<MerchantDto>> Function() fetchMerchants;
  final String title;
  final StoreType storeType;

  const MerchantListPage({
    super.key,
    required this.fetchMerchants,
    required this.title,
    required this.storeType,
  });

  @override
  State<MerchantListPage> createState() => _MerchantListPageState();
}

class _MerchantListPageState extends State<MerchantListPage> {
  late Future<List<MerchantDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.fetchMerchants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.storeType.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<MerchantDto>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('خطا در بارگذاری', style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _future = widget.fetchMerchants();
                      });
                    },
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            );
          }
          final merchants = snapshot.data ?? [];
          if (merchants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('هیچ فروشگاهی یافت نشد', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: merchants.length,
            itemBuilder: (context, index) => MerchantCard(
              merchant: merchants[index],
              isHorizontal: false,
              storeType: widget.storeType,
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 140,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}