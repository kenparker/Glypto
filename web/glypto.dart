void addValuesToMaps(Month month, CheckIn checkin1, Year year, Location location1) {
  CheckInMonths checkInMonths = new CheckInMonths();
  checkInMonths.months.putIfAbsent(month, () => checkin1);

  CheckInYears checkInYears = new CheckInYears();
  checkInYears.years.putIfAbsent(year, () => checkInMonths);

  CheckInLocations checkInLocations = new CheckInLocations();
  checkInLocations.locations.putIfAbsent(location1, () => checkInYears);
}

void loadData() {

  Location location1 = new Location("Glyptho", "Glypthothek");
  Location location2 = new Location("Vorholz", "Vorholzer Forum");

  DateTime dt = new DateTime.now();
  CheckIn checkin1 = new CheckIn(location1, dt);

  Month month = new Month(dt.month);
  Year year = new Year(dt.year);

  addValuesToMaps(month, checkin1, year, location1);

  checkInMonths.printMap();

}

class CheckIn {
  Location location;
  DateTime dateTime;

  CheckIn(this.location, this.dateTime);

  String toString() {
    return " $location dateTime : $dateTime";
  }
}

class Location {
  String location;
  String description;

  Location(this.location, this.description);

  String toString() {
    return "location : $location description : $description";
  }

}

class Year {
  int year;

  Year(this.year);

  String toString() {
    return " Year : $year";
  }
}

class Month {
  int month;

  Month(this.month);

  String toString() {
    return " Month : $month";
  }
}

class CheckInMonths {
  Map<Month, CheckIn> months = new Map();

  void printMap() {
    months.forEach((month, checkIn) {
      print("$month $checkIn   ");
    });
  }
}

class CheckInYears {
  Map<Year, CheckInMonths> years = new Map();

  void printMap() {
    years.forEach((year, checkInMonth) {
      print("$year $checkInMonth");
    });
  }
}

class CheckInLocations {
  Map<Location, CheckInYears> locations = new Map();

  void printMap() {
    locations.forEach((location, checkInYears) {
      print("$location $checkInYears");
    });
  }
}

class DateCount {
  DateTime _date;
  int _count;

  DateCount(this._date, this._count);

  //DateTime get date => _date;
  set date(DateTime date) => _date = date;

  int get count => _count;

  set count(int count) => _count = count;

}

class DateCountList {

  List<DateCount> _dateCountList;

  DateCountList() {
    _dateCountList = new List();
  }

  length() => _dateCountList.length;

  load() {
    _dateCountList.add(new DateCount(new DateTime.now(), 11));
    _dateCountList.add(new DateCount(new DateTime.now(), 112));
  }

  getElement(int elementNumber) {
    return _dateCountList[elementNumber]._date;
  }
}

void main() {

  loadData();
  if (false) {
    DateCountList datecountlist = new DateCountList();
    datecountlist.load();
    print('list lengthhhhh is '
    + datecountlist.length().toString());

    print(datecountlist.getElement(1));
  }


}

