import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:face_recognition_with_images/ML/Recognition.dart';

import 'DatabaseHelper.dart';

class SyncronizationData {

  static Future<bool> isInternet()async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      if (await DataConnectionChecker().hasConnection) {
        print("Mobile data detected & internet connection confirmed.");
        return true;
      }else{
        print('No internet :( Reason:');
        return false;
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      if (await DataConnectionChecker().hasConnection) {
        print("wifi data detected & internet connection confirmed.");
        return true;
      }else{
        print('No internet :( Reason:');
        return false;
      }
    }else {
      print("Neither mobile data or WIFI detected, not internet connection found.");
      return false;
    }
  }

  final conn = DatabaseHelper.instance;

    Future<List<Recognition>> fetchAllInfo()async{
    final dbClient = await conn.db;
    List<Recognition> contactList = [];
    try {
      final maps = await dbClient.query(DatabaseHelper.contactinfoTable);
      for (var item in maps) {
        contactList.add(Recognition.fromJson(item));
      }
    } catch (e) {
      print(e.toString());
    }
    return contactList;
  }
}

