import 'package:advance_notification/advance_notification.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../data/app_data.dart';
import '../widget/reuseable_row_for_cart.dart';
import '../main_wrapper.dart';
import '../model/base_model.dart';
import '../utils/constants.dart';
import '../widget/reuseable_button.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  var _razorpay = Razorpay();
  String address = '';
  String pin = '';

  /// Calculate the Total Price
  double calculateTotalPrice() {
    double total = 0.0;
    if (itemsOnCart.isEmpty) {
      total = 0;
    } else {
      for (BaseModel data in itemsOnCart) {
        total = total + data.price * data.value;
      }
    }
    return total;
  }

  /// Calculate Shipping
  double calculateShipping() {
    double shipping = 0.0;
    if (itemsOnCart.isEmpty) {
      shipping = 0.0;
      return shipping;
    } else if (itemsOnCart.length <= 4) {
      shipping = 25.99;
      return shipping;
    } else {
      shipping = 88.99;
      return shipping;
    }
  }

  /// Calculate the Sub Total Price
  int calculateSubTotalPrice() {
    int subTotal = 0;
    if (itemsOnCart.isEmpty) {
      subTotal = 0;
    } else {
      for (BaseModel data in itemsOnCart) {
        subTotal = subTotal + data.price.round();
        subTotal = subTotal - 160;
      }
    }
    return subTotal < 0 ? 0 : subTotal;
  }

  /// delete function for cart
  void onDelete(BaseModel data) {
    setState(() {
      if (itemsOnCart.length == 1) {
        itemsOnCart.clear();
      } else {
        itemsOnCart.removeWhere((element) => element.id == data.id);
      }
    });
  }

  Future<void> order_success() async {
    final orderRef = FirebaseFirestore.instance.collection('orders');

    // Assuming 'users' is the collection where user information is stored
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email.toString())
        .get();

    if (userSnapshot.exists) {
      String orderId = DateTime.now().microsecondsSinceEpoch.toString();

      await orderRef.doc(orderId).set({
        'orderId': orderId,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'items': itemsOnCart.map((item) {
          return {
            'itemId': item.id,
            'itemName': item.name,
            'itemPrice': item.price,
            'itemQuantity': item.value,
          };
        }).toList(),
        'totalPrice': calculateTotalPrice(),

        // Add user information
        'userName': userSnapshot['name'],
        'userEmail': userSnapshot['email'],
        'userContact': userSnapshot['contact'],

        'shippingAddress': address,
        'pincode': pin,
      });
    } else {
      print('User data not found');
      // Handle the case where user data is not found
    }
  }

  @override
  void initState() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    AdvanceSnackBar(message: "Order Placed Successfully");
    order_success();
    Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("Fail");
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Failed')));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Failed ext')));

    print("External wallet");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear(); // Removes all listeners
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            SizedBox(
              width: size.width,
              height: size.height * 0.6,
              child: itemsOnCart.isEmpty

                  /// List is Empty:
                  ? Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: const Image(
                            image: AssetImage("assets/images/empty.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        FadeInUp(
                          delay: const Duration(milliseconds: 250),
                          child: const Text(
                            "Your cart is empty right now :(",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
                          ),
                        ),
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MainWrapper()));
                            },
                            icon: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )

                  /// List is Not Empty:
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: itemsOnCart.length,
                      itemBuilder: (context, index) {
                        var current = itemsOnCart[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: 100 * index + 80),
                          child: Container(
                            margin: const EdgeInsets.all(5.0),
                            width: size.width,
                            height: size.height * 0.25,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        offset: Offset(0, 4),
                                        blurRadius: 4,
                                        color: Color.fromARGB(61, 0, 0, 0),
                                      )
                                    ],
                                    color: Colors.pink,
                                    image: DecorationImage(
                                        image:
                                            NetworkImage(current.imageUrl[0]),
                                        fit: BoxFit.cover),
                                  ),
                                  width: size.width * 0.4,
                                ),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: size.width * 0.52,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              current.name,
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  onDelete(current);
                                                },
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.grey,
                                                ))
                                          ],
                                        ),
                                      ),
                                      RichText(
                                          text: TextSpan(
                                              text: "₹ ",
                                              style:
                                                  textTheme.subtitle2?.copyWith(
                                                fontSize: 22,
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              children: [
                                            TextSpan(
                                              text: current.price.toString(),
                                              style:
                                                  textTheme.subtitle2?.copyWith(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                          ])),
                                      SizedBox(
                                        height: size.height * 0.04,
                                      ),
                                      Text(
                                        "Size = ${sizes[3]}",
                                        style: textTheme.subtitle2?.copyWith(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: size.height * 0.058,
                                        ),
                                        width: size.width * 0.4,
                                        height: size.height * 0.04,
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.all(4.0),
                                              width: size.width * 0.065,
                                              height: size.height * 0.045,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                onTap: () {
                                                  setState(() {
                                                    if (current.value > 1) {
                                                      current.value--;
                                                    } else {
                                                      onDelete(current);
                                                      current.value = 1;
                                                    }
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.remove,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      size.width * 0.02),
                                              child: Text(
                                                current.value.toString(),
                                                style: textTheme.subtitle2
                                                    ?.copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.all(4.0),
                                              width: size.width * 0.065,
                                              height: size.height * 0.045,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                onTap: () {
                                                  setState(() {
                                                    current.value >= 0
                                                        ? current.value++
                                                        : null;
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.add,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
            ),

            /// Bottom Card
            Positioned(
              bottom: 0,
              child: Container(
                width: size.width,
                height: size.height * 0.36,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 12.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: ReuseableRowForCart(
                          price: calculateSubTotalPrice().toDouble(),
                          text: 'Sub Total',
                        ),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 450),
                        child: ReuseableRowForCart(
                          price: calculateShipping(),
                          text: 'Shipping',
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: ReuseableRowForCart(
                          price: calculateTotalPrice(),
                          text: 'Total',
                        ),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 550),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: ReuseableButton(
                              text: "Checkout",
                              onTap: _showDeliveryDetailsAlertDialog),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "My Cart",
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            LineIcons.user,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  void _showDeliveryDetailsAlertDialog() async {
    final street = TextEditingController();
    final city = TextEditingController();
    final state = TextEditingController();
    final pincode = TextEditingController();

    final user = FirebaseAuth.instance.currentUser;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email.toString())
        .get();
    if (userSnapshot.exists) {
      String userName = userSnapshot['name'];
      String userEmail = userSnapshot['email'];
      String userContact = userSnapshot['contact'];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Delivery Details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: street,
                      decoration: InputDecoration(labelText: 'Street'),
                    ),
                    TextField(
                      controller: city,
                      decoration: InputDecoration(labelText: 'City'),
                    ),
                    TextField(
                      controller: state,
                      decoration: InputDecoration(labelText: 'State'),
                    ),
                    TextField(
                      controller: pincode,
                      decoration: InputDecoration(labelText: 'Pincode'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ReuseableButton(
                        text: 'Place Order',
                        onTap: () {
                          // Access the detailed address components here
                          String detailedAddress =
                              '${street.text}, ${city.text}, ${state.text}, ${pincode.text}';
                          setState(() {
                            address = detailedAddress;
                            pin = pincode.text.toString();
                          });
                          _initiateRazorpay(userName, userContact, userEmail,
                              detailedAddress);
                          Navigator.of(context).pop();
                        })
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

// Call this function when the "Checkout" button is tapped
  void _initiateRazorpay(
      String name, String contact, String email, String address) {
    var options = {
      'key': 'rzp_test_z1TsX4PqgKTv73',
      'amount':
          calculateTotalPrice() * 100, //in the smallest currency sub-unit.
      'name': name,
      'description': 'Delivery for $address',
      'timeout': 300, // in seconds
      'prefill': {'contact': contact, 'email': email}
    };
    _razorpay.open(options);
  }
}
