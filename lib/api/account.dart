import "dart:convert";
import 'package:http/http.dart' as http;
import "package:restaurant_admin/api/utils.dart";
import '../models/session.dart';
import "config.dart";

Future<dynamic> signinApi(String email, String password) async {
  var body = jsonEncode({'email': email, 'password': password});
  try {
    final response = await http.post(Uri.parse("$authApi/sessions"),
        body: body, headers: {'Authorization': await getToken()});
    if (response.statusCode == 201) {
      return Session.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.statusCode);
    }
  } catch (e) {
    return Future.error(e);
  }
}
