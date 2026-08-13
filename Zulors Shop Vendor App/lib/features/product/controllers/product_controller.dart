
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/brand_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/category_model.dart';
import 'package:zulors_shop_vendor/features/product/controllers/category_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/enums/product_type_enum.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/srock_limit_model.dart';
import 'package:zulors_shop_vendor/features/product/domain/services/product_service_interface.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/top_selling_product_model.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';

class ProductController extends ChangeNotifier {
  final ProductServiceInterface productServiceInterface;
  ProductController({required this.productServiceInterface});

  bool _isLoading = false;
  List<int> _offsetList = [];
  int _offset = 1;
  bool _isPaginationLoading = false;
  bool get isLoading => _isLoading;
  int get offset => _offset;
  final List<bool> _isOn = [];
  List<bool> get isOn=>_isOn;
  bool get isPaginationLoading => _isPaginationLoading;

  List<Product>? _stockOutProductList;
  List<Product>? _mostPopularProductList;
  final List<Products> _topSellingProductList = [];
  List<Product> _posProductList = [];
  TopSellingProductModel? _topSellingProductModel;
  TopSellingProductModel? get topSellingProductModel => _topSellingProductModel;
  List<Product>? get mostPopularProductList => _mostPopularProductList;
  List<Products> get topSellingProductList => _topSellingProductList;
  List<Product>? get stockOutProductList => _stockOutProductList;
  List<Product> get posProductList => _posProductList;
  ProductModel? _posProductModel;
  ProductModel? get posProductModel => _posProductModel;
  int? _stockOutProductPageSize;
  int? get stockOutProductPageSize => _stockOutProductPageSize;
  int? _variantIndex;
  List<int>? _variationIndex;
  int? get variantIndex => _variantIndex;
  List<int>? get variationIndex => _variationIndex;
  int? _quantity = 0;
  int? get quantity => _quantity;

  int? _digitalVariationIndex = 0;
  int? get digitalVariationIndex => _digitalVariationIndex;

  int? _digitalVariationSubindex = 0;
  int? get digitalVariationSubindex => _digitalVariationSubindex;

  ProductModel? _sellerProductModel;
  ProductModel? get sellerProductModel => _sellerProductModel;

  StockLimitStatus? _stockLimitStatus;
  StockLimitStatus? get stockLimitStatus => _stockLimitStatus;

  bool _showCookies = true;
  bool get showCookies => _showCookies;


  ProductTypeEnum? _selectedProductType;
  ProductTypeEnum? get selectedProductType => _selectedProductType;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;




  double? _minPrice;
  double? get minPrice => _minPrice;
  double? _maxPrice;
  double? get maxPrice => _maxPrice;

  // double _initMaxPrice = AppConstants.filterMaxPriceRange;
  // double get getInitMaxPrice => _initMaxPrice;

  bool _brandSeeMore = false;
  bool get brandSeeMore => _brandSeeMore;
  bool _categorySeeMore = false;
  bool get categorySeeMore => _categorySeeMore;
  bool _authorSeeMore = false;
  bool get authorSeeMore => _authorSeeMore;

  bool _publishingHouseSeeMore = false;
  bool get publishingHouseSeeMore => _publishingHouseSeeMore;

  final Set<int> _selectedPublishingHouseIds = {};
  Set<int> get selectedPublishingHouseIds => _selectedPublishingHouseIds;

  final Set<int> _selectedAuthorIds = {};
  Set<int> get selectedAuthorIds => _selectedAuthorIds;

  final Set<int> _selectedBrandIds = {};
  Set<int> get selectedBrandIds => _selectedBrandIds;

  bool _isPriceRangeValid = true;
  bool get isPriceRangeValid => _isPriceRangeValid;

  double? _invalidMinPrice;
  double? get invalidMinPrice => _invalidMinPrice;
  double? _invalidMaxPrice;
  double? get invalidMaxPrice => _invalidMaxPrice;

  List<BrandModel>? _brandList;
  List<BrandModel>? get brandList => _brandList;

  int? _brandIndex;
  int? get brandIndex => _brandIndex;

  bool _isUpdateQuantity = true;
  bool get isUpdateQuantity => _isUpdateQuantity;



  void initData(Product product, int? minimumOrderQuantity, BuildContext context) {
    _variantIndex = 0;
    _quantity = 1;
    _variationIndex = [];
    for (int i= 0; i<= product.choiceOptions!.length; i++) {
      _variationIndex!.add(0);
    }
  }

  void setQuantity(int value, {bool isUpdate = true}) async {
    _quantity = value;

    if(isUpdate) {
      notifyListeners();
    }
  }

