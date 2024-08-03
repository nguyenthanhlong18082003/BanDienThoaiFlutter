import 'dart:io';
import 'package:app_api/app/config/const.dart';
import 'package:app_api/app/data/api.dart';
import 'package:app_api/app/data/sqlite.dart';
import 'package:app_api/app/model/cart.dart';
import 'package:app_api/app/model/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeBuilder extends StatefulWidget {
  const HomeBuilder({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeBuilder> createState() => _HomeBuilderState();
}

class _HomeBuilderState extends State<HomeBuilder> {
  final DatabaseHelper _databaseService = DatabaseHelper();

  Future<List<ProductModel>> _getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await APIRepository().getListAdmin(
      prefs.getString('token').toString(),
    );
  }

  Future<void> _onSave(ProductModel pro) async {
    _databaseService.insertProduct(Cart(
      productID: pro.id,
      name: pro.name,
      des: pro.description,
      price: pro.price,
      img: pro.imageUrl,
      count: 1,
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<String> sliders = [
      'https://mir-s3-cdn-cf.behance.net/project_modules/max_3840_webp/34b5bf180145769.6505ae7623131.jpg',
      'https://i.pinimg.com/736x/f0/f5/a6/f0f5a6cc6bff547d2c7d5cbcb00bea85.jpg',
      'https://mir-s3-cdn-cf.behance.net/project_modules/max_3840_webp/34b5bf180145769.6505ae7623131.jpg',
      'https://www.91-cdn.com/pricebaba-blogimages/wp-content/uploads/2019/07/OPPO-A9_2.jpg',
      // Thêm các đường dẫn hình ảnh khác vào đây
    ];
        final deviceSize = MediaQuery.of(context).size;

     return Scaffold(
      body: FutureBuilder<List<ProductModel>>(
        future: _getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  const SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    height: 260,
                    child: FlutterCarousel(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 2),
                        disableCenter: true,
                        viewportFraction: deviceSize.width > 800.0 ? 0.8 : 0.975,
                        height: 250, //thiết lập chiều cao cho mỗi mục
                        indicatorMargin: 12.0,
                        enableInfiniteScroll: true,
                        slideIndicator: const CircularSlideIndicator(),
                      ),
                      items: sliders.map((item) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 8.0, ),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                    15.0), // Set border radius here
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    20.0), // ClipRRect for rounded corners
                                child: Image.network(
                                  item,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Text("Sản phẩm",
                      style: TextStyle(color: mainColor, fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                   SizedBox(height: 10,
                  ),
                 SizedBox(
                    height: 720,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75, // Số cột trong lưới
                          crossAxisSpacing: 4, // Khoảng cách giữa các cột
                          mainAxisSpacing: 20.0, // Khoảng cách giữa các hàng
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final itemProduct = snapshot.data![index];
                          return itemGridView(itemProduct);
                        },
                      ),
                    ),
                  ),
                  
                ],
              ),
            );
          }
          return const Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  
  }

  Widget itemGridView(ProductModel productModel) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                 
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Image.network(
                  productModel.imageUrl ??
                      '', // Sử dụng URL hình ảnh từ productModel
                  height: 100,
                  errorBuilder: (context, error, stackTrace) =>
                    Image.asset(height: 100,"assets/images/img_1.jpg", fit: BoxFit.cover,)
                      //const Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                productModel.name != null
                    ? (productModel.name!.length > 20
                        ? '${productModel.name!.substring(0, 15)}...' // Hiển thị chỉ 20 ký tự đầu tiên của tên sản phẩm và dấu ba chấm
                        : productModel
                            .name) // Hiển thị toàn bộ tên sản phẩm nếu độ dài không vượt quá 20 ký tự
                    : '',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                NumberFormat('###,###.###₫').format(productModel.price),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  _onSave(
                      productModel); // Lưu sản phẩm vào giỏ hàng khi nhấn nút
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${productModel.name} đã thêm vào giỏ hàng.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor, // Màu nền của button
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(
                        15.0,
                      ), // Chỉ áp dụng border cho 2 góc dưới của button
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ), // Icon "Add"
                      SizedBox(width: 2),
                      Text(
                        'Thêm giỏ hàng',
                        style: TextStyle(color: Colors.white),
                      ), // Text "Add"
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 228, 117, 62),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: const Text(
                '15%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: FavoriteButton(), // Sử dụng FavoriteButton ở đây
          ),
        ],
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      },
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Color.fromARGB(255, 228, 117, 62) : Colors.grey,
      ),
    );
  }
}
