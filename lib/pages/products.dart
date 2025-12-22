import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../helpers/AppTheme.dart';
import '../helpers/SizeConfig.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../models/product_model.dart';
import '../models/sell.dart';
import '../models/system.dart';
import '../models/variations.dart';
import 'elements.dart';
import 'widgets/product_grid_widget.dart';
import 'widgets/product_list_widget.dart';
import 'widgets/product_shimmer_widgets.dart';
import 'widgets/products_filter_drawer.dart';
import 'widgets/product_variations_dialog.dart';

class Products extends StatefulWidget {
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List products = [];
  ThemeData themeData = AppTheme.getThemeFromThemeMode(1);
  
  // State flags
  bool changeLocation = false,
      changePriceGroup = false,
      canChangeLocation = true,
      canMakeSell = false,
      inStock = true,
      gridView = false,
      canAddSell = false,
      canViewProducts = false,
      usePriceGroup = true,
      isLoading = false,
      isInitialized = false,
      isLoadingPermissions = true;

  // IDs and counters
  int selectedLocationId = 0,
      categoryId = 0,
      subCategoryId = 0,
      brandId = 0,
      cartCount = 0,
      sellingPriceGroupId = 0,
      offset = 0;
  int? byAlphabets, byPrice;

  // Dropdown menu items
  List<DropdownMenuItem<int>> _categoryMenuItems = [],
      _subCategoryMenuItems = [],
      _brandsMenuItems = [];
  List<DropdownMenuItem<bool>> _priceGroupMenuItems = [];
  
  Map? argument;
  List<Map<String, dynamic>> locationListMap = [
    {'id': 0, 'name': 'set location', 'selling_price_group_id': 0}
  ];

