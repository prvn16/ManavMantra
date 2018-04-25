classdef LogicalComparator < matlab.unittest.constraints.Comparator
    % LogicalComparator - Comparator for comparing two MATLAB logical values
    %
    %   The LogicalComparator comparator supports MATLAB logicals and
    %   performs a comparison using the isequal method. A logical
    %   comparator is satisfied if the actual and expected values have the
    %   same sparsity and the isequal method returns true.
    %
    %   LogicalComparator methods:
    %       LogicalComparator - Class constructor
    %
    %   See also:
    %       matlab.unittest.constraints.Comparator
    %       matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2016 The MathWorks, Inc.
    
    methods
        function comparator = LogicalComparator()
            % LogicalComparator - Class constructor
            %
            %   LogicalComparator creates a comparator for two logical values.
        end
    end
    
    methods(Hidden, Access=protected)
        function bool = supportsContainer(~, value)
            bool = builtin('islogical',value) && ~builtin('isobject',value);
        end
        
        function bool = containerSatisfiedBy(~, actVal, expVal)
            bool = haveSameClass(actVal,expVal) && ...
                haveSameSize(actVal,expVal) && ...
                haveSameSparsity(actVal,expVal) && ...
                isequal(actVal, expVal);
        end
        
        function conds = getContainerConditionsFor(~, actVal, expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.MessageDiagnostic;
            
            if ~haveSameClass(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(actVal, expVal);
            elseif ~haveSameSize(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(actVal, expVal);
            elseif ~haveSameSparsity(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateSparsityMismatchDiagnostic(actVal, expVal);
            elseif ~isequal(actVal, expVal)
                conds = MessageDiagnostic('MATLAB:unittest:LogicalComparator:NotEqual');
            else
                conds = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
            end
        end
    end
end


function bool = haveSameClass(actVal,expVal)
bool = strcmp(class(actVal), class(expVal));
end


function bool = haveSameSize(actVal,expVal)
bool = isequal(size(actVal), size(expVal));
end


function bool = haveSameSparsity(actVal,expVal)
bool = (issparse(actVal) == issparse(expVal));
end