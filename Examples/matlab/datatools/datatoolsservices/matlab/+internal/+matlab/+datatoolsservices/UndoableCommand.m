classdef UndoableCommand < handle
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % The UndoableCommand is an abstract class used in the Undo/Redo
    % implementation.  A class which inherits from this will need to
    % implement three methods:
    % 1. execute
    % 2. undo
    % 3. redo
    %
    % UndoableCommands can be added to an UndoQueue instance, to keep
    % track of sets of UndoableCommands.
    
    % Copyright 2017 The MathWorks, Inc.
	
	methods(Abstract)
        % Will be called to execute an action.  It is expected that
        % this method returns a status:  an empty char vector ''
        % indicates success, while anything else is considered an
        % error message and may be displayed to the user by the
        % caller.
        execute(obj);
		
        % Called to undo an action.
        undo(obj);
		
        % Called to redo an action.
        redo(obj);
    end
end

