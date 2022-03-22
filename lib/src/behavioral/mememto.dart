part of behavioral;

abstract class Mememto  {
  
}

abstract class MememtoOriginator<T extends Mememto>  {
  Mememto save();
  void load(T mememto);
}