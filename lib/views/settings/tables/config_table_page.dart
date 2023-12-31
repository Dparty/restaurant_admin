import 'package:flutter/material.dart';
import 'package:restaurant_admin/configs/constants.dart';

import 'package:restaurant_admin/api/restaurant.dart';
import 'package:restaurant_admin/views/settings/tables/table_info.dart';

import 'package:provider/provider.dart';
import 'package:restaurant_admin/provider/restaurant_provider.dart';
import 'package:restaurant_admin/provider/selected_table_provider.dart';
import 'package:restaurant_admin/views/components/main_layout.dart';

class ConfigTablePage extends StatefulWidget {
  final String restaurantId;
  const ConfigTablePage(this.restaurantId, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _ConfigTablePageState(restaurantId);
}

class _ConfigTablePageState extends State<ConfigTablePage> {
  final String restaurantId;
  List<String?> hasOrdersList = [];

  final events = [];
  bool canScroll = true;

  _ConfigTablePageState(this.restaurantId);

  @override
  void initState() {
    super.initState();
    getRestaurant(restaurantId).then((restaurant) {
      context.read<RestaurantProvider>().setRestaurant(
            restaurant.id,
            restaurant.name,
            restaurant.description,
            restaurant.items,
            restaurant.tables,
            restaurant.categories,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<RestaurantProvider>();

    return MainLayout(
      centerTitle: "選擇餐桌",
      center: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('餐廳名稱：${context.read<RestaurantProvider>().name}'),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: SizedBox(
                  height: 30,
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC88D67),
                      elevation: 0,
                    ),
                    onPressed: () {
                      context.read<SelectedTableProvider>().resetSelectTable();
                    },
                    child: const Text("新增餐桌"),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Wrap(
                  children: restaurant.tables
                      .map<Widget>((table) => Padding(
                            padding: const EdgeInsets.all(5),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      width: 1.0,
                                      color: context
                                                  .read<SelectedTableProvider>()
                                                  .selectedTable
                                                  ?.label ==
                                              table.label
                                          ? kPrimaryColor
                                          : kPrimaryLightColor,
                                    ),
                                    backgroundColor:
                                        hasOrdersList.contains(table.label)
                                            ? kPrimaryLightColor
                                            : Colors.white,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<SelectedTableProvider>()
                                        .selectTable(table);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            table.label,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24),
                                          ),
                                          // Center(
                                          //   child: Text(
                                          //       "(${table.x.toString()},${table.y.toString()})"),
                                          // )
                                        ],
                                      ),
                                    ),
                                  )),
                            ),
                          ))
                      .toList()),
            ),
          ),
        ],
      ),
      right: TableInfoView(
          table: context.watch<SelectedTableProvider>().selectedTable,
          reload: () => getRestaurant(restaurantId).then((restaurant) {
                context.read<RestaurantProvider>().setRestaurant(
                    restaurant.id,
                    restaurant.name,
                    restaurant.description,
                    restaurant.items,
                    restaurant.tables,
                    restaurant.categories);
                context.read<SelectedTableProvider>().resetSelectTable();
              })),
    );
  }
}
