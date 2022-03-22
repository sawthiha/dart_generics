part of behavioral;

abstract class DynamicMessageSubscribable<ChannelTagType, MessageType> {
  void subscribe(
    {
      required DynamicMessageSubscriber<ChannelTagType, MessageType> subscriber,
      required ChannelTagType channel
    }
  );
  void unsubscribe(
    {
      required DynamicMessageSubscriber<ChannelTagType, MessageType> subscriber,
      required ChannelTagType channel
    }
  );
}

abstract class DynamicMessagePublishable<ChannelTagType, MessageType> {
  Future<void> publish(
    {
      required MessageType message,
      required ChannelTagType channel
    }
  );
}

abstract class DynamicMessageBroker<ChannelTagType, MessageType>
implements DynamicMessageSubscribable<ChannelTagType, MessageType>,
DynamicMessagePublishable<ChannelTagType, MessageType> {

  static DynamicMessageBroker base<ChannelTagType, MessageType>()
    => BaseDynamicMessageBroker<ChannelTagType, MessageType>();

}

class BaseDynamicMessageBroker<ChannelTagType, MessageType>
implements DynamicMessageBroker<ChannelTagType, MessageType> {

  final Map<ChannelTagType, DynamicMessageChannel<ChannelTagType, MessageType>>
    _channels = { };

  @override
  void subscribe(
    {
      required DynamicMessageSubscriber<ChannelTagType, MessageType> subscriber,
      required ChannelTagType channel
    }
  ) {
    if (_channels.containsKey(channel)) {
      _channels[channel]!.subscribe(subscriber);
    } else {
      _channels[channel] =
          DynamicMessageChannel.base<ChannelTagType, MessageType>() as DynamicMessageChannel<ChannelTagType, MessageType>
            ..subscribe(subscriber);
    }
  }

  @override
  void unsubscribe(
    {
      required DynamicMessageSubscriber<ChannelTagType, MessageType> subscriber,
      required ChannelTagType channel
    }
  ) {
    _channels[channel]!.unsubscribe(subscriber);
  }

  @override
  Future<void> publish(
    {
      required MessageType message,
      required ChannelTagType channel
    }
  ) async {
    _channels[channel]!.notifyAllSubscribers(message);
  }
}

abstract class DynamicMessageChannel<ChannelTagType, MessageType> {
  static DynamicMessageChannel base<ChannelTagType, MessageType>() =>
      _BaseDynamicMessageChannel<ChannelTagType, MessageType>();

  List<DynamicMessageSubscriber<ChannelTagType, MessageType>> get subscribers;

  void notifyAllSubscribers(MessageType message);

  void subscribe(
      DynamicMessageSubscriber<ChannelTagType, MessageType> subscriber
  );

  void unsubscribe(
      DynamicMessageSubscriber<ChannelTagType, MessageType> subscriber
  );
}

class _BaseDynamicMessageChannel<ChannelTagType, MessageType>
    implements DynamicMessageChannel<ChannelTagType, MessageType> {
  final Set<DynamicMessageSubscriber<ChannelTagType, MessageType>> _subscribers =
      { };

  @override
  List<DynamicMessageSubscriber<ChannelTagType, MessageType>> get subscribers =>
      _subscribers.toList();

  @override
  void notifyAllSubscribers(MessageType message) {
    for (var subscriber in subscribers) {
      subscriber.update(message);
    }
  }

  @override
  void subscribe(
      DynamicMessageSubscriber<ChannelTagType, MessageType> subscriber
  )  {
    _subscribers.add(subscriber);
  }

  @override
  void unsubscribe(
    DynamicMessageSubscriber<ChannelTagType, MessageType> subscriber
  ) {
    _subscribers.remove(subscriber);
  }
}

abstract class DynamicMessageSubscriber<ChannelTagType, MessageType>
extends Observer<MessageType> {

  final DynamicMessageSubscribable<ChannelTagType, MessageType>
    dynamicMessageSubscribable;

  DynamicMessageSubscriber(this.dynamicMessageSubscribable);
}

abstract class DynamicMessagePublisher<ChannelTagType, MessageType> {
  final DynamicMessagePublishable<ChannelTagType, MessageType>
      dynamicMessagePublishable;

  DynamicMessagePublisher(this.dynamicMessagePublishable);
}

abstract class SpecificMessageSubscribable  {
  void subscribe(SpecificMessageSubscriber subscriber);
  void unsubscribe(SpecificMessageSubscriber subscriber);
}

abstract class SpecificMessagePublishable  {
  void publish(dynamic message);
  void add(Stream stream);

  Future<void> dispose();
}

abstract class SpecificMessageBroker
implements SpecificMessageSubscribable, SpecificMessagePublishable  {
  factory SpecificMessageBroker.base() = SpecificMessageBrokerBase;
}

class SpecificMessageBrokerBase implements SpecificMessageBroker  {
  final Set<SpecificMessageSubscriber> _subscribers = {};
  final List<StreamSubscription> _subscriptions = [];

  @override
  void publish(message) {
    // TODO: toList() is a quick fix to concurrent mod exception
    _subscribers.toList().forEach(
      (subscriber)  {
        if(subscriber.specification.isSatisfiedBy(message))  {
          subscriber.update(message);
        }
      }
    );
  }

  @override
  void subscribe(SpecificMessageSubscriber subscriber) {
    _subscribers.add(subscriber);
  }

  @override
  void unsubscribe(SpecificMessageSubscriber subscriber) {
    _subscribers.remove(subscriber);
  }

  @override
  void add(Stream stream) {
    _subscriptions.add(
      stream.listen(publish)
    );
  }

  @override
  Future<void> dispose() async {
    for (var sub in _subscriptions) {
      await sub.cancel();
    }
  }

}

abstract class SpecificMessageSubscriber<T> extends Observer<T> {
  final Specification specification;

  SpecificMessageSubscriber(this.specification);

  factory SpecificMessageSubscriber.base(
    bool Function(dynamic message) specification,
    void Function(T message) onMessage,
  ) = SpecificMessageSubscriberBase;

  factory SpecificMessageSubscriber.byType(
    void Function(T message) onMessage,
  ) = SpecificMessageSubscriberByType;
}

class SpecificMessageSubscriberBase<T> extends SpecificMessageSubscriber<T>  {
  
  final void Function(T message) onMessage;

  SpecificMessageSubscriberBase(
    bool Function(dynamic message) specification,
    this.onMessage,
  ) : super(Specification.base(specification));

  @override
  void update(message) => onMessage(message);

}

class SpecificMessageSubscriberByType<T> extends SpecificMessageSubscriberBase<T>  {
  SpecificMessageSubscriberByType(void Function(T message) onMessage)
  : super((msg) => msg is T, onMessage);
}