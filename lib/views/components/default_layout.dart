import 'package:flutter/material.dart';
import 'package:restaurant_admin/views/components/navbar.dart';

class DefaultLayout extends StatelessWidget {
  final Widget? left;
  final Widget center;
  final String centerTitle;
  final Widget? right;

  const DefaultLayout(
      {Key? key,
      this.left,
      required this.center,
      required this.centerTitle,
      this.right})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        left ??
            SizedBox(
              width: 200,
              child: NavBar(),
            ),
        Expanded(
            child: Scaffold(
          appBar: right != null
              ? AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  elevation: 0.0,
                  centerTitle: true,
                  title: Text(centerTitle,
                      style: const TextStyle(
                          fontSize: 20.0, color: Color(0xFF545D68))))
              : null,
          body: center,
        )),
        right != null
            ? SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const VerticalDivider(),
              )
            : const SizedBox(
                width: 0,
                height: 0,
              ),
        right != null
            ? SizedBox(width: 420, child: right)
            : const SizedBox(
                width: 0,
                height: 0,
              )
      ],
    );
  }
}
