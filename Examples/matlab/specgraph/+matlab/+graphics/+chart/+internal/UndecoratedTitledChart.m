
%   Copyright 2017 The MathWorks, Inc.

% Base-class for charts that support full control by subplot, are backed by
% an axes, and have no decorations outside of Axes plot box, other than
% title.

% Note, this class does not provide storage for any properties. You must
% maintain storage across save/load and copy when using this class.
% properties that need storage:
%
% Units
% ActivePositionProperty
% OuterPosition or InnerPosition (depending on value of
%                                   activePositionProperty)
%
% This class does support forwards compatability of 17b charts that only
% had OuterPosition. Supports this by deserialization of legacy OuterPosition_I and
% Units_I properties when present.
%

classdef (Abstract, ...
        AllowedSubclasses = { ...
        ?matlab.graphics.chart.WordCloudChart,...
        }) ...
        UndecoratedTitledChart ...
        < matlab.graphics.chart.internal.SubplotPositionableChart
    
    
    properties(Dependent, AffectsObject, SetObservable, Hidden)
        % These properties are needed to pass object_is_axeslike in subplot
        % c++ code:
        Position_I@matlab.graphics.datatype.Position
    end
    properties(Dependent, SetObservable, Hidden, SetAccess = private)
        % These properties are needed to pass object_is_axeslike in subplot
        % c++ code:
        LooseInset@matlab.graphics.datatype.Inset
    end
    
    properties(AffectsObject, SetObservable, Hidden, SetAccess = private)
        %Storage for pre-18a MATLAB of values that are expected by charts
        % that did not support ActivePositionProperty (e.g. wordcloud)
        Units_I@matlab.graphics.datatype.Units
        OuterPosition_I@matlab.graphics.datatype.Position
        InnerPosition_I@matlab.graphics.datatype.Position
        
    end
    
    properties(Dependent, AffectsObject, SetObservable, Hidden, SetAccess = private)
        TightInset@matlab.graphics.datatype.Inset %read-only
    end
    %TODO: Provide an active mechanism for dropping out of subplot layout and remove
    % observability of the props.
    % (for now, let subplot listen to our Units and OuterPosition so it can pull us out
    % if those props change.)
    properties (Dependent, AffectsObject, SetObservable, Resettable=false)
        OuterPosition@matlab.graphics.datatype.Position = [0 0 1 1]
        Units@matlab.graphics.datatype.Units = 'normalized'
        InnerPosition@matlab.graphics.datatype.Position
        ActivePositionProperty matlab.graphics.chart.datatype.ChartActivePositionType = 'outerposition';
    end
    
    properties(Dependent, AffectsObject, SetObservable, Resettable=false)
        Position@matlab.graphics.datatype.Position %alias to InnerPosition
    end
    
    
    properties (Abstract, Access={?matlab.graphics.chart.Chart, ?ChartUnitTestFriend, ...
            ?matlab.graphics.chart.internal.SubplotPositionableChart})
        Axes
    end
    
    properties(Dependent, Hidden) %subplot interface
        % Extra space needed by chart to leave room for e.g.
        % colorbar/legend. and still fit inside the SubplotCellOuterPosition.
        % Stored in same units & format as TightInset
        % (container units)
        ChartDecorationInset@matlab.graphics.datatype.Inset
    end
    
    properties(Hidden)
        ChartDecorationInset_I@matlab.graphics.datatype.Inset = [0,0,0,0];
        % Maximum Inset space (as provided by subplot.m setup) for chart
        % decorations before subplot will start squashing the innerposition
        % of a chart. Stored in same units & format as TightInset
        % (container units)
        % subplot stores maximum tightInsets for an axes in axes'
        % looseInset property. For charts, subplot stores the maximum
        % tightInset in this property instead:
        MaxInsetForSubplotCell@matlab.graphics.datatype.Inset = [0,0,0,0];
        
        % Position of grid cell allocated for chart by subplot. Written by
        % subplot.m at subplot grid setup, used for layout calculation.
        SubplotCellOuterPosition@matlab.graphics.datatype.Position = [0,0,0,0];
    end
    
    methods(Hidden)
        function mcodeConstructor(hObj, code)
            % Generate code to recreate the chart.
            
            % Add the parent to the list of input arguments.
            ignoreProperty(code, 'Parent');
            parentArg = codegen.codeargument('Name', 'parent', 'Value', hObj.Parent, ...
                'IsParameter', true, 'Comment', 'Parent');
            addConstructorArgin(code, parentArg);
            
            % Determine whether this chart is part of a subplot and whether
            % there are other charts within the same container.
            parent = hObj.Parent;
            subplotGrid = cell(0);
            numPeers = 0;
            if isscalar(parent) && isvalid(parent)
                % Determine whether this chart has any peers.
                numPeers = sum(parent.Children ~= hObj);
                
                % Check if this chart is managed by subplot.
                slm = getappdata(parent, 'SubplotListenersManager');
                if ~isempty(slm) && slm.isManaged(hObj)
                    subplotGrid = getappdata(hObj, 'SubplotGridLocation');
                end
            end
            
            % Add code for specifying the chart's position.
            if numel(subplotGrid) == 3
                % This chart is part of a subplot, add a call to subplot
                % instead of adding code for position properties.
                
                % Collect the inputs to subplot.
                rowArg = codegen.codeargument('Value', subplotGrid{1});
                colArg = codegen.codeargument('Value', subplotGrid{2});
                indArg = codegen.codeargument('Value', subplotGrid{3});
                
                % Generate the code for the call to subplot. Use a
                % codeblock so the subplot line gets it's own comment.
                subplotCode = codegen.codeblock();
                subplotCode.setConstructorName('subplot');
                subplotCode.addConstructorArgin(rowArg);
                subplotCode.addConstructorArgin(colArg);
                subplotCode.addConstructorArgin(indArg);
                subplotCode.addConstructorArgin(codegen.codeargument('Value', 'Parent'));
                subplotCode.addConstructorArgin(parentArg);
                
                % Add the subplot code before the call to chart constructor.
                code.addPreConstructorFunction(subplotCode);
                
                % Ignore both inner and outer position.
                ignoreProperty(code, 'InnerPosition');
                ignoreProperty(code, 'OuterPosition');
            elseif strcmpi(hObj.ActivePositionProperty, 'OuterPosition')
                ignoreProperty(code, 'InnerPosition');
                if numPeers ~= 0
                    % If there are multiple charts in the same parent,
                    % specify the position, even if it is still the
                    % default, to prevent charts from replacing one
                    % another.
                    addProperty(code, 'OuterPosition');
                end
            else
                ignoreProperty(code, 'OuterPosition');
            end
            
            % Position and ActivePositionProperty should never be in the code.
            ignoreProperty(code, 'Position');
            ignoreProperty(code, 'ActivePositionProperty');
            
            % Make sure that the Units property always comes before both
            % InnerPosition and OuterPosition.
            movePropertyBefore(code, 'Units', {'InnerPosition','OuterPosition'});
        end
    end
    
    % getters and setters for position properties
    methods
        function set.OuterPosition(hObj, pos)
            % Pass-through the OuterPosition property to the Axes.
            hObj.Axes.OuterPosition = pos;
        end
        
        function pos = get.OuterPosition(hObj)
            % Read the OuterPosition from the Axes.
            pos = hObj.Axes.OuterPosition;
        end
        
        function set.Units(hObj, units)
            % Pass-through the Units property to the Axes.
            hObj.Axes.Units = units;
            hObj.postSetUnits();
        end
        
        function units = get.Units(hObj)
            % Read the Units from the Axes.
            units = hObj.Axes.Units;
        end
        
        function units = get.Units_I(hObj)
            % Read the Units from the Axes for storage for pre-18a charts
            units = hObj.Axes.Units;
        end
        
        function set.Units_I(hObj,u)
            hObj.Axes.Units_I = u;
            %for deserializing from 17a figures. in 18a+ Chart responsible for saving/restoring units
        end
        
        function set.InnerPosition(hObj, pos)
            % Pass-through the InnerPosition property to the Axes.
            hObj.Axes.InnerPosition = pos;
        end
        
        function pos = get.InnerPosition(hObj)
            % Read the InnerPosition from the Axes.
            pos = hObj.Axes.InnerPosition;
            hObj.postSetPosition();
        end
        
        function set.Position(hObj, pos)
            % Pass-through the Position property to the Axes.
            hObj.Axes.InnerPosition = pos;
            hObj.postSetPosition();
        end
        
        function pos = get.Position(hObj)
            % Read the Position from the Axes.
            pos = hObj.Axes.InnerPosition;
        end
        
        
        function set.LooseInset(hObj, pos)
            % Pass-through the LooseInset property to the Axes (protected).
            hObj.Axes.LooseInset = pos;
        end
        
        function pos = get.LooseInset(hObj)
            % Read the LooseInset from the Axes.
            pos = hObj.Axes.LooseInset;
        end
        
        function pos = get.TightInset(hObj)
            % use combination of tightInset from axes and layout info
            % gathered in doUpdate (often doLayout)
            forceFullUpdate(hObj,'all','ChartDecorationInsets');
            pos = hObj.ChartDecorationInset;
            
        end
        
        function set.ActivePositionProperty(hObj, val)
            % Pass-through the ActivePositionProperty property to the Axes.
            if strcmpi(val,'InnerPosition')
                val = 'position';
            end
            hObj.Axes.ActivePositionProperty = char(val);
        end
        
        function pos = get.ActivePositionProperty(hObj)
            % Read the OuterPosition from the Axes.
            pos = matlab.graphics.chart.datatype.ChartActivePositionType( ...
                hObj.Axes.ActivePositionProperty);
        end
        
        function set.Position_I(hObj, val)
            % Pass-through the Position_I property to the Axes.
            hObj.Axes.Position_I = val;
        end
        
        function units = get.Position_I(hObj)
            % Read the Position_I from the Axes.
            units = hObj.Axes.Position_I;
        end
        
        function set.OuterPosition_I(hObj, op)
            % Pass-through the OuterPosition_I property to the Axes.
            hObj.Axes.OuterPosition_I = op;
        end
        
        function units = get.OuterPosition_I(hObj)
            % Read the OuterPosition_I from the Axes.
            units = hObj.Axes.OuterPosition_I;
        end
        
        function set.InnerPosition_I(hObj, op)
            % Pass-through the InnerPosition_I property to the Axes.
            hObj.Axes.Position_I = op;
        end
        
        function units = get.InnerPosition_I(hObj)
            % Read the OuterPosition_I from the Axes.
            units = hObj.Axes.Position_I;
        end
        
        function set.ChartDecorationInset(hObj,ins)
            hObj.ChartDecorationInset_I = ins;
        end
        
        function ins = get.ChartDecorationInset(hObj)
            forceFullUpdate(hObj,'all','ChartDecorationInsets');
            ins = hObj.ChartDecorationInset_I;
        end
        
    end
    methods(Hidden)
        function resetSubplotLayoutInfo(hObj)
            hObj.MaxInsetForSubplotCell = [0,0,0,0];
            hObj.SubplotCellOuterPosition = [0,0,0,0];
        end
    end
    
    methods(Access=protected)
        function managed = isInnerPositionManagedBySubplot(hObj)
            managed = any(hObj.SubplotCellOuterPosition ~= 0);
        end
        
        function tightInsetPoints = getTightInsetPoints(hObj, updateState)
            layout = hObj.Axes.GetLayoutInformation();
            % Get the Axes layout information
            
            posPoints = updateState.convertUnits('canvas', 'points', 'pixels', layout.Position);
            %compute the TightInset from the layout information
            decPBPoints = updateState.convertUnits('canvas', 'points', 'pixels', layout.DecoratedPlotBox);
            
            tightInsetPoints = [0,0,0,0];
            tightInsetPoints(1:2) = [ ...
                posPoints(1) - decPBPoints(1), ...
                posPoints(2) - decPBPoints(2)];
            tightInsetPoints(3:4) = [ ...
                decPBPoints(3) - posPoints(3) - tightInsetPoints(1),...
                decPBPoints(4) - posPoints(4) - tightInsetPoints(2)];
            
            tightInsetPoints(tightInsetPoints < 0) = 0;
        end
        
    end
    
    methods(Access=protected)
        %allow implementations to add a post-set hook to position sets (for
        %clearing caches, etc.)
        function postSetPosition(~)
        end
        function postSetUnits(~)
        end
        
    end
    
end

