classdef ObjectComparator < matlab.unittest.constraints.Comparator & ...
                            matlab.unittest.internal.mixin.WithinMixin
    % ObjectComparator - Comparator for comparing two MATLAB or Java objects.
    %
    %   ObjectComparator supports any MATLAB or Java object and performs a
    %   comparison by calling the isequaln or isequal method on the expected
    %   value. The comparator uses isequal only if the class of the expected
    %   value defines an isequal method and does not define an isequaln method.
    %   Otherwise, it uses isequaln. An object comparator is satisfied if the
    %   isequal[n] method returns true.
    %
    %   When a tolerance is supplied, ObjectComparator first calls the
    %   isequal[n] method of the expected value. If this check fails,
    %   ObjectComparator then checks for equivalent class, size, and sparsity
    %   of the actual and expected values. If these checks fail, the comparator
    %   is not satisfied. If these checks pass, ObjectComparator delegates
    %   comparison to the supplied tolerance.
    %
    %   ObjectComparator methods:
    %       ObjectComparator - Class constructor
    %
    %   ObjectComparator properties:
    %       Tolerance - A matlab.unittest.constraints.Tolerance object
    %
    %   See also:
    %       matlab.unittest.constraints.Comparator
    %       matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    methods
        function comparator = ObjectComparator(varargin)
            % ObjectComparator - Class constructor
            %
            %   ObjectComparator creates a comparator for MATLAB or Java objects.
            %
            %   ObjectComparator('Within', TOLOBJ) creates a comparator for MATLAB or
            %   JAVA objects using a specified tolerance.
            
            comparator = comparator.parse(varargin{:});
        end
    end
    
    methods(Hidden, Access=protected)
        function bool = supportsContainer(~, value)
            bool = matlab.unittest.internal.constraints.isobject(value);
        end
        
        function bool = containerSatisfiedBy(comparator, actVal, expVal)
            if areEqualUsingIsequalOrIsequaln(actVal, expVal)
                bool = true;
                return;
            end
            
            % Before applying the tolerance, we check for equivalent size,
            % class, and sparsity because ElementwiseTolerance expects
            % these checks to have already been performed. We might loosen
            % this requirement in the future if use cases are discovered
            % where these checks do not make sense.
            bool = comparator.toleranceIsSupportedBy(expVal) && ...
                haveSameClass(actVal,expVal) && ...
                haveSameSize(actVal,expVal) && ...
                haveSameSparsity(actVal,expVal) && ...
                comparator.Tolerance.satisfiedBy(actVal, expVal);
        end
        
        function conds = getContainerConditionsFor(comparator, actVal, expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.MessageDiagnostic;
            
            if areEqualUsingIsequalOrIsequaln(actVal, expVal)
                conds = generateEqualUsingIsequalOrIsequalnCondition(expVal);
                
            elseif ~comparator.toleranceIsSupportedBy(expVal)
                conds = generateNotEqualUsingIsequalOrIsequalnCondition(expVal);
                if ~isempty(comparator.Tolerance)
                    conds = [conds,...
                        MessageDiagnostic('MATLAB:unittest:ObjectComparator:ToleranceNotUsed', class(expVal))];
                end
                
            elseif ~haveSameClass(actVal,expVal)
                conds = [generateNotEqualUsingIsequalOrIsequalnCondition(expVal),...
                    ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(actVal, expVal)];
                
            elseif ~haveSameSize(actVal,expVal)
                conds = [generateNotEqualUsingIsequalOrIsequalnCondition(expVal),...
                    ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(actVal, expVal)];
                
            elseif ~haveSameSparsity(actVal,expVal)
                conds = [generateNotEqualUsingIsequalOrIsequalnCondition(expVal),...
                    ConstraintDiagnosticFactory.generateSparsityMismatchDiagnostic(actVal, expVal)];
                
            else
                conds = comparator.Tolerance.getDiagnosticFor(actVal, expVal);
                if isa(conds, 'matlab.unittest.diagnostics.ConstraintDiagnostic')
                    conds.DisplayActVal = false;
                    conds.DisplayExpVal = false;
                end
                if ~comparator.Tolerance.satisfiedBy(actVal, expVal)
                    conds = [generateNotEqualUsingIsequalOrIsequalnCondition(expVal),conds];
                end
            end
        end
    end
    
    methods(Access=private)
        function bool = toleranceIsSupportedBy(comparator,value)
            tol = comparator.Tolerance;
            bool = ~isempty(tol) && tol.supports(value);
        end
    end
end


function bool = shouldUseIsequaln(obj)
mc = builtin('metaclass',obj);
if ~isempty(mc)
    methodList = mc.MethodList;
    bool = isempty(methodList.findobj('Name','isequal')) || ...
        ~isempty(methodList.findobj('Name','isequaln'));
else
    % Fall back to ismethod to support java, udd, and oops objects
    className = builtin('class',obj);
    bool = ~ismethod(className,'isequal') || ismethod(className,'isequaln');
end
end


function bool = areEqualUsingIsequalOrIsequaln(actVal, expVal)
if shouldUseIsequaln(expVal)
    bool = isequaln(expVal, actVal);
else
    bool = isequal(expVal, actVal);
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


function cond = generateEqualUsingIsequalOrIsequalnCondition(value)
import matlab.unittest.internal.diagnostics.MessageDiagnostic;
if shouldUseIsequaln(value)
    cond = MessageDiagnostic('MATLAB:unittest:ObjectComparator:Equaln');
else
    cond = MessageDiagnostic('MATLAB:unittest:ObjectComparator:Equal');
end
end


function cond = generateNotEqualUsingIsequalOrIsequalnCondition(value)
import matlab.unittest.internal.diagnostics.MessageDiagnostic;
if shouldUseIsequaln(value)
    cond = MessageDiagnostic('MATLAB:unittest:ObjectComparator:NotEqualn');
else
    cond = MessageDiagnostic('MATLAB:unittest:ObjectComparator:NotEqual');
end
end

% LocalWords:  Elementwise Equaln TOLOBJ conds
