import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../data/models/address_dto.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    debugPrint('📍 [AddressesPage] initState');
    _profileBloc = getIt<ProfileBloc>();
    _profileBloc.add(const ProfileAddressesRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('آدرس‌های من'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                debugPrint('📍 [AddressesPage] Navigate to Add Address');
                context.push('/profile/addresses/add');
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            debugPrint('🔄 [AddressesPage] Pull to refresh');
            _profileBloc.add(const ProfileAddressesRequested());
          },
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileAddressActionSuccess) {
                debugPrint('✅ [AddressesPage] Success: ${state.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
                _profileBloc.add(const ProfileAddressesRequested());
              }
              if (state is ProfileError) {
                debugPrint('❌ [AddressesPage] Error: ${state.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ProfileAddressesLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ProfileAddressesLoaded) {
                return _buildAddressesContent(context, state.addresses);
              }
              if (state is ProfileError) {
                return _buildErrorWidget(context, state.message);
              }
              return const Center(child: Text('داده‌ای وجود ندارد'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'خطا در بارگذاری آدرس‌ها',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              debugPrint('🔄 [AddressesPage] Retry');
              _profileBloc.add(const ProfileAddressesRequested());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesContent(BuildContext context, List<AddressDto> addresses) {
    debugPrint('📍 [AddressesPage] Rendering ${addresses.length} addresses');

    if (addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'هیچ آدرسی ثبت نشده است',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'برای افزودن آدرس جدید، روی دکمه + در بالا کلیک کنید.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final address = addresses[index];
        final isDefault = address.asDefault == '1';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Dismissible(
            key: Key(address.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 28),
            ),
            onDismissed: (direction) {
              debugPrint('🗑️ [AddressesPage] Delete: ${address.id}');
              _showDeleteConfirmation(context, address.id);
            },
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDefault ? Colors.orange.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDefault ? Icons.home : Icons.location_on,
                  color: isDefault ? Colors.orange : Colors.grey.shade600,
                ),
              ),
              title: Text(
                address.address,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDefault)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Text(
                        'پیش‌فرض',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    address.dateAdded,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    onPressed: () {
                      debugPrint('✏️ [AddressesPage] Edit: ${address.id}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ویرایش آدرس در حال توسعه...')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmation(context, address.id);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    debugPrint('🗑️ [AddressesPage] Show delete confirmation: $id');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف آدرس'),
        content: const Text('آیا مطمئن هستید که می‌خواهید این آدرس را حذف کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              debugPrint('🗑️ [AddressesPage] Delete confirmed: $id');
              Navigator.pop(dialogContext);
              _profileBloc.add(ProfileDeleteAddressRequested(id: id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}