  String symbol = '';
  final searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  ScrollController _scrollController = new ScrollController();

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    getPermission();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        productList();
      }
    });
    setLocationMap();
    categoryList();
    subCategoryList(categoryId);
    brandList();
    Helper().syncCallLogs();
  }

  @override
  Future<void> didChangeDependencies() async {
    if (isInitialized) return;
    
    argument = ModalRoute.of(context)!.settings.arguments as Map?;
    if (argument != null) {
      if (mounted) {
        setState(() {
          selectedLocationId = argument!['locationId'];
          canChangeLocation = false;
        });
      }
    } else {
      canChangeLocation = true;
    }
    await setInitDetails(selectedLocationId);
    super.didChangeDependencies();
  }

  //Set location & product
  setInitDetails(selectedLocationId) async {
    try {
      var activeSubscriptionDetails = await System().get('active-subscription');
      if (mounted) {
        setState(() {
          canMakeSell = activeSubscriptionDetails.length > 0;
        });
      }
      
      if (activeSubscriptionDetails.length == 0) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate('no_subscription_found'));
        return;
      }
      
      await Helper().getFormattedBusinessDetails().then((value) {
        symbol = value['symbol'] + ' ';
      });
      await setDefaultLocation(selectedLocationId);
      
      if (mounted) {
        setState(() {
          products = [];
          offset = 0;
        });
      }
      
      await productList();
    } catch (e) {
      print('Error in setInitDetails: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  //Fetch permission from database
  getPermission() async {
    bool directSellPermission = await Helper().getPermission("direct_sell.access");
    bool productViewPermission = await Helper().getPermission("product.view");
    
    if (mounted) {
      setState(() {
        canAddSell = directSellPermission;
        canViewProducts = productViewPermission;
        isLoadingPermissions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: themeData.colorScheme.surface,
        endDrawer: _filterDrawer(),
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: Visibility(
            visible: argument == null,
            child: posBottomBar('products', context)),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Text(AppLocalizations.of(context).translate('products'),
          style: AppTheme.getTextStyle(themeData.textTheme.headlineSmall,
              fontWeight: 600)),
      leading: null,
      actions: <Widget>[
        locations(),
        _buildCartButton(),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoadingPermissions) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return (canViewProducts)
        ? ListView(
            physics: ClampingScrollPhysics(),
            controller: _scrollController,
            padding: EdgeInsets.all(0),
            children: [
              Visibility(
                  visible: (selectedLocationId != 0),
                  child: filter(_scaffoldKey)),
              (selectedLocationId == 0) ? _buildLocationPrompt() : _productsList(),
            ],
          )
        : Center(
            child: Text(
              AppLocalizations.of(context).translate('unauthorised'),
              style: TextStyle(color: Colors.black),
            ),
          );
  }

  Widget _buildLocationPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on),
          Text(AppLocalizations.of(context).translate('please_set_a_location')),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
    return badges.Badge(
      badgeStyle: badges.BadgeStyle(
        badgeColor: themeData.colorScheme.error,
        shape: badges.BadgeShape.circle,
        borderRadius: BorderRadius.circular(MySize.size20!),
      ),
      position: badges.BadgePosition.topStart(start: 5.0, top: 5.0),
      badgeContent: FutureBuilder(
          future: (argument != null && argument!['sellId'] != null)
              ? getCartItemCount(sellId: argument!['sellId'])
              : getCartItemCount(isCompleted: 0),
          builder: (context, AsyncSnapshot<String> snapshot) {
            return Center(
              child: Text(snapshot.hasData ? '${snapshot.data}' : "0",
                  style: TextStyle(color: Colors.white)),
            );
          }),
      child: IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: _onCartPressed),
    );
  }

  void _onCartPressed() {
    if (argument != null) {
      Navigator.pushReplacementNamed(context, '/cart',
          arguments: Helper().argument(
              locId: argument!['locationId'], sellId: argument!['sellId']));
    } else {
      if (selectedLocationId != 0 && cartCount > 0) {
        Navigator.pushNamed(context, '/cart',
            arguments: Helper().argument(locId: selectedLocationId));
      }
      if (cartCount == 0) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate('no_items_added_to_cart'));
      }
    }
  }

  Widget _productsList() {
    if (isLoading && products.isEmpty) {
      return _buildShimmerSkeleton();
    }
    
    return (products.length == 0 && isInitialized)
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty),
                Text(AppLocalizations.of(context).translate('no_products_found')),
              ],
            ),
          )
        : Container(
            child: (gridView) ? _buildGridView() : _buildListView(),
          );
  }

  Widget _buildShimmerSkeleton() {
    return Container(
      child: (gridView) ? _buildGridShimmer() : _buildListShimmer(),
    );
  }

  Widget _buildGridShimmer() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(
          horizontal: MySize.size16!, vertical: MySize.size20!),
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: MySize.size16!,
        crossAxisSpacing: MySize.size12!,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) => ProductGridShimmer(),
    );
  }

  Widget _buildListShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: 8,
      itemBuilder: (context, index) => ProductListShimmer(),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(
          horizontal: MySize.size16!, vertical: MySize.size20!),
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: MySize.size16!,
        crossAxisSpacing: MySize.size12!,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) => ProductGridWidget(
        name: products[index]['product_name'] ?? 'Unknown Product',
        image: products[index]['product_image_url'],
        qtyAvailable: (products[index]['enable_stock'] != 0)
            ? products[index]['stock_available'].toString()
            : '-',
        price: double.parse(products[index]['unit_price'].toString()),
        symbol: symbol,
        onTap: () => onTapProduct(index),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) => ProductListWidget(
        name: products[index]['product_name'] ?? 'Unknown Product',
        image: products[index]['product_image_url'],
        qtyAvailable: (products[index]['enable_stock'] != 0)
            ? products[index]['stock_available'].toString()
            : '-',
        price: double.parse(products[index]['unit_price'].toString()),
        symbol: symbol,
        onTap: () => onTapProduct(index),
      ),
    );
  }

  Widget _filterDrawer() {
    return ProductsFilterDrawer(
      themeData: themeData,
      byAlphabets: byAlphabets,
      byPrice: byPrice,
      inStock: inStock,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
      brandId: brandId,
      usePriceGroup: usePriceGroup,
      categoryMenuItems: _categoryMenuItems,
      subCategoryMenuItems: _subCategoryMenuItems,
      brandsMenuItems: _brandsMenuItems,
      priceGroupMenuItems: _priceGroupMenuItems,
      onAlphabetSort: (value) {
        setState(() {
          byAlphabets = value;
        });
        products = [];
        offset = 0;
        productList();
      },
      onPriceSort: (value) {
        setState(() {
          byPrice = value;
        });
        products = [];
        offset = 0;
        productList();
      },
      onInStockChange: (value) {
        setState(() {
          inStock = value ?? true;
        });
        products = [];
        offset = 0;
        productList();
      },
      onCategoryChange: (value) {
        setState(() {
          subCategoryId = 0;
          categoryId = value!;
          subCategoryList(categoryId);
        });
        products = [];
        offset = 0;
        productList();
      },
      onSubCategoryChange: (value) {
        setState(() {
          subCategoryId = value!;
        });
        products = [];
        offset = 0;
        productList();
      },
      onBrandChange: (value) {
        setState(() {
          brandId = value!;
        });
        products = [];
        offset = 0;
        productList();
      },
      onPriceGroupChange: _showCartResetDialogForPriceGroup,
    );
  }

  //set selling Price Group Id
  findSellingPriceGroupId(locId) {
    if (usePriceGroup) {
      locationListMap.forEach((element) {
        if (element['id'] == selectedLocationId &&
            element['selling_price_group_id'] != null) {
          sellingPriceGroupId =
              int.parse(element['selling_price_group_id'].toString());
        } else if (element['id'] == selectedLocationId &&
            element['selling_price_group_id'] == null) {
          sellingPriceGroupId = 0;
        }
      });
    } else {
      sellingPriceGroupId = 0;
    }
  }

  //set product list
  productList() async {
    if (isLoading) return;
    
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      offset++;
      //check last sync, if difference is 30 minutes then sync again.
      String? lastSync = await System().getProductLastSync();
      final date2 = DateTime.now();
      if (lastSync == null ||
          (date2.difference(DateTime.parse(lastSync)).inMinutes > 30)) {
        if (await Helper().checkConnectivity()) {
          await Variations().refresh();
          await System().insertProductLastSyncDateTimeNow();
        }
      }

      findSellingPriceGroupId(selectedLocationId);
      List productData = await Variations().get(
          brandId: brandId,
          categoryId: categoryId,
          subCategoryId: subCategoryId,
          inStock: inStock,
          locationId: selectedLocationId,
          searchTerm: searchController.text,
          offset: offset,
          byAlphabets: byAlphabets,
          byPrice: byPrice);

      List newProducts = [];
      Set<String> seenProductIds = {};
      
      // Get currently displayed product IDs to avoid duplicates across pages
      products.forEach((existingProduct) {
        seenProductIds.add(existingProduct['product_id'].toString());
      });
      
      productData.forEach((product) {
        String productId = product['product_id'].toString();
        
        // Only add if we haven't seen this product_id before
        if (!seenProductIds.contains(productId)) {
          var price;
          if (product['selling_price_group'] != null) {
            jsonDecode(product['selling_price_group']).forEach((element) {
              if (element['key'] == sellingPriceGroupId) {
                price = double.parse(element['value'].toString());
              }
            });
          }
          newProducts.add(ProductModel().product(product, price));
          seenProductIds.add(productId); // Mark this product_id as seen
        }
      });

      if (mounted) {
        setState(() {
          products.addAll(newProducts);
          isLoading = false;
          isInitialized = true;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<String> getCartItemCount({isCompleted, sellId}) async {
    var counts =
        await Sell().cartItemCount(isCompleted: isCompleted, sellId: sellId);
    setState(() {
      cartCount = int.parse(counts);
    });
    return counts;
  }

  //onTap product - show variations dialog
  onTapProduct(int index) async {
    if (!canViewProducts) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('unauthorised'));
      return;
    }

    try {
      // Get all variations for this product
      final productId = int.parse(products[index]['product_id'].toString());
      final variations = await Variations().getByProductId(productId, selectedLocationId);
      
      if (variations.isEmpty) {
        // No variations found, add current product directly to cart (fallback to old behavior)
        await _addCurrentProductToCart(index);
        return;
      }

      // If only 1 variation (single product), add directly to cart
      if (variations.length == 1) {
        var price;
        if (variations[0]['selling_price_group'] != null && variations[0]['selling_price_group'].toString().isNotEmpty) {
          try {
            jsonDecode(variations[0]['selling_price_group']).forEach((element) {
              if (element['key'] == sellingPriceGroupId) {
                price = double.parse(element['value'].toString());
              }
            });
          } catch (e) {
            print('Error parsing selling_price_group: $e');
          }
        }
        // Use default price if no price group price found
        if (price == null) {
          try {
            price = double.parse(variations[0]['sell_price_inc_tax'].toString());
          } catch (e) {
            price = 0.0; // Safe fallback
          }
        }
        var singleVariation = ProductModel().product(variations[0], price);
        await _addSingleVariationToCart(singleVariation);
        return;
      }

      // Multiple variations found, show dialog
      List processedVariations = [];
      variations.forEach((variation) {
        var price;
        
        if (variation['selling_price_group'] != null && variation['selling_price_group'].toString().isNotEmpty) {
          try {
            jsonDecode(variation['selling_price_group']).forEach((element) {
              if (element['key'] == sellingPriceGroupId) {
                price = double.parse(element['value'].toString());
              }
            });
          } catch (e) {
            print('Error parsing selling_price_group: $e');
          }
        }
        // Use default price if no price group price found
        if (price == null) {
          try {
            price = double.parse(variation['sell_price_inc_tax'].toString());
          } catch (e) {
            price = 0.0; // Safe fallback
          }
        }
        processedVariations.add(ProductModel().product(variation, price));
      });

      // Show variations dialog
      showDialog(
        context: context,
        builder: (context) => ProductVariationsDialog(
          variations: processedVariations,
          symbol: symbol,
          productName: products[index]['product_name'] ?? 'Unknown Product',
          canAddSell: canAddSell,
          canMakeSell: canMakeSell,
          argument: argument,
        ),
      );
    } catch (e) {
      print('Error loading variations: $e');
      Fluttertoast.showToast(
          msg: 'Error loading product variations');
    }
  }

  // Helper method to add current product to cart (original behavior)
  Future<void> _addCurrentProductToCart(int index) async {
    if (!canAddSell) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('no_subscription_found'));
      return;
    }

    if (!canMakeSell) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('no_sells_permission'));
      return;
    }

    if (products[index]['enable_stock'] == 1 && products[index]['stock_available'] <= 0) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('out_of_stock'));
      return;
    }

    try {
      await Sell().addToCart(
          products[index], argument != null ? argument!['sellId'] : null);
      
      if (argument != null) {
        selectedLocationId = argument!['locationId'];
      }

      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('added_to_cart'));
    } catch (e) {
      print('Error adding to cart: $e');
      Fluttertoast.showToast(msg: 'Error adding to cart');
    }
  }

  // Helper method to add single variation to cart (when no actual variations)
  Future<void> _addSingleVariationToCart(Map variation) async {
    if (!canAddSell) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('no_subscription_found'));
      return;
    }

    if (!canMakeSell) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('no_sells_permission'));
      return;
    }

    if (variation['enable_stock'] == 1 && variation['stock_available'] <= 0) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('out_of_stock'));
      return;
    }

    try {
      await Sell().addToCart(
          variation, argument != null ? argument!['sellId'] : null);
      
      if (argument != null) {
        selectedLocationId = argument!['locationId'];
      }

      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('added_to_cart'));
    } catch (e) {
      print('Error adding to cart: $e');
      Fluttertoast.showToast(msg: 'Error adding to cart');
    }
  }

  categoryList() async {
    List categories = await System().getCategories();

    _categoryMenuItems.add(
      DropdownMenuItem(
        child: Text(AppLocalizations.of(context).translate('select_category')),
        value: 0,
      ),
    );

    for (var category in categories) {
      _categoryMenuItems.add(
        DropdownMenuItem(
          child: Text(category['name']),
          value: category['id'],
        ),
      );
    }
  }

  subCategoryList(parentId) async {
    List subCategories = await System().getSubCategories(parentId);
    _subCategoryMenuItems = [];
    _subCategoryMenuItems.add(
      DropdownMenuItem(
        child:
            Text(AppLocalizations.of(context).translate('select_sub_category')),
        value: 0,
      ),
    );
    subCategories.forEach((element) {
      _subCategoryMenuItems.add(
        DropdownMenuItem(
          child: Text(jsonDecode(element['value'])['name']),
          value: jsonDecode(element['value'])['id'],
        ),
      );
    });
  }

  brandList() async {
    List brands = await System().getBrands();

    _brandsMenuItems.add(
      DropdownMenuItem(
        child: Text(AppLocalizations.of(context).translate('select_brand')),
        value: 0,
      ),
    );

    for (var brand in brands) {
      _brandsMenuItems.add(
        DropdownMenuItem(
          child: Text(brand['name']),
          value: brand['id'],
        ),
      );
    }
  }

  setLocationMap() async {
    await System().get('location').then((value) async {
      value.forEach((element) {
        if (element['is_active'].toString() == '1') {
          setState(() {
            locationListMap.add({
              'id': element['id'],
              'name': element['name'],
              'selling_price_group_id': element['selling_price_group_id']
            });
          });
        }
      });
      await priceGroupList();
    });
  }

  priceGroupList() async {
    setState(() {
      _priceGroupMenuItems = [];
      _priceGroupMenuItems.add(
        DropdownMenuItem(
          child: Text(AppLocalizations.of(context)
              .translate('no_price_group_selected')),
          value: false,
        ),
      );

      locationListMap.forEach((element) {
        if (element['id'] == selectedLocationId &&
            element['selling_price_group_id'] != null) {
          _priceGroupMenuItems.add(
            DropdownMenuItem(
              child: Text(AppLocalizations.of(context)
                  .translate('default_price_group')),
              value: true,
            ),
          );
        }
      });
    });
  }

  setDefaultLocation(defaultLocation) {
    if (defaultLocation != 0) {
      if (mounted) {
        setState(() {
          selectedLocationId = defaultLocation;
        });
      }
    } else if (locationListMap.length == 2) {
      if (mounted) {
        setState(() {
          selectedLocationId = locationListMap[1]['id'] as int;
        });
      }
    }
  }

  Widget locations() {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
          dropdownColor: themeData.colorScheme.surface,
          icon: Icon(Icons.arrow_drop_down),
          value: selectedLocationId,
          items: locationListMap.map<DropdownMenuItem<int>>((Map value) {
            return DropdownMenuItem<int>(
                value: value['id'],
                child: SizedBox(
                  width: MySize.screenWidth! * 0.4,
                  child: Text('${value['name']}',
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 15)),
                ));
          }).toList(),
          onTap: () {
            if (locationListMap.length <= 2) {
              canChangeLocation = false;
            }
          },
          onChanged: (int? newValue) async {
            if (canChangeLocation) {
              if (selectedLocationId == newValue) {
                changeLocation = false;
              } else if (selectedLocationId != 0) {
                await _showCartResetDialogForLocation();
                await priceGroupList();
              } else {
                changeLocation = true;
                await priceGroupList();
              }
              setState(() {
                if (changeLocation) {
                  Sell().resetCart();
                  selectedLocationId = newValue!;
                  brandId = 0;
                  categoryId = 0;
                  searchController.clear();
                  inStock = true;
                  cartCount = 0;
                  products = [];
                  offset = 0;
                  productList();
                }
              });
            } else {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)
                      .translate('cannot_change_location'));
            }
          }),
    );
  }

  Widget filter(scaffoldKey) {
    return Container(
      margin: EdgeInsets.all(MySize.size16!),
      padding: EdgeInsets.symmetric(vertical: MySize.size8!),
      decoration: BoxDecoration(
        color: themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(MySize.size20!),
        boxShadow: [
          BoxShadow(
            color: themeData.cardTheme.shadowColor!.withAlpha(20),
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Form(
              key: _formKey,
              child: TextFormField(
                  style: AppTheme.getTextStyle(themeData.textTheme.titleMedium,
                      letterSpacing: 0, fontWeight: 500),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('search'),
                    hintStyle: AppTheme.getTextStyle(
                        themeData.textTheme.titleMedium,
                        letterSpacing: 0,
                        fontWeight: 400,
                        color: themeData.colorScheme.onSurface.withOpacity(0.6)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(MySize.size20!),
                        ),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(MySize.size20!),
                        ),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(MySize.size20!),
                        ),
                        borderSide: BorderSide(
                          color: themeData.colorScheme.primary,
                          width: 2,
                        )),
                    filled: true,
                    fillColor: themeData.colorScheme.surface,
                    prefixIcon: Container(
                      padding: EdgeInsets.all(MySize.size12!),
                      child: Icon(
                        MdiIcons.magnify,
                        size: MySize.size24,
                        color: themeData.colorScheme.primary,
                      ),
                    ),
                    isDense: false,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: MySize.size20!, vertical: MySize.size16!),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  controller: searchController,
                  onEditingComplete: () {
                    products = [];
                    offset = 0;
                    productList();
                  }),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(MySize.size20!),
              onTap: () async {
                var barcode = await Helper().barcodeScan();
                await getScannedProduct(barcode);
              },
              child: Container(
                margin: EdgeInsets.only(left: MySize.size12!),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeData.colorScheme.primary,
                      themeData.colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(MySize.size20!)),
                  boxShadow: [
                    BoxShadow(
                      color: themeData.colorScheme.primary.withAlpha(60),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                padding: EdgeInsets.all(MySize.size16!),
                child: Icon(
                  MdiIcons.barcode,
                  color: themeData.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(MySize.size20!),
              onTap: () {
                scaffoldKey.currentState.openEndDrawer();
              },
              child: Container(
                margin: EdgeInsets.only(left: MySize.size12!),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeData.colorScheme.secondary,
                      themeData.colorScheme.secondary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(MySize.size20!)),
                  boxShadow: [
                    BoxShadow(
                      color: themeData.colorScheme.secondary.withAlpha(60),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                padding: EdgeInsets.all(MySize.size16!),
                child: Icon(
                  MdiIcons.tune,
                  color: themeData.colorScheme.onSecondary,
                  size: 24,
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(MySize.size20!),
              onTap: () async {
                setState(() {
                  gridView = !gridView;
                });
              },
              child: Container(
                margin: EdgeInsets.only(left: MySize.size12!),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gridView 
                        ? [Colors.green, Colors.green.withOpacity(0.8)]
                        : [Colors.orange, Colors.orange.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(MySize.size20!)),
                  boxShadow: [
                    BoxShadow(
                      color: (gridView ? Colors.green : Colors.orange).withAlpha(60),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                padding: EdgeInsets.all(MySize.size16!),
                child: Icon(
                  (gridView) ? MdiIcons.viewList : MdiIcons.viewGrid,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getScannedProduct(String barcode) async {
    if (canMakeSell) {
      await Variations()
          .get(
              locationId: selectedLocationId,
              barcode: barcode,
              offset: 0,
              searchTerm: searchController.text)
          .then((value) async {
        if (canAddSell) {
          if (value.length > 0) {
            var price;
            var product;
            if (value[0]['selling_price_group'] != null) {
              jsonDecode(value[0]['selling_price_group']).forEach((element) {
                if (element['key'] == sellingPriceGroupId) {
                  price = element['value'];
                }
              });
            }
            setState(() {
              product = ProductModel().product(value[0], price);
            });
            if (product != null && product['stock_available'] > 0) {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context).translate('added_to_cart'));
              await Sell().addToCart(
                  product, argument != null ? argument!['sellId'] : null);
              if (argument != null) {
                selectedLocationId = argument!['locationId'];
              }
            } else {
              Fluttertoast.showToast(
                  msg:
                      "${AppLocalizations.of(context).translate("out_of_stock")}");
            }
          } else {
            Fluttertoast.showToast(
                msg:
                    "${AppLocalizations.of(context).translate("no_product_found")}");
          }
        } else {
          Fluttertoast.showToast(
              msg:
                  "${AppLocalizations.of(context).translate("no_sells_permission")}");
        }
      });
    } else {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('no_subscription_found'));
    }
  }

  Future<void> _showCartResetDialogForLocation() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(AppLocalizations.of(context).translate('change_location')),
          content: Text(AppLocalizations.of(context)
              .translate('all_items_in_cart_will_be_remove')),
          actions: [
            TextButton(
                onPressed: () {
                  changeLocation = false;
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context).translate('no'))),
            TextButton(
                onPressed: () {
                  changeLocation = true;
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context).translate('yes')))
          ],
        );
      },
    );
  }

  Future<void> _showCartResetDialogForPriceGroup(bool? value) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)
              .translate('change_selling_price_group')),
          content: Text(AppLocalizations.of(context)
              .translate('all_items_in_cart_will_be_remove')),
          actions: [
            TextButton(
                onPressed: () {
                  changePriceGroup = false;
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context).translate('no'))),
            TextButton(
                onPressed: () {
                  changePriceGroup = true;
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context).translate('yes')))
          ],
        );
      },
    );
    
    setState(() {
      usePriceGroup = value!;
      if (changePriceGroup) {
        Sell().resetCart();
        brandId = 0;
        categoryId = 0;
        searchController.clear();
        inStock = true;
        cartCount = 0;
        products = [];
        offset = 0;
        productList();
      }
    });
  }
}