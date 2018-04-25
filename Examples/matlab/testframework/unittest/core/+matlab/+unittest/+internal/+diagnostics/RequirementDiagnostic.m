classdef(Hidden) RequirementDiagnostic < matlab.unittest.diagnostics.ExtendedDiagnostic & ...
                                         matlab.unittest.internal.diagnostics.GetConditionsSupplierMixin & ...
                                         matlab.unittest.internal.diagnostics.ConditionsSupplier
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    
    %The following properties are Abstract in order to allow subclasses the choice of visibility:
    properties(Abstract)
        DisplayDescription
        Description
        DisplayConditions
        DisplayActVal
        ActValHeader
        ActVal
        DisplayExpVal
        ExpValHeader
        ExpVal
    end
    
    properties(Hidden, Dependent)
        ConditionsList
    end
    
    properties(Abstract, SetAccess=private)
        Conditions
    end
    
    properties(Hidden, Dependent, SetAccess=private)
        FormattableConditions matlab.unittest.internal.diagnostics.FormattableString;
    end
    
    properties(Hidden, SetAccess=protected)
        FormattableDescription matlab.unittest.internal.diagnostics.FormattableString = '';
    end
    
    properties(Abstract, SetAccess = {?matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory,...
            ?matlab.unittest.internal.diagnostics.RequirementDiagnostic})
        Passed
    end
    
    properties(Hidden, Access=protected)
        ConditionsSupplier (1,1) matlab.unittest.internal.diagnostics.CompositeConditionsSupplier = ...
            matlab.unittest.internal.diagnostics.CompositeConditionsSupplier();
    end
    
    properties(Hidden, SetAccess=private)
        WarnOnUse (1,1) logical = false;
        ProducingClass (1,1) string;
    end
    
    methods(Static, Access=protected)
        function str = trimNewlines(str)
            % trimNewlines - Utility method to remove newlines before/after a string
            
            if ~isa(str, 'matlab.unittest.internal.diagnostics.FormattableString')
                validateattributes(str,{'char'},{},'','str');
            end
            
            str = regexprep(str, ...
                {'^\n+','\n+$'}, ...
                {''    ,''});
        end
    end
    
    methods(Hidden, Sealed)
        function diagnoseWith(diag,diagData)
            import matlab.unittest.diagnostics.FileArtifact;
            
            conditionsList = diag.getConditions(diagData);
            
            arrayfun(@(condition) condition.diagnoseWith(diagData),conditionsList);
            
            diag.DiagnosticText = diag.createDiagnosticText(conditionsList);
            
            diag.Artifacts = [FileArtifact.empty(1,0),conditionsList.Artifacts];
        end
        
        function bool = producesSameResultFor(diag,diagData1,diagData2)
            bool = false;
            conditionsList1 = diag.getConditions(diagData1);
            conditionsList2 = diag.getConditions(diagData2);
            if ~isequal(conditionsList1,conditionsList2)
                return;
            end
            
            for condition = conditionsList1
                if ~condition.producesSameResultFor(diagData1,diagData2)
                    return;
                end
            end
            bool = true;
        end
        
        function supplier = getConditionsSupplier(diag)
            supplier = diag.ConditionsSupplier;
        end
        
        function conditions = getConditions(diag,diagData)
            conditions = diag.ConditionsSupplier.getConditions(diagData);
        end
    end
    
    methods(Hidden, Sealed, Access=protected)
        function env = warnIfNeeded(diag)
            import matlab.unittest.internal.getSimpleParentName;
            if diag.WarnOnUse
                warning(message('MATLAB:unittest:ConstraintDiagnostic:ConstraintDiagnosticReliance',...
                    getSimpleParentName(diag.ProducingClass),diag.ProducingClass));
            end
            env = diag.suppressWarnOnUse();
        end
    end
    
    methods(Access=protected)
        function str = getPreDescriptionString(~)
            % getPreDescriptionString - returns text to be displayed prior to the description
            %
            %   This overridable method can be used to inject fields prior to the
            %   Description field.
            str = '';
        end
        
        function str = getPostDescriptionString(~)
            % getPostDescriptionString - returns text to be displayed after the description
            %
            %   This overridable method can be used to inject fields subsequent to the
            %   Description field.
            %   Note: The location of this text is tied to the Description field.
            %         The placement relative to other fields is not guaranteed.
            str = '';
        end
        
        function str = getPostConditionsString(~)
            % getPostConditionsString - returns text to be displayed after the conditions list
            %
            %   This overridable method can be used to inject fields subsequent to the
            %   Conditions field
            %   Note: The location of this text is tied to the Conditions field.
            %         The placement relative to other fields is not guaranteed.
            str = '';
        end
        
        function str = getPostActValString(~)
            % getPostActValString - returns text to be displayed after the actual value
            %
            %   This overridable method can be used to inject fields subsequent to the
            %   ActVal field
            %   Note: The location of this text is tied to the ActVal field.
            %         The placement relative to other fields is not guaranteed.
            str = '';
        end
        
        function str = getPostExpValString(~)
            % getPostExpValString - returns text to be displayed after the expected value
            %
            %   This overridable method can be used to inject fields subsequent to the
            %   ExpVal field
            %   Note: The location of this text is tied to the ExpVal field.
            %         The placement relative to other fields is not guaranteed.
            str = '';
        end
    end
    
    methods
        function value = get.ConditionsList(diag)
            import matlab.unittest.diagnostics.DiagnosticData;
            env = diag.warnIfNeeded(); %#ok<NASGU>
            
            value = diag.getConditions(DiagnosticData());
        end
        
        function set.ConditionsList(diag,conditionsList)
            import matlab.unittest.internal.diagnostics.CompositeConditionsSupplier;
            import matlab.unittest.internal.diagnostics.DirectConditionsSupplier;
            env = diag.warnIfNeeded(); %#ok<NASGU>
            
            validateattributes(conditionsList,{'matlab.unittest.diagnostics.Diagnostic'},{},...
                '','ConditionsList');
            diag.ConditionsSupplier = CompositeConditionsSupplier();
            diag.ConditionsSupplier = diag.ConditionsSupplier.append(...
                DirectConditionsSupplier(conditionsList));
        end
        
        function c = get.FormattableConditions(diag)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            
            c = createFormattableConditionsString(diag.ConditionsList);
        end
    end
    
    methods(Hidden, Sealed)
        function enableWarnOnUseFor(diag,constraint)
            diag.setWarnOnUse(true);
            diag.ProducingClass = class(constraint);
        end
        
        function env = suppressWarnOnUse(diags)
            env = onCleanup.empty(1,0);
            for k=1:numel(diags)
                diag = diags(k);
                origValue = diag.WarnOnUse;
                env = [onCleanup(@() diag.setWarnOnUse(origValue)),env]; %#ok<AGROW>
                diag.setWarnOnUse(false);
            end
        end
        
        function varargout = isequal(varargin)
            env = suppressWarnOnUseForInstancesFound(varargin{:}); %#ok<NASGU>
            [varargout{1:nargout}] = builtin('isequal',varargin{:});
        end
        
        function varargout = isequaln(varargin)
            env = suppressWarnOnUseForInstancesFound(varargin{:}); %#ok<NASGU>
            [varargout{1:nargout}] = builtin('isequal',varargin{:});
        end
        
        function varargout = disp(varargin)
            env = suppressWarnOnUseForInstancesFound(varargin{:}); %#ok<NASGU>
            [varargout{1:nargout}] = builtin('disp',varargin{:});
        end
    end
    
    methods(Access=private,Sealed)
        function setWarnOnUse(diag,value)
            diag.WarnOnUse = value;
        end
        
        function diagText = createDiagnosticText(diag,diagnosedConditions)
            import matlab.unittest.internal.diagnostics.RequirementDiagnostic;
            import matlab.unittest.internal.diagnostics.getDisplayableString;
            
            env = diag.suppressWarnOnUse(); %#ok<NASGU>
            
            % str1:
            %   getPreDescriptionString
            %   Description
            %   getPostDescriptionString
            %   Conditions
            %   getPostConditionsString
            str1 = '';
            str1 = trimAndAppendOnNewline(str1, diag.getPreDescriptionString());
            if diag.DisplayDescription
                str1 = trimAndAppendOnNewline(str1, diag.FormattableDescription);
            end
            str1 = trimAndAppendOnNewline(str1, diag.getPostDescriptionString());
            if diag.DisplayConditions
                
                str1 = trimAndAppendOnNewline(str1, ...
                    createFormattableConditionsString(diagnosedConditions));
            end
            str1 = trimAndAppendOnNewline(str1, diag.getPostConditionsString());
            
            % str2:
            %   ActValHeader
            %   ActVal
            %   getPostActValString
            %   ExpValHeader
            %   ExpVal
            %   getPostExpValString
            str2 = '';
            if diag.DisplayActVal
                str2 = trimAndAppendOnNewline(str2, diag.ActValHeader);
                str2 = trimAndAppendOnNewline(str2, getDisplayableString(diag.ActVal));
            end
            str2 = trimAndAppendOnNewline(str2, diag.getPostActValString());
            if diag.DisplayExpVal
                str2 = trimAndAppendOnNewline(str2, diag.ExpValHeader);
                str2 = trimAndAppendOnNewline(str2, getDisplayableString(diag.ExpVal));
            end
            str2 = trimAndAppendOnNewline(str2, diag.getPostExpValString());
            
            % DiagnosticText:
            %   str1
            %
            %   str2
            diagText = RequirementDiagnostic.trimNewlines(sprintf('%s\n\n%s',str1,str2));
        end
    end
