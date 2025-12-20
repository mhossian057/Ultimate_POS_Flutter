import 'package:flutter/material.dart';

import '../../helpers/AppTheme.dart';
import '../../helpers/SizeConfig.dart';
import '../../locale/MyLocalizations.dart';

class ProductFilterOptionsSection extends StatelessWidget {
  final ThemeData themeData;
  final bool inStock;
  final int categoryId;
  final int subCategoryId;
  final int brandId;
  final bool usePriceGroup;
  final List<DropdownMenuItem<int>> categoryMenuItems;
  final List<DropdownMenuItem<int>> subCategoryMenuItems;
  final List<DropdownMenuItem<int>> brandsMenuItems;
  final List<DropdownMenuItem<bool>> priceGroupMenuItems;
  final Function(bool?) onInStockChange;
  final Function(int?) onCategoryChange;
  final Function(int?) onSubCategoryChange;
  final Function(int?) onBrandChange;
  final Function(bool?) onPriceGroupChange;

  const ProductFilterOptionsSection({
    Key? key,
    required this.themeData,
    required this.inStock,
    required this.categoryId,
    required this.subCategoryId,
    required this.brandId,
    required this.usePriceGroup,
    required this.categoryMenuItems,
    required this.subCategoryMenuItems,
    required this.brandsMenuItems,
    required this.priceGroupMenuItems,
    required this.onInStockChange,
    required this.onCategoryChange,
    required this.onSubCategoryChange,
    required this.onBrandChange,
    required this.onPriceGroupChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildFilterHeader(context),
        _buildInStockFilter(context),
        Divider(),
        _buildCategoryFilter(context),
        _buildSubCategoryFilter(context),
        _buildBrandFilter(context),
        Divider(),
        _buildPriceGroupSection(context),
      ],
    );
  }

  Widget _buildFilterHeader(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        AppLocalizations.of(context).translate('filter'),
        style: AppTheme.getTextStyle(themeData.textTheme.titleMedium,
            fontWeight: 700, color: themeData.colorScheme.primary),
      ),
    );
  }

  Widget _buildInStockFilter(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: MySize.size16!, right: MySize.size16!),
        child: CheckboxListTile(
          title: Text(AppLocalizations.of(context).translate('in_stock')),
          controlAffinity: ListTileControlAffinity.leading,
          value: inStock,
          onChanged: onInStockChange,
        ));
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return _buildDropdownSection(
      context: context,
      label: 'categories',
      value: categoryId,
      items: categoryMenuItems,
      onChanged: onCategoryChange,
      showDivider: true,
    );
  }

  Widget _buildSubCategoryFilter(BuildContext context) {
    return _buildDropdownSection(
      context: context,
      label: 'sub_categories',
      value: subCategoryId,
      items: subCategoryMenuItems,
      onChanged: onSubCategoryChange,
      showDivider: true,
    );
  }

  Widget _buildBrandFilter(BuildContext context) {
    return _buildDropdownSection(
      context: context,
      label: 'brands',
      value: brandId,
      items: brandsMenuItems,
      onChanged: onBrandChange,
      showDivider: false,
    );
  }

  Widget _buildPriceGroupSection(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            AppLocalizations.of(context).translate('group_prices'),
            style: AppTheme.getTextStyle(themeData.textTheme.titleMedium,
                fontWeight: 700, color: themeData.colorScheme.primary),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
              left: MySize.size16!, right: MySize.size16!, top: 0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
                isExpanded: true,
                dropdownColor: themeData.colorScheme.surface,
                icon: Icon(Icons.arrow_drop_down),
                value: usePriceGroup,
                items: priceGroupMenuItems,
                onChanged: onPriceGroupChange),
          ),
        )
      ],
    );
  }

  Widget _buildDropdownSection({
    required BuildContext context,
    required String label,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required Function(int?) onChanged,
    required bool showDivider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(
              left: MySize.size16!,
              right: MySize.size16!,
              top: MySize.size16!),
          child: Text(
            AppLocalizations.of(context).translate(label),
            style: AppTheme.getTextStyle(themeData.textTheme.bodyLarge,
                fontWeight: 600, letterSpacing: 0),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
              left: MySize.size16!,
              right: MySize.size16!,
              top: MySize.size8!),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
                isExpanded: true,
                dropdownColor: themeData.colorScheme.surface,
                icon: Icon(Icons.arrow_drop_down),
                value: value,
                items: items,
                onChanged: onChanged),
          ),
        ),
        if (showDivider) Divider(),
      ],
    );
  }
}