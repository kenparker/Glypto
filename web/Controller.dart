library Controller;

import 'Location.dart';
import 'CheckIn.dart';
import 'ManageLocalStorage.dart';

class Controller {

  Location location1 = new Location("Glyptho", "Glypthothek");
  Location location2 = new Location("Vorholz", "Vorholzer Forum");
  CheckInLocations cil = new CheckInLocations();
  ManageLocalStorage mlc = new ManageLocalStorage();

  void checkInGlypto() {
    CheckIn checkin1 = new CheckIn(new DateTime.now());
    cil.addCheckIn(location1, checkin1);
    mlc.addCheckIn(location1.location, checkin1);
  }

  void loadData() {

    for (var i = 0; i < 5; i++) {
      //print(new DateTime.now());
      checkInGlypto();
    }

    CheckIn checkin2 = new CheckIn(DateTime.parse("2014-11-01 17:00:00-000"));
    cil.addCheckIn(location1, checkin2);
    checkin2 = new CheckIn(DateTime.parse("2014-11-02 17:00:00-000"));
    cil.addCheckIn(location1, checkin2);
    checkin2 = new CheckIn(DateTime.parse("2014-11-03 17:00:00-000"));
    cil.addCheckIn(location1, checkin2);

    checkin2 = new CheckIn(DateTime.parse("2013-11-01 17:00:00-000"));
    cil.addCheckIn(location1, checkin2);
    checkin2 = new CheckIn(DateTime.parse("2013-11-02 17:00:00-000"));
    cil.addCheckIn(location1, checkin2);

    checkin2 = new CheckIn(DateTime.parse("2014-11-02 17:00:00-000"));
    cil.addCheckIn(location2, checkin2);
    checkin2 = new CheckIn(DateTime.parse("2014-11-03 17:00:00-000"));
    cil.addCheckIn(location2, checkin2);

    checkin2 = new CheckIn(DateTime.parse("2013-11-01 17:00:00-000"));
    cil.addCheckIn(location2, checkin2);
    checkin2 = new CheckIn(DateTime.parse("2013-11-02 17:00:00-000"));
    cil.addCheckIn(location2, checkin2);

    cil.printTotalsMap();

    print(" number of elements : " + cil.countMapElements().toString());

  }

  void main() {

    loadData();
  }

  int getTotal() {
    return cil.countMapElements();
  }

  void clearLocalStorage() {
    mlc.clearLocalStorage();
  }
}