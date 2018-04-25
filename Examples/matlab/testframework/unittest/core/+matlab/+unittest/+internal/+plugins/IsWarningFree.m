classdef (Hidden) IsWarningFree < matlab.unittest.constraints.Constraint
    % This class is undocumented and may change in a future release.
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    properties (Constant, Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:FailOnWarningsPlugin');
    end
    
    methods
        function bool = satisfiedBy(~, history)
            bool = isempty(history.Warnings);
        end
        
        function diag = getDiagnosticFor(constraint, history)
            import matlab.unittest.internal.diagnostics.FormattableStringDiagnostic;
            
            if isempty(history.Warnings)
                diag = FormattableStringDiagnostic(constraint.Catalog.getString('IssuedNoWarnings', history.Name));
                return;
            end
            
            header = constraint.Catalog.getString('IssuedWarningsHeader', history.Name);
            warningInfo = arrayfun(@constraint.warningToString, history.Warnings, 'UniformOutput',false);
            diag = FormattableStringDiagnostic(join([header, warningInfo{:}], ''));
        end
    end
    
    methods (Access=private)
        function str = warningToString(constraint, warn)
            import matlab.unittest.internal.trimStackEnd;
            import matlab.unittest.internal.diagnostics.createStackInfo;
            import matlab.unittest.internal.diagnostics.wrapHeader;
            import matlab.unittest.internal.diagnostics.WrappableStringDecorator;
            
            id = warn.identifier;
            if isempty(id)
                id = constraint.Catalog.getString('NoID');
            end
            
            idHeader = wrapHeader(id);
            msg = WrappableStringDecorator(warn.message);
            stackInfo = createStackInfo(trimStackEnd(warn.stack));
            indentedStackInfo = indent(stackInfo);
            
            str = indent(sprintf('\n\n%s\n%s\n%s', idHeader, msg, indentedStackInfo));
        end
    end
end

% LocalWords:  Formattable Wrappable