  void setCartVariantIndex(int? minimumOrderQuantity,int index, BuildContext context) {
    _variantIndex = index;
    _quantity = 1;
    _isUpdateQuantity = true;
    notifyListeners();
  }

  void setCartVariationIndex(int? minimumOrderQuantity, int index, int i, BuildContext context) {
    _variationIndex![index] = i;
    _quantity = 1;
    _isUpdateQuantity = true;
    notifyListeners();
  }


  Future <void> getSellerProductList(String sellerId, int offset, String languageCode,String search, {
    bool reload = true,
    String? productType,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? brandIds,
    List<int>? categoryIds,
    bool isUpdate = false,
    List<int>? publishingHouseIds,
    List<int>? authorIds,

  }) async {
    if(reload || offset == 1) {
      _sellerProductModel = null;

      if(isUpdate) {
        notifyListeners();

      }

    }
      ApiResponse apiResponse = await productServiceInterface.getSellerProductList(
        sellerId: sellerId,  offset: offset,
        languageCode: languageCode, search: search,
        brandIds: brandIds,
        categoryIds: categoryIds,
        startDate: startDate,
        endDate: endDate,
        minPrice: minPrice,
        maxPrice: minPrice == null ? null : maxPrice,
        productType: productType,
        authorIds: authorIds,
        publishingHouseIds: publishingHouseIds,
      );

      if(apiResponse.response?.statusCode == 200) {

        if(offset == 1){
          _sellerProductModel = ProductModel.fromJson(apiResponse.response?.data, fromGetProducts: true);

        }else{
          _sellerProductModel?.products?.addAll(ProductModel.fromJson(apiResponse.response?.data, fromGetProducts: true).products ?? []);
          _sellerProductModel?.offset = ProductModel.fromJson(apiResponse.response?.data).offset;
          _sellerProductModel?.totalSize = ProductModel.fromJson(apiResponse.response?.data).totalSize;
        }

      } else {
        ApiChecker.checkApi(apiResponse);

      }

      _isLoading = false;
      notifyListeners();

  }

  List<int?> _cartQuantity = [];
  List<int?> get cartQuantity => _cartQuantity;

