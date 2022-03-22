part of behavioral;

abstract class Handler<Context>  {
  void handle(Context context);
}

abstract class HandlerChain<Context> extends Handler<Context>  {
  
  void queue(Handler<Context> handler);
  
  void update(Handler<Context> oldHandler, Handler<Context> newHandler);
}