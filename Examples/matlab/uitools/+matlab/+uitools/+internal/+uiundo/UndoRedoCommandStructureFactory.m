classdef UndoRedoCommandStructureFactory
    
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    % This class centralizes all the special case logic for creating
    % structures used by uiundo
    
    methods(Static)
        
        % Create undo/redo entries for the GUI setters
        function cmd = createUndoRedoStruct(hObjs, hMode, opName, propNames, oldValues, newValues, additionalOldValues)
            % propNames is a character vector or a cell array of property
            % names
            % oldValues/newValues can be:
            %    1. A single property value
            %    2. An nx1 cell array (where n is numel(hObjs))
            %    3. An nxm cell array (where m is numel(propNames))
            % additionalOldValues is a structure with fields defined by
            % property names and values which are nx1 cell arrays (where n is numel(hObjs))
            
            cmd = [];
            
            % Create the proxy list:
            proxyList = zeros(size(hObjs));
            for i = 1:length(hObjs)
                proxyList(i) = hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles == hObjs(i));
            end
            
            
            % Special case handling for colorbar and legend where undoing a
            % setting the 'Position' property may require setting the
            % 'Location' property and undoing the 'Location' property
            % may require setting the 'Position' and 'Orientation'
            % properties
            Icolorbar = ishghandle(hObjs,'colorbar');
            Ilegend = ishghandle(hObjs,'legend');
            if any(Icolorbar | Ilegend)
                % Check for special case where a colorbar/legend 'Location' property
                % is being changed. In this case propNames is a char array or
                % a scalar cell array and newValues must be a string or scalar
                % cell array since the only way to set 'Location' is via the
                % colorbar context menu
                % In this case propNames is a single value since the
                % Location property is only set from the scribe context
                % menu. Similarly, hObjs is a single value since the
                % Location context menu is not displayed when multiple
                % objects are selected
                if any(strcmp(propNames,'Location')) && ...
                        ((Icolorbar && ~strcmp(newValues,'manual')) || (Ilegend && ~strcmp(newValues,'none')))
                    
                    % Transitioning from manual position to enumerated position =>
                    % Redo - sets the Location
                    % Undo - sets the Position and the Orientation
                    
                    % Note was assume that createUndoRedoStruct() method is being called
                    % before the change has been made so that addional
                    % oldValues can be obtained from hObj
                    
                    cmd.Name = opName;
                    cmd.Function = @localChangeProperty;
                    cmd.Varargin = {hMode,proxyList,propNames,newValues};
                    cmd.InverseFunction = @localChangeProperty;
                    cmd.InverseVarargin = {hMode,proxyList,propNames,struct('Position',hObjs(i).Position,'Orientation',hObjs(i).Orientation)};
                    
                    % Check for special case where a colorbar/legend 'Position' property
                    % is being changed.
                elseif any(strcmp(propNames,'Position'))
                    % Multiple objects may have been re-positioned and only
                    % some of them may be colorbars or legends which are
                    % transitioning from enumerated position to manual
                    % position. Build a cell array or structs propUndoPVPairs
                    % as the InverseVarargin which undoes the Location
                    % property set for these transitions, and undoes the
                    % Position property set otherwise
                    propUndoPVPairs = cell(length(hObjs),1);
                    propRedoPVPairs = cell(length(hObjs),1);
                    for i = 1:length(hObjs)
                        isColorbarEnumToManual = Icolorbar(i) && length(additionalOldValues.Location)>=i && ~strcmp(additionalOldValues.Location{i},'manual');
                        isLegendEnumToManual = Ilegend(i) && length(additionalOldValues.Location)>=i && ~strcmp(additionalOldValues.Location{i},'none');
                        if isColorbarEnumToManual || isLegendEnumToManual
                            % Transitioning from enumerated position to manual position =>
                            % Redo - set the Position
                            % Undo - set the Location
                            propUndoPVPairs{i} = struct('Location',additionalOldValues.Location{i});
                        else
                            propUndoPVPairs{i} = struct('Position',additionalOldValues.Position{i});
                        end
                        propRedoPVPairs{i} = struct('Position',newValues{i});
                    end
                    
                    cmd.Name = opName;
                    cmd.Function = @localChangeProperty;
                    cmd.Varargin = {hMode,proxyList,[],propRedoPVPairs};
                    cmd.InverseFunction = @localChangeProperty;
                    cmd.InverseVarargin = {hMode,proxyList,[],propUndoPVPairs};
                end
            end
            
            % Deal with non-special case property set operations
            if isempty(cmd)
                cmd.Name = opName;
                cmd.Function = @localChangeProperty;
                cmd.Varargin = {hMode,proxyList,propNames,newValues};
                cmd.InverseFunction = @localChangeProperty;
                cmd.InverseVarargin = {hMode,proxyList,propNames,oldValues};
            end
        end
    end
end

function localChangeProperty(hMode,proxyList,propNames,value)
% Change a property on an object

% value can be a single value, a struct of PV pairs, or a cell array of values
% where the ith row is the value of the ith property name

% Given the proxy list, construct the object list:
for i = numel(proxyList):-1:1
    hObjs(i) = hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == proxyList(i));
end


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
    % Remove invalid handles
    hObjs(~ishghandle(hObjs)) = [];
    for i=1:length(propNames)
        % UndoRedo should also select the object whose property is
        % modified when plot-edit mode is enabled
        if isactiveuimode(hMode.FigureHandle,'Standard.EditPlot')
            selectobject(hObjs,'replace');
        end
        
        if ~iscell(value)
            % Set each property to the single value (or struct of PV pairs)
            set(hObjs,propNames{i},value);
        else
            % Set all the objects for the i-th property name to the i-th
            % row of value
            arrayfun(@set,double(hObjs(:)),repmat(propNames(i),size(hObjs(:))),value(:,i));
        end
    end
end
end