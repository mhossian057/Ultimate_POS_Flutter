import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../helpers/AppTheme.dart';
import '../../helpers/SizeConfig.dart';
import '../../locale/MyLocalizations.dart';

class ProductFilterSortSection extends StatelessWidget {
  final ThemeData themeData;
  final int? byAlphabets;
  final int? byPrice;
  final Function(int?) onAlphabetSort;
  final Function(int?) onPriceSort;

  const ProductFilterSortSection({
    Key? key,
    required this.themeData,
    required this.byAlphabets,
    required this.byPrice,
    required this.onAlphabetSort,
    required this.onPriceSort,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        Row(
          children: [
            _buildAlphabetSortButton(context),
            _buildPriceSortButton(context),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MySize.size24!, bottom: MySize.size24!),
      alignment: Alignment.center,
      child: Text(
        AppLocalizations.of(context).translate('sort'),
        style: AppTheme.getTextStyle(themeData.textTheme.titleMedium,
            fontWeight: 700, color: themeData.colorScheme.primary),
      ),
    );
  }

  Widget _buildAlphabetSortButton(BuildContext context) {
    return InkWell(
      onTap: () {
        int? newValue;
        if (byAlphabets == null) {
          newValue = 0;
        } else if (byAlphabets == 0) {
          newValue = 1;
        } else {
          newValue = null;
        }
        onAlphabetSort(newValue);
      },
      child: Container(
        margin: EdgeInsets.only(left: MySize.size16!),
        decoration: _buildSortButtonDecoration(byAlphabets != null),
        padding: EdgeInsets.all(MySize.size12!),
        child: Row(
          children: [
            Text("A", style: _buildSortButtonTextStyle(byAlphabets != null)),
            Icon(
                (byAlphabets == 1)
                    ? MdiIcons.arrowLeftBold
                    : MdiIcons.arrowRightBold,
                color: (byAlphabets != null)
                    ? themeData.colorScheme.primary
                    : Colors.grey,
                size: 22),
            Text("Z", style: _buildSortButtonTextStyle(byAlphabets != null)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSortButton(BuildContext context) {
    return InkWell(
      onTap: () {
        int? newValue;
        if (byPrice == null) {
          newValue = 0;
        } else if (byPrice == 0) {
          newValue = 1;
        } else {
          newValue = null;
        }
        onPriceSort(newValue);
      },
      child: Container(
        margin: EdgeInsets.only(left: MySize.size16!),
        decoration: _buildSortButtonDecoration(byPrice != null),
        padding: EdgeInsets.all(MySize.size12!),
        child: Row(
          children: [
            Text(AppLocalizations.of(context).translate('price'),
                style: _buildSortButtonTextStyle(byPrice != null)),
            Icon(
                (byPrice == 1)
                    ? MdiIcons.arrowDownBold
                    : MdiIcons.arrowUpBold,
                color: (byPrice != null)
                    ? themeData.colorScheme.primary
                    : Colors.grey,
                size: 22),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildSortButtonDecoration(bool isActive) {
    return BoxDecoration(
      color: themeData.colorScheme.surface,
      borderRadius: BorderRadius.all(Radius.circular(MySize.size16!)),
      boxShadow: [
        BoxShadow(
          color: themeData.cardTheme.shadowColor!.withAlpha(48),
          blurRadius: isActive ? 5 : 0,
          offset: isActive ? Offset(3, 3) : Offset(0, 0),
        )
      ],
    );
  }

  TextStyle _buildSortButtonTextStyle(bool isActive) {
    return AppTheme.getTextStyle(themeData.textTheme.titleMedium,
        fontWeight: 700,
        color: isActive ? themeData.colorScheme.primary : Colors.grey);
  }
}