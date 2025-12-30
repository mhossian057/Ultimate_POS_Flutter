import 'package:flutter/material.dart';

import '../../../helpers/SizeConfig.dart';

class SalesListShimmer extends StatefulWidget {
  @override
  _SalesListShimmerState createState() => _SalesListShimmerState();
}

class _SalesListShimmerState extends State<SalesListShimmer>
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
          margin: EdgeInsets.only(bottom: MySize.size12!),
          padding: EdgeInsets.all(MySize.size16!),
          decoration: BoxDecoration(
            color: themeData.cardTheme.color,
            borderRadius: BorderRadius.circular(MySize.size12!),
            border: Border.all(
              color: themeData.dividerColor.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date shimmer
              _buildShimmerBox(height: 12, width: 150),
              SizedBox(height: MySize.size12!),
              
              // Status badge shimmer (positioned right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Invoice number
                  _buildShimmerBox(height: 16, width: 180),
                  // Status badge
                  _buildShimmerBox(height: 24, width: 60, borderRadius: 12),
                ],
              ),
              SizedBox(height: MySize.size12!),
              
              // Invoice amount container shimmer
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MySize.size12!,
                  vertical: MySize.size8!,
                ),
                decoration: BoxDecoration(
                  color: themeData.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(MySize.size8!),
                  border: Border.all(
                    color: themeData.colorScheme.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerBox(height: 14, width: 100),
                    _buildShimmerBox(height: 16, width: 80),
                  ],
                ),
              ),
              SizedBox(height: MySize.size8!),
              
              // Paid amount container shimmer
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MySize.size12!,
                  vertical: MySize.size8!,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(MySize.size8!),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerBox(height: 14, width: 90),
                    _buildShimmerBox(height: 16, width: 70),
                  ],
                ),
              ),
              SizedBox(height: MySize.size12!),
              
              // Customer and location info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(height: 12, width: 80),
                  SizedBox(width: MySize.size8!),
                  Expanded(child: _buildShimmerBox(height: 12, width: double.infinity)),
                ],
              ),
              SizedBox(height: MySize.size6!),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(height: 12, width: 80),
                  SizedBox(width: MySize.size8!),
                  Expanded(child: _buildShimmerBox(height: 12, width: double.infinity)),
                ],
              ),
              SizedBox(height: MySize.size12!),
              
              // Action buttons area
              Container(
                padding: EdgeInsets.only(top: MySize.size8!),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: themeData.dividerColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShimmerBox(height: 32, width: 80, borderRadius: 16),
                    _buildShimmerBox(height: 32, width: 80, borderRadius: 16),
                    _buildShimmerBox(height: 32, width: 80, borderRadius: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox({
    required double height,
    required double width,
    double? borderRadius,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(_animation.value * 0.3),
        borderRadius: BorderRadius.circular(borderRadius ?? (height / 2)),
      ),
    );
  }
}

class SalesShimmerList extends StatelessWidget {
  final int itemCount;

  const SalesShimmerList({Key? key, this.itemCount = 6}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: itemCount,
      itemBuilder: (context, index) => SalesListShimmer(),
    );
  }
}