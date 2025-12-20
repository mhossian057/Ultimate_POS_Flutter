import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../helpers/AppTheme.dart';
import '../../helpers/SizeConfig.dart';
import '../../helpers/otherHelpers.dart';

class ProductListWidget extends StatefulWidget {
  final String? name, image, symbol;
  final String? qtyAvailable;
  final double? price;
  final VoidCallback? onTap;

  const ProductListWidget({
    Key? key,
    required this.name,
    required this.image,
    required this.qtyAvailable,
    required this.price,
    required this.symbol,
    this.onTap,
  }) : super(key: key);

  @override
  _ProductListWidgetState createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: _buildCardDecoration(themeData),
        margin: EdgeInsets.symmetric(
            horizontal: MySize.size16!, vertical: MySize.size8!),
        padding: EdgeInsets.all(MySize.size12!),
        child: ListTile(
          leading: _buildProductImage(themeData),
          title: Text(widget.name!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.getTextStyle(themeData.textTheme.titleMedium,
                  fontWeight: 600, letterSpacing: 0.2)),
          trailing: _buildPriceAndStock(themeData),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration(ThemeData themeData) {
    return BoxDecoration(
      color: themeData.cardTheme.color,
      borderRadius: BorderRadius.all(Radius.circular(MySize.size16!)),
      boxShadow: [
        BoxShadow(
          color: themeData.cardTheme.shadowColor!.withAlpha(20),
          blurRadius: 8,
          spreadRadius: 1,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildProductImage(ThemeData themeData) {
    return Container(
      width: MySize.size60,
      height: MySize.size60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MySize.size16!),
        boxShadow: [
          BoxShadow(
            color: themeData.colorScheme.primary.withAlpha(20),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MySize.size16!),
        child: CachedNetworkImage(
            width: MySize.size60,
            height: MySize.size60,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
                Image.asset('assets/images/default_product.png'),
            placeholder: (context, url) =>
                Image.asset('assets/images/default_product.png'),
            imageUrl: widget.image ?? ''),
      ),
    );
  }

  Widget _buildPriceAndStock(ThemeData themeData) {
    return Container(
      width: MySize.size100,
      height: MySize.size56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _buildPriceTag(themeData),
          SizedBox(height: MySize.size2!),
          _buildStockBadge(themeData),
        ],
      ),
    );
  }

  Widget _buildPriceTag(ThemeData themeData) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MySize.size6!, vertical: MySize.size2!),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeData.colorScheme.primary.withOpacity(0.1),
              themeData.colorScheme.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(MySize.size6!),
        ),
        child: Text(
          widget.symbol! + Helper().formatCurrency(widget.price),
          style: AppTheme.getTextStyle(themeData.textTheme.bodySmall,
              fontWeight: 700,
              fontSize: 11,
              color: themeData.colorScheme.primary,
              letterSpacing: 0.1),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildStockBadge(ThemeData themeData) {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeData.colorScheme.secondary,
                themeData.colorScheme.secondary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(MySize.size8!))),
        padding: EdgeInsets.symmetric(
            horizontal: MySize.size6!, vertical: MySize.size2!),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              MdiIcons.stocking,
              color: themeData.colorScheme.onSecondary,
              size: MySize.size10,
            ),
            SizedBox(width: MySize.size2!),
            Flexible(
              child: (widget.qtyAvailable != '-')
                  ? Text(Helper().formatQuantity(widget.qtyAvailable),
                      style: AppTheme.getTextStyle(themeData.textTheme.bodySmall,
                          fontSize: 10,
                          color: themeData.colorScheme.onSecondary,
                          fontWeight: 600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1)
                  : Text('-',
                      style: TextStyle(
                          color: themeData.colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}