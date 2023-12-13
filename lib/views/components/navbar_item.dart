import 'package:flutter/material.dart';
import 'package:restaurant_admin/configs/constants.dart';

class DrawerItem extends StatelessWidget {
  DrawerItem(
      {Key? key,
      this.selected,
      required this.name,
      required this.icon,
      required this.onPressed})
      : super(key: key);

  final String name;
  final IconData icon;
  final Function() onPressed;
  bool? selected = false;

  @override
  Widget build(BuildContext context) {
    return selected == true
        ? GestureDetector(
            onTap: onPressed,
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: kPrimaryColor,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 16,
                        color: kPrimaryColor), //, color: Colors.white
                  )
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: onPressed,
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    name,
                    style:
                        const TextStyle(fontSize: 16), //, color: Colors.white
                  )
                ],
              ),
            ),
          );
  }
}
