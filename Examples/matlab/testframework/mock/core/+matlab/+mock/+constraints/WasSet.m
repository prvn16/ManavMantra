classdef WasSet < matlab.unittest.constraints.BooleanConstraint
    % WasSet - Constraint specifying that a property was set.
    %
    %   The WasSet constraint produces a qualification failure for any actual
    %   value that is not a PropertyBehavior. It also produces a qualification
    %   failure for a PropertyBehavior corresponding to a property that was not
    %   set the specified number of times.
    %
    %   By default, the constraint qualifies that the property was set at least
    %   once. However, any specific count can be specified using the WithCount
    %   name/value pair.
    %
    %   Negate the WasSet constraint with the "~" operator to qualify that a
    %   property was not set.
    %
    %   WasSet methods:
    %       WasSet - Class constructor
    %
    %   WasSet properties:
    %       Value - Value of the property
    %       Count - Numeric value specifying the property set count
    %
    %   Examples:
    %       import matlab.mock.constraints.WasSet;
    %       testCase = matlab.mock.TestCase.forInteractiveUse;
    %
    %       % Create a mock for a person class
    %       [fakePerson, behavior] = testCase.createMock("AddedProperties",["Name","Age"]);
    %
    %       % Use the mock
    %       fakePerson.Name = 'David';
    %
    %       % Passing Cases:
    %       testCase.verifyThat(behavior.Name, WasSet);
    %       testCase.verifyThat(behavior.Age, ~WasSet);
    %       testCase.verifyThat(behavior.Name, WasSet('ToValue','David'));
    %       testCase.verifyThat(behavior.Name, WasSet('WithCount',1));
    %
    %       % Failing Cases:
    %       testCase.verifyThat(behavior.Name, ~WasSet);
    %       testCase.verifyThat(behavior.Age, WasSet);
    %       testCase.verifyThat(behavior.Name, WasSet('ToValue','Andy'));
    %       testCase.verifyThat(behavior.Name, WasSet('WithCount',5));
    %
    %   See also:
    %       matlab.mock.TestCase
    %       matlab.mock.PropertyBehavior
    %
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Value - Value of the property
        %
        %   The Value property represents the value the mock object property must
        %   have been set to.
        %
        %   The Value property is set through the class constructor using the
        %   ToValue name/value pair.
        Value;
        
        % Count - Numeric value specifying the property set count
        %
        %   The Count property is a scalar numeric value specifying the exact
        %   number of property sets.
        %
        %   The Count property is set through the class constructor using the
        %   WithCount name/value pair.
        Count double;
    end
    
    properties (Constant, Access=private)
        Catalog matlab.internal.Catalog = matlab.internal.Catalog('MATLAB:mock:WasSet');
    end
    
    properties (SetAccess=immutable, GetAccess=private)
        HasValue logical = false;
        HasCount logical = false;
    end
    
    methods
        function constraint = WasSet(varargin)
            % WasSet - Class constructor
            %
            %   constraint = WasSet constructs a WasSet instance to determine if a
            %   property was set at least once.
            %
            %   constraint = WasSet('ToValue',value) constructs a WasSet instance to
            %   determine if a property was set to the specified value.
            %
            %   constraint = WasSet('WithCount',count) constructs a WasSet instance to
            %   determine if a property was set the specified number of times. The
            %   count must be a scalar numeric value.
            %
            
            parser = matlab.unittest.internal.strictInputParser;
            parser.addParameter('ToValue',[]);
            parser.addParameter('WithCount',[], ...
                @(v)validateattributes(v, {'double'}, {'scalar', 'finite', 'positive', 'integer'}));
            
            parser.parse(varargin{:});
            
            if ~ismember('ToValue', parser.UsingDefaults)
                constraint.HasValue = true;
                constraint.Value = parser.Results.ToValue;
            end
            
            if ~ismember('WithCount', parser.UsingDefaults)
                constraint.HasCount = true;
                constraint.Count = parser.Results.WithCount;
            end
        end
        
        function bool = satisfiedBy(constraint, actual)
            bool = isPropertyBehavior(actual) && ...
                constraint.propertyWasSetTheCorrectNumberOfTimes(actual);
        end
        
        function diag = getDiagnosticFor(constraint,actual)
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
                diag.addCondition(constraint.Catalog.getString('NotPropertyBehavior', 'PropertyBehavior'));
                return;
            end
            
            setBehavior = constraint.getPropertySetBehavior(actual);
            allSets = setBehavior.SetsToAnyValue;
            
            if ~constraint.propertyWasSetTheCorrectNumberOfTimes(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, sense, setBehavior);
                diag.ActValHeader = constraint.Catalog.getString('SpecifiedPropertySet');
                
                if numel(allSets) == 0
                    diag.addCondition(constraint.Catalog.getString('PropertyNeverSet', actual.Name));
                else
                    diag.addCondition(constraint.getCountDiagnostic(setBehavior, sense, "fail"));
                    diag.addCondition(getInteractionLogCondition(allSets));
                end
                
            else % passing
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, sense, setBehavior);
                diag.ActValHeader = constraint.Catalog.getString('SpecifiedPropertySet');
                diag.addCondition(constraint.getCountDiagnostic(setBehavior, sense, "pass"));
                diag.addCondition(getInteractionLogCondition(allSets));
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
                diag.addCondition(constraint.Catalog.getString('NotPropertyBehavior', 'PropertyBehavior'));
                return;
            end
            
            setBehavior = constraint.getPropertySetBehavior(actual);
            allSets = setBehavior.SetsToAnyValue;
            
            if ~constraint.propertyWasSetTheCorrectNumberOfTimes(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, sense, setBehavior);
                diag.ActValHeader = constraint.Catalog.getString('SpecifiedPropertySet');
                
                if numel(allSets) == 0
                    diag.addCondition(constraint.Catalog.getString('PropertyNeverSet', actual.Name));
                else
                    diag.addCondition(constraint.getCountDiagnostic(setBehavior, sense, "pass"));
                    diag.addCondition(getInteractionLogCondition(allSets));
                end
                
            else % failing
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, sense, setBehavior);
                diag.ActValHeader = constraint.Catalog.getString('SpecifiedPropertySet');
                diag.addCondition(constraint.getCountDiagnostic(setBehavior, sense, "fail"));
                    diag.addCondition(getInteractionLogCondition(allSets));
            end
        end
    end
    
    methods(Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            diag = constraint.getNegativeConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods
        function value = get.Value(constraint)
            if ~constraint.HasValue
                error(message('MATLAB:mock:WasSet:NoValue'));
            end
            value = constraint.Value;
        end
        
        function count = get.Count(constraint)
            if ~constraint.HasCount
                error(message('MATLAB:mock:WasSet:NoCount'));
            end
            count = constraint.Count;
        end
    end
    
    methods (Access=private)
        function bool = propertyWasSetTheCorrectNumberOfTimes(constraint, actual)
            setBehavior = constraint.getPropertySetBehavior(actual);
            if constraint.HasCount
                bool = constraint.Count == setBehavior.Count;
            else
                bool = setBehavior.Count > 0;
            end
        end
        
        function cond = getCountDiagnostic(constraint, setBehavior, sense, passOrFail)
            if constraint.HasCount
                cond = getFullCountCondition(setBehavior, constraint.Count, sense, passOrFail);
            else
                cond = getBasicCountCondition(setBehavior, sense, passOrFail);
            end
        end
        
        function setBehavior = getPropertySetBehavior(constraint, actual)
            if constraint.HasValue
                setBehavior = actual.setToValue(constraint.Value);
            else
                setBehavior = set(actual);
            end
        end
    end
end

function bool = isPropertyBehavior(actual)
bool = metaclass(actual) <= ?matlab.mock.PropertyBehavior;
end

function cond = getFullCountCondition(setBehavior, expCount, sense, passOrFail)
import matlab.unittest.diagnostics.ConstraintDiagnostic;
import matlab.mock.constraints.WasSet;

if sense == "Positive" && passOrFail == "pass"
    descKey = 'PropertySetExpectedNumberOfTimes';
    expValKey = 'ExpectedPropertySetCount';
elseif passOrFail == "pass"
    descKey = 'PropertyNotSetProhibitedNumberOfTimes';
    expValKey = 'ProhibitedPropertySetCount';
elseif sense == "Positive"
    descKey = 'PropertyNotSetExpectedNumberOfTimes';
    expValKey = 'ExpectedPropertySetCount';
else
    descKey = 'PropertySetProhibitedNumberOfTimes';
    expValKey = 'ProhibitedPropertySetCount';
end

cond = ConstraintDiagnostic;
cond.DisplayDescription = true;
cond.Description = WasSet.Catalog.getString(descKey, setBehavior.Name);
cond.DisplayActVal = true;
cond.ActValHeader = WasSet.Catalog.getString('ActualPropertySetCount');
cond.ActVal = setBehavior.Count;
cond.DisplayExpVal = true;
cond.ExpValHeader = WasSet.Catalog.getString(expValKey);
cond.ExpVal = expCount;
end

function cond = getBasicCountCondition(setBehavior, sense, passOrFail)
import matlab.mock.constraints.WasSet;

if sense == "Positive" && passOrFail == "pass"
    cond = WasSet.Catalog.getString('PropertySetAtLeastOnce', setBehavior.Name, setBehavior.Count);
elseif passOrFail == "pass"
    cond = WasSet.Catalog.getString('PropertyNotSetAtLeastOnce', setBehavior.Name);
elseif sense == "Positive"
    cond = WasSet.Catalog.getString('PropertyNotSetAtLeastOnce', setBehavior.Name);
else
    cond = WasSet.Catalog.getString('PropertyUnexpectedlySetAtLeastOnce', setBehavior.Name, setBehavior.Count);
end
end

function cond = getInteractionLogCondition(setsToAnyValue)
import matlab.unittest.internal.diagnostics.indent;
import matlab.mock.constraints.WasSet;

MAX_SETS_DISPLAYED = 10;
numAllCalls = numel(setsToAnyValue);
calls = indent(join(setsToAnyValue(1:min(MAX_SETS_DISPLAYED,numAllCalls)), newline));

if numAllCalls <= MAX_SETS_DISPLAYED
    header = WasSet.Catalog.getString('ObservedPropertySets');
else
    header = WasSet.Catalog.getString('ObservedPropertySetsFirstN', MAX_SETS_DISPLAYED, numAllCalls);
end

cond = sprintf('%s\n%s', header, calls);
end
