import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../model/base_model.dart';
import '../utils/constants.dart';
import '../widget/add_to_cart.dart';
import 'cart.dart';
import 'details.dart';

class grid_all_product extends StatefulWidget {
  var category;

  grid_all_product({required this.category});
  @override
  State<grid_all_product> createState() => _grid_all_productState();
}

class _grid_all_productState extends State<grid_all_product> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<BaseModel>> fetchDataFromFirestore() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: widget.category.toLowerCase()) // Convert to lowercase for case-insensitive comparison
          .get();

      List<BaseModel> models = [];

      querySnapshot.docs.forEach((doc) {
        BaseModel model = BaseModel(
          id: doc['id'],
          imageUrl: doc['image'],
          name: doc['name'],
          price: double.parse(doc['price']),
          size: doc['size'],
          desc: doc['description'],
          value: 1,
        );

        models.add(model);
      });

      return models;
    } catch (e) {
      print('Error fetching data from Firestore: $e');
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(
                LineIcons.shoppingBag,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Cart(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<BaseModel>>(
        future: fetchDataFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Error state
            return Text('Error: ${snapshot.error}');
          } else {
            // Data loaded successfully
            List<BaseModel>? products = snapshot.data;

            return GridView.builder(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.63,
              ),
              itemCount: products?.length,
              itemBuilder: (context, index) {
                BaseModel current = products![index];
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            return Details(
                              data: current,
                              isCameFromMostPopularPart: false,
                            );
                          },
                        ),
                      );
                    },
                    child: Hero(
                      tag: current.id,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: size.height * 0.02,
                            left: size.width * 0.01,
                            right: size.width * 0.01,
                            child: Container(
                              width: size.width * 0.5,
                              height: size.height * 0.28,
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                image: DecorationImage(
                                  image: NetworkImage(current.imageUrl[0]),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(0, 4),
                                    blurRadius: 4,
                                    color: Color.fromARGB(61, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: size.height * 0.04,
                            child: Text(
                              current.name,
                              style: textTheme.headline2,
                            ),
                          ),
                          Positioned(
                            bottom: size.height * 0.01,
                            child: RichText(
                              text: TextSpan(
                                text: "₹ ",
                                style: textTheme.subtitle2?.copyWith(
                                  color: primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: current.price.toString(),
                                    style: textTheme.subtitle2?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: size.height * 0.01,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: primaryColor,
                              child: IconButton(
                                onPressed: () {
                                  AddToCart.addToCart(current, context);
                                },
                                icon: const Icon(
                                  LineIcons.addToShoppingCart,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
