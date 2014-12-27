void main() {
  
  DemoObj obj = new DemoObj();
  obj.load();
  print(obj.length());
}

class DemoObj {
  List<int> _count;
  
  DemoObj() {
    _count = new List();
  }
  
  load() {
    print("load is starting");
    _count.add(10);
    _count.add(333);
    print(_count.length);
    
  }
  
   int length() => _count.length;
  
}