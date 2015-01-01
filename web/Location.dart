library Location;

import "Year.dart";
import 'CheckIn.dart';


class Location {
  String location;
  String description;

  Location(this.location, this.description);

  int get hashCode {
    int result = 17;
    result = 37 * result * location.hashCode;
    return result;
  }

  bool operator==(other) {
    if (other is! Location) return false;
    Location location = other;
    return (location.location == this.location);
  }
  String toString() {
    return "location : $location description : $description";
  }

}class CheckInLocations {
  Map<Location, CheckInYears> locations = new Map();

  void printDetailsMap() {
    //print(locations.length);
    locations.forEach((location, checkInYears) {
      int number = checkInYears.countMapElements();
      print("$location Number of elements: $number \n $checkInYears \n");
    });
  }

  void printTotalsMap() {
    locations.forEach((location, checkInYears) {
      int number = checkInYears.countMapElements();
      print("$location Number of elements: $number \n");
      checkInYears.printTotalsMap();
    });
  }

  bool addCheckIn(Location location, CheckIn checkIn) {
    if(locations[location] == null) {
      CheckInYears checkInYears = new CheckInYears();
      locations.putIfAbsent(location, () => checkInYears);

    }
    locations[location].addCheckIn(checkIn);
    return true;
  }

  int countElements(Location location) {
    return this.locations[location].countMapElements();
  }

  int countMapElements() {
    int counter = 0;
    this.locations.forEach((k,v) {
      counter = counter + countElements(k);
    });
    return counter;
  }
}