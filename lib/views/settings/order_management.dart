import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:restaurant_admin/api/bill.dart';
import 'package:restaurant_admin/configs/constants.dart';
import 'package:restaurant_admin/views/components/main_layout.dart';

import 'package:provider/provider.dart';
import 'package:restaurant_admin/provider/restaurant_provider.dart';
import 'package:restaurant_admin/provider/selected_table_provider.dart';

import '../../../api/restaurant.dart';
import '../../../api/utils.dart';
import '../../../models/bill.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../components/showbill.dart';

// import '../../provider/socket_util.dart';

class OrderManagement extends StatefulWidget {
  final String restaurantId;
  const OrderManagement(this.restaurantId, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _OrderManagementState(restaurantId);
}

class _OrderManagementState extends State<OrderManagement> {
  final String restaurantId;
  Timer? _timeDilationTimer;

  List<Bill>? oldOrders;
  List<String>? oldIdList;

  DateTime? start;
  DateTime? end;

  String type = '';

  final int _rowsPerPage = 8;
  int total = 0;

  _OrderManagementState(this.restaurantId);

  @override
  void initState() {
    super.initState();
    listBills(restaurantId,
            startAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            endAt: DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .then((orders) {
      context.read<SelectedTableProvider>().setAllTableOrders(orders);
      setState(() {
        total = orders.map((item) => item.total).sum;
      });
    });
    // getBills();
  }

  void showBill(orders) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ShowCurrentBill(orders: orders);
      },
    );
  }

  bool sort = true;
  List<Bill>? filterData;

  onSortColumn(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (sort) {
        filterData!.sort((a, b) => a.id!.compareTo(b.id!));
      } else {
        filterData!.sort((a, b) => b.id!.compareTo(a.id!));
      }
    } else if (columnIndex == 5) {
      if (sort) {
        filterData!.sort((a, b) => a.total!.compareTo(b.total!));
      } else {
        filterData!.sort((a, b) => b.total!.compareTo(a.total!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<RestaurantProvider>();
    final tableProvider = context.watch<SelectedTableProvider>();
    List<Bill>? orders = tableProvider.tableOrders;
    filterData = orders;

    void updateOrders() {
      listBills(restaurantId,
              startAt: start!.millisecondsSinceEpoch ~/ 1000,
              endAt: end!.millisecondsSinceEpoch ~/ 1000,
              status: type)
          .then((orders) {
        context.read<SelectedTableProvider>().setAllTableOrders(orders);
        setState(() {
          total = orders.map((item) => item.total).reduce((a, b) => a + b);
        });
        // updateOrders(orders);
      });
    }

    return MainLayout(
        automaticallyImplyLeading: true,
        centerTitle: "訂單列表",
        center: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Card(
              //   margin:
              //       const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              //   shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(15)),
              //   child: Padding(
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              //     child: Row(
              //       children: [
              //         Text(DateFormat('yyyy-MM-dd')
              //                 .format(start ?? DateTime.now())
              //                 ?.toString() ??
              //             "-"),
              //         const Text("  -  "),
              //         Text(DateFormat('yyyy-MM-dd')
              //                 .format(end ?? DateTime.now())
              //                 ?.toString() ??
              //             "-"),
              //         const SizedBox(
              //           width: 20,
              //         ),
              //         ElevatedButton(
              //             onPressed: () async {
              //               DateTimeRange? picked = await showDateRangePicker(
              //                   context: context,
              //                   cancelText: '取消',
              //                   confirmText: '確認',
              //                   saveText: '確認',
              //                   firstDate: DateTime(2000),
              //                   lastDate: DateTime.now(),
              //                   builder: (context, child) {
              //                     return Theme(
              //                       data: ThemeData.light().copyWith(
              //                         colorScheme: ColorScheme.light(
              //                           // primary: MyColors.primary,
              //                           primary: Theme.of(context)
              //                               .colorScheme
              //                               .primary,
              //                           onPrimary: Colors.white,
              //                           surface: Colors.white,
              //                           onSurface: Colors.black,
              //                         ),
              //                         //.dialogBackgroundColor:Colors.blue[900],
              //                       ),
              //                       child: Column(
              //                         mainAxisAlignment:
              //                             MainAxisAlignment.center,
              //                         crossAxisAlignment:
              //                             CrossAxisAlignment.center,
              //                         children: [
              //                           ConstrainedBox(
              //                             constraints: const BoxConstraints(
              //                               maxWidth: 400.0,
              //                               maxHeight: 520.0,
              //                             ),
              //                             child: child,
              //                           )
              //                         ],
              //                       ),
              //                     );
              //                     // return Column(
              //                     //   children: [
              //                     //     ConstrainedBox(
              //                     //       constraints: const BoxConstraints(
              //                     //         maxWidth: 400.0,
              //                     //         maxHeight: 400.0,
              //                     //       ),
              //                     //       child: child,
              //                     //     )
              //                     //   ],
              //                     // );
              //                   });
              //               if (picked != null) {
              //                 setState(() {
              //                   start = picked.start;
              //                   end = picked.end;
              //                 });
              //                 listBills(restaurantId,
              //                         startAt:
              //                             start!.millisecondsSinceEpoch ~/ 1000,
              //                         endAt:
              //                             end!.millisecondsSinceEpoch ~/ 1000)
              //                     .then((orders) {
              //                   oldOrders = context
              //                       .read<SelectedTableProvider>()
              //                       .tableOrders;
              //
              //                   context
              //                       .read<SelectedTableProvider>()
              //                       .setAllTableOrders(orders);
              //                 });
              //               }
              //             },
              //             child: const Text("選擇日期")),
              //         const SizedBox(
              //           width: 50,
              //         ),
              //         SizedBox(
              //           width: 350,
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.start,
              //             children: [
              //               Row(children: [
              //                 Radio(
              //                   value: "",
              //                   groupValue: type,
              //                   onChanged: (value) {
              //                     setState(() {
              //                       type = value.toString();
              //                       listBills(restaurantId).then((orders) {
              //                         oldOrders = context
              //                             .read<SelectedTableProvider>()
              //                             .tableOrders;
              //
              //                         context
              //                             .read<SelectedTableProvider>()
              //                             .setAllTableOrders(orders);
              //                       });
              //                     });
              //                   },
              //                 ),
              //                 const Text(
              //                   '全部',
              //                   style: TextStyle(fontSize: 17.0),
              //                 ),
              //               ]),
              //               Row(children: [
              //                 Radio(
              //                   value: "SUBMITTED",
              //                   groupValue: type,
              //                   onChanged: (value) {
              //                     setState(() {
              //                       type = value.toString();
              //                       listBills(restaurantId, status: "SUBMITTED")
              //                           .then((orders) {
              //                         oldOrders = context
              //                             .read<SelectedTableProvider>()
              //                             .tableOrders;
              //
              //                         context
              //                             .read<SelectedTableProvider>()
              //                             .setAllTableOrders(orders);
              //                       });
              //                     });
              //                   },
              //                 ),
              //                 const Text(
              //                   '已提交',
              //                   style: TextStyle(fontSize: 17.0),
              //                 ),
              //               ]),
              //               Row(children: [
              //                 Radio(
              //                   value: "PAIED",
              //                   groupValue: type,
              //                   onChanged: (value) {
              //                     setState(() {
              //                       type = value.toString();
              //                       listBills(restaurantId, status: "PAIED")
              //                           .then((orders) {
              //                         oldOrders = context
              //                             .read<SelectedTableProvider>()
              //                             .tableOrders;
              //
              //                         context
              //                             .read<SelectedTableProvider>()
              //                             .setAllTableOrders(orders);
              //                       });
              //                     });
              //                   },
              //                 ),
              //                 const Text(
              //                   '已完成',
              //                   style: TextStyle(fontSize: 17.0),
              //                 ),
              //               ]),
              //             ],
              //           ),
              //         ),
              //         SizedBox(
              //           width: 200,
              //           height: 40,
              //           child: SearchBar(
              //             leading: const Icon(Icons.search),
              //             onChanged: (e) {
              //               setState(() {
              //                 // filterData!.sort((a, b) => b.id!.compareTo(a.id!));
              //                 // filterData = List.from(orders!);
              //                 //     .toList();
              //                 filterData = filterData
              //                     ?.where((element) => element.id.contains(e))
              //                     .toList();
              //                 // print(filterData?.length);
              //                 // context
              //                 //     .read<SelectedTableProvider>()
              //                 //     .setAllTableOrders(filterData!
              //                 //         .where((element) => element.id.contains(e))
              //                 //         .toList());
              //                 // print(orders?.length);
              //                 // filterData = tmp;
              //               });
              //             },
              //             // other arguments
              //           ),
              //         )
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: PaginatedDataTable(
                    actions: [Icon(Icons.refresh)],
                    rowsPerPage: _rowsPerPage,
                    // availableRowsPerPage: [8, 16, 20],
                    // onRowsPerPageChanged: (value) =>
                    //     setState(() => _rowsPerPage = value!),
                    sortColumnIndex: 0,
                    sortAscending: sort,
                    source: BillData(filterData!, showBill),
                    // header: const Text('訂單列表'),
                    header: SizedBox(
                      height: 200,
                      child: Row(
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                DateTimeRange? picked =
                                    await showDateRangePicker(
                                        context: context,
                                        cancelText: '取消',
                                        confirmText: '確認',
                                        saveText: '確認',
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                        builder: (context, child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme: ColorScheme.light(
                                                // primary: MyColors.primary,
                                                primary: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Colors.black,
                                              ),
                                              //.dialogBackgroundColor:Colors.blue[900],
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxWidth: 400.0,
                                                    maxHeight: 520.0,
                                                  ),
                                                  child: child,
                                                )
                                              ],
                                            ),
                                          );
                                        });
                                if (picked != null) {
                                  setState(() {
                                    start = picked.start;
                                    end = picked.end;
                                  });
                                  updateOrders();
                                  // listBills(restaurantId,
                                  //         startAt:
                                  //             start!.millisecondsSinceEpoch ~/
                                  //                 1000,
                                  //         endAt: end!.millisecondsSinceEpoch ~/
                                  //             1000)
                                  //     .then((orders) {
                                  //   updateOrders(orders);
                                  // });
                                }
                              },
                              child: const Text("選擇日期")),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(DateFormat('yyyy年MM月dd日')
                                  .format(start ?? DateTime.now())
                                  ?.toString() ??
                              "-"),
                          const Text("  -  "),
                          Text(DateFormat('yyyy年MM月dd日')
                                  .format(end ?? DateTime.now())
                                  ?.toString() ??
                              "-"),
                          const SizedBox(
                            width: 50,
                          ),
                          SizedBox(
                            width: 350,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Radio(
                                    value: "",
                                    groupValue: type,
                                    onChanged: (value) {
                                      setState(() {
                                        type = value.toString();
                                        updateOrders();
                                        // listBills(restaurantId).then((orders) {
                                        //   updateOrders(orders);
                                        // });
                                      });
                                    },
                                  ),
                                  const Text(
                                    '全部',
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                ]),
                                Row(children: [
                                  Radio(
                                    value: "SUBMITTED",
                                    groupValue: type,
                                    onChanged: (value) {
                                      setState(() {
                                        type = value.toString();
                                        updateOrders();
                                        // listBills(restaurantId,
                                        //         status: "SUBMITTED")
                                        //     .then((orders) {
                                        //   updateOrders(orders);
                                        // });
                                      });
                                    },
                                  ),
                                  const Text(
                                    '已提交',
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                ]),
                                Row(children: [
                                  Radio(
                                    value: "PAIED",
                                    groupValue: type,
                                    onChanged: (value) {
                                      setState(() {
                                        type = value.toString();
                                        updateOrders();
                                        // listBills(restaurantId, status: "PAIED")
                                        //     .then((orders) {
                                        //   updateOrders(orders);
                                        // });
                                      });
                                    },
                                  ),
                                  const Text(
                                    '已完成',
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                          SizedBox(
                            child: Text("所有訂單總額：\$${total / 1000}"),
                          )
                          // SizedBox(
                          //   width: 200,
                          //   height: 40,
                          //   child: SearchBar(
                          //     leading: const Icon(Icons.search),
                          //     onChanged: (e) {
                          //       setState(() {
                          //         // filterData!.sort((a, b) => b.id!.compareTo(a.id!));
                          //         // filterData = List.from(orders!);
                          //         //     .toList();
                          //         filterData = filterData
                          //             ?.where(
                          //                 (element) => element.id.contains(e))
                          //             .toList();
                          //
                          //       });
                          //     },
                          //     // other arguments
                          //   ),
                          // )
                        ],
                      ),
                    ),
                    columns: [
                      DataColumn(
                          label: const Text('訂單ID'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              sort = !sort;
                            });
                            onSortColumn(columnIndex, ascending);
                          }),
                      const DataColumn(label: Text('取餐號')),
                      const DataColumn(label: Text('訂單時間')),
                      const DataColumn(label: Text('點餐桌')),
                      const DataColumn(label: Text('訂單狀態')),
                      DataColumn(
                          label: const Text('訂單總額'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              sort = !sort;
                            });
                            onSortColumn(columnIndex, ascending);
                          }),
                      const DataColumn(label: Text('訂單詳情')),
                    ],
                    columnSpacing: 70,
                    horizontalMargin: 10,
                    showCheckboxColumn: false,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// The "soruce" of the table
