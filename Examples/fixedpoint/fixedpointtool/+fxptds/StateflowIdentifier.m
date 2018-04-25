classdef StateflowIdentifier < fxptds.SimulinkIdentifier
% STATEFLOWIDENTIFIER Class definition for stateflow identifiers. This class provides suitable behavior for Stateflow objects.

% Copyright 2013-2017 The MathWorks, Inc.

% Command line syntax:
%
%     H = fxptds.StateflowIdentifier(<stateflow object>, 'Output');
%     H = fxptds.StateflowIdentifier(<stateflow object>);
   
    methods
        function this = StateflowIdentifier(sfObject, name)            
            if isa(sfObject, 'Stateflow.Data') || nargin < 2
                name = '1';
            end            
            if fxptds.isStateflowChartObject(sfObject)
                sfObject = sfObject.up;
            end
            this@fxptds.SimulinkIdentifier(sfObject, name);
        end
        
        function displayName = getDisplayName(this, varargin)
        % Returns the display name for the entity being represented by this
        % identifier relative to the scope of the provided identifier.
            displayName = '';
            slObj = this.getObject;
            chartObj = this.getChartObject;
            if isempty(slObj); return; end
            if nargin > 1
                SLIdentifierObj = varargin{1};
            end
            if isa(slObj,'Simulink.SubSystem')
                displayName = getDisplayName@fxptds.SimulinkIdentifier(this, varargin{:});
            else
                path =  strrep(slObj.Path, newline, ' ');
                if isprop(slObj,'Name')
                    name = slObj.Name;
                    displayName = [path '.' name];
                    elementName = this.ElementName;
                    idx = regexp(this.ElementName,'^\d+$','once');
                    if ~isempty(idx)
                        elementName = '';
                    end
                    % If the entity has only one port, don't display the output name
                    if ~isempty(elementName)
                        displayName = [displayName ' : ' elementName];
                    end
                end
            end
            sfName = chartObj.Path;
            sfNameRegExp = regexptranslate('escape',sfName);
            if ~isempty(regexp(displayName,['^' sfNameRegExp], 'once'))
                % If current selected displayname includes the whole sfName, then 
                % replace '/' with a '.' in sfName and replace sfName part in 
                % display name. 
                names = regexp(displayName,['^' sfNameRegExp], 'split');
                idx = ~cellfun(@isempty,names);
                if sum(idx) > 0
                    properSFName = strrep(names{idx},'/','.');
                    displayName = [sfName properSFName];
                end
            end
            if nargin < 2 || ~isa(SLIdentifierObj,'fxptds.SimulinkIdentifier') 
                return; 
            end
            % Modify the name to be relative to the provided identifier
            parent = SLIdentifierObj.getObject;
            % remove new lines from the name
            parentName = strrep(parent.getFullName,newline,' ');
            
            if ~isempty(regexp(parentName,['^' sfNameRegExp], 'once'))
                % If current selected parentName includes the whole sfName, then
                % replace '/' with a '.' in sfName and replace sfName part in
                % name.
                names = regexp(parentName,['^' sfNameRegExp], 'split');
                idx = ~cellfun(@isempty,names);
                if sum(idx) > 0
                    properSFName = strrep(names{idx},'/','.');
                    parentName = [sfName properSFName];
                end
            end
            relativeParentName = parentName;
           
            % If the parent is a model ref block, then use the model name to get the string relative to it.
            if isa(parent, 'Simulink.ModelReference')
                % remove new lines from the name
                relativeParentName = strrep(parent.ModelName,newline,' ');
            end
            
            % Remove the parent name from the displayName since it is
            % relative to it. Remove the two matching patterns: parentName
            % followed by a '.' or parentName followed by a '/'
            displayName = regexprep(displayName,['^' regexptranslate('escape',relativeParentName) '\.' ...
                '|' '^' regexptranslate('escape',relativeParentName) '/'],'');

            displayName = regexprep(displayName,'^\.','');
        end
        
        function b = isStateflowChart(this)
            b = isa(this.getObject,'Simulink.SubSystem');
        end
        
        function b = isValid(this)
            % Evaluate if the identifier contains valid information
            isParentValid = isValid@fxptds.SimulinkIdentifier(this);
            % Check if the object is valid. In cases where blocks go out of
            % scope due to termination of the engine interface or when blocks
            % are being deleted from the graph, you can run into situations
            % where the object is still a DAObject, but is not in a valid graph
            % and cannot be resolved.
            b = isParentValid && isempty(regexp(this.SLObject.getFullName,'^built-in/','once'));
        end
        
        function openDialog(this)
        % Open the properties dialog of the stateflow chart or stateflow state/data
            slObj = this.getObject;
            if isempty(slObj); return; end
            if isa(slObj,'Simulink.SubSystem')
                slObj = this.getChartObject;
            end
            if ~isempty(slObj)
                slObj.dialog;
            end
        end
        
        function relativePath = getRelativePath(this)
            % get the relative path of the stateflow object
            relativePath = [this.getObject.Path '/'];
        end
    end
    
    methods(Static)
        function obj = loadobj(this)
            if Simulink.ID.isValid(this.SLObject) % SLObject is holding SID and to be restored back to the block object if SID is valid
                this.SLObject = Simulink.ID.getHandle(this.SLObject);  % restore SLObject property back to the block object
            else
                this.SLObject = []; % SID cannot resolve to the block. Assign emtpy to let isValid() return false
            end
            this.UniqueKey = this.calcUniqueKey;
            obj = this;
        end 
    end
    methods
        function obj = saveobj(this) % explicitly call the base class saveobj for better readability
            % without saveobj, base class saveobj is called automatically
            % (however if saveobj exists, base class saveobj will not be
            % triggered)
            % explicityly do so for a clear code path
            obj = saveobj@fxptds.SimulinkIdentifier(this); 
        end 
    end
    
    methods(Access=protected)
        function [b, numOutputs] = hasOutput(this)
            slObj = this.getObject;
            b = true;
            numOutputs = 1;
            if isempty(slObj); return; end
            if isa(slObj,'Simulink.SubSystem')
                [b, numOutputs] = hasOutput@fxptds.SimulinkIdentifier(this);
            end
        end
        
        function key = calcUniqueKey(this)
            element = this.ElementName;
            slObject = this.getObject;
            if isa(slObject,'Simulink.SubSystem')
               slObject = this.getChartObject; 
            end
            try
                keyBase = num2hex(slObject.Id);
                key = [keyBase '::' element];
            catch
                key = [];
            end
        end %calcUniqueKey
        
    end
    
    methods (Hidden)
        function chartObj = getChartObject(this)
        % Gets the chart object masked within the subsystem.
            chartObj = this.getObject;
            if isempty(chartObj); return; end
             try
                if isa(chartObj,'Simulink.SubSystem')
                    chartObj = fxptds.getSFChartObject(chartObj);
                else
                    while ~fxptds.isStateflowChartObject(chartObj)
                        chartObj = chartObj.getParent;
                    end
                end
            catch
                % if there was an issue finding the stateflow chart within
                % the hierarchy, return an empty object.
                chartObj = [];
            end
        end
    end
end

