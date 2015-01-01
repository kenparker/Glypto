library CheckIn;

import 'Location.dart';

class CheckInList {

  List<CheckIn> checkInList = new List();

  bool addCheckIn(CheckIn checkIn) {
    checkInList.add(checkIn);
    return true;
  }

  String toString() {
    String allCheckIns = '\n';
    checkInList.forEach((CheckIn) {
      allCheckIns = allCheckIns + CheckIn.toString() + '\n';
    });
    return allCheckIns;
  }

  int countElements() {
    return checkInList.length;
  }
}

class CheckIn {

  DateTime dateTime;

  CheckIn(this.dateTime);

  String toString() {
    return " dateTime : $dateTime";
  }

  int get hashCode {
    int result = 17;
    result = 37 * result * dateTime.hashCode;
    return result;
  }

  bool operator==(other) {
    if (other is! CheckIn) return false;
    CheckIn ci = other;
    return (ci.dateTime == this.dateTime);
  }
}