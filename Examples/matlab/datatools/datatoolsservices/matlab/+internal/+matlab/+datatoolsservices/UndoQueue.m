classdef UndoQueue < handle
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % UndoQueue for use by Data Tools components.
    
    % Copyright 2017 The MathWorks, Inc.
    properties
        % Undo/Redo stacks
        UndoableStack@internal.matlab.datatoolsservices.UndoableCommand
        RedoableStack@internal.matlab.datatoolsservices.UndoableCommand
        
        % Empty stack representation
        EmptyStack@internal.matlab.datatoolsservices.UndoableCommand
    end
    
    methods
        % Creates a new UndoQueue instance.
        %
        % emptyStack - the empty stack representation, used to clear
        % out lists when needed.
        function obj = UndoQueue(emptyStack)
            obj.UndoableStack = emptyStack;
            obj.RedoableStack = emptyStack;
            obj.EmptyStack = emptyStack;
        end
        
        % Add a command to the Undo queue.
        % 
        % command - UndoableCommand instance
        function addCommand(obj, command)
            % When we add something, the redo stack dies
            obj.RedoableStack = obj.EmptyStack;
            
            obj.UndoableStack(end+1) = command;
        end
        
        % Called to Undo the most recent command.
        %
        % varargin: passed into the UndoableCommand's undo method.
        function undo(obj, varargin)
            if ~isempty(obj.UndoableStack)
                % When we undo, we
                %
                % - take the existing item off the undo stack
                % - put it on the redo stack
                command = obj.UndoableStack(end);
                
                % remove from undo
                obj.UndoableStack(end) = [];
                
                % add to redo
                obj.RedoableStack(end+1) = command;
                
                % do the undo
                command.undo(varargin{:})
            end
        end
        
        % Called to Redo the most recent command.
        %
        % varargin: passed into the UndoableCommand's undo method.
        function redo(obj, varargin)
            if ~isempty(obj.RedoableStack)
                % when we redo, we
                %
                % - take the existing item off the redo stack
                % - put it back on the undo stack
                command = obj.RedoableStack(end);
                
                % remove from redo
                obj.RedoableStack(end) = [];
                
                % add to undo
                obj.UndoableStack(end+1) = command;
                
                % do the redo
                command.redo(varargin{:})
            end
        end
        
        % Returns true if both the Undo and Redo stacks are empty
        function b = isQueueEmpty(obj)
            b = isempty(obj.UndoableStack) && isempty(obj.RedoableStack);
        end
    end
end

