
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'Controller.dart';

@CustomTag('main-app')
class MainApp extends PolymerElement {

  Controller controller = new Controller();

  @observable int counter = myConstructor();
  @observable int totalGlypto = 0;

  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created();


    static int myConstructor() {
    print("myConstructor Started");
    return controller.getTotal();
  }

  void setupCheckIn(Event e, var detail, Node target) {
    print("Setup started");
    controller.checkInGlypto();
    counter = controller.getTotal();
  }

  void resetCheckIn(Event e, var detail, Node target) {
    print("reset started");
  }

  void loadCheckIn(Event e, var detail, Node target) {
    print("load started");
    controller.loadData();
    counter = controller.getTotal();
  }


}
