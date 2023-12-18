import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Order_History extends StatefulWidget {
  Order_History({Key? key});

  @override
  State<Order_History> createState() => _Order_HistoryState();
}

class _Order_HistoryState extends State<Order_History> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Text(
              'Order History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                // .where('userId', isEqualTo: user?.uid)
                // .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    // Display placeholder box when there are no orders
                    return Center(
                      child: SizedBox(
                        height: 400,
                        width: 300,
                        child: Column(
                          children: [
                            Image.asset('assets/box.png'),
                            Text('No orders yet...:(',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),)
                          ],
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var orderData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                        // Customize this part based on your order data structure
                        String orderId = orderData['orderId'];
                        String orderDate = orderData['timestamp'].toString();

                        // Fetch and display item names
                        List<Map<String, dynamic>> items =
                        List<Map<String, dynamic>>.from(orderData['items']);

                        String itemNames =
                        items.map((item) => item['itemName']).join(', ');

                        // Fetch and display product image URL
                        String itemId =
                        items.isNotEmpty ? items[0]['itemId'] : '';
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('products')
                              .doc(itemId)
                              .get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> productSnapshot) {
                            if (productSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ListTile(
                                title: Text('Order ID: $orderId'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Order Date: $orderDate'),
                                    Text('Items: $itemNames'),
                                  ],
                                ),
                              );
                            } else if (productSnapshot.hasError) {
                              return Text('Error: ${productSnapshot.error}');
                            } else if (!productSnapshot.hasData ||
                                !productSnapshot.data!.exists) {
                              return ListTile(
                                title: Text('Order ID: $orderId'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Order Date: $orderDate'),
                                    Text('Items: $itemNames'),
                                  ],
                                ),
                              );
                            } else {
                              var productData =
                              productSnapshot.data!.data() as Map<String, dynamic>;
                              // Ensure 'imageUrls' is initialized as an empty list
                              List<String> imageUrls =
                              List<String>.from(productData['image'] ?? []);

                              String productImageUrl =
                              imageUrls.isNotEmpty ? imageUrls[0] : '';

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    productImageUrl),
                                                fit: BoxFit.cover)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              itemNames,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 25),
                                            ),
                                            Text('Order Id : $orderId')
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
