import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../helpers/AppTheme.dart';
import '../../helpers/SizeConfig.dart';
import '../../helpers/generators.dart';
import '../../helpers/otherHelpers.dart';

class ProductGridWidget extends StatefulWidget {
  final String? name, image, symbol;
  final String? qtyAvailable;
  final double? price;
  final VoidCallback? onTap;

  const ProductGridWidget({
    Key? key,
    required this.name,
    required this.image,
    required this.qtyAvailable,
    required this.price,
    required this.symbol,
    this.onTap,
  }) : super(key: key);

  @override
  _ProductGridWidgetState createState() => _ProductGridWidgetState();
}

class _ProductGridWidgetState extends State<ProductGridWidget> {
  @override
  Widget build(BuildContext context) {
    String key = Generator.randomString(10);
    ThemeData themeData = Theme.of(context);
    
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: _buildCardDecoration(themeData),
        padding: EdgeInsets.all(MySize.size8!),
        margin: EdgeInsets.symmetric(vertical: MySize.size4!),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: _buildProductImage(key),
            ),
            Expanded(
              flex: 2,
              child: _buildProductInfo(themeData),
            ),
          ],
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
          blurRadius: 12,
          spreadRadius: 2,
          offset: Offset(0, 6),
        ),
        BoxShadow(
          color: themeData.colorScheme.primary.withAlpha(8),
          blurRadius: 4,
          spreadRadius: 0,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildProductImage(String heroTag) {
    return Stack(
      children: <Widget>[
        Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(MySize.size16!),
                topRight: Radius.circular(MySize.size16!)),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.1),
                    Colors.grey.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: CachedNetworkImage(
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/images/default_product.png'),
                  placeholder: (context, url) =>
                      Image.asset('assets/images/default_product.png'),
                  imageUrl: widget.image ?? ''),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(ThemeData themeData) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: MySize.size6!, vertical: MySize.size4!),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: Text(widget.name!,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: AppTheme.getTextStyle(themeData.textTheme.bodyMedium,
                    fontWeight: 600, fontSize: 12, letterSpacing: 0.1)),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildPriceTag(themeData),
              SizedBox(width: MySize.size2!),
              _buildStockBadge(themeData),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTag(ThemeData themeData) {
    return Flexible(
      flex: 3,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MySize.size4!, vertical: MySize.size2!),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeData.colorScheme.primary.withOpacity(0.1),
              themeData.colorScheme.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(MySize.size4!),
        ),
        child: Text(
          widget.symbol! + Helper().formatCurrency(widget.price),
          style: AppTheme.getTextStyle(themeData.textTheme.bodySmall,
              fontWeight: 700,
              fontSize: 10,
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
      flex: 2,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeData.colorScheme.secondary,
                themeData.colorScheme.secondary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(MySize.size4!))),
        padding: EdgeInsets.symmetric(
            horizontal: MySize.size4!, vertical: MySize.size2!),
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
                          fontSize: 9,
                          color: themeData.colorScheme.onSecondary,
                          fontWeight: 600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1)
                  : Text('-',
                      style: TextStyle(
                          color: themeData.colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 9)),
            ),
          ],
        ),
      ),
    );
  }
}