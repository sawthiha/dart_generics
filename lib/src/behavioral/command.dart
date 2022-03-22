part of behavioral;

abstract class Command  {
  void execute();
  void rollback();
}

class CommandManager  {
  final Queue<Command?> _undoables = Queue();
  final Queue<Command> _redoables = Queue();

  void register(Command command, {bool isToBeExecuted = true})  {
    if(isToBeExecuted)  command.execute();
    _undoables.addLast(command);
    if(isRedoable) _redoables.clear();
  }

  void deregister(Command command, {bool isToRollback = false})  {
    _undoables.remove(command);
    _redoables.remove(command);
    if(isToRollback) command.rollback();
  }

  bool get isUndoable => _undoables.isNotEmpty;
  bool get isRedoable => _redoables.isNotEmpty;

  void undo()  {
    if(_undoables.isNotEmpty)  {
      var command = _undoables.removeLast()!;
      command.rollback();
      _redoables.addLast(command);
    }
  }

  void redo()  {
    if(_redoables.isNotEmpty)  {
      var command = _redoables.removeLast();
      command.execute();
      _undoables.addLast(command);
    }
  }

  void clear()  {
    _undoables.clear();
    _redoables.clear();
  }

}