class BillData extends DataTableSource {
  BillData(List<Bill> _data, Function? onClick) {
    this._data = _data;
    this.onClick = onClick;
  }

  late List<Bill> _data;
  Function? onClick;
  Map<String, String> statusMap = {'SUBMITTED': '已提交', 'PAIED': '已完成'};

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(_data[index].id.toString())),
      DataCell(Text(_data[index].pickUpCode.toString())),
      DataCell(Text(DateFormat('yyyy-MM-dd, HH:mm')
          .format(DateTime.fromMillisecondsSinceEpoch(
              _data[index].createdAt * 1000))
          .toString())),
      DataCell(Text(_data[index].tableLabel.toString())),
      DataCell(
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _data[index].status == 'SUBMITTED'
                    ? Colors.blue
                    : Colors.yellow,
              ),
              height: 10,
              width: 10,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(statusMap[_data[index].status]!),
          ],
        ),
      ),
      DataCell(Text('\$ ${(_data[index].total / 100).toString()}')),
      DataCell(
        SizedBox(
          height: 30,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.white,
              // side: const BorderSide(width: 0, color: Colors.white),
            ),
            onPressed: () {
              onClick!(_data[index]);
            },
            child: const Text(
              "查看",
              style: TextStyle(color: kPrimaryColor),
            ),
          ),
        ),
      )
    ]);
  }
}
