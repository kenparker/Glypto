
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'Controller.dart';

@CustomTag('main-app')
class MainApp extends PolymerElement {

  Controller glypto = new Controller();

  @observable int counter = 0;
  @observable int totalGlypto = 0;

  factory MainApp.custom() {
    MainApp mainApp = new Element.tag('main-app');
    mainApp.myConstructor();
    return mainApp;
  }

  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created();

  MainApp ma = new MainApp.custom();

  void myConstructor() {
    print("myConstructor Started");
    counter = 1;
  }

  void setupCheckIn(Event e, var detail, Node target) {
    print("Setup started");
    glypto.checkInGlypto();
    counter = glypto.getTotal();
  }

  void resetCheckIn(Event e, var detail, Node target) {
    print("reset started");
  }

  void loadCheckIn(Event e, var detail, Node target) {
    print("load started");
    glypto.loadData();
    counter = glypto.getTotal();
  }


}
