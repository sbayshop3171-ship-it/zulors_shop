import 'package:flutter/material.dart';
import 'package:zulors_shop/common/basewidget/api_retry_widget.dart';
import 'package:zulors_shop/common/basewidget/no_internet_screen_widget.dart';
import 'package:zulors_shop/common/basewidget/product_shimmer_widget.dart';
import 'package:zulors_shop/common/basewidget/product_widget.dart';
import 'package:zulors_shop/features/product/controllers/product_controller.dart';
import 'package:zulors_shop/helper/debounce_helper.dart';
import 'package:zulors_shop/helper/responsive_helper.dart';
import 'package:zulors_shop/utill/dimensions.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'
    show SliverMasonryGrid;
import 'package:provider/provider.dart';

class HomeProductListWidget extends StatelessWidget {
  final ScrollController? scrollController;
  const HomeProductListWidget({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
        builder: (context, productController, child) {
      final products = productController.selectedProductModel?.products ?? [];
      final totalSize = productController.selectedProductModel?.totalSize;
      final offset = productController.selectedProductModel?.offset;

      if (products.isEmpty &&
          (productController.selectedProductModel != null)) {
        if (productController.selectedProductError != null) {
          return SliverToBoxAdapter(
            child: ApiRetryWidget(
              message: productController.selectedProductError!,
              onRetry: () => productController.getSelectedProductModel(1),
              compact: true,
            ),
          );
        }
        return const SliverToBoxAdapter(
          child: NoInternetOrDataScreenWidget(isNoInternet: false),
        );
      }

      if (products.isEmpty) {
        if (productController.selectedProductError != null) {
          return SliverToBoxAdapter(
            child: ApiRetryWidget(
              message: productController.selectedProductError!,
              onRetry: () => productController.getSelectedProductModel(1),
            ),
          );
        }
        return const SliverToBoxAdapter(
          child: ProductShimmer(isHomePage: false, isEnabled: true),
        );
      }
      return SliverPaginatedMasonryGrid(
        scrollController: scrollController,
        onPaginate: (offset) {
          productController.getSelectedProductModel(offset ?? 1);
        },
        totalSize: totalSize,
        offset: offset,
        itemCount: products.length,
        crossAxisCount: ResponsiveHelper.isTab(context) ? 3 : 2,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        errorMessage: productController.selectedProductError,
        onRetry: productController.selectedProductError == null
            ? null
            : () =>
                productController.getSelectedProductModel((offset ?? 1) + 1),
        itemBuilder: (context, index) => ProductWidget(
          margin: 0,
          productModel: products[index],
        ),
      );
    });
  }
}

class SliverPaginatedMasonryGrid extends StatefulWidget {
  final Function(int? offset) onPaginate;
  final int? totalSize;
  final int? offset;
  final int? limit;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool enabledPagination;
  final ScrollController? scrollController;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const SliverPaginatedMasonryGrid({
    super.key,
    required this.onPaginate,
    required this.totalSize,
    required this.offset,
    required this.itemCount,
    required this.itemBuilder,
    this.limit = 10,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 4.0,
    this.crossAxisSpacing = 4.0,
    this.enabledPagination = true,
    this.scrollController,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<SliverPaginatedMasonryGrid> createState() =>
      _SliverPaginatedMasonryGridState();
}

class _SliverPaginatedMasonryGridState
    extends State<SliverPaginatedMasonryGrid> {
  int? _offset;
  late List<int?> _offsetList;
  bool _isLoading = false;
  final _debounce = DebounceHelper(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _offset = 1;
    _offsetList = [1];
    widget.scrollController?.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(covariant SliverPaginatedMasonryGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_scrollListener);
      widget.scrollController?.addListener(_scrollListener);
    }
  }

  void _scrollListener() {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;
    if (controller.position.pixels >=
            controller.position.maxScrollExtent - 300 &&
        widget.totalSize != null &&
        !_isLoading &&
        widget.enabledPagination) {
      _debounce.run(_paginate);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_scrollListener);
    _debounce.dispose();
    super.dispose();
  }

  Future<void> _paginate() async {
    final pageSize = (widget.totalSize! / widget.limit!).ceil();
    if (_offset! < pageSize && !_offsetList.contains(_offset! + 1)) {
      setState(() => _isLoading = true);
      await widget.onPaginate(_offset! + 1);
      if (mounted) {
        setState(() {
          _offset = _offset! + 1;
          _offsetList.add(_offset);
          _isLoading = false;
        });
      }
    } else if (_isLoading && mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offset != null) {
      _offset = widget.offset;
      _offsetList = [];
      for (int index = 1; index <= widget.offset!; index++) {
        _offsetList.add(index);
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSizeSmall,
        right: Dimensions.paddingSizeSmall,
        bottom: Dimensions.paddingSizeSmall,
      ),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverMasonryGrid.count(
            crossAxisCount: widget.crossAxisCount,
            mainAxisSpacing: widget.mainAxisSpacing,
            crossAxisSpacing: widget.crossAxisSpacing,
            childCount: widget.itemCount,
            itemBuilder: widget.itemBuilder,
          ),
          if (widget.errorMessage != null && widget.onRetry != null)
            SliverToBoxAdapter(
              child: ApiRetryWidget(
                message: widget.errorMessage!,
                onRetry: widget.onRetry!,
                compact: true,
              ),
            ),
          if (_isLoading ||
              (widget.totalSize != null &&
                  _offset! < (widget.totalSize! / widget.limit!).ceil() &&
                  !_offsetList.contains(_offset! + 1)))
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