end


function str = createFormattableConditionsString(conditionsList)
import matlab.unittest.internal.diagnostics.FormattableString;
arrowIndentedConditions = arrayfun(@indentResultWithArrow,...
    conditionsList, 'UniformOutput', false);
str = join([FormattableString.empty, arrowIndentedConditions{:}], newline);
end


function cond = indentResultWithArrow(diag)
import matlab.unittest.internal.diagnostics.RequirementDiagnostic;

cond = diag.FormattableDiagnosticText;
cond = RequirementDiagnostic.trimNewlines(cond);
cond = indentWithArrow(cond);
end


function str = trimAndAppendOnNewline(str, newStr)
import matlab.unittest.internal.diagnostics.RequirementDiagnostic;

newStr = RequirementDiagnostic.trimNewlines(newStr);
str = sprintf('%s\n%s',str,newStr);
str = RequirementDiagnostic.trimNewlines(str);
end


function env = suppressWarnOnUseForInstancesFound(varargin)
env = onCleanup.empty(1,0);
for k=1:nargin
    arg = varargin{k};
    if builtin('isa',arg,'matlab.unittest.internal.diagnostics.RequirementDiagnostic')
        env = [arg.suppressWarnOnUse(),env]; %#ok<AGROW>
    end
end
end

% LocalWords:  overridable Formattable