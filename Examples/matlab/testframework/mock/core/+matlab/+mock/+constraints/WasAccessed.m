classdef WasAccessed < matlab.unittest.constraints.BooleanConstraint
    % WasAccessed - Constraint specifying that a property was accessed.
    %
    %   The WasAccessed constraint produces a qualification failure for any
    %   actual value that is not a PropertyBehavior. It also produces a
    %   qualification failure for a PropertyBehavior corresponding to a property
    %   that was not accessed the specified number of times.
    %
    %   By default, the constraint qualifies that the property was accessed at
    %   least once. However, any specific count can be specified using the
    %   WithCount name/value pair.
    %
    %   Negate the WasAccessed constraint with the "~" operator to qualify that
    %   a property was not accessed.
    %
    %   WasAccessed methods:
    %       WasAccessed - Class constructor
    %
    %   WasAccessed properties:
    %       Count - Numeric value specifying the property access count
    %
    %   Examples:
    %       import matlab.mock.constraints.WasAccessed;
    %       testCase = matlab.mock.TestCase.forInteractiveUse;
    %
    %       % Create a mock for a person class
    %       [fakePerson, behavior] = testCase.createMock("AddedProperties",["Name","Age"]);
    %       fakePerson.Name = 'David';
    %       fprintf(1, 'The person''s name is %s.\n', fakePerson.Name);
    %
    %       % Passing Cases:
    %       testCase.verifyThat(behavior.Name, WasAccessed);
    %       testCase.verifyThat(behavior.Age, ~WasAccessed);
    %       testCase.verifyThat(behavior.Name, WasAccessed('WithCount',1));
    %
    %       % Failing Cases:
    %       testCase.verifyThat(behavior.Name, ~WasAccessed);
    %       testCase.verifyThat(behavior.Age, WasAccessed);
    %       testCase.verifyThat(behavior.Name, WasAccessed('WithCount',5));
    %
    %   See also:
    %       matlab.mock.TestCase
    %
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Count - Numeric value specifying the property access count
        %
        %   The Count property is a scalar numeric value specifying the exact
        %   number of property accesses.
        %
        %   The Count property is set through the class constructor using the
        %   WithCount name/value pair.
        %
        Count double;
    end
    
    properties (SetAccess=immutable, GetAccess=private)
        HasCount logical = false;
    end
    
    methods
        function constraint = WasAccessed(varargin)
            % WasAccessed - Class constructor
            %
            %   constraint = WasAccessed constructs a WasAccessed instance to determine if
            %   a property was accessed at least once.
            %
            %   constraint = WasAccessed('WithCount',count) constructs a WasAccessed
            %   instance to determine if a property was accessed the specified number
            %   of times. The count must be a scalar numeric value.
            %
            
            parser = matlab.unittest.internal.strictInputParser;
            parser.addParameter('WithCount', [], ...
                @(v)validateattributes(v, {'double'}, {'scalar', 'finite', 'positive', 'integer'}));
            parser.parse(varargin{:});
            
            if ~ismember('WithCount', parser.UsingDefaults)
                constraint.HasCount = true;
                constraint.Count = parser.Results.WithCount;
            end
        end
        
        function bool = satisfiedBy(constraint, actual)
            bool = isPropertyBehavior(actual) && ...
                constraint.propertyWasAccessedTheCorrectNumberOfTimes(get(actual));
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            sense = DiagnosticSense.Positive;
            
            if ~isPropertyBehavior(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, sense, actual);
                diag.addCondition(message('MATLAB:mock:WasAccessed:NotPropertyBehavior', 'PropertyBehavior'));
                return;
            end
            
            getBehavior = get(actual);
            
            if ~constraint.propertyWasAccessedTheCorrectNumberOfTimes(getBehavior)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, sense, getBehavior);
                diag.ActValHeader = getString(message('MATLAB:mock:WasAccessed:SpecifiedPropertyAccess'));
                
                if getBehavior.Count == 0
                    diag.addCondition(getString(message('MATLAB:mock:WasAccessed:PropertyNeverAccessed', actual.Name)));
                else
                    diag.addCondition(getFullCountCondition(getBehavior, constraint.Count, sense, "fail"));
                end
            else % passing
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, sense, getBehavior);
                diag.ActValHeader = getString(message('MATLAB:mock:WasAccessed:SpecifiedPropertyAccess'));
                diag.addCondition(constraint.getCountCondition(getBehavior, sense, "pass"));
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            sense = DiagnosticSense.Negative;
            
            if ~isPropertyBehavior(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, sense, actual);
                diag.addCondition(message('MATLAB:mock:WasAccessed:NotPropertyBehavior', 'PropertyBehavior'));
                return;
            end
            
            getBehavior = get(actual);
            
            if ~constraint.propertyWasAccessedTheCorrectNumberOfTimes(getBehavior)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, sense, getBehavior);
                diag.ActValHeader = getString(message('MATLAB:mock:WasAccessed:SpecifiedPropertyAccess'));
                
                if getBehavior.Count == 0
                    diag.addCondition(getString(message('MATLAB:mock:WasAccessed:PropertyNeverAccessed', actual.Name)));
                else
                    diag.addCondition(getFullCountCondition(getBehavior, constraint.Count, sense, "pass"));
                end
            else % failing
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, sense, getBehavior);
                diag.ActValHeader = getString(message('MATLAB:mock:WasAccessed:SpecifiedPropertyAccess'));
                diag.addCondition(constraint.getCountCondition(getBehavior, sense, "fail"));
            end
        end
    end
    
    methods(Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            diag = constraint.getNegativeConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods (Access=private)
        function bool = propertyWasAccessedTheCorrectNumberOfTimes(constraint, getBehavior)
            if constraint.HasCount
                bool = getBehavior.Count == constraint.Count;
            else
                bool = getBehavior.Count > 0;
            end
        end
        
        function cond = getCountCondition(constraint, getBehavior, sense, passOrFail)
            if constraint.HasCount
                cond = getFullCountCondition(getBehavior, constraint.Count, sense, passOrFail);
            else
                cond = getBasicCountCondition(getBehavior, sense);
            end
        end
    end
    
    methods
        function count = get.Count(constraint)
            if ~constraint.HasCount
                error(message('MATLAB:mock:WasAccessed:NoCount'));
            end
            count = constraint.Count;
        end
    end
end

function bool = isPropertyBehavior(actual)
bool = metaclass(actual) <= ?matlab.mock.PropertyBehavior;
end

function cond = getFullCountCondition(getBehavior, expCount, sense, passOrFail)
import matlab.unittest.diagnostics.ConstraintDiagnostic;

if sense == "Positive" && passOrFail == "pass"
    descKey = 'AccessedExpectedNumberOfTimes';
    expValKey = 'ExpectedPropertyAccessCount';
elseif passOrFail == "pass"
    descKey = 'NotAccessedProhibitedNumberOfTimes';
    expValKey = 'ProhibitedPropertyAccessCount';
elseif sense == "Positive"
    descKey = 'NotAccessedExpectedNumberOfTimes';
    expValKey = 'ExpectedPropertyAccessCount';
else
    descKey = 'AccessedProhibitedNumberOfTimes';
    expValKey = 'ProhibitedPropertyAccessCount';
end

cond = ConstraintDiagnostic;
cond.DisplayDescription = true;
cond.Description = getString(message(['MATLAB:mock:WasAccessed:', descKey], getBehavior.Name));
cond.DisplayActVal = true;
cond.ActValHeader = getString(message('MATLAB:mock:WasAccessed:ActualPropertyAccessCount'));
cond.ActVal = getBehavior.Count;
cond.DisplayExpVal = true;
cond.ExpValHeader = getString(message(['MATLAB:mock:WasAccessed:', expValKey]));
cond.ExpVal = expCount;
end

function cond = getBasicCountCondition(getBehavior, sense)
if sense == "Positive"
    cond = message('MATLAB:mock:WasAccessed:PropertyAccessedAtLeastOnce', getBehavior.Name, getBehavior.Count);
else
    cond = message('MATLAB:mock:WasAccessed:PropertyUnexpectedlyAccessedAtLeastOnce', getBehavior.Name, getBehavior.Count);
end
end

