classdef MATLABVariableIdentifier < fxptds.MATLABExpressionIdentifier
%MATLABVariableIdentifier

% Copyright 2013-2016 The MathWorks, Inc.
    
    properties(SetAccess = private)
        MATLABExpressionIdentifiers
        VariableName = ''
        InstanceCount
        NumberOfInstances
    end % properties
    
    methods
        function obj = MATLABVariableIdentifier(...
                MATLABFunctionIdentifier,...
                MATLABExpressionIdentifiers,...
                VariableName,...
                MxInfoID,...
                InstanceCount,...
                NumberOfInstances,...
                textLength)
            
            if nargin==0
                return
            end
            
            numExprs = length(MATLABExpressionIdentifiers);
            textStarts = zeros(1, numExprs);
            isArgin = false;
            isArgout = false;
            isGlobal = false;
            isPersistent = false;
            for exprCount = 1:numExprs
                textStarts(exprCount) = MATLABExpressionIdentifiers(exprCount).TextStart;
                isArgin = isArgin || MATLABExpressionIdentifiers(exprCount).IsArgin;
                isArgout = isArgout || MATLABExpressionIdentifiers(exprCount).IsArgout;
                isGlobal = isGlobal || MATLABExpressionIdentifiers(exprCount).IsGlobal;
                isPersistent = isPersistent || MATLABExpressionIdentifiers(exprCount).IsPersistent;
            end
            
            % Base class properties. Cannot call constructor directly because
            % some information is calculated, and we need to call the
            % default constructor if there are no input arguments.            
            obj.MATLABFunctionIdentifier = MATLABFunctionIdentifier;
            obj.MxInfoID = obj.MasterInferenceManager.CurrentMap.MxInfos(MxInfoID);
            obj.TextStart = textStarts;
            obj.TextLength = textLength;
            obj.IsArgin = isArgin;
            obj.IsArgout = isArgout;
            obj.IsGlobal = isGlobal;
            obj.IsPersistent = isPersistent;
            obj.NumericType = MATLABExpressionIdentifiers(1).NumericType;
            obj.FiMath = MATLABExpressionIdentifiers(1).FiMath;
            
            % Child class properties
            obj.MATLABExpressionIdentifiers = MATLABExpressionIdentifiers;
            obj.VariableName = VariableName;
            obj.InstanceCount = InstanceCount;
            obj.NumberOfInstances = NumberOfInstances;
            obj.ResultConstructor = @fxptds.MATLABVariableResult;
            
            % Base class property, but needs to be calculated last because
            % it depends on the other properties of the class.
            obj.UniqueKey = obj.calcUniqueKey;
        end % MATLABIdentifier
        
        function name = getDisplayName(obj, varargin)
            % Get the string that will be displayed for a result that obj
            % identifier is associatyed with. If the optional identifier
            % object is provided as an input argument, the display name
            % should be relative to that. For example, strings relative to
            % a given subsystem

            variable_name = obj.VariableName;
            mlBlockIdentifier = obj.MATLABFunctionIdentifier.BlockIdentifier;
            relativeDisplayName = '';
            isMLBlockValid = mlBlockIdentifier.isValid;
            if obj.NumberOfInstances > 1
                variable_name = [variable_name,'>',int2str(obj.InstanceCount)];
            end
            if isempty(varargin)
                if isMLBlockValid
                    relativeDisplayName = mlBlockIdentifier.getObject.getFullName;
                end
            else
                otherIdentifier = varargin{1};
                if isa(otherIdentifier, 'fxptds.SimulinkIdentifier')
                    if isequal(obj.MATLABFunctionIdentifier.BlockIdentifier,otherIdentifier)
                        relativeDisplayName = '';
                    else
                        relativeDisplayName = obj.MATLABFunctionIdentifier.BlockIdentifier.getDisplayName(otherIdentifier);
                        relativeDisplayName = regexprep(relativeDisplayName,'\s:\s\d+$','');
                    end
                elseif isa(otherIdentifier, 'fxptds.MATLABFunctionIdentifier')
                    if isequal(obj.MATLABFunctionIdentifier.BlockIdentifier, otherIdentifier.BlockIdentifier)
                        % Belongs to the same MATLAB Function block
                        name = [obj.MATLABFunctionIdentifier.getDisplayName,...
                            ' : ',variable_name];
                        % If it belongs to the same function specialization,
                        % then just return the variable name
                        name = regexprep(name, ['^' otherIdentifier.getDisplayName '\s:\s'],'');
                        return;
                    else
                        if isMLBlockValid
                            relativeDisplayName = mlBlockIdentifier.getObject.getFullName;
                        end
                    end
                else
                    % Simulink block object
                    if isMLBlockValid
                        relativeDisplayName = mlBlockIdentifier.getObject.getFullName;
                    end
                end
            end
            if isempty(relativeDisplayName)
                name = [obj.MATLABFunctionIdentifier.getDisplayName,...
                    ' : ',variable_name];
            else
                name = [relativeDisplayName,...
                    '/', obj.MATLABFunctionIdentifier.getDisplayName,...
                    ' : ',variable_name];
            end
        end
                
        function elementName = getElementName(obj)
            % Get the name of the element that obj identifier corresponds
            % to.
            elementName = obj.VariableName;
        end
       
        function hiliteInEditor(obj)
            % Hilite behavior for obj identifier.
            if obj.IsArgout && length(obj.TextStart)>1
                textStart = obj.TextStart(2);
            elseif ~isempty(obj.TextStart)>0
                textStart = obj.TextStart(1);
            else
                textStart = 1;
            end
            hiliteInEditor(obj.MATLABFunctionIdentifier,...
                           textStart);
        end
        
        function obj = getObject(obj)
        % obj is a dummy method to bridge the autoscaler for now.
            obj = obj; %#ok<ASGSL>
        end
        
        function b = isWithinProvidedScope(obj, SLIdentifierObj)
        % Determine if the entity described by obj identifier is
        % within the scope of the provided identifier. For example,
        % block within a subsystem
            b = obj.MATLABFunctionIdentifier.isWithinProvidedScope(SLIdentifierObj);
        end
        
        function newId = getIdWithNewSID(obj, newSID)
            newFunctionId = obj.MATLABFunctionIdentifier.getIdWithNewSID(newSID);
            for exprIdCount = 1:length(obj.MATLABExpressionIdentifiers)
                obj.MATLABExpressionIdentifiers(exprIdCount) = obj.MATLABExpressionIdentifiers(exprIdCount).getIdWithNewSID(newSID);                
            end
            obj.MasterInferenceManager.disableRemapping;
            newId = fxptds.MATLABVariableIdentifier(...
                newFunctionId,...
                obj.MATLABExpressionIdentifiers,...
                obj.VariableName,...
                obj.MxInfoID,...
                obj.InstanceCount,...
                obj.NumberOfInstances,...
                obj.TextLength);
            obj.MasterInferenceManager.enableRemapping;
        end
    end % public methods
    
    methods(Access=protected)
        
        function key = calcUniqueKey(obj)
            key = sprintf('%s%i|%s',...
                obj.MATLABFunctionIdentifier.UniqueKey,...                
                obj.MxInfoID,...
                obj.VariableName);
        end % calcUniqueKey       
        
    end % methods(Access=protected)    
    
    methods(Hidden)
        
        function b = isStruct(obj)
            % returns true if the variable identifier is contained within a
            % struct. 
            % The name of the variable will only contain a '.' if it is a
            % structure
            idx = strfind(obj.VariableName,'.');
            b = ~isempty(idx);
        end
    end
end
