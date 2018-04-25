classdef MATLABExpressionIdentifier < fxptds.MATLABIdentifier
%MATLABExpressionIdentifier

% Copyright 2014-2016 The MathWorks, Inc.
    
    properties(SetAccess = protected)
        MATLABFunctionIdentifier = []
        MxInfoID = -1
        TextStart = -1
        TextLength = -1
        IsArgin = false        % True if obj location is an input argument
        IsArgout = false       % True if obj location is an output argument
        IsGlobal = false       % True if obj location is a global variable
        IsPersistent = false   % True if obj location is a persistent variable
        Reason = 0
        NumericType = []
        FiMath = []
    end % properties
    
    methods
        function obj = MATLABExpressionIdentifier(...
                MATLABFunctionIdentifier,...
                MxInfoID,...
                TextStart,...
                TextLength,...
                IsArgin,...
                IsArgout,...
                IsGlobal,...
                IsPersistent,...
                Reason,...
                varargin)
            
            if nargin==0
                return
            end
            
            obj.MATLABFunctionIdentifier = MATLABFunctionIdentifier;            
            if ~isempty(varargin)
                masterInference = varargin{1};
            else
                % Create local to prevent multiple dependent property access
                masterInference = obj.MasterInferenceReport;
            end            
            obj.MxInfoID = masterInference.CurrentMap.MxInfos(MxInfoID);
            mxInfo = masterInference.MxInfos{obj.MxInfoID};
            if isa(mxInfo, 'eml.MxFiInfo')
                obj.FiMath = masterInference.MxArrays{mxInfo.FiMathID};
                obj.NumericType = masterInference.MxArrays{mxInfo.NumericTypeID};
            end
            obj.TextStart = TextStart;
            obj.TextLength = TextLength;
            obj.IsArgin = IsArgin;
            obj.IsArgout = IsArgout;
            obj.IsGlobal = IsGlobal;
            obj.IsPersistent = IsPersistent;
            obj.ResultConstructor = @fxptds.MATLABExpressionResult;
            obj.Reason = Reason;
            obj.UniqueKey = obj.calcUniqueKey;
        end % MATLABIdentifier
        
        function newId = getIdWithNewSID(obj, newSID)            
            newFunctionId = obj.MATLABFunctionIdentifier.getIdWithNewSID(newSID);
            obj.MasterInferenceManager.disableRemapping;
            newId = fxptds.MATLABExpressionIdentifier(...
                newFunctionId,...
                obj.MxInfoID,...
                obj.TextStart,...
                obj.TextLength,...
                obj.IsArgin,...
                obj.IsArgout,...
                obj.IsGlobal,...
                obj.IsPersistent,...
                obj.Reason);
            obj.MasterInferenceManager.enableRemapping;
        end
        
        function name = getDisplayName(obj, varargin)
            % Get the string that will be displayed for a result that obj
            % identifier is associatyed with. If the optional identifier
            % object is provided as an input argument, the display name
            % should be relative to that. For example, strings relative to
            % a given subsystem
            [~, unicodeScript]  = emlcprivate('makeunicodemap',...
                obj.MasterInferenceReport.Scripts(obj.MATLABFunctionIdentifier.ScriptID).ScriptText);
            expression_string = '';
            if numel(unicodeScript) >= (obj.TextStart + obj.TextLength -1)
                expression_string = unicodeScript(obj.TextStart : (obj.TextStart + obj.TextLength-1));
            end
                               
            mlBlockIdentifier = obj.MATLABFunctionIdentifier.BlockIdentifier;
            relativeDisplayName = '';
            isMLBlockValid = mlBlockIdentifier.isValid;

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
                        if isempty(expression_string)
                            name = obj.MATLABFunctionIdentifier.getDisplayName;
                        else
                            % Belongs to the same MATLAB Function block
                            name = [obj.MATLABFunctionIdentifier.getDisplayName,...
                                ' : ', expression_string];
                        end
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
                    ' : ', expression_string];
            else
                name = [relativeDisplayName,...
                    '/', obj.MATLABFunctionIdentifier.getDisplayName,...
                    ' : ', expression_string];
            end
        end     
        
        function elementName = getElementName(~)
            % Get the name of the element that obj identifier corresponds
            % to.
            elementName = '';
        end
        
        function b = isWithinProvidedScope(obj, SLIdentifierObj)
            % Determine if the entity described by obj identifier is
            % within the scope of the provided identifier. For example,
            % block within a subsystem                
            
            if slsvTestingHook('FxptuiExpr') == 0
                b = false;
            elseif slsvTestingHook('FxptuiExpr') == 1                
                if (obj.Reason == fxptds.InstrumentationReason.REASON_ADD  ||...
                        obj.Reason == fxptds.InstrumentationReason.REASON_SUBTRACT ||...
                        obj.Reason == fxptds.InstrumentationReason.REASON_MULTIPLY ||...
                        obj.Reason == fxptds.InstrumentationReason.REASON_DIVIDE)
                    b = obj.MATLABFunctionIdentifier.isWithinProvidedScope(SLIdentifierObj);
                else
                    b = false;
                end
            else
                b = true;
            end
        end
        
        function parent = getHighestLevelParent(obj)
            % Get the top most model that stores the FPT repository for
            % obj identifier.
            parent = obj.MATLABFunctionIdentifier.getHighestLevelParent();
            
        end
        
        function b = isValid(obj)
            % Determine if the entity represented by obj identifier is
            % still valid.
            b = false;
            functionIdentifier = obj.MATLABFunctionIdentifier;
            if ~isempty(functionIdentifier)
                b = functionIdentifier.isValid;
            end
        end
        
        function hiliteInEditor(obj)
            % Hilite behavior for obj identifier.
            hiliteInEditor(obj.MATLABFunctionIdentifier,...
                           obj.TextStart);
        end
        
        function unhilite(~)
            % Unhilite behavior for obj identifier.
            % No-op
        end
        
        function obj = getObject(obj)
        % obj is a dummy method to bridge the autoscaler for now.
            obj = obj; %#ok<ASGSL>
        end       
    end % public methods

    methods (Access=protected)
        
        function key = calcUniqueKey(obj)
            key = [obj.MATLABFunctionIdentifier.UniqueKey,...
                sprintf('%i|%i|%i', obj.MxInfoID, obj.TextStart, obj.TextLength)];
        end % calcUniqueKey    
        
    end % methods (Access=protected)
    
    methods(Hidden)
        function mlfb = getMATLABFunctionBlock(obj) 
        % Convenience method to return the MLFB that the identifier belongs to. obj is used in the MATLABEntityAutoscaler
            mlfb = [];
            blkID = obj.MATLABFunctionIdentifier.BlockIdentifier;
            if ~isempty(blkID)
                mlfb = blkID.getObject;
            end
        end        
    end
end


