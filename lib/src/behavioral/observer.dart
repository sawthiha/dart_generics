part of behavioral;

abstract class Observer<T>  {
  void update(T event);
}

abstract class Observable<T>  {
  Set<Observer<T>> observers = {};

  void registerObserver(Observer<T> observer)  {
    observers.add(observer);
  }

  void deregisterObserver(Observer<T> observer)  {
    observers.remove(observer);
  }

  void notifyAllObservers(T update)  {
    for(var observer in observers.toList())  {
      observer.update(update);
    }
  }
}