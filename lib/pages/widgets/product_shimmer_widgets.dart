import 'package:flutter/material.dart';

import '../../helpers/SizeConfig.dart';

class ProductGridShimmer extends StatefulWidget {
  @override
  _ProductGridShimmerState createState() => _ProductGridShimmerState();
}

class _ProductGridShimmerState extends State<ProductGridShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: _buildCardDecoration(themeData),
          padding: EdgeInsets.all(MySize.size8!),
          margin: EdgeInsets.symmetric(vertical: MySize.size4!),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: _buildImageShimmer(),
              ),
              Expanded(
                flex: 2,
                child: _buildContentShimmer(),
              ),
            ],
          ),
        );
      },
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
      ],
    );
  }

  Widget _buildImageShimmer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(_animation.value * 0.3),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(MySize.size16!),
            topRight: Radius.circular(MySize.size16!)),
      ),
    );
  }

  Widget _buildContentShimmer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: MySize.size6!, vertical: MySize.size4!),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(_animation.value * 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(height: 4),
          Container(
            height: 10,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(_animation.value * 0.3),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 16,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(_animation.value * 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                height: 14,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(_animation.value * 0.3),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProductListShimmer extends StatefulWidget {
  @override
  _ProductListShimmerState createState() => _ProductListShimmerState();
}

class _ProductListShimmerState extends State<ProductListShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: _buildCardDecoration(themeData),
          margin: EdgeInsets.symmetric(
              horizontal: MySize.size16!, vertical: MySize.size8!),
          padding: EdgeInsets.all(MySize.size12!),
          child: ListTile(
            leading: _buildImageShimmer(),
            title: _buildTitleShimmer(),
            trailing: _buildTrailingShimmer(),
          ),
        );
      },
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

  Widget _buildImageShimmer() {
    return Container(
      width: MySize.size60,
      height: MySize.size60,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(_animation.value * 0.3),
        borderRadius: BorderRadius.circular(MySize.size16!),
      ),
    );
  }

  Widget _buildTitleShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 14,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(_animation.value * 0.3),
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        SizedBox(height: 4),
        Container(
          height: 12,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(_animation.value * 0.3),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingShimmer() {
    return Container(
      width: MySize.size100,
      height: MySize.size56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            height: 16,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(_animation.value * 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 4),
          Container(
            height: 14,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(_animation.value * 0.3),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ],
      ),
    );
  }
}