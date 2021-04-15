part of 'behavioral.dart';

bool checkIfValidIndex(int index, dynamic iterable)
  => index >= 0 && index < iterable.length;

abstract class FlexibleIterator<T> extends BidirectionalIterator<T> {

  FlexibleIterator();

  int get idx;

  bool step({bool isReverse = false});

  bool get hasNext;
  bool get hasPrev;

  void begin();
  void end();

  bool get isBegin;
  bool get isEnd;

  bool get isFirst;
  bool get isLast;

  void move(int to);

  factory FlexibleIterator.base(Iterable<T> iterable, {bool isReverse}) = FlexibleIteratorBase;

}

class FlexibleIteratorBase<T> extends FlexibleIterator<T>  {
  final Iterable<T> _iterable;
  int _idx;

  FlexibleIteratorBase(Iterable<T> iterable, {bool isReverse = false})
  : _iterable = iterable
  , _idx = isReverse ? iterable.length: -1;

  @override
  T get current => _iterable.elementAt(_idx);

  @override
  bool moveNext() {
    if(hasNext)  {
      _idx++;
      return hasNext;
    }
    return false;
  }

  @override
  bool movePrevious()  {
    if(hasPrev)  {
      _idx--;
      return hasPrev;
    }
    return false;
  }

  @override
  bool get hasNext => _iterable.isNotEmpty && _idx < _iterable.length;

  @override
  bool get hasPrev => _iterable.isNotEmpty && _idx > -1;

  @override
  void begin() {
    _idx = -1;
  }

  @override
  void end() {
    _idx = _iterable.isNotEmpty ? _iterable.length: -1;
  }

  @override
  void move(int to) {
    if(checkIfValidIndex(to, _iterable))  {
      _idx = to;
    }
  }

  @override
  bool step({bool isReverse = false}) {
    return isReverse ? movePrevious(): moveNext();
  }

  @override
  bool get isBegin => _idx == -1; 

  @override
  bool get isEnd => _iterable.isEmpty || _idx == _iterable.length;

  @override
  bool get isFirst => _idx == 0;

  @override
  bool get isLast => _iterable.isNotEmpty && _idx == _iterable.length - 1;

  @override
  int get idx => _idx;
}
