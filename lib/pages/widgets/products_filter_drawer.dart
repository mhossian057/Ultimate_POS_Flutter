import 'package:flutter/material.dart';

import '../../helpers/SizeConfig.dart';
import 'product_filter_sort_section.dart';
import 'product_filter_options_section.dart';

class ProductsFilterDrawer extends StatelessWidget {
  final ThemeData themeData;
  final int? byAlphabets;
  final int? byPrice;
  final bool inStock;
  final int categoryId;
  final int subCategoryId;
  final int brandId;
  final bool usePriceGroup;
  final List<DropdownMenuItem<int>> categoryMenuItems;
  final List<DropdownMenuItem<int>> subCategoryMenuItems;
  final List<DropdownMenuItem<int>> brandsMenuItems;
  final List<DropdownMenuItem<bool>> priceGroupMenuItems;
  final Function(int?) onAlphabetSort;
  final Function(int?) onPriceSort;
  final Function(bool?) onInStockChange;
  final Function(int?) onCategoryChange;
  final Function(int?) onSubCategoryChange;
  final Function(int?) onBrandChange;
  final Function(bool?) onPriceGroupChange;

  const ProductsFilterDrawer({
    Key? key,
    required this.themeData,
    required this.byAlphabets,
    required this.byPrice,
    required this.inStock,
    required this.categoryId,
    required this.subCategoryId,
    required this.brandId,
    required this.usePriceGroup,
    required this.categoryMenuItems,
    required this.subCategoryMenuItems,
    required this.brandsMenuItems,
    required this.priceGroupMenuItems,
    required this.onAlphabetSort,
    required this.onPriceSort,
    required this.onInStockChange,
    required this.onCategoryChange,
    required this.onSubCategoryChange,
    required this.onBrandChange,
    required this.onPriceGroupChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: EdgeInsets.only(bottom: MySize.size14!),
      color: themeData.colorScheme.surface,
      child: Container(
        decoration: _buildGradientDecoration(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ProductFilterSortSection(
                themeData: themeData,
                byAlphabets: byAlphabets,
                byPrice: byPrice,
                onAlphabetSort: onAlphabetSort,
                onPriceSort: onPriceSort,
              ),
              ProductFilterOptionsSection(
                themeData: themeData,
                inStock: inStock,
                categoryId: categoryId,
                subCategoryId: subCategoryId,
                brandId: brandId,
                usePriceGroup: usePriceGroup,
                categoryMenuItems: categoryMenuItems,
                subCategoryMenuItems: subCategoryMenuItems,
                brandsMenuItems: brandsMenuItems,
                priceGroupMenuItems: priceGroupMenuItems,
                onInStockChange: onInStockChange,
                onCategoryChange: onCategoryChange,
                onSubCategoryChange: onSubCategoryChange,
                onBrandChange: onBrandChange,
                onPriceGroupChange: onPriceGroupChange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          themeData.colorScheme.surface,
          themeData.colorScheme.surface.withOpacity(0.95),
        ],
      ),
    );
  }
}