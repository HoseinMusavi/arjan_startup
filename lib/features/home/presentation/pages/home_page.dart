import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<HomeBloc>()..add(HomeStarted())),
        BlocProvider(create: (context) => getIt<ProfileBloc>()..add(ProfileRequested())),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: _buildAppBar(),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // حتی اگر ارور باشد، سعی می‌کنیم دیتای موجود (مثل بنر) را نشان دهیم
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(HomeRefreshed());
                context.read<ProfileBloc>().add(ProfileRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // --- بنرها (به صورت اسلایدر) ---
                    if (state.banners.isNotEmpty) 
                       _buildBannerSlider(state.banners)
                    else if (state.status == HomeStatus.success)
                       // اگر بنر نبود پلیس‌هولدر
                       Container(height: 150, margin: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(16))),

                    // --- دسته‌بندی‌ها ---
                    if (state.cuisines.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle("دسته‌بندی‌ها"),
                      _buildCuisines(state.cuisines),
                    ],

                    // --- پیشنهادات ویژه ---
                    if (state.specialOffers.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle("تخفیف‌های ویژه 🔥"),
                      _buildHorizontalList(state.specialOffers),
                    ],

                    // --- برگزیده‌ها ---
                    if (state.featuredMerchants.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle("برگزیده‌ها ⭐"),
                      _buildHorizontalList(state.featuredMerchants),
                    ],

                    // --- همه رستوران‌ها ---
                    const SizedBox(height: 24),
                    _buildSectionTitle(state.nearbyMerchants.isNotEmpty ? "رستوران‌های اطراف" : "همه رستوران‌ها"),
                    
                    if (state.nearbyMerchants.isEmpty && state.allMerchants.isEmpty)
                      _buildEmptyState()
                    else
                      _buildVerticalList(
                        state.nearbyMerchants.isNotEmpty ? state.nearbyMerchants : state.allMerchants
                      ),
                      
                    const SizedBox(height: 80), 
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
          const Text("آرژان فود", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return Text(
                  "خوش آمدید، ${state.profile.firstName}", 
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  // ✅ اسلایدر بنر اصلاح شده
  Widget _buildBannerSlider(List<String> banners) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(banners[index]),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildCuisines(List<dynamic> cuisines) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cuisines.length,
        itemBuilder: (context, index) {
          final item = cuisines[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(left: 12),
            child: Column(
              children: [
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5
                      )
                    ],
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
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalList(List<dynamic> merchants) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: merchants.length,
        itemBuilder: (context, index) {
          final m = merchants[index];
          return Container(
            width: 170,
            margin: const EdgeInsets.only(left: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: m.logo.isNotEmpty 
                      ? Image.network(m.logo, fit: BoxFit.cover, width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)))
                      : Container(color: Colors.grey.shade200, child: const Icon(Icons.store, color: Colors.grey)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                          Text(" ${m.rating}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalList(List<dynamic> merchants) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: merchants.length,
      itemBuilder: (context, index) {
        final m = merchants[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10
              )
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)), // RTL rounded
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade200,
                  child: m.logo.isNotEmpty 
                    ? Image.network(m.logo, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.store))
                    : const Icon(Icons.store, size: 40, color: Colors.grey),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(m.address, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.delivery_dining, size: 16, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(m.deliveryFee, style: const TextStyle(fontSize: 12)),
                          const Spacer(),
                          const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                          Text(" ${m.rating}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.restaurant_menu, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "فعلاً رستورانی در این اطراف یافت نشد",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}