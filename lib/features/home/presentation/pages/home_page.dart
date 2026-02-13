import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(HomeStarted()),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == HomeStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.errorMessage, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<HomeBloc>().add(HomeRefreshed()),
                      child: const Text("تلاش مجدد"),
                    )
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(HomeRefreshed());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // بنرها
                    if (state.banners.isNotEmpty) ...[
                       _buildSectionTitle("پیشنهادهای ویژه"),
                       _buildBanners(state.banners),
                    ],

                    // دسته‌بندی‌ها
                    if (state.cuisines.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle("دسته‌بندی‌ها"),
                      _buildCuisines(state.cuisines),
                    ],

                    // رستوران‌ها
                    const SizedBox(height: 24),
                    _buildSectionTitle("رستوران‌های اطراف"),
                    if (state.merchants.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(child: Text("فعلاً رستورانی یافت نشد.")),
                      )
                    else
                      _buildMerchants(state.merchants),
                      
                    const SizedBox(height: 80), // فضای خالی برای اسکرول آخر
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        children: [
          const Text("آرژان فود", style: TextStyle(fontSize: 16, color: Colors.grey)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.location_on, size: 14, color: Colors.orange),
              SizedBox(width: 4),
              Text("انتخاب آدرس", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: Colors.black))
      ],
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  // ویجت موقت برای نمایش بنرها
  Widget _buildBanners(List<String> banners) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(banners[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
  
  // ویجت موقت برای دسته‌بندی‌ها
  Widget _buildCuisines(List<dynamic> cuisines) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: cuisines.length,
        itemBuilder: (context, index) {
          final item = cuisines[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    image: item.image.isNotEmpty 
                      ? DecorationImage(image: NetworkImage(item.image), fit: BoxFit.cover)
                      : null,
                  ),
                  child: item.image.isEmpty ? const Icon(Icons.fastfood, color: Colors.orange) : null,
                ),
                const SizedBox(height: 8),
                Text(
                  item.name, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ویجت موقت برای رستوران‌ها
  Widget _buildMerchants(List<dynamic> merchants) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: merchants.length,
      itemBuilder: (context, index) {
        final m = merchants[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عکس کاور رستوران (فعلا از لوگو استفاده میکنیم اگر کاور ندارد)
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.grey.shade200,
                  image: m.logo.isNotEmpty 
                    ? DecorationImage(image: NetworkImage(m.logo), fit: BoxFit.cover)
                    : null,
                ),
                child: m.logo.isEmpty ? const Center(child: Icon(Icons.store, size: 50, color: Colors.grey)) : null,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(m.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(m.rating.toString(), style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              Icon(Icons.star, size: 14, color: Colors.green.shade800),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(m.address, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 8),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.delivery_dining, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text("پیک: ${m.deliveryFee} تومان", style: const TextStyle(fontSize: 12)),
                        const Spacer(),
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text("۳۰-۴۰ دقیقه", style: TextStyle(fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}