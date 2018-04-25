classdef (Sealed) MethodCallBehavior < matlab.mixin.internal.Scalar & matlab.mixin.CustomDisplay
    % MethodCallBehavior - Specify mock object behavior and record interactions.
    %
    %   Use MethodCallBehavior to specify behavior for a mock object method and
    %   provide a record of methods that were called. Methods of the Behavior
    %   return MethodCallBehavior instances. Define behavior by calling the
    %   when method on a MethodCallBehavior. Qualify interactions by passing
    %   the instance to a constraint such as WasCalled.
    %
    %   The framework creates instances of this class, so there is no need for
    %   test authors to construct instances of the class directly.
    %
    %   MethodCallBehavior methods:
    %       when            - Specify mock object method action
    %       withAnyInputs   - Specify any method inputs
    %       withExactInputs - Specify exact method inputs
    %       withNargout     - Specify number of output arguments
    %
    %   See also:
    %       matlab.mock.TestCase
    %       matlab.mock.constraints.WasCalled
    %
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=immutable)
        % Name - String indicating the method name
        %
        %   The Name property is a string that indicates the name of the method.
        %
        Name string;
        
        % Static - Boolean indicating static nature
        %
        %   The Static property is a boolean that indicates when a method is Static.
        %
        Static logical;
    end
    
    properties (Hidden, SetAccess=private)
        % Inputs - Method input arguments
        %
        %   The Inputs property is a cell array of input arguments passed to the
        %   method.
        %
        Inputs cell;
    end
    
    properties (Hidden, SetAccess=private)
        % Nargout - Number of output arguments from method
        %
        %   The Nargout property is a scalar numeric value specifying the criteria
        %   that the number of output arguments from the method call must satisfy.
        %   The default Nargout is matlab.unittest.constraints.IsAnything, meaning
        %   that the number of output arguments can be any value.
        %
        %   Set the Nargout property through the withNargout method.
        %
        %   See also:
        %       withNargout
        %
        Nargout = matlab.unittest.constraints.IsAnything;
    end
    
    properties (Hidden, Dependent, SetAccess=private)
        % Count - Number of times the method was called
        %
        %   The Count property is a scalar double that indicates the number of
        %   times the mock object method was called with the specified input and
        %   output criteria.
        Count double;
        
        % CallsWithAnySignature - List of all observed method calls
        %
        %   The CallsWithAnySignature is a string array representing all
        %   observed calls to the method with any signature.
        CallsWithAnySignature string;
    end
    
    properties (Access=private)
        % HasOutputs - Boolean indicating whether the method produced outputs
        %
        %   The HasOutputs property is a Boolean indicating whether the method call
        %   produced outputs. A method that throws an exception, for example, does
        %   not produce outputs.
        %
        HasOutputs logical = false;
        
        ExactInputs logical = false;
    end
    
    properties (Hidden, SetAccess=private)
        % Outputs - Method output arguments
        %
        %   The Outputs property is a cell array of output arguments returned from
        %   the method.
        %
        Outputs cell;
    end
    
    properties (Hidden, Dependent, SetAccess=private)
        InputRequirements;
        NargoutRequirement;
        OutputRequirements;
    end
    
    properties (Hidden)
        Action;
    end
    
    properties (SetAccess=immutable, GetAccess=private)
        InteractionCatalog matlab.mock.internal.InteractionCatalog;
    end
    
    methods (Hidden)
        function behavior = MethodCallBehavior(catalog, name, static, inputs)
            behavior.InteractionCatalog = catalog;
            behavior.Name = name;
            behavior.Static = static;
            behavior.Inputs = inputs;
        end
        
        function bool = describesMethodCall(behavior, history)
            bool = behavior.basicRequirementsSatisfiedBy(history) && ...
                ~behavior.HasOutputs;
        end
        
        function bool = describesSuccessfulMethodCall(behavior, history)
            bool = behavior.basicRequirementsSatisfiedBy(history) && ...
                behavior.outputRequirementsSatisfiedBy(history);
        end
    end
    
    methods
        function behavior = withNargout(count, behavior)
            % withNargout - Specify the number of output arguments
            %
            %   behavior = withNargout(count, behavior) specifies the number of output
            %   arguments that must be requested from the call to the corresponding
            %   mock object method.
            %
            %   Examples:
            %       import matlab.mock.actions.AssignOutputs;
            %       import matlab.mock.constraints.WasCalled;
            %
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create a mock for a quadrilateral class
            %       [dummyQuad, behavior] = testCase.createMock("AddedMethods","sideLengths");
            %
            %       % Set up behavior
            %       when(withNargout(1, withExactInputs(behavior.sideLengths)), AssignOutputs([2,2,4,4]));
            %       when(withNargout(4, withExactInputs(behavior.sideLengths)), AssignOutputs(2,2,4,4));
            %
            %       len = dummyQuad.sideLengths;
            %
            %       % Verify interactions
            %       testCase.verifyThat(withNargout(1, withExactInputs(behavior.sideLengths)), WasCalled);
            %       testCase.verifyThat(withNargout(4, withExactInputs(behavior.sideLengths)), ~WasCalled);
            %
            
            validateattributes(count, {'double'}, {'scalar', 'finite', 'nonnegative', 'integer'});
            behavior.Nargout = count;
        end
        
        function behavior = withAnyInputs(behavior)
            % withAnyInputs - Specify any method inputs
            %
            %   behavior = withAnyInputs(behavior) specifies a method call with any
            %   number of inputs that can have any value.
            %
            %   Examples:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedMethods","myMethod");
            %       testCase.assignOutputsWhen(withAnyInputs(behavior.myMethod), 'abc');
            %
            %       % All of the following return 'abc':
            %       mock.myMethod
            %       mock.myMethod(123)
            %       myMethod(123, mock)
            %
            %       testCase.verifyCalled(withAnyInputs(behavior.myMethod));
            %
            %   See also:
            %       withExactInputs
            
            import matlab.mock.AnyArguments;
            
            if ~behavior.isAmbiguousSpecification
                error(message('MATLAB:mock:MethodCallBehavior:UnableToSpecifyInputs', 'withAnyInputs'));
            end
            
            behavior.Inputs = {AnyArguments};
        end
        
        function behavior = withExactInputs(behavior)
            % withExactInputs - Specify exact method inputs
            %
            %   behavior = withExactInputs(behavior) specifies a method call with exact
            %   inputs. Use withExactInputs to specify a behavior or qualify an
            %   interaction when a method is called with only the object as an input
            %   and no additional inputs are provided.
            %
            %   Examples:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock('AddedMethods',{'myMethod'});
            %       testCase.assignOutputsWhen(withExactInputs(behavior.myMethod), 'abc');
            %
            %       mock.myMethod       % returns 'abc'
            %       mock.myMethod(123)  % returns default []
            %
            %       testCase.verifyCalled(withExactInputs(behavior.myMethod));
            %
            %   See also:
            %       withAnyInputs
            
            if ~behavior.hasMinimalInputs
                error(message('MATLAB:mock:MethodCallBehavior:UnableToSpecifyInputs', 'withExactInputs'));
            end
            
            behavior.ExactInputs = true;
        end
        
        function when(behavior, action)
            % when - Specify mock object method action
            %
            %   when(behavior, action) is used to specify the action that the mock object
            %   method takes when called with inputs matching those given by the
            %   MethodCallBehavior.
            %
            %   Example:
            %       import matlab.mock.actions.AssignOutputs;
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create a mock for a quadrilateral class
            %       [mock, behavior] = testCase.createMock("AddedMethods","sideLengths");
            %       when(withAnyInputs(behavior.sideLengths), AssignOutputs(2,2,4,4));
            %       [a,b,c,d] = mock.sideLengths
            %
            %   See also:
            %       matlab.mock.actions
            
            if behavior.HasOutputs
                error(message('MATLAB:mock:MethodCallBehavior:MustNotHaveOutputs'));
            end
            behavior.validateUnambiguousMethodCall;
            
            behavior.Action = action;
            behavior.InteractionCatalog.addMethodSpecification(behavior);
        end
        
        function behavior = set.Action(behavior, action)
            validateattributes(action, {'matlab.mock.actions.MethodCallAction'}, {});
            action.applyToAllActionsInList(@(a)validateattributes(a, ...
                {'matlab.mock.actions.MethodCallAction'}, {}));
            behavior.Action = action;
        end
        
        function count = get.Count(behavior)
            behavior.validateUnambiguousMethodCall;
            count = behavior.InteractionCatalog.getMethodCallCount(behavior);
        end
        
        function records = get.CallsWithAnySignature(behavior)
            import matlab.mock.InteractionHistory;
            
            allCalls = behavior.InteractionCatalog.getAllMethodCalls(behavior.Name);
            history = [InteractionHistory.empty, allCalls.Value];
            
            records = strings(1, numel(history));
            for idx = 1:numel(history)
                records(idx) = getOutputArgumentDisplay(history(idx).NumOutputs) + ...
                    history(idx).getDisplaySummary;
            end
        end
        
        function requirements = get.InputRequirements(behavior)
            import matlab.mock.internal.values2requirements;
            requirements = values2requirements(behavior.Inputs);
        end
        
        function requirements = get.OutputRequirements(behavior)
            import matlab.mock.internal.values2requirements;
            requirements = values2requirements(behavior.Outputs);
        end
        
        function outputs = get.Outputs(behavior)
            if ~behavior.HasOutputs
                error(message('MATLAB:mock:MethodCallBehavior:NoOutputs'));
            end
            outputs = behavior.Outputs;
        end
        
        function constraint = get.NargoutRequirement(behavior)
            import matlab.mock.internal.values2requirements;
            constraint = values2requirements({behavior.Nargout});
        end
    end
    
    methods (Hidden)
        function behavior = withOutputs(outputs, behavior)
            % withOutputs - Specify output arguments
            %
            %   behavior = withOutputs(outputs, behavior) specifies the output argument
            %   criteria for the method call.
            %
            
            if ~isequal(outputs, {})
                validateattributes(outputs, {'cell'}, {'row'});
            end
            
            behavior.HasOutputs = true;
            behavior.Outputs = outputs;
        end
    end
    
    methods (Access=private)
        function validateUnambiguousMethodCall(behavior)
            if behavior.isAmbiguousSpecification
                error(message('MATLAB:mock:MethodCallBehavior:AmbiguousMethodCallSpecification', ...
                    behavior.Name, 'withExactInputs', 'withAnyInputs'));
            end
        end
        
        function bool = isAmbiguousSpecification(behavior)
            bool = behavior.hasMinimalInputs && ~behavior.ExactInputs;
        end
        
        function bool = hasMinimalInputs(behavior)
            % A method has minimal inputs if:
            % * Instance methods: only has the behavior instance;
            % * Static methods: has zero inputs
            
            if behavior.Static
                bool = numel(behavior.Inputs) == 0;
                return;
            end
            
            if numel(behavior.Inputs) > 1
                bool = false;
                return;
            end
            
            label = builtin('matlab.mock.internal.getLabel', behavior.Inputs{1});
            bool = isa(label, 'matlab.mock.internal.BehaviorRole');
        end
        
        function bool = basicRequirementsSatisfiedBy(behavior, history)
            bool = behavior.Name == history.Name && ...
                behavior.NargoutRequirement.satisfiedByAllArguments({history.NumOutputs}) && ...
                behavior.InputRequirements.satisfiedByAllArguments(history.Inputs);
        end
        
        function bool = outputRequirementsSatisfiedBy(behavior, history)
            bool = ~behavior.HasOutputs || ...
                behavior.OutputRequirements.satisfiedByAllArguments(history.Outputs);
        end
        
        function str = getStaticMethodCallDisplay(behavior)
            str = "";
            if behavior.Static
                str = getString(message('MATLAB:mock:display:MockObjectSummary', ...
                    behavior.InteractionCatalog.MockObjectSimpleClassName)) + ".";
            end
        end
    end
    
    methods (Hidden, Access=protected)
        function header = getHeader(behavior)
            header = behavior.getClassNameForHeader(behavior);
        end
        
        function footer = getFooter(behavior)
            % Note: this method assumes the object is always scalar.
            
            import matlab.unittest.internal.diagnostics.indent;
            
            if behavior.isAmbiguousSpecification
                displayedInputs = getString(message('MATLAB:mock:display:UnspecifiedSummary'));
            else
                displayedInputs = strjoin([string.empty, behavior.InputRequirements.OneLineSummary], ", ");
            end
            
            footer = indent(getOutputArgumentDisplay(behavior.Nargout) + behavior.getStaticMethodCallDisplay + ...
                behavior.Name + "(" + displayedInputs + ")");
            footer = [footer, newline];
        end
    end
end

function str = getOutputArgumentDisplay(numOutputs)
if isa(numOutputs, 'matlab.unittest.constraints.IsAnything')
    str = "[...] = ";
elseif numOutputs == 0
    str = "";
elseif numOutputs == 1
    str = "out = ";
elseif numOutputs == 2
    str = "[out1, out2] = ";
elseif numOutputs == 3
    str = "[out1, out2, out3] = ";
else
    str = compose("[out1, ..., out%d] = ", numOutputs);
end
end

% LocalWords:  abc unittest strjoin
