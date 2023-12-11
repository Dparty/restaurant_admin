import 'package:flutter/material.dart';
import 'package:restaurant_admin/api/restaurant.dart';
import 'package:restaurant_admin/provider/selected_discount_provider.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_admin/provider/restaurant_provider.dart';

import 'package:restaurant_admin/views/components/main_layout.dart';
import 'package:restaurant_admin/views/settings/discount/discount_list.dart';
import 'package:restaurant_admin/views/settings/discount/create_discount_page.dart';

class ConfigDiscount extends StatefulWidget {
  final String restaurantId;
  const ConfigDiscount(this.restaurantId, {super.key});

  @override
  State<ConfigDiscount> createState() => _ConfigDiscountState();
}

class _ConfigDiscountState extends State<ConfigDiscount> {
  // Printer? _selectedPrinter;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<RestaurantProvider>();

    void setSelectedPrinter(discount) {
      context.read<SelectedDiscountProvider>().setDiscount(discount);
    }

    return MainLayout(
      centerTitle: "折扣設置",
      center: ListView(
        padding: const EdgeInsets.only(left: 20.0),
        children: <Widget>[
          const SizedBox(height: 15.0),
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
                      context
                          .read<SelectedDiscountProvider>()
                          .resetSelectDiscount();
                    },
                    child: const Text("新增折扣"),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 150.0,
            width: double.infinity,
            child: DiscountListView(
              discountList: restaurant.discount,
              reload: () =>
                  listDiscount(restaurant.id).then((list) => setState(() {
                        context
                            .read<RestaurantProvider>()
                            .setRestaurantDiscount(list.data);
                      })),
              onTap: setSelectedPrinter,
            ),
          )
        ],
      ),
      right: CreateDiscountPage(
        restaurant.id,
        reload: () => listDiscount(restaurant.id).then((list) => setState(() {
              context
                  .read<RestaurantProvider>()
                  .setRestaurantDiscount(list.data);
            })),
        automaticallyImplyLeading: false,
        // printer: context.watch<SelectedPrinterProvider>().selectedPrinter,
      ),
    );
  }
}
