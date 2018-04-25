classdef MATLABFunctionIdentifier < fxptds.MATLABIdentifier
%MATLABFunctionIdentifier

% Copyright 2013-2017 The MathWorks, Inc.
    
    properties(SetAccess = private)
        SID  = ''        % The SID denotes the root MATLAB Function block
        BlockIdentifier  % Simulink Identifier for the MATLAB Function block
        ScriptPath = ''
        IsClass = false
        ClassName = ''
        FunctionName = ''
        InstanceCount
        NumberOfInstances
        InputOneID
        FunctionID
        ScriptID
        IsRootFunc = false;
        RootFunctionIDs;
        IsStandAloneMATLABFile;
    end % properties
    
    methods
        function obj = MATLABFunctionIdentifier(...
                SID, ...
                scriptPath, ...
                functionID, ...
                instanceCount, ...
                numberOfInstances, ...
                rootFunctionIDs, ...
                varargin)
            if nargin==0
                % Default constructor
                return
            end
            
            is_root_function = ~isempty(find(functionID == rootFunctionIDs, 1));
            obj.IsRootFunc = is_root_function;            
            if ~isempty(varargin)
                masterInference = varargin{1};
            else
                % Create local to prevent multiple dependent property access
                masterInference = obj.MasterInferenceReport;
            end            
            obj.FunctionID = masterInference.CurrentMap.Functions(functionID);
            obj.RootFunctionIDs = masterInference.CurrentMap.Functions(rootFunctionIDs);
            inferenceFunction = masterInference.Functions(obj.FunctionID);
            
            obj.SID  = SID;
            dh = fxptds.SimulinkDataArrayHandler;
            obj.BlockIdentifier = dh.getUniqueIdentifier(struct('Object',(get_param(Simulink.ID.getHandle(SID),...
                'Object'))));
            obj.ScriptPath = scriptPath;
            function_name = inferenceFunction.FunctionName;
            obj.FunctionName = function_name;
            [~,file_name,file_extension] = fileparts(scriptPath);
            if (~isempty(file_extension) && ~strcmpi(file_name,function_name))
                % This is either a method of an object, or a
                % sub-function of a function on the path.
                obj.IsClass = true;
                obj.ClassName = file_name;
            end
            if isempty(file_extension) && ~is_root_function
                % This is a sub-function in the MATLAB Function block. Find
                % the name of the top-level function.
                root_function_name = masterInference.Functions(obj.RootFunctionIDs(1)).FunctionName;
                if ~isempty(root_function_name)
                    if ~strcmpi(root_function_name,function_name)
                        % IsClass and ClassName do double duty for methods
                        % of classes and sub-functions.
                        obj.IsClass = true;
                        obj.ClassName = root_function_name;
                    end
                end
            end
            if exist(obj.ScriptPath, 'file') == 2
                obj.IsStandAloneMATLABFile = true;
            else
                obj.IsStandAloneMATLABFile = false;
            end
            obj.InstanceCount = instanceCount;  
            obj.NumberOfInstances = numberOfInstances;
            obj.ScriptID = masterInference.Functions(obj.FunctionID).ScriptID;
            obj.UniqueKey = obj.calcUniqueKey;
        end % MATLABIdentifier
        
        function newSID = get.SID(this)
            % Get for property SID.
            % SID cannot be a fully Dependent property because sometimes
            % BlockIdentifier is empty.
            newSID = this.SID;
            if ~isempty(this.BlockIdentifier)
                newSID = this.BlockIdentifier.getSID;
            end
        end
        
        function newScriptPath = get.ScriptPath(this)
            % Get for property ScriptPath
            % Update script path with the current block identifier SID,
            % which changes, for example, during a "save as".
            newScriptPath = this.ScriptPath;
            if ~this.IsStandAloneMATLABFile 
                if ~isempty(this.BlockIdentifier)
                    % MATLAB Function blocks have the block identifier SID
                    % as part of their name.
                    newScriptPath = ['#', this.BlockIdentifier.getSID];
                end
            end
        end
        
        function newId = getIdWithNewSID(obj, newSID)
            obj.MasterInferenceManager.disableRemapping;
            newScriptPath = obj.ScriptPath;
            % When the function is in the MATLAB Function Block the
            % ScriptPath is just the SID pre-pended by a #. Otherwise, the
            % function is an external function, and the ScriptPath stays
            % the same.
            if ~obj.IsStandAloneMATLABFile
                newScriptPath = sprintf('#%s', newSID);
            end
            newId = fxptds.MATLABFunctionIdentifier(...
                newSID, ...
                newScriptPath, ...
                obj.FunctionID, ...
                obj.InstanceCount, ...
                obj.NumberOfInstances, ...
                obj.RootFunctionIDs);
            obj.MasterInferenceManager.enableRemapping;
        end
        
        function name = getDisplayName(obj, varargin)
            % Get the string that will be displayed for a result that obj
            % identifier is associatyed with. If the optional identifier
            % object is provided as an input argument, the display name
            % should be relative to that. For example, strings relative to
            % a given subsystem
            if ~isempty(obj.ClassName)
                name = [obj.ClassName,'>'];
            else
                name = '';
            end
            name = [name, obj.FunctionName];
            if obj.NumberOfInstances > 1
                name = [name,'>',int2str(obj.InstanceCount)];
            end
            
        end       
        
        function elementName = getElementName(obj)
            % Get the name of the element that obj identifier corresponds
            % to.
            elementName = obj.FunctionName;
        end
        
        function b = isWithinProvidedScope(obj, otherIdentifierObj)
            % Determine if the entity described by obj identifier is
            % within the scope of the provided identifier. For example,
            % block within a subsystem
            if isa(otherIdentifierObj, 'fxptds.SimulinkIdentifier')
                b = obj.BlockIdentifier.isWithinProvidedScope(otherIdentifierObj) ...
                    || isequal(obj.BlockIdentifier,otherIdentifierObj);
            elseif isa(otherIdentifierObj, 'fxptds.MATLABFunctionIdentifier')
                b = isequal(obj.BlockIdentifier,otherIdentifierObj.BlockIdentifier) && ...
                    strcmp(obj.FunctionName, otherIdentifierObj.FunctionName);
                if otherIdentifierObj.NumberOfInstances > 1
                    b = b && isequal(obj.InstanceCount, otherIdentifierObj.InstanceCount) && ...
                        isequal(obj.NumberOfInstances, otherIdentifierObj.NumberOfInstances);
                end
            end
        end
        
        function parent = getHighestLevelParent(obj)
            % Get the top most model that stores the FPT repository for
            % obj identifier.
                parent = obj.BlockIdentifier.getHighestLevelParent;
            % parent = [];
            % if obj.isValid
            %     parent = Simulink.ID.getModel(obj.SID);
            % end
        end % getHighestLevelParent
        
        function b = isValid(obj)
            % Determine if the entity represented by obj identifier is
            % still valid.
            b = false;
            blockIdentifier = obj.BlockIdentifier;
            if ~isempty(blockIdentifier)
                b = blockIdentifier.isValid;
            end
        end % isValid
        
        function hiliteInEditor(obj,textStart)
            % Hilite behavior for obj identifier.
            
            if nargin>1
                newlines = emlcprivate('emcLinePositions', obj.MasterInferenceReport.Scripts(obj.ScriptID).ScriptText);
                % Find the first newline that textStart is less than.
                lineNumber = find(textStart<newlines,1);
                if isempty(lineNumber)
                    % The last line does not have a new-line, 
                    % and text start is on the last line.
                    lineNumber = length(newlines) + 1;
                end
            else
                lineNumber = 1;
            end
            
            emlcprivate('irOpenToLine',obj.ScriptPath,lineNumber);
        end % hiliteInEditor
        
        function openInEditor(this, textStart)
        % Same behavior as hilite
            if nargin > 1
                this.hiliteInEditor(textStart);
            else
                this.hiliteInEditor;
            end
        end %openInEditor
        
        
        function unhilite(~)
            % Unhilite behavior for obj identifier.
            % Nothing to do, since the block is not hilited in the usual way.
        end % unhilite
        
        % do not want to save and load the block identifier as it keeps
        % run-time objects. We can reconstruct on load. obj will need to
        % be carefully thought about in the save/restore workflows.
        function obj = saveobj(obj)
            if ~isempty(obj.BlockIdentifier)
                obj.SID = obj.BlockIdentifier.getSID;
            end
            obj.BlockIdentifier = [];
        end
        
    end % public methods
    
    methods (Access=protected)
        
        function key = calcUniqueKey(obj)
            % If this is a MATLAB file, then we want to use the scriptpath
            % an part of the unique string, otherwise the Scriptpath is the
            % SID which is usually redundant to the BlockIdentifier
            % uniqueKey, but will also break merging if the customer uses
            % 'SaveAs', since the SID will change, but the block handle
            % will not.
            key = sprintf('%s|', obj.BlockIdentifier.UniqueKey);
            if obj.IsStandAloneMATLABFile
                key = sprintf('%s%s|', key, obj.ScriptPath);
            end
            key = sprintf('%s%i|%d|', key, obj.FunctionID, obj.RootFunctionIDs);
        end % calcUniqueKey  
        
    end % methods (Access=protected)
    
    methods (Static)
        
        function new_functionID = copyAndSetInstanceCountToOne(obj)
            % Copy and set instance count to one
            obj.MasterInferenceManager.disableRemapping;
            new_functionID = fxptds.MATLABFunctionIdentifier(...
                obj.SID, ...
                obj.ScriptPath, ...
                obj.FunctionID, ...
                1, ... % InstanceCount
                1, ... % NumberOfInstances
                obj.RootFunctionIDs);
            obj.MasterInferenceManager.enableRemapping;
        end
        
        function obj = loadobj(obj)
            fxptds.MATLABIdentifier.loadobj(obj);
            dh = fxptds.SimulinkDataArrayHandler;
            obj.BlockIdentifier = dh.getUniqueIdentifier(struct('Object',(get_param(Simulink.ID.getHandle(obj.SID),...
                'Object'))));            
        end
        
    end % methods (Static)
    
end

% LocalWords:  emc ir
