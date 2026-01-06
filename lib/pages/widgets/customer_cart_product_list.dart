import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/AppTheme.dart';
import '../../helpers/SizeConfig.dart';
import '../../locale/MyLocalizations.dart';
import '../../models/sellDatabase.dart';
import '../../providers/previous_price_provider.dart';

class CustomerCartProductList extends StatefulWidget {
  final int? sellId;
  final int? locationId;
  final int customerId;

  const CustomerCartProductList({
    Key? key,
    required this.sellId,
    required this.locationId,
    required this.customerId,
  }) : super(key: key);

  @override
  _CustomerCartProductListState createState() => _CustomerCartProductListState();
}

class _CustomerCartProductListState extends State<CustomerCartProductList> {
  List cartItems = [];
  bool isLoading = true;
  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  @override
  void didUpdateWidget(CustomerCartProductList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload cart items when customer changes
    if (widget.customerId != oldWidget.customerId) {
      debugPrint('Customer changed from ${oldWidget.customerId} to ${widget.customerId}');
      _loadCartItems();
    }
  }

  void refreshCartItems() {
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    debugPrint('Loading cart items: sellId=${widget.sellId}, locationId=${widget.locationId}, customerId=${widget.customerId}');
    
    if (widget.locationId != null) {
      try {
        List items;
        
        if (widget.sellId != null) {
          // Load specific cart if sellId is provided
          items = await SellDatabase().getInCompleteLines(
            widget.locationId!,
            sellId: widget.sellId,
          );
        } else {
          // Load incomplete cart items for this location (no specific sellId)
          items = await SellDatabase().getInCompleteLines(widget.locationId!);
        }
        
        debugPrint('Loaded ${items.length} cart items');
        if (items.isNotEmpty) {
          debugPrint('First item data: ${items.first}');
        }
        
        if (mounted) {
          setState(() {
            cartItems = items;
            isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error loading cart items: $e');
        if (mounted) {
          setState(() {
            cartItems = [];
            isLoading = false;
          });
        }
      }
    } else {
      debugPrint('No locationId provided, cannot load cart items');
      if (mounted) {
        setState(() {
          cartItems = [];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customerId == 0) {
      return SizedBox.shrink();
    }

    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(MySize.size16!),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (cartItems.isEmpty) {
      return Container(
        padding: EdgeInsets.all(MySize.size16!),
        child: Text(
          AppLocalizations.of(context).translate('no_products_in_cart'),
          style: AppTheme.getTextStyle(
            themeData.textTheme.bodyMedium,
            color: themeData.textTheme.bodyMedium!.color!.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: cartItems.length,
      separatorBuilder: (context, index) => Container(
        height: MySize.size2!,
        color: themeData.dividerColor,
      ),
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return _buildProductItem(item);
      },
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    return ChangeNotifierProvider(
      create: (_) => PreviousPriceProvider(),
      child: Consumer<PreviousPriceProvider>(
        builder: (context, provider, child) {
          // Load previous price when widget is built (only once)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !provider.isLoading && !provider.hasPreviousPrice && provider.error == null) {
              provider.fetchPreviousPrice(
                variationId: item['variation_id'] ?? 0,
                customerId: widget.customerId,
                locationId: widget.locationId ?? 1,
              );
            }
          });

          return Container(
            color: customAppTheme.bgLayer1,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(MySize.size16!),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          item['name'] ?? 'Unknown Product',
                          style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyLarge,
                            fontWeight: 600,
                          ),
                        ),
                        
                        SizedBox(height: MySize.size8!),
                        
                        // Current Price (inc. VAT)
                        Text(
                          '${AppLocalizations.of(context).translate('current_price_inc_vat')}: ${(item['sell_price_inc_tax'] ?? item['unit_price'] ?? 0.0).toStringAsFixed(2)}',
                          style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyMedium,
                            fontWeight: 600,
                            color: themeData.primaryColor,
                          ),
                        ),
                        
                        SizedBox(height: MySize.size4!),
                        
                        // Previous Price (inc. VAT)
                        if (provider.isLoading)
                          Row(
                            children: [
                              Text(
                                '${AppLocalizations.of(context).translate('previous_price_inc_vat')}: ',
                                style: AppTheme.getTextStyle(themeData.textTheme.bodyMedium),
                              ),
                              SizedBox(
                                width: MySize.size12,
                                height: MySize.size12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(themeData.primaryColor),
                                ),
                              ),
                            ],
                          )
                        else if (provider.hasPreviousPrice)
                          Text(
                            '${AppLocalizations.of(context).translate('previous_price_inc_vat')}: ${(provider.unitPriceIncTax ?? 0.0).toStringAsFixed(2)}',
                            style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyMedium,
                              color: Colors.orange,
                              fontWeight: 500,
                            ),
                          )
                        else
                          Text(
                            '${AppLocalizations.of(context).translate('previous_price_inc_vat')}: ${AppLocalizations.of(context).translate('not_available')}',
                            style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyMedium,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Quantity display
                Container(
                  alignment: Alignment.centerRight,
                  width: MySize.screenWidth! * 0.25,
                  height: MySize.screenHeight! * 0.05,
                  child: Text(
                    "${AppLocalizations.of(context).translate('quantity')}: ${item['quantity']?.toString() ?? '0'}",
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyMedium),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}