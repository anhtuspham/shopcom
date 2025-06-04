import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_com/data/config/app_config.dart';
import 'package:shop_com/providers/order_provider.dart';
import 'package:shop_com/providers/user_provider.dart';

import '../../../utils/widgets/appbar_widget.dart';
import '../../../utils/widgets/button_widget.dart';
import '../../../utils/widgets/error_widget.dart';
import '../../../utils/widgets/input_form_widget.dart';
import '../../../utils/widgets/loading_widget.dart';

class ShippingAddress extends ConsumerStatefulWidget {
  const ShippingAddress({super.key});

  @override
  ConsumerState<ShippingAddress> createState() => _ShippingAddressState();
}

class _ShippingAddressState extends ConsumerState<ShippingAddress> {
  bool _isProcessingSave = false;
  String? email;
  String? name;
  String? address;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () {
        ref.read(userProvider.notifier).getUserInfo();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProvider);
    if (state.isLoading) return const LoadingWidget();
    if (state.isError) return const ErrorsWidget();
    nameController = TextEditingController(text: state.user.name);
    emailController = TextEditingController(text: state.user.email);
    addressController = TextEditingController(text: state.user.address);

    return Scaffold(
      appBar: const AppBarWidget(title: 'Shipping Address'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          InputForm(
                            labelText: 'Full name',
                            hintText: 'Full name',
                            controller: nameController,
                            // initialValue: state.user.name,
                            onSaved: (newValue) => name = newValue,
                          ),
                          const SizedBox(height: 20),
                          InputForm(
                            labelText: 'Email',
                            hintText: '123@gmail.com',
                            controller: emailController,
                            // initialValue: state.user.email,
                            onSaved: (newValue) => email = newValue,
                          ),
                          const SizedBox(height: 20),
                          InputForm(
                            labelText: 'Address',
                            hintText: 'Ho Chi Minh city',
                            controller: addressController,
                            // initialValue: state.user.address,
                            onSaved: (newValue) => address = newValue,
                          ),
                        ],
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: CommonButtonWidget(
                            callBack: _handleUpdateInfo,
                            label: _isProcessingSave
                                ? 'PROCESSING...'
                                : 'SAVE ADDRESS',
                            style: const TextStyle(color: Colors.white),
                            buttonStyle: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                    _isProcessingSave
                                        ? Colors.grey
                                        : Colors.black)),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdateInfo() async {
    if (_isProcessingSave) return;
    setState(() {
      _isProcessingSave = true;
    });

    try {
      await ref
          .read(userProvider.notifier)
          .updateUserInfo(email: emailController.text, name: nameController.text, address: addressController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cập nhật thành công'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cập nhật thất bại: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingSave = false;
        });
      }
    }
  }

  Future<void> _refresh() {
    return ref.read(orderProvider.notifier).refresh();
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          const SizedBox(width: 4),
          const Text(
            'Shipping Address',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
