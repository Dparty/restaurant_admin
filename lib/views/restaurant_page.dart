import 'package:flutter/material.dart';
import 'package:restaurant_admin/configs/constants.dart';
import 'package:restaurant_admin/main.dart';
import 'package:restaurant_admin/models/restaurant.dart';
import 'package:restaurant_admin/views/restaurant_settings_page.dart';
import 'package:restaurant_admin/views/settings/create_restaurant_page.dart';

import '../api/restaurant.dart';
import '../api/utils.dart';

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key});

  @override
  State<StatefulWidget> createState() => _RestaurantState();
}

class _RestaurantState extends State<RestaurantsPage> {
  late List<Restaurant> restaurants;

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var restaurantList;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    listRestaurant().then((value) {
      setState(() {
        restaurantList = value;
      });
    });
  }

  createRestaurant() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CreateRestaurantPage();
    }));
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return restaurantList == null
        ? const SizedBox(
            height: 300.0,
            width: 300.0,
            child: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('餐廳列表'),
              actions: [
                IconButton(
                    onPressed: () {
                      signout().then((_) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()));
                      });
                    },
                    icon: const Icon(Icons.logout))
              ],
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: kPrimaryColor,
                onPressed: createRestaurant,
                child: const Icon(Icons.add)),
            body: Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 40),
              child: Wrap(
                spacing: 20.0,
                runSpacing: 4.0,
                children: [
                  ...restaurantList.data.map((e) => SizedBox(
                        width: 300,
                        height: 300,
                        child: RestaurantCard(
                          restaurant: e,
                          key: Key(e.id),
                          reload: loadData,
                        ),
                      ))
                ],
              ),
            )
            // gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            //     maxCrossAxisExtent: 700,
            //     childAspectRatio: 3 / 2,
            //     crossAxisSpacing: 20,
            //     mainAxisSpacing: 10),
            // itemCount: restaurantList.data.length,
            // itemBuilder: (context, index) => RestaurantCard(
            //       restaurant: restaurantList.data[index],
            //       key: Key(restaurantList.data[index].id),
            //       reload: loadData,
            //     ))

            );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final Function? reload;

  const RestaurantCard({super.key, required this.restaurant, this.reload});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RestaurantSettingsPage(
                      restaurantId: restaurant.id,
                      reload: reload,
                    )));
      },
      child: Card(
        color: Colors.white,
        elevation: 8.0,
        margin: const EdgeInsets.all(4.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Image.asset(
                "./assets/images/favicon.png",
                height: 144,
                width: 144,
                fit: BoxFit.contain,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey[800],
                          ),
                        ),
                        restaurant.description != ''
                            ? Text(
                                restaurant.description.length > 6
                                    ? '${restaurant.description.substring(0, 6)}...'
                                    : restaurant.description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ))
                            : const SizedBox.shrink(),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RestaurantSettingsPage(
                                        restaurantId: restaurant.id,
                                      )));
                        },
                        icon: const Icon(Icons.settings))
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: <Widget>[
                    //     IconButton(
                    //         onPressed: () async {
                    //           await Navigator.push(context,
                    //               MaterialPageRoute(builder: (context) {
                    //             return CreateRestaurantPage(
                    //                 restaurant: restaurant);
                    //           }));
                    //           reload!();
                    //         },
                    //         icon: const Icon(Icons.info_outline)),

                    //   ],
                    // ),
                  ],
                ),
              ),
              // Add a small space between the card and the next widget
            ],
          ),
        ),
      ),
    );
  }
}
