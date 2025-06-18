import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_com/providers/cart_provider.dart';
import 'package:shop_com/providers/currency_provider.dart';
import 'package:shop_com/utils/util.dart';
import 'package:shop_com/utils/widgets/appbar_widget.dart';
import '../../../providers/product_detail_provider.dart';
import '../../../utils/screen_size_checker.dart';
import '../../../utils/widgets/button_widget.dart';
import '../../../utils/widgets/error_widget.dart';
import '../../../utils/widgets/loading_widget.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const ProductDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? selectedRAM;
  String? selectedROM;
  String? selectedColor;

  int currentPage = 0;
  final PageController _pageController = PageController();

  // Lists to store available variant combinations
  List<String> availableRAM = [];
  List<String> availableROM = [];
  List<String> availableColors = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = ref.read(productDetailProvider(widget.id));

    // Get all unique variant options from the product variants
    _updateAvailableOptions(state);

    // Set initial selections if options are available
    if (availableRAM.isNotEmpty) selectedRAM ??= availableRAM.first;
    if (availableROM.isNotEmpty) selectedROM ??= availableROM.first;
    if (availableColors.isNotEmpty) selectedColor ??= availableColors.first;
  }

  // Method to update available options based on current selections
  void _updateAvailableOptions(ProductDetailState state) {
    final variants = state.product.variants ?? [];

    // Reset available options
    availableRAM = [];
    availableROM = [];
    availableColors = [];

    // Extract unique values from variants
    for (final variant in variants) {
      if (variant.ram != null && !availableRAM.contains(variant.ram)) {
        availableRAM.add(variant.ram!);
      }
      if (variant.rom != null && !availableROM.contains(variant.rom)) {
        availableROM.add(variant.rom!);
      }
      if (variant.color != null && !availableColors.contains(variant.color)) {
        availableColors.add(variant.color!);
      }
    }
  }

  // Method to filter available options based on current selections
  void _filterOptionsBasedOnSelection(ProductDetailState state) {
    final variants = state.product.variants ?? [];
    final category = state.product.category?.toLowerCase() ?? '';

    // For laptop we only need to filter ROM based on RAM
    if (category == 'laptop' && selectedRAM != null) {
      availableROM = [];
      for (final variant in variants) {
        if (variant.ram == selectedRAM && variant.rom != null && !availableROM.contains(variant.rom)) {
          availableROM.add(variant.rom!);
        }
      }
      // If current ROM selection is no longer valid, reset it
      if (selectedROM != null && !availableROM.contains(selectedROM)) {
        selectedROM = availableROM.isNotEmpty ? availableROM.first : null;
      }
    }

    // For smartphone and tablet, we need to filter ROM based on RAM and Color
    else if ((category == 'smartphone' || category == 'tablet')) {
      // If RAM is selected, filter ROM and Color
      if (selectedRAM != null) {
        List<String> tempROM = [];
        List<String> tempColors = [];

        for (final variant in variants) {
          if (variant.ram == selectedRAM) {
            if (variant.rom != null && !tempROM.contains(variant.rom)) {
              tempROM.add(variant.rom!);
            }
            if (variant.color != null && !tempColors.contains(variant.color)) {
              tempColors.add(variant.color!);
            }
          }
        }

        availableROM = tempROM;

        // Only update available colors if no ROM is selected yet
        if (selectedROM == null) {
          availableColors = tempColors;
        }

        // If current ROM selection is no longer valid, reset it
        if (selectedROM != null && !availableROM.contains(selectedROM)) {
          selectedROM = availableROM.isNotEmpty ? availableROM.first : null;
        }
      }

      // If ROM is selected, filter RAM and Color
      if (selectedROM != null) {
        List<String> tempColors = [];

        for (final variant in variants) {
          if ((selectedRAM == null || variant.ram == selectedRAM) &&
              variant.rom == selectedROM &&
              variant.color != null &&
              !tempColors.contains(variant.color)) {
            tempColors.add(variant.color!);
          }
        }

        availableColors = tempColors;

        // If current Color selection is no longer valid, reset it
        if (selectedColor != null && !availableColors.contains(selectedColor)) {
          selectedColor = availableColors.isNotEmpty ? availableColors.first : null;
        }
      }

      // If Color is selected, filter RAM and ROM
      if (selectedColor != null) {
        List<String> tempRAM = [];
        List<String> tempROM = [];

        for (final variant in variants) {
          if (variant.color == selectedColor) {
            if ((selectedRAM == null || selectedROM == null) && variant.ram != null && !tempRAM.contains(variant.ram)) {
              tempRAM.add(variant.ram!);
            }
            if ((selectedRAM == null || selectedROM == null || (variant.ram == selectedRAM)) &&
                variant.rom != null && !tempROM.contains(variant.rom)) {
              tempROM.add(variant.rom!);
            }
          }
        }

        // Only update if we haven't already selected RAM
        if (selectedRAM == null) {
          availableRAM = tempRAM;
        }

        // Only update if we haven't already selected ROM
        if (selectedROM == null) {
          availableROM = tempROM;
        }
      }
    }

    // For headphone, we only have color options
    else if (category == 'headphone') {
      // No filtering needed since there's only one option type
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailProvider(widget.id));
    final height = MediaQuery.sizeOf(context).height;
    // final formattedPrice = formatPrice(usdPrice, currency)

    if (state.isLoading) return const LoadingWidget();
    if (state.isError) return const ErrorsWidget();

    // Update available options whenever state changes
    _updateAvailableOptions(state);
    _filterOptionsBasedOnSelection(state);

    return Scaffold(
      appBar: AppBarWidget(title: state.product.name,),
      body: SafeArea(
        child: Column(
          children: [
            // AppBarWidget(title: state.product.name),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildImageSlider(state.images, height),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDynamicDropdowns(state),
                          const SizedBox(height: 16),
                          _buildTitlePriceSection(state, ref),
                          const SizedBox(height: 8),
                          _buildDescription(state),
                          const SizedBox(height: 16),
                          _buildAddToCartButton(state),
                          const SizedBox(height: 20),
                          _buildAccordion(state),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider(List<String> images, double height) {
    return Column(
      children: [
        Container(
          height: height * (ScreenSizeChecker.isTabletLandscape(context) ? 0.55 : 0.45),
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) => setState(() => currentPage = index),
            itemBuilder: (context, index) => Image.network(
              images[index],
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) =>
              loadingProgress == null ? child : const LoadingWidget(),
              errorBuilder: (context, error, stackTrace) =>
              const ErrorsWidget(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: currentPage == index ? 12 : 8,
              height: currentPage == index ? 12 : 8,
              decoration: BoxDecoration(
                color:
                currentPage == index ? Colors.black : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicDropdowns(ProductDetailState state) {
    final category = state.product.category?.toLowerCase() ?? '';
    final options = {
      'laptop': ['RAM', 'ROM'],
      'headphone': ['Color'],
      'smartphone': ['RAM', 'ROM', 'Color'],
      'tablet': ['RAM', 'ROM', 'Color'],
    }[category] ??
        [];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: options.map((option) {
        final items = _getOptions(option);
        final selected = _getSelected(option);
        return SizedBox(
          width: 150,
          child: _buildDropdown(
            hint: option,
            items: items,
            selected: selected,
            onChanged: (value) => _setSelected(option, value),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required List<String> items,
    String? selected,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$hint:'),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(selected) ? selected : null,
              hint: const Text('Chọn'),
              isExpanded: true,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onChanged: (value) => onChanged(value!),
              items: items
                  .map((value) =>
                  DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitlePriceSection(ProductDetailState state, WidgetRef ref) {
    // Find the current variant based on selections to display the correct price
    final variantIndex = _findSelectedVariantIndex(state);
    final price = variantIndex != -1
        ? state.product.variants![variantIndex].price
        : state.product.defaultVariant?.price;
    final currency = ref.watch(currencyProvider);
    final formattedPrice = formatMoney(price ?? 0, currency);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.product.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(state.product.brand ?? '',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
        Text(formattedPrice ?? '',
            style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget _buildDescription(ProductDetailState state) => Text(
    state.product.description ?? '',
    style: const TextStyle(fontSize: 14),
  );

  Widget _buildAddToCartButton(ProductDetailState state) => SizedBox(
    width: double.infinity,
    child: CommonButtonWidget(
      callBack: () async {
        final variantIndex = _findSelectedVariantIndex(state);
        if (variantIndex == -1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng chọn đầy đủ các lựa chọn')),
          );
          return;
        }

        await ref.read(cartProvider.notifier).addProductToCart(
          productId: state.product.id ?? '',
          variantIndex: variantIndex,
          quantity: 1,
        );

        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã thêm vào giỏ hàng'), backgroundColor: Colors.green,),
          );
        }
      },
      label: 'Thêm vào giỏ hàng',
      style: const TextStyle(color: Colors.white),
      buttonStyle: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.black),
      ),
    ),
  );

  Widget _buildAccordion(ProductDetailState state) {
    return Column(
      children: [
        ListTile(
          title: const Text('Đánh giá'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () => context.push('/review', extra: state.product),
        ),
        const ListTile(
          title: Text('Hỗ trợ'),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
      ],
    );
  }

  List<String> _getOptions(String type) {
    switch (type) {
      case 'RAM':
        return availableRAM;
      case 'ROM':
        return availableROM;
      case 'Color':
        return availableColors;
      default:
        return [];
    }
  }

  String? _getSelected(String type) {
    switch (type) {
      case 'RAM':
        return selectedRAM;
      case 'ROM':
        return selectedROM;
      case 'Color':
        return selectedColor;
      default:
        return null;
    }
  }

  void _setSelected(String type, String value) {
    setState(() {
      switch (type) {
        case 'RAM':
          selectedRAM = value;
          break;
        case 'ROM':
          selectedROM = value;
          break;
        case 'Color':
          selectedColor = value;
          break;
      }
    });
  }

  int _findSelectedVariantIndex(ProductDetailState state) {
    final variants = state.product.variants ?? [];

    for (int i = 0; i < variants.length; i++) {
      final v = variants[i];
      final matchRAM = selectedRAM == null || v.ram == selectedRAM;
      final matchROM = selectedROM == null || v.rom == selectedROM;
      final matchColor = selectedColor == null || v.color == selectedColor;

      if (matchRAM && matchROM && matchColor) {
        return i;
      }
    }

    return -1;
  }
}