library Year;

import 'Month.dart';
import 'CheckIn.dart';
import 'Location.dart';

class Year {
  int year;

  Year(this.year);

  int get hashCode {
    int result = 17;
    result = 37 * result * year.hashCode;
    return result;
  }

  bool operator==(other) {
    if (other is! Year) return false;
    Year year = other;
    return (year.year == this.year);
  }

  String toString() {
    return " Year : $year";
  }
}

class CheckInYears {
  Map<Year, CheckInMonths> years = new Map();

  void printTotalsMap() {
    years.forEach((year, checkInMonth) {
      int number = checkInMonth.countMapElements();
      print("$year Number of elements : $number");
      checkInMonth.printTotalsMap();
    });
  }

  String toString() {
    String allCheckIns = '';
    years.forEach((Year, CheckInMonths) {
      allCheckIns = allCheckIns + " $Year \n $CheckInMonths \n";
    });
    return allCheckIns;
  }


  bool addCheckIn(Location location ,CheckIn checkIn) {
    Year year = new Year(checkIn.dateTime.year);
    if (years[year] == null) {
      CheckInMonths checkInMonths = new CheckInMonths();
      years.putIfAbsent(year, () => checkInMonths);
    }
    years[year].addCheckIn(location, checkIn);

    return true;
  }

  int countElements(Year year) {
    return years[year].countMapElements();
  }

  int countMapElements() {
    int counter = 0;
    years.forEach((k,v){
      counter = counter + countElements(k);
    });
    return counter;
  }

}
