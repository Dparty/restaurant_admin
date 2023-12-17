import 'package:flutter/material.dart';
import 'package:restaurant_admin/provider/selected_discount_provider.dart';
import 'package:restaurant_admin/views/restaurant_settings_page.dart';
import '../settings/order_management.dart';
import 'navbar_item.dart';
import '../../main.dart';
import '../../api/utils.dart';
import '../restaurant_page.dart';

// providers
import 'package:provider/provider.dart';
import 'package:restaurant_admin/provider/restaurant_provider.dart';
import 'package:restaurant_admin/provider/selected_table_provider.dart';
import 'package:restaurant_admin/provider/selected_printer_provider.dart';
import 'package:restaurant_admin/provider/selected_item_provider.dart';

enum Config { Item, Table, Printer, Discount, Category, Restaurant }

class NavBar extends StatelessWidget {
  NavBar(
      {Key? key, this.navIndex, this.onTap, this.showSettings, this.selected})
      : super(key: key);

  final int? navIndex;
  bool? showSettings = true;
  final Function? onTap;
  int? selected = 0;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 240,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 20, 12, 0),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              DrawerItem(
                name: '餐廳列表',
                icon: Icons.list,
                onPressed: () => onItemPressed(context, index: 6),
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(
                thickness: 1,
                height: 10,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 20,
              ),
              showSettings == true
                  ? Column(
                      children: [
                        DrawerItem(
                            selected: selected == Config.Item.index,
                            name: '品項設置',
                            icon: Icons.settings,
                            onPressed: () {
                              onItemPressed(context,
                                  index: Config.Item.index, onTap: onTap);
                            }),
                        const SizedBox(
                          height: 20,
                        ),
                        DrawerItem(
                            selected: selected == Config.Table.index,
                            name: '餐桌設置',
                            icon: Icons.restaurant,
                            onPressed: () => onItemPressed(context,
                                index: Config.Table.index, onTap: onTap)),
                        const SizedBox(
                          height: 20,
                        ),
                        DrawerItem(
                            selected: selected == Config.Printer.index,
                            name: '打印機設置',
                            icon: Icons.print,
                            onPressed: () => onItemPressed(context,
                                index: Config.Printer.index, onTap: onTap)),
                        const SizedBox(
                          height: 20,
                        ),
                        DrawerItem(
                            selected: selected == Config.Discount.index,
                            name: '折扣設置',
                            icon: Icons.discount,
                            onPressed: () => onItemPressed(context,
                                index: Config.Discount.index, onTap: onTap)),
                        const SizedBox(
                          height: 20,
                        ),
                        DrawerItem(
                            selected: selected == Config.Category.index,
                            name: '分類設置',
                            icon: Icons.category,
                            onPressed: () => onItemPressed(context,
                                index: Config.Category.index, onTap: onTap)),
                        const SizedBox(
                          height: 20,
                        ),
                        DrawerItem(
                            selected: selected == Config.Restaurant.index,
                            name: '餐廳設置',
                            icon: Icons.category,
                            onPressed: () => onItemPressed(context,
                                index: Config.Restaurant.index, onTap: onTap)),
                        const SizedBox(
                          height: 20,
                        ),
                        const Divider(
                          thickness: 1,
                          height: 10,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        DrawerItem(
                            name: '訂單管理',
                            icon: Icons.tab,
                            onPressed: () => onItemPressed(context, index: 8)),
                        const SizedBox(
                          height: 20,
                        ),
                        const Divider(
                          thickness: 1,
                          height: 10,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
              DrawerItem(
                  name: '登出',
                  icon: Icons.logout,
                  onPressed: () => onItemPressed(context, index: 7)),
            ],
          ),
        ),
      ),
    );
  }

  void onItemPressed(BuildContext context,
      {required int index, Function? onTap}) {
    final restaurant = context.read<RestaurantProvider>();
    if (onTap != null) {
      onTap(index);
    }
    context.read<SelectedTableProvider>().resetSelectTable();
    context.read<SelectedPrinterProvider>().resetSelectPrinter();
    context.read<SelectedDiscountProvider>().resetSelectDiscount();
    context.read<SelectedItemProvider>().resetSelectItem();

    switch (index) {
      case 8:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderManagement(restaurant.id)));

        break;
      case 6:
        Navigator.pop(context);
        context.read<RestaurantProvider>().resetRestaurant();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const RestaurantsPage()),
            (route) => false);

        break;
      case 7:
        Navigator.pop(context);
        (() {
          signout().then((_) {
            context.read<RestaurantProvider>().resetRestaurant();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          });
        })();

        break;
    }
  }
}
