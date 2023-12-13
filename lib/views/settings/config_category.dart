import 'package:flutter/material.dart';
import 'package:restaurant_admin/api/restaurant.dart';
import 'package:restaurant_admin/components/dialog.dart';
import 'package:restaurant_admin/provider/selected_printer_provider.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_admin/provider/restaurant_provider.dart';

import 'package:restaurant_admin/views/components/main_layout.dart';
import 'package:restaurant_admin/views/settings/printers/printers_list.dart';
import 'package:restaurant_admin/views/settings/printers/create_printer_page.dart';

import '../../components/dynamic_textfield.dart';

class ConfigCategory extends StatefulWidget {
  const ConfigCategory({super.key});

  @override
  State<ConfigCategory> createState() => _ConfigCategoryState();
}

class _ConfigCategoryState extends State<ConfigCategory> {
  // Printer? _selectedPrinter;
  List<TextEditingController>? _listController = [TextEditingController()];

  @override
  void initState() {
    super.initState();
    final restaurant = context.read<RestaurantProvider>();
    _listController = restaurant == null
        ? [TextEditingController()]
        : restaurant?.categories
            .map((e) => TextEditingController(text: e))
            .toList();
  }

  update(restaurant) {
    List<String> categoryList = _listController!
        .where((element) => element.text != "")
        .map((e) => e.text)
        .toList();

    updateRestaurant(restaurant!.id, restaurant!.name!, restaurant!.description,
            categoryList)
        .then((value) => showAlertDialog(context, "更新成功"));
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<RestaurantProvider>();

    return MainLayout(
      centerTitle: "品項分類設置",
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
                      update(restaurant);
                    },
                    child: const Text("更新"),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 150.0,
            width: double.infinity,
            child: DynamicTextField(listController: _listController),
          )
        ],
      ),
    );
  }
}
