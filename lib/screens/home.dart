
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_app/screens/grid_all_product.dart';
import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../screens/details.dart';
import '../model/categories_model.dart';
import '../utils/constants.dart';
import '../model/base_model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<BaseModel> mostPopularList = [];
  List<BaseModel> sliderProductList = [];

  late PageController _pageController;
  final int _currentIndex = 2;
  List<CategoriesModel> categories = [];
  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: _currentIndex, viewportFraction: 0.7);
    fetchCategoriesFromFirestore();
    fetchMostPopularFromFirestore();
    fetchSliderFromFirestore();
  }

  Future<void> fetchCategoriesFromFirestore() async {
    try {
      final CollectionReference collection =
          FirebaseFirestore.instance.collection('categories');
      QuerySnapshot querySnapshot = await collection.get();

      List<CategoriesModel> fetchedCategories = [];

      querySnapshot.docs.forEach((doc) {
        CategoriesModel model = CategoriesModel(
          imageUrl: doc['image'],
          title: doc['name'],
        );
        fetchedCategories.add(model);
      });

      setState(() {
        categories =
            fetchedCategories; // Update the categories list with fetched data
      });
    } catch (e) {
      print('Error fetching data from Firestore Category: $e');
    }
  }

  Future<void> fetchMostPopularFromFirestore() async {
    try {
      final CollectionReference collection =
          FirebaseFirestore.instance.collection('most_popular');
      QuerySnapshot querySnapshot = await collection.get();

      List<BaseModel> fetchedMostPopularList = [];

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

        fetchedMostPopularList.add(model);
      });

      setState(() {
        mostPopularList =
            fetchedMostPopularList; // Update the list with fetched data
      });

    } catch (e) {
      print('Error fetching data from Firestore MP: $e');

    }
  }

  Future<void> fetchSliderFromFirestore() async {
    try {
      final CollectionReference collection =
          FirebaseFirestore.instance.collection('slider');
      QuerySnapshot querySnapshot = await collection.get();

      List<BaseModel> fetchedSliderList = [];

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
        fetchedSliderList.add(model);
      });

      setState(() {
        sliderProductList =
            fetchedSliderList; // Update the list with fetched data
      });
    } catch (e) {
      print('Error fetching data from Firestore Slider: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top Text
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Online",
                          style: textTheme.headline1?.copyWith(
                            color: Colors.orange,
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                                text: " Book Store",
                                style: textTheme.headline1
                                    ?.copyWith(fontSize: 30)),
                          ],
                        ),
                      ),
                      RichText(
                        text: const TextSpan(
                          text: "Books are the mirrors of the soul !! ",
                          style: TextStyle(
                            color: Color.fromARGB(186, 0, 0, 0),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Categories
              FadeInUp(
                delay: const Duration(milliseconds: 450),
                child: Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: size.width,
                  height: size.height * 0.14,
                  child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (ctx, index) {
                        CategoriesModel current = categories[index];
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              grid_all_product(category: current.title,)));
                                },
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundImage:
                                      NetworkImage(current.imageUrl),
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.008,
                              ),
                              Text(
                                current.title,
                                style: textTheme.subtitle1,
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ),

              /// Body Slider
              FadeInUp(
                delay: const Duration(milliseconds: 550),
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: size.width,
                  height: size.height * 0.45,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: sliderProductList.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Details(
                                  data: sliderProductList[index],
                                  isCameFromMostPopularPart: false,
                                ),
                              ),
                            );
                          },
                          child:
                              card(sliderProductList[index], textTheme, size));
                    },
                  ),
                ),
              ),

              /// Most Popular Text
              FadeInUp(
                delay: const Duration(milliseconds: 650),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Most Popular", style: textTheme.headline3),
                      Text("See all", style: textTheme.headline4),
                    ],
                  ),
                ),
              ),

              /// Most Popular Content
              FadeInUp(
                delay: const Duration(milliseconds: 750),
                child: Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  width: size.width,
                  height: size.height * 0.44,
                  child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: mostPopularList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, childAspectRatio: 0.63),
                      itemBuilder: (context, index) {
                        BaseModel current = mostPopularList[index];
                        return GestureDetector(
                          onTap: (() => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  return Details(
                                    data: current,
                                    isCameFromMostPopularPart: true,
                                  );
                                }),
                              )),
                          child: Hero(
                            tag: current.imageUrl,
                            child: Column(
                              children: [
                                Container(
                                  width: size.width * 0.5,
                                  height: size.height * 0.3,
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
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    current.name,
                                    style: textTheme.headline2,
                                  ),
                                ),
                                RichText(
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
                                      )
                                    ])),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // /// Page View
  // Widget view(int index, TextTheme theme, Size size) {
  //   return AnimatedBuilder(
  //       animation: _pageController,
  //       builder: (context, child) {
  //         double value = 0.0;
  //         if (_pageController.position.haveDimensions) {
  //           value = index.toDouble() - (_pageController.page ?? 0);
  //           value = (value * 0.04).clamp(-1, 1);
  //         }
  //         return Transform.rotate(
  //           angle: 3.14 * value,
  //         );
  //       });
  // }

  /// Page view Cards
  Widget card(BaseModel data, TextTheme theme, Size size) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        children: [
          Hero(
            tag: data.id,
            child: Container(
              width: size.width * 0.6,
              height: size.height * 0.35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                image: DecorationImage(
                  image: NetworkImage(data.imageUrl[0]),
                  fit: BoxFit.cover,
                ),
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 4),
                      blurRadius: 4,
                      color: Color.fromARGB(61, 0, 0, 0))
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              data.name,
              style: theme.headline2,
            ),
          ),
          RichText(
            text: TextSpan(
              text: "₹ ",
              style: theme.subtitle2?.copyWith(
                color: primaryColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: data.price.toString(),
                  style: theme.subtitle2
                      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 25),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
