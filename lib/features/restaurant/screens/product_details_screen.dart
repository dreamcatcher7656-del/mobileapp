import 'package:stackfood_multivendor_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor_restaurant/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor_restaurant/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor_restaurant/common/widgets/custom_card.dart';
import 'package:stackfood_multivendor_restaurant/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor_restaurant/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor_restaurant/common/widgets/custom_tool_tip_widget.dart';
import 'package:stackfood_multivendor_restaurant/common/widgets/rating_bar_widget.dart';
import 'package:stackfood_multivendor_restaurant/common/widgets/readmore_widget.dart';
import 'package:stackfood_multivendor_restaurant/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor_restaurant/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor_restaurant/features/restaurant/domain/models/review_model.dart';
import 'package:stackfood_multivendor_restaurant/features/restaurant/widgets/update_stock_bottom_sheet.dart';
import 'package:stackfood_multivendor_restaurant/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor_restaurant/features/restaurant/domain/models/product_model.dart';
import 'package:stackfood_multivendor_restaurant/helper/date_converter_helper.dart';
import 'package:stackfood_multivendor_restaurant/helper/price_converter_helper.dart';
import 'package:stackfood_multivendor_restaurant/helper/route_helper.dart';
import 'package:stackfood_multivendor_restaurant/util/dimensions.dart';
import 'package:stackfood_multivendor_restaurant/util/images.dart';
import 'package:stackfood_multivendor_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final bool? isCampaign;
  const ProductDetailsScreen({super.key, required this.product, this.isCampaign});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {

  bool haveSubscription = false;


  @override
  void initState() {
    super.initState();

    if(Get.find<ProfileController>().profileModel!.restaurants![0].restaurantModel == 'subscription'){
      haveSubscription = Get.find<ProfileController>().profileModel!.subscription!.review == 1;
    }else{
      haveSubscription = true;
    }

    Get.find<RestaurantController>().setAvailability(widget.product.status == 1);
    Get.find<RestaurantController>().setRecommended(widget.product.recommendedStatus == 1);

    if(Get.find<ProfileController>().profileModel!.restaurants![0].reviewsSection!) {
      Get.find<RestaurantController>().getProductReviewList(widget.product.id);
    }

  }

  @override
  Widget build(BuildContext context) {

    double? discount = (widget.product.restaurantDiscount == 0 || (widget.isCampaign ?? false)) ? widget.product.discount : widget.product.restaurantDiscount;
    String? discountType = (widget.product.restaurantDiscount == 0 || (widget.isCampaign ?? false)) ? widget.product.discountType : 'percent';

    return Scaffold(

      appBar: CustomAppBarWidget(title: 'food_details'.tr),

      body: SafeArea(
        child: GetBuilder<RestaurantController>(builder: (restController) {
          return Column(children: [

            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                CustomCard(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  isBorder: false,
                  borderRadius: 0,
                  child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Row(children: [

                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImageWidget(
                              image: '${widget.product.imageFullUrl}',
                              height: 80, width: 85, fit: BoxFit.cover,
                            ),
                          ),

                          Positioned(
                            right: 0, bottom: 0, left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(Dimensions.radiusDefault),
                                  bottomRight: Radius.circular(Dimensions.radiusDefault),
                                ),
                              ),
                              child: Text(
                                '${widget.product.discount} ${widget.product.discountType == 'percent' ? '% ${'off'.tr}' : Get.find<SplashController>().configModel!.currencySymbol}',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Row(children: [

                          Flexible(
                            child: Text(
                              widget.product.name ?? '',
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          CustomAssetImageWidget(
                            image: widget.product.veg == 0 ? Images.nonVegImage : Images.vegImage,
                            height: 11, width: 11,
                          ),

                        ]),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Row(children: [

                          Text('${'price'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),

                          Text(
                            PriceConverter.convertPrice(widget.product.price, discount: discount, discountType: discountType),
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor), textDirection: TextDirection.ltr,
                          ),
                          SizedBox(width: discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                          discount > 0 ? Text(
                            PriceConverter.convertPrice(widget.product.price), textDirection: TextDirection.ltr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor, decoration: TextDecoration.lineThrough, decorationColor: Theme.of(context).hintColor),
                          ) : const SizedBox(),

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                            height: 12, width: 1, color: Theme.of(context).disabledColor,
                          ),

                          Text(
                            '${'discount'.tr}: ${widget.product.discount} ${widget.product.discountType == 'percent' ? '%' : Get.find<SplashController>().configModel!.currencySymbol}',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                          ),

                        ]),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Icon(Icons.star_rounded, color: Theme.of(context).primaryColor, size: 16),
                          const SizedBox(width: 2),

                          Text(
                            widget.product.avgRating!.toStringAsFixed(1),
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w600),
                          ),

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                            height: 12, width: 1, color: Theme.of(context).disabledColor,
                          ),

                          Text(
                            '${widget.product.ratingCount ?? 0} ${'review'.tr}',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline, decorationColor: Theme.of(context).primaryColor,
                              height: 1.3, fontWeight: FontWeight.w600,
                            ),
                          ),

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                            height: 12, width: 1, color: Theme.of(context).disabledColor,
                          ),

                          Row(children: [
                            Text('${'stock'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),

                            Text(
                              widget.product.stockType == 'unlimited' ? 'unlimited'.tr : widget.product.itemStock! > 0 ? widget.product.itemStock.toString() : 'out_of_stock'.tr,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),
                          ]),

                        ]),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Row(children: [

                          Icon(Icons.access_time_filled, color: Theme.of(context).primaryColor, size: 16),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text(
                            '${DateConverter.convertStringTimeToTime(widget.product.availableTimeStarts!)} - ${DateConverter.convertStringTimeToTime(widget.product.availableTimeEnds!)}',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                          ),

                        ]),
                      ])),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    ReadMoreText(
                      widget.product.description ?? '',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                      trimMode: TrimMode.Line,
                      trimLines: 3,
                      colorClickableText: Colors.blue,
                      lessStyle: robotoRegular.copyWith(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue),
                      trimCollapsedText: 'see_more'.tr,
                      trimExpandedText: ' ${'see_less'.tr}',
                      moreStyle: robotoRegular.copyWith(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue),
                    ),

                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                CustomCard(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  isBorder: false,
                  borderRadius: 0,
                  child: Column(children: [
                    Row(children: [

                      Expanded(
                        child: Text('available'.tr, style: robotoBold.copyWith(fontWeight: FontWeight.w600)),
                      ),

                      FlutterSwitch(
                        width: 60, height: 30, valueFontSize: Dimensions.fontSizeExtraSmall,
                        activeColor: Theme.of(context).primaryColor,
                        value: restController.isAvailable, onToggle: (bool isActive) {
                        restController.toggleAvailable(widget.product.id);
                        },
                      ),

                    ]),

                    Divider(color: Theme.of(context).disabledColor, height: 40),

                    Row(children: [

                      Expanded(
                        child: Text('recommended'.tr, style: robotoBold.copyWith(fontWeight: FontWeight.w600)),
                      ),

                      FlutterSwitch(
                        width: 60, height: 30, valueFontSize: Dimensions.fontSizeExtraSmall,
                        activeColor: Theme.of(context).primaryColor,
                        value: restController.isRecommended, onToggle: (bool isActive) {
                        restController.toggleRecommendedProduct(widget.product.id);
                      },
                      ),

                    ]),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                (widget.product.variations != null && widget.product.variations!.isNotEmpty) ? Column(children: [
                  CustomCard(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    isBorder: false,
                    borderRadius: 0,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('variations'.tr, style: robotoBold.copyWith(fontWeight: FontWeight.w600)),

                        widget.product.stockType == 'unlimited' ? CustomToolTip(
                          message: 'your_main_stock_is_empty_variations_stock_will_not_work_if_the_main_stock_is_empty'.tr,
                          preferredDirection: AxisDirection.down,
                        ) : const SizedBox(),

                      ]),
                      const SizedBox(height:Dimensions.paddingSizeSmall),

                      ListView.builder(
                        itemCount: widget.product.variations!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                              ListView.builder(
                                itemCount: widget.product.variations![index].variationValues!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                //padding: const EdgeInsets.only(left: 20),
                                shrinkWrap: true,
                                itemBuilder: (context, i) {

                                  return Column(children: [

                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(
                                          '${widget.product.variations![index].name!} - ${widget.product.variations![index].variationValues![i].level}',
                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                        ),
                                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                        Text(PriceConverter.convertPrice(_convertStringToDouble(widget.product.variations![index].variationValues![i].optionPrice!)), textDirection: TextDirection.ltr,
                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                                        ),
                                      ]),

                                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

                                        Text(
                                          'stock'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: _convertStringToInt(widget.product.variations![index].variationValues![i].currentStock!)! > 0
                                          ? Theme.of(context).hintColor : widget.product.stockType == 'unlimited' ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).colorScheme.error)),
                                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                        Text(
                                          widget.product.stockType == 'unlimited' ? 'unlimited'.tr : _convertStringToInt(widget.product.variations![index].variationValues![i].currentStock!)! > 0
                                            ? widget.product.variations![index].variationValues![i].currentStock! : '00',
                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: _convertStringToInt(widget.product.variations![index].variationValues![i].currentStock!)! > 0
                                           ? Theme.of(context).textTheme.bodyLarge?.color : widget.product.stockType == 'unlimited' ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).colorScheme.error),
                                        ),

                                      ]),


                                    ]),

                                    i != widget.product.variations![index].variationValues!.length - 1 ? const Divider() : const SizedBox(),
                                  ]);
                                },
                              ),
                              index != widget.product.variations!.length - 1 ? const Divider() : const SizedBox(),
                            ]),
                          );
                        },
                      ),
                    ]),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ]) : const SizedBox(),

                widget.product.addOns!.isNotEmpty ? Column(children: [
                  CustomCard(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    isBorder: false,
                    borderRadius: 0,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('addons'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      ListView.builder(
                        itemCount: widget.product.addOns!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Row(children: [

                            Text('${widget.product.addOns![index].name!}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Text(
                              PriceConverter.convertPrice(widget.product.addOns![index].price), textDirection: TextDirection.ltr,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),

                          ]);
                        },
                      ),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ]) : const SizedBox(),

                widget.product.tags != null && widget.product.tags!.isNotEmpty ? Column(children: [
                  CustomCard(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    isBorder: false,
                    borderRadius: 0,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('tags'.tr, style: robotoBold.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      SizedBox(
                        height: 35,
                        child: ListView.builder(
                          itemCount: widget.product.tags!.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: index == widget.product.tags!.length-1 ? 0 : Dimensions.paddingSizeSmall),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(widget.product.tags?[index].tag ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                              ),
                            );
                          },
                        ),
                      ),

                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ]) : const SizedBox(),

                widget.product.nutrition != null && widget.product.nutrition!.isNotEmpty ? Column(children: [
                  CustomCard(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    isBorder: false,
                    borderRadius: 0,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('nutrition'.tr, style: robotoBold.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Text(
                        widget.product.nutrition!.join(', '),
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),

                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ]) : const SizedBox(),

                widget.product.allergies != null && widget.product.allergies!.isNotEmpty ? Column(children: [
                  CustomCard(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    isBorder: false,
                    borderRadius: 0,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('allergies'.tr, style: robotoBold.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Text(
                        widget.product.allergies!.join(', '),
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ]) : const SizedBox(),

                if(Get.find<SplashController>().configModel!.systemTaxType == 'product_wise')
                (widget.product.taxData != null && widget.product.taxData!.isNotEmpty) ? CustomCard(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  isBorder: false,
                  borderRadius: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('vat_tax'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      ListView.builder(
                        itemCount: widget.product.taxData!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Row(children: [

                            Text('${widget.product.taxData?[index].name}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Text(
                              '(${widget.product.taxData![index].taxRate} %)',
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),

                          ]);
                        },
                      ),
                    ],
                  ),
                ) : const SizedBox(),
                if(Get.find<SplashController>().configModel!.systemTaxType == 'product_wise')
                SizedBox(height: widget.product.taxData != null && widget.product.taxData!.isNotEmpty ? Dimensions.paddingSizeDefault : 0),

                Get.find<ProfileController>().profileModel!.restaurants![0].reviewsSection! ? CustomCard(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  isBorder: false,
                  borderRadius: 0,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Text('reviews'.tr, style: robotoBold.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    haveSubscription ? restController.productReviewList != null ? restController.productReviewList!.isNotEmpty ? SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: restController.productReviewList!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {

                          ReviewModel review = restController.productReviewList![index];

                          return Padding(
                            padding: EdgeInsets.only(right: index == restController.productReviewList!.length - 1 ? 0 : Dimensions.paddingSizeDefault),
                            child: Container(
                              width: context.width * 0.7,
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                Text(review.customerName ?? 'customer_not_found'.tr, style: robotoMedium),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                RatingBarWidget(rating: review.rating!.toDouble(), ratingCount: null),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Text(DateConverter.convertDateToDate(review.createdAt!), style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Text(
                                  review.comment ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7), fontSize: Dimensions.fontSizeSmall),
                                ),

                              ]),
                            ),
                          );
                        },
                      ),
                    ) : Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeLarge),
                      child: Center(child: Text('no_review_found'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall))),
                    ) : Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge, bottom: Dimensions.paddingSizeExtraLarge),
                      child: Center(child: SizedBox(width: context.width * 0.6, child: const LinearProgressIndicator())),
                    ) : Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeLarge),
                      child: Center(child: Text('not_available_subscription_for_reviews'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall))),
                    ),

                  ]),
                ) : const SizedBox(),

              ]),
            )),

            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
              ),
              child: Row(
                children: [

                  widget.product.stockType != 'unlimited' && ((widget.product.variations != null && widget.product.variations!.isNotEmpty)) ? Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(color: Theme.of(context).primaryColor),
                      ),
                      child: CustomButtonWidget(
                        transparent: true,
                        textColor: Theme.of(context).textTheme.bodyLarge?.color,
                        onPressed: () {
                          Get.bottomSheet(
                            UpdateStockBottomSheet(product: widget.product),
                          );
                        },
                        buttonText: 'update_stock'.tr,
                      ),
                    ),
                  ) : const SizedBox(),
                  SizedBox(width: widget.product.stockType != 'unlimited' && ((widget.product.variations != null && widget.product.variations!.isNotEmpty)) ? Dimensions.paddingSizeDefault : 0),

                  Expanded(
                    child: !restController.isLoading ? CustomButtonWidget(
                      onPressed: () {
                        if(Get.find<ProfileController>().profileModel!.restaurants![0].foodSection!) {
                          restController.getProductDetails(widget.product.id!).then((itemDetails) {
                            if(itemDetails != null){
                              Get.toNamed(RouteHelper.getAddProductRoute(itemDetails));
                            }
                          });
                        }else {
                          showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
                        }
                      },
                      buttonText: 'edit'.tr,
                    ) : const Center(child: CircularProgressIndicator()),
                  ),

                ],
              ),
            ),

          ]);
        }),
      ),
    );
  }

  double? _convertStringToDouble(String? price) {
    if (price == null) return null;
    try {
      return double.parse(price);
    } catch (e) {
      return null;
    }
  }

  int? _convertStringToInt(String? value) {
    if (value == null) return null;
    try {
      return int.parse(value);
    } catch (e) {
      return null;
    }
  }

}