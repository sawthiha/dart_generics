part of 'behavioral.dart';

abstract class Specification<T>  {
  const Specification();
  
  bool isSatisfiedBy(T obj);

  factory Specification.base(
    bool Function(T) specification
  ) = SpecificationBase;
}

extension CompositedSpecification<T> on Specification<T>  {
  
  Specification<T> and(Specification<T> other) => AndSpecification([this, other]);

  Specification or(Specification other) => OrSpecification([this, other]);

  Specification not() => NegationSpecification(this);
}

class SpecificationBase<T> extends Specification<T>  {
  final bool Function(T) specification;

  SpecificationBase(this.specification);

  @override
  bool isSatisfiedBy(obj) => specification(obj);

}

abstract class CompositeSpecification<T> extends Specification<T> {
  final List<Specification<T>> expressions;
  
  const CompositeSpecification(this.expressions);
  
}


class AndSpecification<T> extends CompositeSpecification<T>  {
  const AndSpecification(List<Specification<T>> expressions): super(expressions);
  
  @override
  bool isSatisfiedBy(T obj)  => expressions.every(
    (expression) => expression.isSatisfiedBy(obj)
  );
  
}

class OrSpecification<T> extends CompositeSpecification<T>  {
  const OrSpecification(List<Specification<T>> expressions): super(expressions);
  
  @override
  bool isSatisfiedBy(T obj)  => expressions.any(
    (expression) => expression.isSatisfiedBy(obj)
  );
}

class NegationSpecification<T> extends Specification<T>  {
  final Specification negatee;
  
  const NegationSpecification(this.negatee);
  
  @override
  bool isSatisfiedBy(T obj) => !negatee.isSatisfiedBy(obj);
}