  Future <void> getPosProductList(int offset, BuildContext context,List <String> id, {bool reload = true}) async {
    _isLoading = true;
      ApiResponse apiResponse = await productServiceInterface.getPosProductList(offset, id);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        if(offset == 1 ){
          _cartQuantity = [];
          _posProductModel = ProductModel.fromJson(apiResponse.response!.data);
        }else{
          _posProductModel!.totalSize =  ProductModel.fromJson(apiResponse.response!.data).totalSize;
          _posProductModel!.offset =  ProductModel.fromJson(apiResponse.response!.data).offset;
          _posProductModel!.products!.addAll(ProductModel.fromJson(apiResponse.response!.data).products!)  ;
        }
        for(int i = 0; i< _posProductModel!.products!.length; i++){
          _cartQuantity.add(0);
        }
        _isLoading = false;
      } else {
        _isLoading = false;
        ApiChecker.checkApi(apiResponse);
      }
      notifyListeners();

  }

  void setCartQuantity(int? quantity, int index){
    _cartQuantity[index] = quantity;
  }

  bool _showDialog = false;
  bool get showDialog=> _showDialog;

  void shoHideDialog(bool showDialog, {bool notify = true}){
    _showDialog = showDialog;
    if(notify){
      notifyListeners();
    }
  }

  Future <void> getSearchedPosProductList(BuildContext context, String search, List<String> ids, {bool filter = false}) async {
    if(!filter){
      shoHideDialog(true);
    }

      ApiResponse apiResponse = await productServiceInterface.getSearchedPosProductList(search, ids);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _posProductList = [];
        _posProductList.addAll(ProductModel.fromJson(apiResponse.response!.data).products!);

      } else {
        ApiChecker.checkApi(apiResponse);
      }
      notifyListeners();
  }

  Future<void> getStockOutProductList(int offset, String languageCode, {bool reload = false}) async {
    if(reload || offset == 1) {
      _offset = 1;
      _offsetList = [];
      _isLoading = true;
    }
    if(reload){
      _stockOutProductList = null;
      notifyListeners();
    }

    if(!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      ApiResponse apiResponse = await productServiceInterface.getStockLimitedProductList(offset,languageCode);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        if(_offset == 1) {
          _stockOutProductList = [];
        }
        _stockOutProductList!.addAll(ProductModel.fromJson(apiResponse.response!.data).products!);
        _stockOutProductPageSize = ProductModel.fromJson(apiResponse.response!.data).totalSize;
        _isLoading = false;
        _isPaginationLoading = false;
      } else {
        ApiChecker.checkApi(apiResponse);
      }
      notifyListeners();
    }else{
      if(_isLoading || _isPaginationLoading) {
        _isPaginationLoading = false;
        _isLoading = false;
      }
    }
  }

  Future<void> getMostPopularProductList(int offset, BuildContext context, String languageCode, {bool reload = false}) async {
    if(reload || offset == 1) {
      _offset = 1;
      _offsetList = [];
    }
    if(reload){
      _mostPopularProductList = null;
      notifyListeners();
    }
    if(!_offsetList.contains(offset)){
      _offsetList.add(offset);
      ApiResponse apiResponse = await productServiceInterface.getMostPopularProductList(offset,languageCode);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        if(reload || offset == 1){
          _mostPopularProductList = [];
        }
        _mostPopularProductList?.addAll(ProductModel.fromJson(apiResponse.response!.data).products!);
        // _stockOutProductPageSize = ProductModel.fromJson(apiResponse.response!.data).totalSize;
        _isLoading = false;
      } else {
        ApiChecker.checkApi(apiResponse);
      }
      notifyListeners();

    }else{
      if(_isLoading) {
        _isLoading = false;
      }
    }

  }

  Future<void> getTopSellingProductList(int offset, BuildContext context, String languageCode, {bool reload = false}) async {
    if(reload) {
      _topSellingProductModel = null;
      notifyListeners();
    }

      ApiResponse apiResponse = await productServiceInterface.getTopSellingProductList(offset,languageCode);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        if(offset == 1 ){
          _topSellingProductModel = TopSellingProductModel.fromJson(apiResponse.response!.data);
        }else{
          _topSellingProductModel!.totalSize =  TopSellingProductModel.fromJson(apiResponse.response!.data).totalSize;
          _topSellingProductModel!.offset =  TopSellingProductModel.fromJson(apiResponse.response!.data).offset;
          _topSellingProductModel!.products!.addAll(TopSellingProductModel.fromJson(apiResponse.response!.data).products!)  ;
        }
        _isLoading = false;
      } else {
        ApiChecker.checkApi(apiResponse);
      }
      notifyListeners();
  }

  Future<void> deleteProduct(BuildContext context, int? productID) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse response = await productServiceInterface.deleteProduct(productID);
    if(response.response!.statusCode == 200) {
      Navigator.pop(Get.context!);
      showCustomSnackBarWidget(getTranslated('product_deleted_successfully', Get.context!),Get.context!, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }


  void setOffset(int offset) {
    _offset = offset;
  }


  void showBottomLoader() {
    _isPaginationLoading = true;
    notifyListeners();
  }


  Future<void> getStockLimitStatus(BuildContext context) async {
    ApiResponse response = await productServiceInterface.getStockLimitStatus();
    if(response.response?.statusCode == 200) {
      _stockLimitStatus = StockLimitStatus.fromJson(response.response!.data);
    }else {
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }

  bool isShowCookies() {
    return productServiceInterface.isShowCookies();
  }


  Future<void> setShowCookies() {
    _showCookies = false;
    notifyListeners();
    return productServiceInterface.setIsShowCookies();
  }


  void setShowCookie(bool isShow,{bool notify = false}) {
    _showCookies = isShow;
    if(notify){
      notifyListeners();
    }
  }

  Future<void> removeCookies() {
    return productServiceInterface.removeShowCookies();
  }

  void setDigitalVariationIndex(int? minimumOrderQuantity, int index, int subIndex, BuildContext context) {
    _quantity = 1;
    _digitalVariationIndex = index;
    _digitalVariationSubindex = subIndex;
    _isUpdateQuantity = true;
    notifyListeners();
  }

  void initDigitalVariationIndex() {
    _digitalVariationIndex = 0;
    _digitalVariationSubindex = 0;
  }


  void emptySellerProduct() {
    _sellerProductModel = null;
  }


  void setSelectedProductType({ProductTypeEnum? type, bool isUpdate = true}){
    _selectedProductType = type;

    if(isUpdate){
      notifyListeners();
    }
  }


  Future <void> selectDate(DateTime? startDate, DateTime? endDate) async {
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
  }


  void setPriceRange(double? min, double? max, {bool isUpdate = true}){

    _minPrice = min;
    _maxPrice = max;

    setPriceRangeValidity(isValid: true, isUpdate: isUpdate);

    if(isUpdate){
      notifyListeners();
    }
  }


  void toggleBrandSeeMore(){
    _brandSeeMore = !_brandSeeMore;
    notifyListeners();
  }

  void toggleCategorySeeMore(){
    _categorySeeMore = !_categorySeeMore;
    notifyListeners();
  }

  void onToggleAuthorSeeMore(){
    _authorSeeMore = !_authorSeeMore;
    notifyListeners();
  }
  void onTogglePublishingHouseSeeMore(){
    _publishingHouseSeeMore = !_publishingHouseSeeMore;
    notifyListeners();
  }

  void initFilterData(BuildContext context){
    _selectedProductType = _sellerProductModel?.productType;
    final double systemMaxPrice = PriceConverter.convertAmount(Provider.of<SplashController>(context, listen: false).configModel?.productMaxPriceRange ?? 0, context);
    setPriceRange(_sellerProductModel?.minPrice, _sellerProductModel?.maxPrice ?? systemMaxPrice, isUpdate: false);

    // _initBrandCheck();
    _initCategoryCheck();

    _startDate = _sellerProductModel?.startDate;
    _endDate = _sellerProductModel?.endDate;

    onClearPublisherIds();
    _selectedPublishingHouseIds.addAll(_sellerProductModel?.publishHouseIds ?? {});

    onClearAuthorIds();
    _selectedAuthorIds.addAll(_sellerProductModel?.authorIds ?? {});

    onClearBrandIds();
    _selectedBrandIds.addAll(_sellerProductModel?.brandIds ?? {});


  }



  void _initCategoryCheck() {
    final categoryController = Provider.of<CategoryController>(Get.context!, listen: false);
    final List<CategoryModel> categoryList = categoryController.categoryList ?? [];
    final Set<int> categoryIds = Set<int>.from( _sellerProductModel?.categoryIds ?? []);

    // Uncheck all categories and check matching categories in a single loop
    for (var category in categoryList) {
      if (category.checked == true) category.toggleChecked(); // Ensure unchecked
      if (categoryIds.contains(category.id)) {
        category.toggleChecked(); // Check if ID matches
      }
    }
  }

  void onChangePublisherIds(int id, {bool isUpdate = true}){

    if(_selectedPublishingHouseIds.contains(id)){
      _selectedPublishingHouseIds.remove(id);

    }else {
      _selectedPublishingHouseIds.add(id);
    }

    if(isUpdate) {
      notifyListeners();
    }
  }

  void onChangeAuthorIds(int id, {bool isUpdate = true}){

    if(_selectedAuthorIds.contains(id)){
      _selectedAuthorIds.remove(id);

    }else {
      _selectedAuthorIds.add(id);
    }

    if(isUpdate) {
      notifyListeners();
    }
  }

  void onChangeBrandIds(int id, {bool isUpdate = true}){

    if(_selectedBrandIds.contains(id)){
      _selectedBrandIds.remove(id);

    }else {
      _selectedBrandIds.add(id);
    }

    if(isUpdate) {
      notifyListeners();
    }
  }

  void onClearAuthorIds()=> _selectedAuthorIds.clear();
  void onClearPublisherIds()=> _selectedPublishingHouseIds.clear();
  void onClearBrandIds()=> _selectedBrandIds.clear();


  void setPriceRangeValidity({double? minPrice, double? maxPrice, bool isValid = true, bool isUpdate = true}){

    if(!isValid){
      _invalidMaxPrice = maxPrice;
      _invalidMinPrice = minPrice;
    }

    _isPriceRangeValid = isValid;

    if(isUpdate){
      notifyListeners();
    }
  }

  ///Move to Add Product Directory
  Future<void> getBrandList(BuildContext context, String language) async {
    ApiResponse response = await productServiceInterface.getBrandList(language);
    if (response.response?.statusCode == 200) {
      _brandList = [];
      response.response!.data.forEach((brand) => _brandList!.add(BrandModel.fromJson(brand)));
    } else {
      ApiChecker.checkApi(response);
    }

    notifyListeners();
  }


  void setBrandIndex(int? index, bool notify) {
    _brandIndex = index;
    if(notify) {
      notifyListeners();
    }
  }


  void updateQuantity(bool value, {bool isUpdate = true}) {
    _isUpdateQuantity = value;
    if(isUpdate){
      notifyListeners();
    }
  }


  void setAiBrandIndex(int? brandId) {
    if(_brandList != null && _brandList!.isNotEmpty && brandId != null) {
      for(int i =0; i< _brandList!.length; i++) {
        if(brandList?[i].id == brandId) {
          _brandIndex = i+2;
        }
      }
    }
  }



}
