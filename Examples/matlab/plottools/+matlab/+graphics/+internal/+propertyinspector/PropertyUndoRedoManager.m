classdef PropertyUndoRedoManager < handle
    
    % PropertyUndoRedoManager - This class is used to perform undo/redo of
    % property editing actions performed via property inspector
    
    % Copyright 2017 The MathWorks, Inc.
    methods (Static)
        
        function h = getInstance()
            
            mlock
            persistent hUndoRedoManager;
            
            if isempty(hUndoRedoManager)
                hUndoRedoManager = matlab.graphics.internal.propertyinspector.PropertyUndoRedoManager();
            end
            
            h = hUndoRedoManager;
        end
        
        % Execute Figure's Undo actions
        function performUndo(fig)
            uiundo(fig,'execUndo');
        end
        
        % Execute redo action
        function performRedo(fig)
            uiundo(fig,'execRedo');
        end
        
        function undoRedoChangeProperty(hObjs,propNames,value)
            % Change a property on an object
            % value can be a single value, a struct of PV pairs, or a cell array of values
            % where the ith row is the value of the ith property name
            if ~iscell(propNames)
                propNames = {propNames};
            end
            % Deal with a structure of values
            if isstruct(value)
                % Set all objects to the same structure of PV pairs
                set(hObjs(ishghandle(hObjs)),value)
            elseif iscell(value) && all(cellfun('isclass',value,'struct'))
                for k=1:length(value)
                    if ishghandle(hObjs(k))
                        set(hObjs(k), value{k});
                    end
                end
            else
                % Exclude deleted objects
                value(~ishghandle(hObjs)) = [];
                hObjs(~ishghandle(hObjs)) = [];
                for i=1:length(propNames)
                    % Set each property to the single value (or struct of PV pairs)
                    if ~iscell(value)
                        % Set each property to the single value (or struct of PV pairs)
                        set(hObjs,propNames{i},value);
                    elseif contains(lower(propNames{i}),'tick')
                        % Ticks sometimes contains a value which is a
                        % cellstr or a cell array. cellstr is sent for
                        % TickLabel and cell array for Ticks
                        if iscellstr(value)
                            set(hObjs,propNames{i},value);
                        else
                            set(hObjs,propNames{i},value{:});
                        end
                    else
                        % Set all the objects for the i-th property name to the i-th
                        % row of value
                        % Loop through all the objects and set the value.
                        for j=1:size(hObjs(:))
                            set(hObjs(j),propNames{i},value{j});
                        end
                    end
                end
                % Make sure the object is selectable
                if all(isprop(hObjs,'Selected'))
                    selectobject(hObjs,'replace');
                end
            end
        end
    end
    
    methods (Access = public)
        
        % Add the figure's uiundo command to the stack on receiving
        % dataChange event from the PeerInspectorViewModel
        function addCommandToUiUndo(this,~,ed,fig)
            
            % Make sure only the DataChange event emitted on adding
            % UndoCommand is handled here. Other DataChange events should
            % be bypassed
            if isstruct(ed.Values) && isfield(ed.Values,'command')
                
                command = ed.Values.command;
                undoPropName = command.UndoPropertyInfo.PropertyName;
                redoPropName = command.RedoPropertyInfo.PropertyName;
                
                % Create the command structure:
                opName = sprintf('Change %s',redoPropName);
                prevValue = command.UndoPropertyInfo.PropertyValue;
                newValue = command.RedoPropertyInfo.AllPropertyValues;
                
                
                % TODO: DataChangeEvent is notified more than once if the
                % inspector window is closed and then reopened due to a bug
                % in Rob's PeerInspectorViewModel class
                if isequal(class(prevValue),class(newValue)) && isequal(prevValue,newValue)
                    return;
                end
                
                % For a mode property AffectedPropertyName is passed in the
                % undoPropertyInfo so that one undo action can reset both
                % XLimMode and XLim
                if isfield(command.UndoPropertyInfo,'AffectedPropertyName')
                    undoPropName = {undoPropName,command.UndoPropertyInfo.AffectedPropertyName};
                    prevValue = {prevValue,command.UndoPropertyInfo.AffectedPropertyValue};
                end
                
                hObjs = command.EditedObject;
                
                cmd = matlab.uitools.internal.uiundo.FunctionCommand;
                cmd.Name = opName;
                cmd.Function = @this.undoRedoChangeProperty;
                cmd.Varargin = {hObjs,redoPropName,newValue};
                cmd.InverseFunction = @this.undoRedoChangeProperty;
                cmd.InverseVarargin = {hObjs,undoPropName,prevValue};
                
                % Register with undo/redo
                uiundo(fig,'function',cmd);
            end
        end
        
    end
    
    methods (Access = private)
        
        % Empty constructor
        function this = PropertyUndoRedoManager(~)
        end
    end
end