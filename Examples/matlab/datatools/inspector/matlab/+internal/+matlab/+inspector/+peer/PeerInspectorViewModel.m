classdef PeerInspectorViewModel < ...
        internal.matlab.variableeditor.peer.PeerObjectViewModel & ...
        internal.matlab.inspector.InspectorViewModel

    % This class is unsupported and might change or be removed without
    % notice in a future version.

    % PeerViewModel for the Inspector.

    % Copyright 2015-2018 The MathWorks, Inc.

    properties(Access = private)
        propertyChangedListener = [];
        propertyRemovedListener = [];
        propertyAddedListener = [];

        objectViewMap;
        tooltipMap;
    end

    properties(Access = public)
        UndoQueue;
    end

	properties(Constant)
		% A Group
		GroupType = 'group'

		% A Subgroup within a group
		SubGroupType = 'subgroup'

		% A group of properties, within another group, that share an editor
		EditorGroupType = 'editorgroup'

		% A property
		PropertyType = 'property'
	end

    methods
        % Constructor - creates a new PeerInspectorViewModel for the given
        % parentNode and variable
        function this = PeerInspectorViewModel(parentNode, variable)
            this@internal.matlab.inspector.InspectorViewModel(...
                variable.DataModel);
            this = this@internal.matlab.variableeditor.peer.PeerObjectViewModel(...
                parentNode, variable);

            % Create listener for property changed events
            this.propertyChangedListener = event.listener(...
                variable.DataModel, 'PropertyChanged', ...
                @(es,ed) this.handlePropertyChanged(es, ed));
            this.propertyRemovedListener = event.listener(...
                variable.DataModel, 'PropertyRemoved', ...
                @(es,ed) this.handlePropertyRemoved(es, ed));
            this.propertyAddedListener = event.listener(...
                variable.DataModel, 'PropertyAdded', ...
                @(es,ed) this.handlePropertyAdded(es, ed));

            this.objectViewMap = containers.Map;
        end
        
        function [renderedData, renderedDims] = refreshRenderedData(this, varargin)
            % Fetches latest rendered data and sends an update to the
            % client with that data block.
            startRow = this.getStructValue(varargin{1}, 'startRow') + 1;
            endRow = this.getStructValue(varargin{1}, 'endRow') + 1;
            startColumn = this.getStructValue(varargin{1}, 'startColumn') + 1;
            endColumn = this.getStructValue(varargin{1}, 'endColumn') + 1;
            limitCount = this.getStructValue(varargin{1}, 'limitCount');
            
            % Get the rendered data and dimensions
            [renderedData, renderedDims] = this.getRenderedData(...
                startRow, endRow, startColumn, endColumn, limitCount);
            
            % Dispatch a peer event with the data
            this.PeerNode.dispatchEvent(struct('type', 'setData', ...
                'source', 'server', ...
                'startRow', startRow-1, ...
                'endRow', endRow-1, ...
                'startColumn', startColumn-1, ...
                'endColumn', endColumn-1, ...
                'data', {renderedData}, ...
                'rowCount', renderedDims(1), ...
                'columnCount', renderedDims(2)));
        end

        function propList = getLimitedPropertyList(~, groups, limitCount, propList)
            % Get a limited property list, limited to approximately the
            % limit count.  Considers the properties of the groups in
            % order, and constructs a list of the visible properties (not
            % in sub groups), until the limit count is hit (but completes
            % the current group)
            if ~isempty(groups)
                for groupRow = 1:length(groups)
                    groupPropertyList = groups(groupRow).PropertyList;
                    for p = 1:length(groupPropertyList)
                        if ischar(groupPropertyList{p})
                            propList = [propList groupPropertyList{p}]; %#ok<*AGROW>
                        elseif isa(groupPropertyList{p}, 'internal.matlab.inspector.InspectorSubGroup')
                            subgroup = groupPropertyList{p};
                            if ischar(subgroup.PropertyList{1})
                                propList = [propList subgroup.PropertyList{1}];
                            else
                                sg = subgroup.PropertyList{1};
                                propList = [propList sg.PropertyList{1}];
                            end
                        else
                            propList = [propList groupPropertyList{p}.PropertyList];
                        end
                    end
                    if length(propList) > limitCount
                        break;
                    end
                end
            end
        end
            
        function [renderedData, renderedDims] = getRenderedData(this, ...
                startRow, endRow, startColumn, endColumn, limitCount, propList)
            % Overrides the getRenderedData so that the Group information
            % can be added.
            this.DataModel.pauseTimer();
            
            rawData = this.getData();
            groups = rawData.getGroups();
            
             if nargin < 7
                propList = strings(0,0);
             end
            
             pagedData = false;
             if nargin == 6 && ~isempty(limitCount) && limitCount < length(fieldnames(rawData))
                 propList = this.getLimitedPropertyList(groups, limitCount, propList);
                 pagedData = true;
             end

            % Get the rendered data from the PeerObjectViewModel
            [propertySheetData, objectValueData, propsDims] = this.renderData(...
                startRow, endRow, startColumn, endColumn, propList);

            % Get the group data
            groupData = this.getRenderedGroupData();

            idx = 1;
            % Create a cell array of the appropriate size
            renderedData = cell(propsDims(1) + size(groupData, 1) + 2, 1);
            renderedData{idx,1} = sprintf('{\n\t"propertySheet":{\n\t\t"properties": [\n');
            idx = idx + 1;
            % Add in the properties from the propsData retrieved above
            for i = 1:propsDims(1)
                if (i>1)
                    renderedData{idx-1,1} = [renderedData{idx-1,1} ','];
                end
                renderedData{idx,1} = propertySheetData{i};
                idx = idx + 1;
            end

            if ~isempty(groupData)
                % Add in the groups, if there are any defined
                renderedData{idx,1} = sprintf('\t\t],\n\t\t"groups": [\n');
                idx = idx+1;
                for j = 1:size(groupData, 1)
                    if (j>1)
                        renderedData{idx-1,1} = [renderedData{idx-1,1} ','];
                    end
                    renderedData{idx,1} = groupData{j};
                    idx = idx + 1;
                end
            end

            renderedData{idx,1} = sprintf('\t\t]},\n');
            idx = idx + 1;

            renderedData{idx,1} = sprintf('\t"objects":[{\n');
            idx = idx + 1;
            for i = 1:propsDims(1)
                if (i>1)
                    renderedData{idx-1,1} = [renderedData{idx-1,1} ','];
                end
                renderedData{idx,1} = objectValueData{i};
                idx = idx + 1;
            end
            renderedData{idx,1} = sprintf('\t\t}],\n');

            % Add in an ID to be used for caching on the client.  (Currently
            % this is just the classname (the proxy or the original class)
            idx = idx + 1;
            varClass = class(rawData);
            if varClass == "internal.matlab.inspector.DefaultInspectorProxyMixin"
                varClass = class(rawData.OriginalObjects(1));
            end

            if pagedData
                % Add a special prefix to the ID so we know this is the initial
                % page of properties.  We don't want the initial page of
                % properties to be cached -- passing a special prefix will
                % prevent this.
                varClass = ['__pagedata__' varClass];
            end
            renderedData{idx,1} = sprintf(['\t"id":"' varClass '"\n}']);

            % Set the dimensions based on the full set of renderedData
            renderedDims = size(renderedData);
            this.DataModel.unpauseTimer();
        end

        function groupData = getRenderedGroupData(this)
            % Retrieve the group information defined for the object being
            % inspected
			%
			% The format of the group will look like this, using Gauge's
			% tick section as an example:
			%
			%	{
			%     "type": "group",
			%     "name": "MATLAB:ui:propertygroups:TickValuesandLabelsGroup",
			%     "displayName": "Tick Values and Labels",
			%     "tooltip": "",
			%     "expanded": true,
			%     "items": [{
			%         "type": "editorgroup",
			%         "items": [{
			%             "type": "property",
			%             "name": "MajorTicks"
			%         }, {
			%             "type": "property",
			%             "name": "MajorTickLabels"
			%         }]
			%     }, {
			%         "type": "subgroup",
			%         "items": [{
			%             "type": "property",
			%             "name": "MinorTicks"
			%         }, {
			%             "type": "property",
			%             "name": "MajorTicksMode"
			%         }, {
			%             "type": "property",
			%             "name": "MajorTickLabelsMode"
			%         }, {
			%             "type": "property",
			%             "name": "MinorTicksMode"
			%         }]
			%     }]
			% }
			%
			% Note:
			%
			% - Every construct has a 'type'
			% - Every construct with sub objects stores them in 'items'
			%
			% When creating this data structure, what is assembled (before
			% giving to JSON conversion utilities) looks like this in
			% MATLAB:
			%
			%
			%	struct
			%     type =  "group",
			%     name =  "My Group"
			%     ...
			%     items: cell array of structs having fields:
			%
			%         type  = 'editorgroup' | 'subgroup | 'group' | 'property'
			%         items = cell array of structs for sub components
			%         ...
			%         other type specific fields
			%         ...
			%
			% A cell array of structs is used, rather than a regular array
			% of structs, so that each type can have fieldnames unique to its
			% type.  An array of structs forces homogeneous fieldnames.

            rawData = this.getData();
            groups = rawData.getGroups();
            groupData = cell(size(groups, 2), 1);
            if ~isempty(groups)
                for groupRow = 1:length(groups)
                    % For each group, create the JSON data which includes
                    % the groupID, title, description, and the properties
                    % included in the group
                    group = groups(groupRow);

					% Handle top level properties
					groupItemsData = createGroupItemsData(this, group.PropertyList);

					% recursively for all
                    groupData{groupRow, 1} = ...
                        internal.matlab.variableeditor.peer.PeerUtils.toJSON(...
                        true, ...
						struct( ...
						'type', 'group', ...
						'name', group.GroupID, ...
                        'displayName', internal.matlab.inspector.Utils.getPossibleMessageCatalogString(group.Title), ...
                        'tooltip', internal.matlab.inspector.Utils.getPossibleMessageCatalogString(group.Description), ...
                        'expanded', group.Expanded, ...
						... Note: the group data needs to be wrapped in a cell array, otherwise it results in incorrect hierarchy
						'items', {groupItemsData} ...
                        ));
                end
            end
        end

		function groupItems = createGroupItemsData(this, allGroupProps)
			% For the given group object, creates all 'items' under the
			% group

			groupItems = {};

			for idx = 1:length(allGroupProps)
				property = allGroupProps{idx};

				if(isa(property, 'internal.matlab.inspector.InspectorEditorGroup'))
					%
					% editor group
					%
					% Ex: Group of {'Ticks', 'Labels'}
                    editorGroupItems = cellfun(@(x) {this.createPropertyData(x)}, property.PropertyList);

					thisProperty = struct;
					thisProperty.type = this.EditorGroupType;
					thisProperty.items = editorGroupItems;
				elseif(isa(property, 'internal.matlab.inspector.InspectorSubGroup'))
					% Creates a sub group by iterating over all given properties

					subGroupItems = this.createGroupItemsData(property.PropertyList);

					thisProperty = struct;
					thisProperty.type = this.SubGroupType;
					thisProperty.items = subGroupItems;

				else
					% just a regular property
					thisProperty = this.createPropertyData(property);
				end
				groupItems = [groupItems {thisProperty}];
			end
		end

		function property = createPropertyData(this, propertyName)
			% Creates specification for a property
			property = struct;
			property.type = this.PropertyType;
			property.name = propertyName;
		end

        function varargout = handleClientSetData(this, varargin)
            % Handles setData from the client and calls MCOS setData.  Also
            % fires a dataChangeStatus peerEvent.
            propertyName = this.getStructValue(varargin{1}, 'property');
            value = this.getStructValue(varargin{1}, 'value');
            if isjava(value)
                value = cell(value);
            end
            this.logDebug('PeerInspectorView', 'handleClientSetData', '', ...
                'property', propertyName, 'value', value);

            try
                % Retrieve current value for the property
                currentValue = this.DataModel.getData.getPropertyValue(propertyName);
            catch
                % Just return if there's an error finding the original property.
                % Its possible that the object being inspected changed since the
                % setData call was made, so assume the user just switched
                % objects and return.
                varargout{1} = '';
                return;
            end

            w = warning('off', 'backtrace');
            varargout{1} = '';
            try
                [dataType, isEnumeration] = this.getClassType(propertyName);

                % Check for empty value passed from user and replace with
                % valid "empty" value if current value is not an object or
                % is scalar datatype
                if isempty(value) && (isequal(dataType, 'any') || ...
                    contains(dataType, " ") || ...
                    any([internal.matlab.variableeditor.NumericArrayDataModel.NumericTypes, ...
                    "struct", "table", "timetable", "cell", "datetime", ...
                    "duration", "calendarDuration", "char", "string", "categorical"] == dataType))

                    value = this.getEmptyValueReplacement(propertyName);
                    if ~ischar(value)
                        value = mat2str(value);
                    end
                else
                    % TODO: Code below does not test for expressions in
                    % terms of variables in the current workspace (e.g.
                    % "x(2)") and it allows expression in terms of local
                    % variables in this workspace. We need a better method
                    % for testing validity. LXE may provide this
                    % capability.
                    if ~ischar(value)
                        L = lasterror; %#ok<*LERR>
                        try
                            % If mat2str fails, it may be ok as the
                            % EditorConverter below may handle this
                            % class type
                            value = mat2str(value);
                        catch
                        end
                        lasterror(L);
                    end

                    widgetRegistry = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance;
                    widgets = widgetRegistry.getWidgets(class(this), dataType);
                    if isempty(widgets.EditorConverter) 
                        if isEnumeration
                        widgets = widgetRegistry.getWidgets(class(this), ...
                            'categorical');
                        elseif isa(currentValue, 'function_handle')
                            widgets = widgetRegistry.getWidgets(class(this), ...
                                'function_handle');
                        end
                    end
                    if ~isempty(widgets.EditorConverter)
                        converter = eval(widgets.EditorConverter);
                        
                        % Set the server value in order to get the editor state,
                        % which contains the dependent properties list
                        converter.setServerValue(currentValue, struct('Name', dataType), propertyName);
                        s = converter.getEditorState();

                        % Pass in data type and currentValue to the editor
                        % converter class.  (Don't use the struct function
                        % for currentValue because it has extra logic
                        % around handling empties/arrays that we don't want
                        % here).  Also include the values of the dependent
                        % properties as fields of the editor state struct.
                        currVal = struct('dataType', dataType);
                        currVal.currentValue = currentValue;
                        if ~isempty(s) && isfield(s, 'richEditorDependencies')
                            for i = 1:length(s.richEditorDependencies)
                                reProp = s.richEditorDependencies{i};
                                currVal.(reProp) = this.DataModel.getData.getPropertyValue(reProp);
                            end
                        end

                        converter.setEditorState(currVal);
                            
                        converter.setClientValue(value);

                        % Get the server value from the converter.  If its
                        % not text and non-numeric, use it as is
                        value = converter.getServerValue();
                        if ~ischar(value) && isnumeric(value)
                            value = mat2str(value);
                        elseif ischar(value)
                            isCellText = startsWith(value, '{') && endsWith(value, '}');
                            hasSingleQuotes = startsWith(value, '''') && endsWith(value, '''');
                            if ~isCellText && ~hasSingleQuotes
                                value = mat2str(value);
                            end
                        end
                    end

                    % Test for a valid expression. (assume cell arrays and
                    % any value which is not text will be valid)
                    if ischar(value) && ~isequal(strfind(value, '{'), 1)
                        [result] = evalin(this.DataModel.Workspace, value);
                        if ~this.validateInput(propertyName, result, currentValue)
                            this.dispatchErrorMessage(...
                                getString(message('MATLAB:codetools:variableeditor:InvalidInputType')), propertyName);
                            return;
                        end
                    end
                end

                if ischar(value)
                % evaluate the text data sent from the client and break it
                % apart as needed
                eValue = evalin(this.DataModel.Workspace, value);
                if ~ischar(eValue)
                    if ~ischar(this.DataModel.Workspace) && ...
                            ismethod(this.DataModel.Workspace, 'disp')
                        try
                            dispValue = this.DataModel.Workspace.disp(value);
                        catch
                            dispValue = strtrim(evalc(...
                                'evalin(this.DataModel.Workspace, [''disp('' value '')''])'));
                        end
                    else
                        dispValue = strtrim(evalc(...
                            'evalin(this.DataModel.Workspace, [''disp('' value '')''])'));
                    end
                else
                    if contains(eValue, '*')
                        % The display value contains a scaling factor, like
                        % '1.03+04 * 
                        % 2.5 1.18
                        % Use the original value instead (we know that its
                        % a char value already)
                        eValue = value;
                    end
                    containsBreaks = contains(eValue, newline);
                    hdr = strtrim(matlab.internal.display.getHeader({}));

                    % The eValue may contain hyperlink information, if
                    % hotlinks are enabled.  But (only?) under test
                    % situations can the evaluated value and the header
                    % have different hotlinks settings, so consider both
                    % with and without hotlinks for this comparison.
                    eValue2 = regexprep(eValue, '<[^>]*>', '');
                    if strcmp(eValue, hdr) || strcmp(eValue2, hdr)
                        % handle empty cell arrays
                        eValue = {};
                    elseif containsBreaks || startsWith(value, '{')
                        % This is a multi-line value, and should be treated
                        % as a cell array.  value will be something like:
                        % {'a';'b';'c'}, cellContents will be a 1x1 cell
                        % array, containing a 3x1 cell array like: {''a'';
                        % ''b'';''c''}, so just need to remove the extra
                        % quotes.
                        cellContents = textscan(value(2:end-1), '%q', ...
                            'Delimiter', ';', 'MultipleDelimsAsOne', true);
                        eValue = strrep(cellContents{1}, '''', '');
                    else
                        % The value is just a scalar char vector.  Eval it
                        % instead of using the result from the evalin
                        % this.DataModel.Workspace above, because we need
                        % the quotes to be removed.  For example, if
                        % value = '''test1'''; % 1x7 char array
                        % evalin(this.DataModel.Workspace, value) =
                        %     'test1' % 1x7 char array
                        % eval(value) = test1 % 1x5 char array
                        eValue = eval(value);
                    end

                    dispValue = value;
                end
                else
                    % The value was retrieved from the convert above, just
                    % use it (no need to eval it)
                    eValue = value;
                    dispValue = '';
                end

                % Send data change event for equal data
                if isnumeric(eValue) && isnumeric(currentValue)
                    % use isSmallNumericChange to check if the value is the same.Because we want to ingore very small change in double.
                    noChange = internal.matlab.inspector.InspectorProxyMixin.isSmallNumericChange(eValue, currentValue);
                else
                    noChange = isequaln(eValue, currentValue);
                end
                if ~isequaln(class(currentValue), dataType) && ~strcmp(dataType, 'any')
                    L = lasterror; %#ok<*LERR>
                    try
                        noChange = isequaln(eValue, feval(dataType, currentValue));
                    catch
                    end
                    lasterror(L);
                end
                
                if noChange
                    [rowData, ~] = this.getRowDataForProperty(propertyName);
                    this.PeerNode.dispatchEvent(struct(...
                        'type', 'dataChangeStatus', ...
                        'source', 'server', ...
                        'status', 'noChange', ...
                        'oldValue', rowData, ...
                        'property', propertyName));

                    % Even though the data has not changed we will fire a
                    % data changed event to take care of the case that the
                    % user has typed in a value that was to be evaluated in
                    % order to clear the expression and replace it with the
                    % value (e.g. pi with 3.1416)
                    eventdata = internal.matlab.variableeditor.DataChangeEventData;
                    eventdata.Range = [];
                    eventdata.Values = value;
                    this.notify('DataChange',eventdata);
                end
                varargout{1} = '';
                if isEnumeration && ischar(eValue)
                    eValue = strrep(eValue, '''', '');
                    L = lasterror; %#ok<*LERR>
                    try
                        % Try to convert to actual enumeration if possible,
                        % but if not, just use the string representation
                        eValue = eval([dataType '.' eValue]);
                    catch
                    end
                    lasterror(L);
                end

                if isnumeric(eValue)
                    dispValue = ...
                        internal.matlab.variableeditor.peer.PeerStructureViewModel.getDisplayEditValue(...
                        eValue);
                end

                [oldValue, ~] = this.getRowDataForProperty(propertyName);

                % Defer to the command to update the Data Model
                command = internal.matlab.inspector.InspectorUndoableCommand(...
                    this.DataModel, ...
                    propertyName, ...
                    eValue, ...
                    dispValue, ...
                    this.DataModel.Name);
                status = command.execute();

                if isempty(status)
                    % status = '' when there is no error
                    this.UndoQueue.addCommand(command);

                    [newValue, ~] = this.getRowDataForProperty(propertyName);
                    this.PeerNode.dispatchEvent(struct(...
                        'type', 'dataChangeStatus', ...
                        'source', 'server', ...
                        'status', 'success', ...
                        'dispValue', dispValue, ...
                        'oldValue', oldValue, ...
                        'newValue', newValue, ...
                        'property', propertyName));
                    
                    undoRedoEventData = internal.matlab.variableeditor.DataChangeEventData;
                    % Set the event to contain the required data
                    undoRedoData.command = command;
                    
                    undoRedoEventData.Values = undoRedoData;
                    % This event is handled in PlotEditUndoRedoManager to
                    % perform undo/redo actions on figure property editing
                    this.notify('DataChange',undoRedoEventData);
                end
            catch e
                status = e.message;
                varargout{1} = status;
            end

            warning(w);
            if ~isempty(status)
                this.dispatchErrorMessage(status, propertyName);
            end
        end

        function dispatchErrorMessage(this, status, property)
            % Send a status change and error message for the failure.
            % Include the oldValue (current rowData) for the property, for
            % potential use in undo/redo scenarios.
            [rowData, ~] = this.getRowDataForProperty(property);

            this.PeerNode.dispatchEvent(struct(...
                'type', 'dataChangeStatus', ...
                'source', 'server', ...
                'status', 'error', ...
                'property', property, ...
                'oldValue', rowData, ...
                'message', status));
            this.sendErrorMessage(status);
        end

        function delete(this)
            % Delete the ViewModel.  Removes any listeners first.
            if ~isempty(this.propertyChangedListener)
                delete(this.propertyChangedListener);
            end

            if ~isempty(this.propertyAddedListener)
                delete(this.propertyAddedListener);
            end

            if ~isempty(this.propertyRemovedListener)
                delete(this.propertyRemovedListener);
            end
        end

        function handlePropertyChanged(this, ~, ed)
            % Only one property changed at a time
            propertyName = ed.Properties;

            [rowData, editorProps] = this.getRowDataForProperty(propertyName);

            % Make sure the row for the property is found
            if ~isempty(rowData)
                eventData = struct(...
                    'source', 'server', ...
                    'type', 'propertyChanged', ...
                    'property', propertyName, ...
                    'value', rowData);

                if ~isempty(editorProps)
                    % Add in any editor properties as well.  This could
                    % include, for example, the categories for a
                    % categorical variable.
                    eventData.state = editorProps;
                end
                this.PeerNode.dispatchEvent(eventData);
            end
        end

        function handlePropertyAdded(this, ~, ed)
            this.PeerNode.dispatchEvent(struct(...
                'type', 'propertyAdded', ...
                'property', ed.Properties));
        end

        function handlePropertyRemoved(this, ~, ed)
            this.PeerNode.dispatchEvent(struct(...
                'type', 'propertyRemoved', ...
                'property', ed.Properties));
        end
        
        function handleFocusLost(this)
            this.PeerNode.dispatchEvent(struct(...
                'type', 'focusLost'));
        end   
        
        % Called to reset the object cache on the client which holds the state of
        % inspected objects (group expansion, scroll position, and alpha/grouped view
        function resetObjectCache(this)
            this.PeerNode.dispatchEvent(struct(...
                'type', 'resetCache'));
        end       
        
        function handleSelectChange(this)
            this.PeerNode.dispatchEvent(struct(...
                'type', 'selectChange'));
        end           
                    
        function varargout = handlePeerEvents(this, es, ed)
            % Handles peer events from the client
            if isfield(ed.EventData, 'source') && strcmp('server', ed.EventData.source)
                % Ignore any events generated by the server
                varargout{1} = 'noop';
                return;
            end
            
            if isfield(ed.EventData,'type')
                switch ed.EventData.type
                    case {'focusLost', 'resetCache', 'selectChange'}
                        varargout{1} = 'noop';
                    otherwise
                        varargout{1} = handlePeerEvents@internal.matlab.variableeditor.peer.PeerArrayViewModel(this, es, ed);
                end
            end            
        end
    end

    methods (Access = protected)
        function setupPagedDataHandler(~, ~)
            % This isn't used by the Property Inspector
        end

        function [propertySheetData, objectValueData, renderedDims] = renderData(this, ...
                startRow, endRow, startColumn, endColumn, propList)
            % Creates the rendered data specific to the Inspector

            import internal.matlab.variableeditor.peer.WidgetRegistry;
            import internal.matlab.variableeditor.peer.PeerUtils;
            import internal.matlab.inspector.peer.PeerInspectorViewModel;

            % Get an instance of the WidgetRegistry, and cache some of the
            % commonly used widget sets
            widgetRegistry = WidgetRegistry.getInstance;
            objectWidgets = widgetRegistry.getWidgets(class(this), ...
                'object');
            charWidgets = widgetRegistry.getWidgets(class(this), ...
                'char');
            categoricalWidgets = widgetRegistry.getWidgets(class(this), ...
                'categorical');

            % Setup the start/end rows/columns
            if isempty(startRow)
                this.StartRow = 1;
            else
                this.StartRow = startRow;
            end
            if isempty(endRow)
                this.EndRow = 1;
            else
                this.EndRow = endRow;
            end
            this.StartColumn = startColumn;
            this.EndColumn = endColumn;
            rawData = this.getData();
            
            if ~isempty(propList)
                fieldNames = propList';
            else
                fieldNames = string(fieldnames(rawData));
                propList = string(fieldNames);
            end
            
            propertySheetData = cell(size(fieldNames,1), 1);
            objectValueData = cell(size(fieldNames,1), 1);
            this.tooltipMap = initHelpTooltips(this, rawData);

            if ischar(this.DataModel.Workspace)
                workspaceStr = this.DataModel.Workspace;
            else
                workspaceStr = ['internal.matlab.inspector.peer.InspectorFactory.createInspector(''' ...
                    this.DataModel.Workspace.Application ''','''...
                    this.DataModel.Workspace.Channel ''')'];
            end

            isProxy = isa(this.DataModel.getData, 'internal.matlab.inspector.InspectorProxyMixin');
            if isProxy
                [origObjSetAccessNames, origObjectPropNames] = PeerInspectorViewModel.getPublicSetAccessProps(...
                    this.DataModel.getData.OriginalObjects(1));
            end
            converterMap = containers.Map;

            % For each of the rows of rendered data, create the json object
            % string for each row's data.  Use a while loop because the number of 
            % properties may grow.
            row = 0;
            while row < size(propertySheetData, 1)
                row = row + 1;
                propName = fieldNames{row,1}; 
                
                if ~any(propName == propList)
                    continue;
                end
                rawDataVal = rawData.(propName);
                metaData = false;
                
                if ischar(rawDataVal)
                    propValue = char("'" + rawDataVal + "'");
                elseif isobject(rawDataVal) && ~istall(rawDataVal)
                    cls = class(rawDataVal);
                    if contains(cls, ".")
                        % Only display class names for full matlab classes,
                        % For example: 'Text' instead of
                        % 'matlab.graphics.primitive.Text'
                        cls = reverse(extractBefore(reverse(cls), "."));
                    end
                    propValue = strtrim([num2str(size(rawDataVal,1)) this.TIMES_SYMBOL num2str(size(rawDataVal,2)) ...
                        ' ' cls]);
                elseif isnumeric(rawDataVal) && isempty(rawDataVal)
                    propValue = '[ ]';
                else
                    [rd, ~, metaData] = this.formatSingleDataForMixedView(rawDataVal);
                    propValue =  rd{1};
                end
                dataValue = this.getFieldData(rawData, propName);
                classType = this.getClassString(rawDataVal, false, true); %data{row,4};

                % Find the metaclass property data, so it can be used for
                % the description, detailed description, etc...
                prop = findprop(rawData, propName);

                % The type may have been defined with the property, for
                % example propName@logical
                if isKey(rawData.PropertyTypeMap, prop.Name)
                    propType = rawData.PropertyTypeMap(prop.Name);
                else
                    propType = class(rawData.(prop.Name));
                end

                [isCatOrEnum, dataType] = ...
                    internal.matlab.variableeditor.peer.editors.ComboBoxEditor.isCategoricalOrEnum(...
                    classType, propType, rawData.(prop.Name));
                inPlaceEditorProps = '';

                % Setup the widgets to be used.  First, check to see if
                % there is an editor in place for this data type
                [widgets, ~, matchedVariableClass] = widgetRegistry.getWidgets(class(this), dataType);
                if ~isequal(matchedVariableClass, dataType) && isCatOrEnum
                    % If the variable class we matched against is different than
                    % the actual class (so we matched a superclass), but the
                    % value is a categorical or enum, we should show the
                    % property as a dropdown menu.  (This can happen with
                    % enumerations which extend other types like logicals or
                    % doubles -- these should be edited as enumerations)
                    widgets = categoricalWidgets;
                elseif widgetRegistry.isUnknownView(widgets.Editor) || ...
                    strcmp(widgets.Editor, 'inspector/peer/InspectorViewModel')
                
                    % If there isn't one, try to get the editor based on
                    % the property's current data type
                    if isCatOrEnum
                        widgets = categoricalWidgets;
                    else
                        [widgets, ~, matchedClass] = widgetRegistry.getWidgets(class(this), classType);
                        if matchedClass == "categorical" && ~isscalar(dataValue)
                            % Non-scalar categorical values should show as 1xN
                            % categorical, and not as a dropdown
                            widgets = objectWidgets;
                        elseif isempty(widgets.CellRenderer) && isobject(dataValue)
                            widgets = objectWidgets;
                        elseif isempty(widgets.CellRenderer)
                            widgets = charWidgets;
                        end
                    end
                end

                if ~isempty(widgets.EditorConverter)
                    % If a converter is set, use it to convert to the
                    % client value
                    if isKey(converterMap, widgets.EditorConverter)
                        converter = converterMap(widgets.EditorConverter);
                    else
                        converter = eval(widgets.EditorConverter);
                        converterMap(widgets.EditorConverter) = converter;
                    end
                    converter.setServerValue(dataValue, propType, propName);
                    propValue = converter.getClientValue();

                    % Its possible the converter changes the class type, so 
                    % get the value again
                    classType = this.getClassString(propValue, false, true);

                    % In Place Editor
                    inPlaceEditorProps = converter.getEditorState;
                    if isfield(inPlaceEditorProps, 'richEditorDependencies') && length(fieldNames) > 1
                        % Make sure dependent properties are included in the list
                        for dep = 1:length(inPlaceEditorProps.richEditorDependencies)
                            dependentProp = string(inPlaceEditorProps.richEditorDependencies{dep});
                            if ~any(fieldNames == dependentProp) && isprop(rawData, dependentProp)
                                % Add tihs property to the end of the list, and increment everything
                                fieldNames(end+1) = dependentProp;
                                propList(end+1) = dependentProp;
                                propertySheetData{end+1} = [];
                            end
                        end
                    end
                    if ~isempty(inPlaceEditorProps)
                        inPlaceEditorProps = PeerUtils.toJSON(true, inPlaceEditorProps);
                    end
                end

                cellEditor = widgets.Editor;
                if ~isequal(prop.SetAccess, 'public')
                    % If the property value doesn't have setAccess =
                    % public, it should be displayed as read-only on the
                    % client.  (This is done by having no editor for the
                    % cell).
                    cellInPlaceEditor = '';
                else
                    cellInPlaceEditor = widgets.InPlaceEditor;
                end

                % Assume that we need the full precision of numeric values if
                % there is an EditorConverter.  The Rich Editor either requires
                % the full precision (like ticks) or its EditorConverter would
                % have already resolved the value to something ilke a text summary.
                requiresFullPrecision = ~isempty(widgets.EditorConverter);
                
                % Create the rendered data for the row
                objectValueData{row,1} = this.getObjectDataForProperty(...
                    propName, dataValue, propValue, classType, isCatOrEnum, metaData, workspaceStr, requiresFullPrecision);

                hasSetAccess = true;
                if ~isempty(prop)
                    hasSetAccess = strcmp(prop.SetAccess, 'public');
                    if isProxy && hasSetAccess && any(origObjectPropNames == prop.Name)
                        % this is a proxy class, check the original
                        % object's SetAccess because the proxy may not have
                        % it set properly.  Use the original object's
                        % SetAccess as truth.
                        hasSetAccess = any(origObjSetAccessNames == prop.Name);
                    end

                    if ~hasSetAccess
                        if PeerInspectorViewModel.requiresReadOnlyText(isCatOrEnum, dataValue, dataType)
                            % Some ReadOnly properties should be shown as
                            % text
                            widgets = charWidgets;
                        end
                    end
                end

                if isKey(this.tooltipMap, propName)
                    tooltipValue = this.tooltipMap(propName);
                else 
                    tooltipValue = prop.DetailedDescription;
                end
          
                % Properties are editable if they have setAccess, the cell
                % editor is not empty, and they are not tall.  (There is no way
                % to provide some features for editing talls, like undo/redo).
                isEditable = hasSetAccess && ~isempty(cellInPlaceEditor) ...
                    && ~istall(rawDataVal);
                
                % Create the property sheet data for the property, which
                % includes the display name, tooltip, and renderers.
                % (Specifying dataType as 'char' just effects the
                % justification - so the Property Inspector shows
                % everything left justified)
                % any changes in order may effect the InspectorFactory's functionality for updating the help information
                propertySheetData{row,1} = ...
                    PeerUtils.toJSON(true, ...
                    struct('name', propName, ...  % Property Name
                    'displayName', this.getDisplayName(prop), ...
                    'tooltip', tooltipValue, ...
                    'dataType', 'char', ...
                    'className', dataType, ...
                    'renderer', widgets.CellRenderer,...
                    'inPlaceEditor', cellInPlaceEditor,...
                    'editor', cellEditor,...
                    'editable', isEditable,...
                    'workspace',workspaceStr...
                    ));

                if (~isempty(inPlaceEditorProps))
                    s = propertySheetData{row,1};
                    s(end) = ',';
                    s = [s '"inPlaceEditorProperties":' inPlaceEditorProps '}']; 
                    propertySheetData{row,1} = s;
                    
                    % TODO reconcile inplace editor with rich editor
                    %
                    % are there any components that still have an inplace
                    % editor?  can we just remove the inplaceEditorName all
                    % together?
                    s = propertySheetData{row,1};
                    s(end) = ',';
                    s = [s '"richEditorProperties":' inPlaceEditorProps '}']; 
                    propertySheetData{row,1} = s;
                end

            end

            renderedDims = size(propertySheetData);
        end

        function objectData = getObjectDataForProperty(this, propertyName, ...
                dataValue, varValue, classType, isCatOrEnum, metaData, workspaceStr, requiresFullPrecision)

            % Get the display value for the object
            editValue = varValue;
            isScalarDataValue = isscalar(dataValue);

            % If we have a numeric value, that isn't a value summary
            % create the full-precision representation of it.
            if isnumeric(dataValue)
                if ~metaData || requiresFullPrecision
                    editValue = this.getEditValue(dataValue);
                    if isScalarDataValue
                        if contains(editValue, '.')
                            % Strip off excess 0's for display
                            editValue = strip(editValue, 'right', '0');
                            if iscell(varValue)
                                % Use first item since we know this is a scalar
                                % value
                                varValue = strip(varValue{1}, 'right', '0');
                            else
                                varValue = strip(varValue, 'right', '0');
                            end
                        end
                        if length(editValue) > length(varValue)
                            varValue = [varValue '...'];
                        end
                    else
                        % Strip off excess 0's from the array for display
                        editValue = internal.matlab.inspector.Utils.getArrayWithZerosStripped(editValue);
                        if ischar(editValue) && startsWith(editValue, '[')
                            editValue = editValue(2:end-1);
                        end
                        varValue = internal.matlab.inspector.Utils.getArrayWithZerosStripped(varValue);
                        if ischar(varValue) && startsWith(varValue, '[')
                            varValue = varValue(2:end-1);
                        elseif iscellstr(varValue)
                            for n = 1:length(varValue)
                                if startsWith(varValue{n}, '[')
                                    varValue{n} = varValue{n}(2:end-1);
                                end
                            end
                        end
                    end
                end
            elseif strcmp(classType, 'logical') && isScalarDataValue
                % workspacefunc return a Java logical in the case of
                % scalar logicals so we need to correct for that here
                if strcmp(varValue, 'true') || strcmp(varValue, '1')
                    varValue = '1';
                else
                    varValue = '0';
                end
                editValue = varValue;
            elseif (strcmp(classType, 'cell') && ~ischar(varValue))
                editValue = this.getEditValue(dataValue);

                if length(varValue) > 1
                    % Check if varValue is of type cell and format (lineStyleOrder sends in line/markers as cell)
                    varValue = strjoin(varValue, ', ');
                else
                    varValue = varValue{1};
                end
            elseif isCatOrEnum || iscategorical(dataValue)
                % For categoricals and enumerations, if varValue isn't
                % already a char, then typically this means it isn't scalar
                % and varValue is the actual value.  Use FormatDataUtils to
                % format this (to something like '4x1 categorical').  
                if ~ischar(varValue)
                    [valueSummary, ~, metaData] = this.formatSingleDataForMixedView(dataValue);
                    varValue = char(valueSummary);
                    if isScalarDataValue
                        editValue = this.getEditValue(dataValue);
                    else
                        editValue = varValue;
                    end
                end
            elseif strcmp(classType, 'datetime') && ...
                    ~contains(editValue, " datetime")
                metaData = false;
            elseif strcmp(classType, 'duration') && ...
                    ~contains(editValue, " duration")
                metaData = false;
            elseif any(strcmp(classType, {'function_handle', 'char'}))
                metaData = false;
            elseif isnumeric(dataValue) && ~isScalarDataValue
                editValue = this.getEditValue(dataValue);
            end
            objectData = ['"' propertyName '": '...
                internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, ...
                struct('value', varValue,...
                'editValue', editValue,...
                'editorValue', char(this.DataModel.Name + "." + propertyName),...
                'workspace', workspaceStr, ...
                'isMetaData', metaData ...
                ))];

            % Also save in a map for reuse
            this.objectViewMap(propertyName) = objectData;
        end

        function displayName = getDisplayName(~, prop)
            % Return the display name for the given property.  This will be
            % the Description of the property, if it is set, otherwise it
            % will be the property name.
            if isempty(prop.Description)
                displayName = prop.Name;
            else
                displayName = internal.matlab.inspector.Utils.getPossibleMessageCatalogString(prop.Description);
            end
        end

        function replacementValue = getEmptyValueReplacement(this, propName)
            % Called to return the replacement value for empties when
            % setting a new value
            [dataType,isEnumeration] = this.getClassType(propName);

            if internal.matlab.variableeditor.peer.PeerUtils.isNumericType(dataType)
                % For numerics, its 0
                replacementValue = '0';
            elseif isEnumeration
                % Return the original value for an enumeration
                replacementValue = this.DataModel.getData.getPropertyValue(propName);
            else
                switch dataType
                    case 'logical'
                        replacementValue = '0';
                    otherwise
                        % Default to empty for other cases
                        replacementValue = '[]';
                end
            end
        end

        function [dataType,isEnumeration] = getClassType(this, propName)
            % Called to get the class type for the property name, and if
            % it is an enumeration or categorical.
            rawData = this.DataModel.getData();
            dataType = 'any';
            isEnumeration = false;

            if isKey(rawData.PropertyTypeMap, propName)
                % The type may have been defined with the property, for
                % example propName@logical
                propType = rawData.PropertyTypeMap(propName);

                % The type will either be a meta.type object, or it could
                % be just a class name, depending on if the metaclass
                % object had data for the property or not
                if isa(propType, 'meta.type') || isa(propType, 'meta.class')
                    if ~strcmp(propType.Name, 'any')
                        % Use the type as defined
                        dataType = propType.Name;
                    end

                    if internal.matlab.inspector.Utils.isEnumerationFrompropType(propType)
                        % If its a meta.EnumeratedType, then its an
                        % enumeration
                        isEnumeration = true;
                    elseif iscategorical(rawData.(propName))
                        % The property may not be typed, but if the current
                        % value is categorical, then treat it as a
                        % categorical variable
                        isEnumeration = true;
                    elseif isobject(rawData.(propName))
                        % But it can also be a user-defined MCOS
                        % enumeration, in which case the call to
                        % enumeration() will return the valid values
                        [~, values] = enumeration(rawData.(propName));
                        isEnumeration = ~isempty(values);
                    end
                else
                    dataType = propType;
                end
            end

            % Treat categoricals as enumerations as well
            isEnumeration = isEnumeration || ismember(dataType, ...
                {'categorical', 'nominal', 'ordinal'});

            if isEnumeration
                prop = findprop(rawData, propName);
                if ~isempty(prop)
                    % If the property doesn't have setAccess, set it to not
                    % be an enumeration, so the client doesn't show a drop
                    % down menu for this property
                    isEnumeration = strcmp(prop.SetAccess, 'public');
                end
            end
        end

        function isValid = validateInput(this, propName, value, ...
                currentValue)
            % Called to see if the value is valid for the property propName
            [dataType,isEnumeration] = this.getClassType(propName);
            isValid = true;

            if internal.matlab.variableeditor.peer.PeerUtils.isNumericType(...
                    dataType)
                % If its numeric, just verify the new value is also numeric
                isValid = isnumeric(value);
            elseif isEnumeration
                % Check enumeration values
                propType = this.DataModel.getData.PropertyTypeMap(propName);
                if isa(propType, 'meta.EnumeratedType') && ischar(value)
                    % If the possible values is set, make sure that the new
                    % value is one of them
                    isValid = isempty(propType.PossibleValues) || ...
                        ismember(strrep(value, '''', ''), ...
                        propType.PossibleValues);
                elseif isobject(currentValue)
                    % Otherwise, if its currently an object, check to see
                    % if its a user-defined enumeration.  If it is,
                    % enumeration() will return the valid values.
                    [~, enumValues] = enumeration(currentValue);
                    isValid = isempty(enumValues) || ...
                        ismember(strrep(value, '''', ''), enumValues);
                end
            else
                % Default to valid for other cases
                isValid = true;
            end
        end

        function [rowData, editorProps] = getRowDataForProperty(this, propertyName)
            rowData = [];
            editorProps = [];
            fieldNames = fieldnames(this.DataModel.getData);

            if ~this.SortAscending
                fieldNames = fieldNames(end:-1:1);
            end
            row = find(strcmp(fieldNames, propertyName));

            % Make sure the row for the property is found
            if ~isempty(row)
                % Get the rendered data for just a single property
                renderedData = this.getRenderedData(row, row, 1, 1, ...
                    1, string(propertyName));
                value = renderedData{end-2};
                rowData = value(strfind(value, '{'):end);

                editorPropsIdx = strfind(renderedData{2}, ...
                    'inPlaceEditorProperties');
                if ~isempty(editorPropsIdx)
                    % Add in any editor properties as well.  This could
                    % include, for example, the categories for a
                    % categorical variable.
                    editorProps = renderedData{2}(editorPropsIdx:end-1);
                    startIdx = strfind(editorProps, '{');
                    startIdx = startIdx(1);
                    pointer = startIdx + 1;
                    endIdx = strlength(editorProps);
                    stack = 1;
                    while pointer < endIdx
                        if editorProps(pointer) == '{'
                            stack = stack + 1;
                        elseif editorProps(pointer) == '}'
                            stack = stack - 1;
                            if stack == 0
                                break;
                            end
                        end
                        pointer = pointer + 1;
                    end
                    editorProps = editorProps(startIdx:pointer);
                end
            end
        end
        
        function helpTooltipsMap = initHelpTooltips(~, rawData)
            % keep a  persistent tooltipContainerMap so that if user close
            % that inspector and open again the same inspector, the
            % helpTooltipsMap will be there for using, no need to fetch the
            % data one more time, which will save the time
            
            mlock; % Keep persistent variables until MATLAB exits
            persistent tooltipCacheMap; 
            if isempty(tooltipCacheMap)
                tooltipCacheMap = containers.Map;
            end
            
            helpTooltipsMap = containers.Map;            
            try 
                originalObj = rawData.OriginalObjects;
                searchTerm = class(originalObj);
                
                % if the CacheMap has the tooltip map for the search term,
                % then just use this. if not, fetch the data and add this
                % into CachMap;
                if tooltipCacheMap.isKey(searchTerm)
                    helpTooltipsMap = tooltipCacheMap(searchTerm);
                else
                    tooltipProp = internal.matlab.inspector.Utils.getObjectProperties(searchTerm);

                    for index = 1:size(tooltipProp, 2)
                        propertyName = tooltipProp(index).property;
                        tooltip = strcat(tooltipProp(index).description, '||', tooltipProp(index).inputs);
                        helpTooltipsMap(propertyName) = tooltip;
                    end
                    
                    tooltipCacheMap(searchTerm) = helpTooltipsMap;
                end             
            catch
            end        
        end       
    end
    
    methods(Static = true)
        function requiresROText = requiresReadOnlyText(isCatOrEnum, dataValue, dataType)
            % If the property doesn't have setAccess, set it to not be an
            % enumeration, so the client doesn't show a drop down menu or a
            % checkbox for this property
            requiresROText = isCatOrEnum || ...
                islogical(dataValue) || ...
                dataType == "matlab.graphics.datatype.on_off";
        end
        
        function [origObjSetAccessNames, origObjectPropNames] = getPublicSetAccessProps(obj)
            % Returns a list of properties which have SetAccess == public
            m = metaclass(obj);
            origObjProps = m.PropertyList;

            numProps = length(origObjProps);
            origObjSetAccess = false(size(origObjProps));
            for i=1:numProps
                try
                    access = origObjProps(i).SetAccess;
                    origObjSetAccess(i) = ischar(access) && access == "public";
                catch
                end
            end
            origObjectPropNames = string({origObjProps.Name});
            origObjSetAccessNames = origObjectPropNames(origObjSetAccess);
            
            % Dynamic properties don't show up in the property list -- but its
            % quicker to traverse the metaclass PropertyList first and only use
            % calls to findprop if we need to.
            extraProps = setdiff(properties(obj), origObjectPropNames);
            for i = 1:length(extraProps)
                extraPropName = extraProps(i);
                p = findprop(obj, extraPropName);
                origObjectPropNames(end+1) = extraPropName; 
                if ischar(p.SetAccess) && p.SetAccess == "public"
                    origObjSetAccessNames(end+1) = extraPropName; 
                end
            end
        end
    end
end
