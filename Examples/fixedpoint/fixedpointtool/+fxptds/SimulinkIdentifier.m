classdef SimulinkIdentifier < fxptds.AbstractIdentifier 
% SIMULINKIDENTIFIER Class definition for a unique identifier for a given Simulink object

% Copyright 2013-2017 The MathWorks, Inc.

% Command line syntax:
%
%     H = fxptds.SimulinkIdentifier(<block object>, 'Output');
%     H = fxptds.SimulinkIdentifier(<block object>);
   
    properties (GetAccess = protected, SetAccess = private) 
        ElementName   % String such as '2'
    end
    
    properties (GetAccess = protected, SetAccess = protected) 
        % change SetAccess from private to protected so that the derived
        % class stateflow ID can change SLObject property in its overridden
        % restoreObj method
        SLObject      % DAStudio.Object
    end

    methods(Static)
        function checkExpectedClass(object,expectedClass)
            if ~isa(object,expectedClass)
                DAStudio.error(...
                    'FixedPointTool:fixedPointTool:incorrectObjectClass',...
                    expectedClass,...
                    class(object));
            end
        end
    end
    
    methods      
        function this = SimulinkIdentifier(object, element)

            this.checkExpectedClass(object,'DAStudio.Object');
            
            this.SLObject = object;
                        
            if nargin > 1
                this.ElementName = num2str(element);                
            else
                this.ElementName = '';
            end
            
            this.UniqueKey = this.calcUniqueKey;
        end
        
        function elementName = getElementName(this)
            elementName = this.ElementName;
        end
            
        
        function displayName = getDisplayName(this, varargin)
        % Gets the display name for the entity described by this identifier
        % relative to the system indicated by its identifier object
            slObj = this.getObject;
            displayName = '';
            if isempty(slObj); return; end
            if nargin > 1
                SLIdPotentialParent = varargin{1};
            end
            % remove new lines from the name
            path = strrep(slObj.getFullName, newline, ' ');
            element = this.ElementName;
            idx = regexp(this.ElementName,'^\d+$','once'); 
            if ~isempty(idx)
                if isa(slObj,'Simulink.BlockDiagram')
                    element = '';
                else
                    [hasOutput,numOutputs] = this.hasOutput;
                    if hasOutput
                        if numOutputs < 2
                            element = '';
                        end
                    else
                        [hasInput, numInputs] = this.hasInput;
                        if hasInput
                            if numInputs < 2
                                element = '';
                            end
                        end
                    end
                end
            end
            if ~isempty(element)
                displayName = [path ' : ' element];
            else
                displayName = path;
            end
            if nargin < 2 || ~isa(SLIdPotentialParent,'fxptds.SimulinkIdentifier')
                return; 
            end
            parent = SLIdPotentialParent.getObject;
            
            if isa(parent, 'Simulink.ModelReference')
                % If the parent is a model ref block, then use the 
                % the use the referenced model name to get the string relative to it.
                parentName = parent.ModelName;
            else
                parentName = parent.getFullName;
            end
            
            % remove new lines from the name of the parent
            parentName = strrep(parentName,newline,' ');
            
            % Remove the parent name from the displayName to return the relative name
            if ~isempty(parentName)
                displayName = regexprep(displayName,['^' regexptranslate('escape',parentName) '\/'],'');
            end
        end
        
        function b = isWithinProvidedScope(this, SLIdPotentialParent)
        % Return true if the simulink object corresponding to this
        % identifier is within the scope of a subsystem represented by another
        % identifier object
            b = false;
            if ~isa(SLIdPotentialParent,'fxptds.SimulinkIdentifier')
                
                % Under the current Simulink design
                % The entities covered by this class can be children of
                % other child classes.
                % For example, a Simulink block or Stateflow State would 
                % not be a child of 
                % MATLAB code or of a Signal Object
                %
                return;
            end

            try 
                thisDAObject = this.SLObject;
                
                potentialParentDAObject = SLIdPotentialParent.SLObject;
                
                if isa(potentialParentDAObject, 'Simulink.ModelReference')
                    
                    mdlName = potentialParentDAObject.ModelName;
                    % Eliminated due to risks with protected models
                    %load_system(mdlName);
                    potentialParentDAObject = get_param(mdlName,'Object');
                end
                
                % Must avoid pitfalls
                %   Where items FullName begins identical to
                %   FullName of potential parent
                %   But is not actually a child
                %
                %   Pitfall 1: Sibling subsystem has same name but longer
                %      mdl/sub
                %      mdl/subWithLongerName
                %      mdl/subWithLongerName/Block
                %
                %   Pitfall 2: Slash in middle of Block name
                %     Subsystem:  
                %       mdl/sub
                %     Block with / in Name:
                %       mdl/sub//sub
                %       i.e.  Parent is      mdl
                %           Block Name is  sub/sub
                %     This Block is NOT a child of
                %        mdl/sub
                %     even thought first part of FullName matches
                %
                % Solution used here
                %    Append a slash to end of potential parent full name
                %       Directly solves pitfall 1
                %         because block names are NOT allowed to 
                %         begin or end with a slash
                %    If strfind works make sure next char in child is not a slash
                %         Slash in middle of name is escaped as //
                %       Together solves pitfall 2
                %
                %  Pitfall 3: Simulink inside Stateflow STATE
                %             Separator switches to . instead of slash
                %     Potential Parent
                %         mdlName/ChartName/StateName
                %     Potential Child
                %         mdlName/ChartName/StateName.SubsysName...
                %
                %     SubPitfall: Blocks can have a . in the middle of their name
                %                 That period is NOT escaped when getting name.
                %
                potentialParentFullName = potentialParentDAObject.getFullName;
                nParentFullName = length(potentialParentFullName);
                
                if nParentFullName > 0
                    
                    thisFullName = thisDAObject.getFullName;
                    
                    if length(thisFullName) < (nParentFullName+2)
                        % Child name must be bigger than parent with at least a separator
                        % and one character AFTER the separator hence +2 above
                        return;
                    end
                    
                    newLineChar = newline;
                    % replace all the new line characters with the spaces & then compare the name.
                    % g1229663
                    if strncmp(...
                            strrep(potentialParentFullName,newLineChar,' '),...
                            strrep(thisFullName,newLineChar,' '),...
                            nParentFullName)
                        
                        % Beginning of Name matches
                        % Now need to check valid separators
                        % while avoiding pitfalls
                        
                        nextChar = thisFullName(nParentFullName+1);
                        
                        if ('/' == nextChar) && ...
                                thisFullName(nParentFullName+2) ~= '/'
                            % YES. Valid child
                            b = true;
                            
                        elseif ('.' == nextChar) && ...
                                isa(potentialParentDAObject,'Stateflow.State')
                            % YES. Valid child
                            b = true;
                        end
                    end
                end
            catch
            end
        end
        
        function parent = getHighestLevelParent(this)
        % Returns the top most parent containing this identifier.

            curSID = getSID(this);
            if isempty(curSID)
                parent = [];
            else
                parent = Simulink.ID.getModel(curSID);
            end
        end
        
        function b = isValid(this)
        % Evaluate if the identifier contains valid information

        % Check if the object is valid. In cases where blocks go out of
        % scope due to termination of the engine interface or when blocks
        % are being deleted from the graph, you can run into situations
        % where the object is still a DAObject, but is not in a valid graph
        % and cannot be resolved.
            slObj = this.SLObject;
            b = isa(slObj, 'DAStudio.Object');
            if b
                % A block object can be in UNDO purgatory.
                % The block under went UE-Cut or UE-Delete.
                % The block is not fully deleted.
                % It can live on for some time in an UNDO queue,
                % in case UE-UNDO-Cut or UE-UNDO-Delete is performed.
                %
                % As far as functionality of the original parent model,
                % the block should not be treated as part of the model.
                % Trying to perform actions on the block object
                % can lead to errors. When under a UI thread, these
                % errors can lead to a crash of the MATLAB session.
                %
                % At this point, the only known way to detect if an object
                % is in UNDO purgatory is to see if getFullName
                % begins with 'built-in/'.
                % This is costly, so a faster way is needed.
                %
                % Testing-Pitfall: delete_block NOT effective for testing this.
                %   delete_block is NOT the same as UE-Delete.
                %   delete_block permanently deletes the block with 
                %   no chance of UNDO and no UNDO purgatory.
                %
                bstr = 'built-in/';
                len = length(bstr);
                fullName = slObj.getFullName;
                b = ~strncmp(fullName,bstr,len);
            end
        end

        function hiliteInEditor(this)
        % Hilite the object in the Simulink editor

            curSID = getSID(this);
            if ~isempty(curSID)
                Simulink.ID.hilite(curSID);
            end
        end
        
        function unhilite(this)
        % Remove highlighting on the object in the Simulink editor
            parent = this.getHighestLevelParent;
            if ~isempty(parent)
                bd = get_param(parent,'Object');
                bd.hilite('off');
            end
        end
        
        function openInEditor(this)
        % Opens the system in the Simulink editor
            slObj = this.getObject;
            if isempty(slObj); return; end
            slObj.view;
        end
        
        function openDialog(this)
        % Open the block dialog of the object represented by this identifier.
            slObj = this.getObject;
            if isempty(slObj); return; end
            if(slObj.isMasked)
                open_system(slObj.getFullName,'mask');
            else
                open_system(slObj.getFullName,'parameter');
            end
        end
        
        function openSignalPropertiesDialog(this)
        % Open the signal properties dialog on the output line of the block represented by this identifier.
            slObj = this.getObject;
            if isempty(slObj) || ~isa(slObj,'Simulink.Object'); return; end
            portHandles = get_param(slObj.getFullName,'PortHandles');
            if isempty(portHandles) || isempty(portHandles.Outport); return; end
            outports = get_param(portHandles.Outport,'Object');
            if(iscell(outports)); outports = [outports{:}]; end
            portNumber = str2double(this.ElementName);
            if isnan(portNumber); portNumber = 1; end
            DAStudio.Dialog(outports(portNumber));
        end
        
        function slObj = getObject(this)
        % Returns the simulink object that this identifier represents.
            slObj = [];
            if this.isValid
                slObj = this.SLObject;
            end
        end
    end
    
    methods(Static)
        function obj = loadobj(this)
            if Simulink.ID.isValid(this.SLObject) % SLObject is holding SID and to be restored back to the block object if SID is valid
                this.SLObject = get_param(this.SLObject, 'Object'); % restore SLObject property back to the block object
            else
                this.SLObject = [];
            end
            this.UniqueKey = this.calcUniqueKey;
            obj = this;
        end 
    end
    methods
        function obj = saveobj(this) 
            obj = this.copy;
            obj.SLObject = Simulink.ID.getSID(this.SLObject); % Store SID in SLObject property when exporting
            obj.UniqueKey = []; % clean UniqueKey here. getUniqueKey will recalc it.
        end 
    end
    
    methods(Hidden)
        function sid = getSID(this)
            slObj = getObject(this);
            if isempty(slObj)
                sid = [];
            else
                sid = Simulink.ID.getSID(slObj);
            end
        end
    end
    
    methods(Access=protected)
        function [b, numInputs] = hasInput(this)
            b = false;
            numInputs = [];
            blkObj = this.getObject;
            if isempty(blkObj); return; end
            portHandles = blkObj.PortHandles;
            inportHandles = portHandles.Inport;
            % If the block does not have any outports, then it is a sink.
            if ~isempty(inportHandles)
                b = true;
                numInputs = numel(inportHandles);
            end
        end
        
        function [b, numOutputs] = hasOutput(this)
            b = false;
            numOutputs = [];
            blkObj = this.getObject;
            if isempty(blkObj); return; end
            portHandles = blkObj.PortHandles;
            outportHandles = portHandles.Outport;
            if ~isempty(outportHandles) 
                b = true;
                numOutputs = numel(outportHandles);
            end
        end

        function key = calcUniqueKey(this)
            % Returns a unique string that is used as a key in the map.
            try 
                element = this.ElementName;
                if isempty(element)
                    element = '1';
                end
                try
                    keyBase = num2hex(this.SLObject.Handle);
                catch
                    keyBase = this.SLObject.getFullName;
                end
                
                key = [keyBase '::' element];            
            catch
                key = [];
            end
        end % calcUniqueKey
        
    end
end

% LocalWords:  TMP
