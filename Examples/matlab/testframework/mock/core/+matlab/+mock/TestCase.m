classdef (Abstract) TestCase < matlab.unittest.TestCase
    % TestCase - TestCase for writing tests using the mocking framework.
    %
    %   The matlab.mock.TestCase class is a class derived from
    %   matlab.unittest.TestCase whose intent is to be used for writing tests
    %   that leverage mocking framework functionality.
    %
    %   matlab.mock.TestCase methods:
    %       forInteractiveUse - Create TestCase to use interactively.
    %       createMock - Create mock object.
    %       getMockHistory - Obtain history of mock object interactions.
    %       assignOutputsWhen - Provide return values for method call or property access.
    %       throwExceptionWhen - Throw exception for method call or property interaction.
    %       storeValueWhen - Store property value.
    %       returnStoredValueWhen - Return stored property value.
    %       verifyCalled - Verify that a method was called with certain inputs.
    %       verifyNotCalled - Verify that a method was never called with certain inputs.
    %       assumeCalled - Assume that a method was called with certain inputs.
    %       assumeNotCalled - Assume that a method was never called with certain inputs.
    %       assertCalled - Assert that a method was called with certain inputs.
    %       assertNotCalled - Assert that a method was never called with certain inputs.
    %       fatalAssertCalled - Fatally assert that a method was called with certain inputs.
    %       fatalAssertNotCalled - Fatally assert that a method was never called with certain inputs.
    %       verifyAccessed - Verify that a property was accessed.
    %       verifyNotAccessed - Verify that a property was never accessed.
    %       assumeAccessed - Assume that a property was accessed.
    %       assumeNotAccessed - Assume that a property was never accessed.
    %       assertAccessed - Assert that a property was accessed.
    %       assertNotAccessed - Assert that a property was never accessed.
    %       fatalAssertAccessed - Fatally assert that a property was accessed.
    %       fatalAssertNotAccessed - Fatally assert that a property was never accessed.
    %       verifySet - Verify that a property was set.
    %       verifyNotSet - Verify that a property was never set.
    %       assumeSet - Assume that a property was set.
    %       assumeNotSet - Assume that a property was never set.
    %       assertSet - Assert that a property was set.
    %       assertNotSet - Assert that a property was never set.
    %       fatalAssertSet - Fatally assert that a property was set.
    %       fatalAssertNotSet - Fatally assert that a property was never set.
    %
    %   Example:
    %       import matlab.unittest.constraints.IsLessThan;
    %       testCase = matlab.mock.TestCase.forInteractiveUse;
    %
    %       % Create a mock for a bank account class
    %       [mock, behavior] = testCase.createMock("AddedMethods",["deposit","isOpen"]);
    %
    %       % Set up behavior
    %       testCase.throwExceptionWhen(behavior.deposit(IsLessThan(0)), ...
    %           MException('Account:deposit:Negative', ...
    %           'Deposit amount must be positive.'));
    %
    %       % Use mock object
    %       mock.deposit(100);
    %       testCase.verifyError(@()mock.deposit(-10), 'Account:deposit:Negative');
    %
    %       % Passing verifications
    %       testCase.verifyCalled(behavior.deposit(100), 'A $100 deposit should have been made.');
    %       testCase.assertNotCalled(behavior.deposit(0));
    %       testCase.assertCalled(behavior.deposit(IsLessThan(0)));
    %
    %       % Failing assertion
    %       testCase.assertCalled(withExactInputs(behavior.isOpen));
    %
    %   See also: matlab.unittest.TestCase
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods (Static)
        function testCase = forInteractiveUse
            % forInteractiveUse - Create a TestCase to use interactively.
            %   TESTCASE = matlab.mock.TestCase.forInteractiveUse creates a TestCase
            %   instance that is configured for experimentation at the MATLAB command
            %   prompt. TESTCASE is a matlab.mock.TestCase instance that reacts to
            %   qualification failures and successes by printing messages to standard
            %   output (the screen) for both passing and failing conditions.
            %
            %   Examples:
            %       import matlab.mock.TestCase;
            %
            %       % Create a TestCase configured for interactive use at the MATLAB
            %       % Command Prompt.
            %       testCase = TestCase.forInteractiveUse;
            %
            %       % Construct mock object and call a method
            %       [mock, behavior] = testCase.createMock("AddedMethods","myMethod");
            %       mock.myMethod('abc');
            %
            %       % Produce a passing verification.
            %       testCase.verifyCalled(behavior.myMethod('abc'));
            %
            %       % Produce a failing verification.
            %       testCase.verifyCalled(behavior.myMethod(123));
            %
            
            import matlab.mock.InteractiveTestCase;
            testCase = InteractiveTestCase;
        end
    end
    
    methods (Sealed)
        function [mock, behavior] = createMock(testCase, varargin)
            % createMock - Create mock object.
            %
            %   [MOCK, BEHAVIOR] = testCase.createMock(METACLASS, varargin) constructs
            %   a mock object MOCK and an associated object BEHAVIOR. Use BEHAVIOR to
            %   define the behavior for MOCK and to qualify interactions with MOCK.
            %
            %   METACLASS is an optional input which specifies the class the mock
            %   object should derive from. The mock object implements all abstract
            %   properties and methods of this class.
            %
            %   createMock optionally accepts any of the following name/value pairs:
            %
            %       * AddedMethods - Methods to add to the mock object.
            %           AddedMethods is a string array or cell array of character
            %           vectors specifying the names of methods to add to the mock
            %           object class.
            %
            %       * AddedProperties - Properties to add to the mock object.
            %           AddedProperties is a string array or cell array of character
            %           vectors specifying the names of properties to add to the mock
            %           object class.
            %
            %       * ConstructorInputs - Inputs to pass to superclass constructor.
            %           ConstructorInputs is a cell array of values to be passed to the
            %           constructor of the specified superclass when constructing the
            %           mock object subclass.
            %
            %       * DefaultPropertyValues - Scalar structure specifying property
            %           default values. Each field refers to the name of a property
            %           implemented on the mock class, and the corresponding value
            %           represents the default value for that property.
            %
            %       * Strict - Logical scalar indicating whether the mock is strict.
            %           When false (default), the mock is tolerant. When true, the mock
            %           implements all abstract methods and properties of the specified
            %           interface to produce an assertion failure when used. For strict
            %           mocks, methods added to the mock using AddedMethods and
            %           properties added to the mock using AddedProperties also, by
            %           default, produce assertion failures when used.
            %
            %   Examples:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Construct mock with specific methods
            %       [mock, behavior] = testCase.createMock('AddedMethods', {'one', 'two', 'three'});
            %
            %       % Construct mock providing constructor inputs
            %       [mock, behavior] = testCase.createMock(?MException, 'ConstructorInputs', {'My:ID', 'My message'});
            %
            %       % Construct strict mock
            %       [mock, behavior] = testCase.createMock(?MyInterface, 'Strict', true);
            %
            %       % Construct mock with property default values
            %       [mock, behavior] = testCase.createMock('AddedProperties',"Prop", ...
            %           'DefaultPropertyValues',struct('Prop',123));
            
            import matlab.mock.internal.MockContext;
            
            context = MockContext(testCase, varargin{:});
            testCase.addTeardown(@deleteMockContext);
            context.constructMock;
            
            mock = context.Mock;
            behavior = context.Behavior;
            
            function deleteMockContext
                delete(context);
            end
        end
        
        function history = getMockHistory(~, mock)
            % getMockHistory - Obtain history of mock object interactions.
            %
            %   history = testCase.getMockHistory(MOCK) returns an array
            %   of InteractionHistory objects indicating the recorded mock object
            %   interactions. Each element in the array corresponds to one method call,
            %   property access, or property modification. The array elements are
            %   ordered with the first element indicating the first recorded
            %   interaction. This method only returns interactions with
            %   publicly-visible methods and properties.
            
            import matlab.mock.InteractionHistory;
            history = InteractionHistory.forMock(mock);
        end
        
        function assignOutputsWhen(~, behavior, varargin)
            % assignOutputsWhen - Provide return values for method call or property access.
            %
            %   testCase.assignOutputsWhen(BEHAVIOR, varargin) defines values to return
            %   when a method is called or a property is accessed.
            %
            %   Examples:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties","PropertyFoo", "AddedMethods","methodBar");
            %       testCase.assignOutputsWhen(get(behavior.PropertyFoo), 'abc');
            %       testCase.assignOutputsWhen(withExactInputs(behavior.methodBar), 1, 2, 3);
            %       % Carry out actions
            %       mock.PropertyFoo
            %       mock.methodBar
            %
            %   See also: matlab.mock.actions.AssignOutputs
            
            import matlab.mock.actions.AssignOutputs;
            
            validateattributes(behavior, {'matlab.mock.MethodCallBehavior', ...
                'matlab.mock.PropertyGetBehavior'}, {'scalar'});
            when(behavior, AssignOutputs(varargin{:}));
        end
        
        function throwExceptionWhen(~, behavior, varargin)
            % throwExceptionWhen - Throw exception for method call or property interaction.
            %
            %   testCase.throwExceptionWhen(BEHAVIOR, EXCEPTION) specifies an exception
            %   to be thrown when a method is called or a property is accessed or set.
            %   The method optionally accepts an MException instance EXCEPTION
            %   specifying the exception to throw. When not specified, the framework
            %   produces a generic exception.
            %
            %   Examples:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties","PropertyFoo", "AddedMethods","methodBar");
            %       testCase.throwExceptionWhen(get(behavior.PropertyFoo));
            %       testCase.throwExceptionWhen(set(behavior.PropertyFoo), ...
            %           MException('PropertyFoo:set', 'Do not change PropertyFoo'));
            %       testCase.throwExceptionWhen(withAnyInputs(behavior.methodBar));
            %       % Carry out actions
            %       mock.PropertyFoo
            %       mock.PropertyFoo = 123;
            %       mock.methodBar;
            %
            %   See also: matlab.mock.actions.ThrowException
            
            import matlab.mock.actions.ThrowException;
            
            validateattributes(behavior, {'matlab.mock.MethodCallBehavior', ...
                'matlab.mock.PropertyGetBehavior', ...
                'matlab.mock.PropertySetBehavior'}, {'scalar'});
            when(behavior, ThrowException(varargin{:}));
        end
        
        function storeValueWhen(~, behavior)
            % storeValueWhen - Store property value.
            %
            %   testCase.storeValueWhen(BEHAVIOR) specifies that the property value
            %   should be stored when a property is set.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       % Create strict mock; all property interactions throw exceptions by default
            %       [mock, behavior] = testCase.createMock("AddedProperties","PropertyFoo", "Strict", true);
            %       % Enable PropertyFoo to be set instead of throwing an exception
            %       testCase.storeValueWhen(set(behavior.PropertyFoo));
            %
            %   See also: matlab.mock.actions.StoreValue
            
            import matlab.mock.actions.StoreValue;
            
            validateattributes(behavior, {'matlab.mock.PropertySetBehavior'}, {'scalar'});
            when(behavior, StoreValue);
        end
        
        function returnStoredValueWhen(~, behavior)
            % returnStoredValueWhen - Return stored property value.
            %
            %   testCase.returnStoredValueWhen(BEHAVIOR) specifies that the stored
            %   value should be returned when a property is accessed.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       % Create strict mock; all property interactions throw exceptions by default
            %       [mock, behavior] = testCase.createMock("AddedProperties","PropertyFoo", "Strict", true);
            %       % Enable PropertyFoo to be accessed instead of throwing an exception
            %       testCase.returnStoredValueWhen(get(behavior.PropertyFoo));
            %
            %   See also: matlab.mock.actions.ReturnStoredValue
            
            import matlab.mock.actions.ReturnStoredValue;
            
            validateattributes(behavior, {'matlab.mock.PropertyGetBehavior'}, {'scalar'});
            when(behavior, ReturnStoredValue);
        end
        
        function verifyCalled(testCase, behavior, varargin)
            % verifyCalled - Verify that a method was called with certain inputs.
            %
            %   testCase.verifyCalled(BEHAVIOR, DIAG) verifies that a method was called
            %   with certain inputs. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedMethods","foo");
            %       mock.foo(123);
            %
            %       % Passing
            %       testCase.verifyCalled(behavior.foo(123));
            %       testCase.verifyCalled(behavior.foo(123), 'Method foo should have been called with input 123.');
            %
            %       % Failing
            %       testCase.verifyCalled(behavior.foo(456));
            %       testCase.verifyCalled(withExactInputs(behavior.foo));
            %
            %   See also: matlab.mock.constraints.WasCalled
            
            import matlab.mock.constraints.WasCalled;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.MethodCallBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(WasCalled, 'verifyCalled');
            testCase.verifyThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function verifyNotCalled(testCase, behavior, varargin)
            % verifyNotCalled - Verify that a method was never called with certain inputs.
            %
            %   testCase.verifyNotCalled(BEHAVIOR, DIAG) verifies that a method was
            %   never called with certain inputs. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedMethods","foo");
            %       mock.foo(123);
            %
            %       % Passing
            %       testCase.verifyNotCalled(behavior.foo(456));
            %       testCase.verifyNotCalled(withExactInputs(behavior.foo));
            %
            %       % Failing
            %       testCase.verifyNotCalled(behavior.foo(123));
            %       testCase.verifyNotCalled(behavior.foo(123), ...
            %           'Method foo should not have been called with input 123.');
            %
            %   See also: matlab.mock.constraints.WasCalled
            
            import matlab.mock.constraints.WasCalled;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.MethodCallBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(~WasCalled, 'verifyNotCalled');
            testCase.verifyThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function assumeCalled(testCase, behavior, varargin)
            % assumeCalled - Assume that a method was called with certain inputs.
            %
            %   testCase.assumeCalled(BEHAVIOR, DIAG) assumes that a method was called
            %   with certain inputs. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedMethods","foo");
            %       mock.foo(123);
            %
            %       % Passing
            %       testCase.assumeCalled(behavior.foo(123));
            %       testCase.assumeCalled(behavior.foo(123), 'Method foo should have been called with input 123.');
            %
            %       % Failing
            %       testCase.assumeCalled(behavior.foo(456));
            %       testCase.assumeCalled(withExactInputs(behavior.foo));
            %
            %   See also: matlab.mock.constraints.WasCalled
            
            import matlab.mock.constraints.WasCalled;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.MethodCallBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(WasCalled, 'assumeCalled');
            testCase.assumeThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function assumeNotCalled(testCase, behavior, varargin)
            % assumeNotCalled - Assume that a method was never called with certain inputs.
            %
            %   testCase.assumeNotCalled(BEHAVIOR, DIAG) assumes that a method was
            %   never called with certain inputs. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedMethods","foo");
            %       mock.foo(123);
            %
            %       % Passing
            %       testCase.assumeNotCalled(behavior.foo(456));
            %       testCase.assumeNotCalled(withAnyInputs(behavior.foo));
            %
            %       % Failing
            %       testCase.assumeNotCalled(behavior.foo(123));
            %       testCase.assumeNotCalled(behavior.foo(123), ...
            %           'Method foo should not have been called with input 123.');
            %
            %   See also: matlab.mock.constraints.WasCalled
            
            import matlab.mock.constraints.WasCalled;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.MethodCallBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(~WasCalled, 'assumeNotCalled');
            testCase.assumeThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function assertCalled(testCase, behavior, varargin)
            % assertCalled - Assert that a method was called with certain inputs.
            %
            %   testCase.assertCalled(BEHAVIOR, DIAG) asserts that a method was called
            %   with certain inputs. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedMethods","foo");
            %       mock.foo(123);
            %
            %       % Passing
            %       testCase.assertCalled(behavior.foo(123));
            %       testCase.assertCalled(behavior.foo(123), 'Method foo should have been called with input 123.');
            %
            %       % Failing
            %       testCase.assertCalled(behavior.foo(456));
            %       testCase.assertCalled(withAnyInputs(behavior.foo));
            %
            %   See also: matlab.mock.constraints.WasCalled
            
            import matlab.mock.constraints.WasCalled;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.MethodCallBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(WasCalled, 'assertCalled');
            testCase.assertThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function assertNotCalled(testCase, behavior, varargin)
            % assertNotCalled - Assert that a method was never called with certain inputs.
            %
            %   testCase.assertNotCalled(BEHAVIOR, DIAG) asserts that a method was
            %   never called with certain inputs. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedMethods","foo");
            %       mock.foo(123);
            %
            %       % Passing
            %       testCase.assertNotCalled(behavior.foo(456));
            %       testCase.assertNotCalled(withAnyInputs(behavior.foo));
            %
            %       % Failing
            %       testCase.assertNotCalled(behavior.foo(123));
            %       testCase.assertNotCalled(behavior.foo(123), ...
            %           'Method foo should not have been called with input 123.');
            %
            %   See also: matlab.mock.constraints.WasCalled
            
            import matlab.mock.constraints.WasCalled;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.MethodCallBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(~WasCalled, 'assertNotCalled');
            testCase.assertThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function fatalAssertCalled(testCase, behavior, varargin)
            % fatalAssertCalled - Fatally assert that a method was called with certain inputs.
            %
            %   testCase.fatalAssertCalled(BEHAVIOR, DIAG) fatally asserts that a method was
            %   called with certain inputs. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedMethods","foo");
            %       mock.foo(123);
            %
            %       % Passing
            %       testCase.fatalAssertCalled(behavior.foo(123));
            %       testCase.fatalAssertCalled(behavior.foo(123), 'Method foo should have been called with input 123.');
            %
            %       % Failing
            %       testCase.fatalAssertCalled(behavior.foo(456));
            %       testCase.fatalAssertCalled(withAnyInputs(behavior.foo));
            %
            %   See also: matlab.mock.constraints.WasCalled
            
            import matlab.mock.constraints.WasCalled;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.MethodCallBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(WasCalled, 'fatalAssertCalled');
            testCase.fatalAssertThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function fatalAssertNotCalled(testCase, behavior, varargin)
            % fatalAssertNotCalled - Fatally assert that a method was never called with certain inputs.
            %
            %   testCase.fatalAssertNotCalled(BEHAVIOR, DIAG) fatally asserts that a
            %   method was never called with certain inputs. DIAG is an optional test
            %   diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedMethods","foo");
            %       mock.foo(123);
            %
            %       % Passing
            %       testCase.fatalAssertNotCalled(behavior.foo(456));
            %       testCase.fatalAssertNotCalled(withAnyInputs(behavior.foo));
            %
            %       % Failing
            %       testCase.fatalAssertNotCalled(behavior.foo(123));
            %       testCase.fatalAssertNotCalled(behavior.foo(123), ...
            %           'Method foo should not have been called with input 123.');
            %
            %   See also: matlab.mock.constraints.WasCalled
            
            import matlab.mock.constraints.WasCalled;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.MethodCallBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(~WasCalled, 'fatalAssertNotCalled');
            testCase.fatalAssertThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function verifyAccessed(testCase, behavior, varargin)
            % verifyAccessed - Verify that a property was accessed.
            %
            %   testCase.verifyAccessed(BEHAVIOR, DIAG) verifies that a property was
            %   accessed. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       value = mock.PropertyFoo;
            %
            %       % Passing
            %       testCase.verifyAccessed(behavior.PropertyFoo);
            %       testCase.verifyAccessed(behavior.PropertyFoo, 'PropertyFoo should have been accessed.');
            %
            %       % Failing
            %       testCase.verifyAccessed(behavior.PropertyBar);
            %
            %   See also: matlab.mock.constraints.WasAccessed
            
            import matlab.mock.constraints.WasAccessed;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(WasAccessed, 'verifyAccessed');
            testCase.verifyThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function verifyNotAccessed(testCase, behavior, varargin)
            % verifyNotAccessed - Verify that a property was never accessed.
            %
            %   testCase.verifyNotAccessed(BEHAVIOR, DIAG) verifies that a property was
            %   never accessed. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       value = mock.PropertyFoo;
            %
            %       % Passing
            %       testCase.verifyNotAccessed(behavior.PropertyBar);
            %
            %       % Failing
            %       testCase.verifyNotAccessed(behavior.PropertyFoo);
            %       testCase.verifyNotAccessed(behavior.PropertyFoo, 'PropertyFoo should have never been accessed.');
            %
            %   See also: matlab.mock.constraints.WasAccessed
            
            import matlab.mock.constraints.WasAccessed;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(~WasAccessed, 'verifyNotAccessed');
            testCase.verifyThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function assumeAccessed(testCase, behavior, varargin)
            % assumeAccessed - Assume that a property was accessed.
            %
            %   testCase.assumeAccessed(BEHAVIOR, DIAG) assumes that a property was
            %   accessed. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       value = mock.PropertyFoo;
            %
            %       % Passing
            %       testCase.assumeAccessed(behavior.PropertyFoo);
            %       testCase.assumeAccessed(behavior.PropertyFoo, 'PropertyFoo should have been accessed.');
            %
            %       % Failing
            %       testCase.assumeAccessed(behavior.PropertyBar);
            %
            %   See also: matlab.mock.constraints.WasAccessed
            
            import matlab.mock.constraints.WasAccessed;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(WasAccessed, 'assumeAccessed');
            testCase.assumeThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function assumeNotAccessed(testCase, behavior, varargin)
            % assumeNotAccessed - Assume that a property was never accessed.
            %
            %   testCase.assumeNotAccessed(BEHAVIOR, DIAG) assumes that a property was
            %   never accessed. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       value = mock.PropertyFoo;
            %
            %       % Passing
            %       testCase.assumeNotAccessed(behavior.PropertyBar);
            %
            %       % Failing
            %       testCase.assumeNotAccessed(behavior.PropertyFoo);
            %       testCase.assumeNotAccessed(behavior.PropertyFoo, 'PropertyFoo should have never been accessed.');
            
            import matlab.mock.constraints.WasAccessed;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(~WasAccessed, 'assumeNotAccessed');
            testCase.assumeThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function assertAccessed(testCase, behavior, varargin)
            % assertAccessed - Assert that a property was accessed.
            %
            %   testCase.assertAccessed(BEHAVIOR, DIAG) asserts that a property was
            %   accessed. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       value = mock.PropertyFoo;
            %
            %       % Passing
            %       testCase.assertAccessed(behavior.PropertyFoo);
            %       testCase.assertAccessed(behavior.PropertyFoo, 'PropertyFoo should have been accessed.');
            %
            %       % Failing
            %       testCase.assertAccessed(behavior.PropertyBar);
            %
            %   See also: matlab.mock.constraints.WasAccessed
            
            import matlab.mock.constraints.WasAccessed;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(WasAccessed, 'assertAccessed');
            testCase.assertThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function assertNotAccessed(testCase, behavior, varargin)
            % assertNotAccessed - Assert that a property was never accessed.
            %
            %   testCase.assertNotAccessed(BEHAVIOR, DIAG) asserts that a property was
            %   never accessed. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       value = mock.PropertyFoo;
            %
            %       % Passing
            %       testCase.assertNotAccessed(behavior.PropertyBar);
            %
            %       % Failing
            %       testCase.assertNotAccessed(behavior.PropertyFoo);
            %       testCase.assertNotAccessed(behavior.PropertyFoo, 'PropertyFoo should have never been accessed.');
            
            import matlab.mock.constraints.WasAccessed;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(~WasAccessed, 'assertNotAccessed');
            testCase.assertThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function fatalAssertAccessed(testCase, behavior, varargin)
            % fatalAssertAccessed - Fatally assert that a property was accessed.
            %
            %   testCase.fatalAssertAccessed(BEHAVIOR, DIAG) fatally asserts that a
            %   property was accessed. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       value = mock.PropertyFoo;
            %
            %       % Passing
            %       testCase.fatalAssertAccessed(behavior.PropertyFoo);
            %       testCase.fatalAssertAccessed(behavior.PropertyFoo, 'PropertyFoo should have been accessed.');
            %
            %       % Failing
            %       testCase.fatalAssertAccessed(behavior.PropertyBar);
            %
            %   See also: matlab.mock.constraints.WasAccessed
            
            import matlab.mock.constraints.WasAccessed;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(WasAccessed, 'fatalAssertAccessed');
            testCase.fatalAssertThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function fatalAssertNotAccessed(testCase, behavior, varargin)
            % fatalAssertNotAccessed - Fatally assert that a property was never accessed.
            %
            %   testCase.fatalAssertNotAccessed(BEHAVIOR, DIAG) fatally asserts that a
            %   property was never accessed. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       value = mock.PropertyFoo;
            %
            %       % Passing
            %       testCase.fatalAssertNotAccessed(behavior.PropertyBar);
            %
            %       % Failing
            %       testCase.fatalAssertNotAccessed(behavior.PropertyFoo);
            %       testCase.fatalAssertNotAccessed(behavior.PropertyFoo, 'PropertyFoo should have never been accessed.');
            
            import matlab.mock.constraints.WasAccessed;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(~WasAccessed, 'fatalAssertNotAccessed');
            testCase.fatalAssertThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function verifySet(testCase, behavior, varargin)
            % verifySet - Verify that a property was set.
            %
            %   testCase.verifySet(BEHAVIOR, DIAG) verifies that a property was set.
            %   DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       mock.PropertyFoo = 123;
            %
            %       % Passing
            %       testCase.verifySet(behavior.PropertyFoo);
            %       testCase.verifySet(behavior.PropertyFoo, 'PropertyFoo should have been set.');
            %
            %       % Failing
            %       testCase.verifySet(behavior.PropertyBar);
            %
            %   See also: matlab.mock.constraints.WasSet
            
            import matlab.mock.constraints.WasSet;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(WasSet, 'verifySet');
            testCase.verifyThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function verifyNotSet(testCase, behavior, varargin)
            % verifyNotSet - Verify that a property was never set.
            %
            %   testCase.verifyNotSet(BEHAVIOR, DIAG) verifies that a property was
            %   never set. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       mock.PropertyFoo = 123;
            %
            %       % Passing
            %       testCase.verifyNotSet(behavior.PropertyBar);
            %
            %       % Failing
            %       testCase.verifyNotSet(behavior.PropertyFoo);
            %       testCase.verifyNotSet(behavior.PropertyFoo, 'PropertyFoo should have been set.');
            %
            %   See also: matlab.mock.constraints.WasSet
            
            import matlab.mock.constraints.WasSet;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(~WasSet, 'verifyNotSet');
            testCase.verifyThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function assumeSet(testCase, behavior, varargin)
            % assumeSet - Assume that a property was set.
            %
            %   testCase.assumeSet(BEHAVIOR, DIAG) assumes that a property was set.
            %   DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       mock.PropertyFoo = 123;
            %
            %       % Passing
            %       testCase.assumeSet(behavior.PropertyFoo);
            %       testCase.assumeSet(behavior.PropertyFoo, 'PropertyFoo should have been set.');
            %
            %       % Failing
            %       testCase.assumeSet(behavior.PropertyBar);
            %
            %   See also: matlab.mock.constraints.WasSet
            
            import matlab.mock.constraints.WasSet;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(WasSet, 'assumeSet');
            testCase.assumeThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function assumeNotSet(testCase, behavior, varargin)
            % assumeNotSet - Assume that a property was never set.
            %
            %   testCase.assumeNotSet(BEHAVIOR, DIAG) assumes that a property was
            %   never set. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       mock.PropertyFoo = 123;
            %
            %       % Passing
            %       testCase.assumeNotSet(behavior.PropertyBar);
            %
            %       % Failing
            %       testCase.assumeNotSet(behavior.PropertyFoo);
            %       testCase.assumeNotSet(behavior.PropertyFoo, 'PropertyFoo should have been set.');
            %
            %   See also: matlab.mock.constraints.WasSet
            
            import matlab.mock.constraints.WasSet;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(~WasSet, 'assumeNotSet');
            testCase.assumeThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function assertSet(testCase, behavior, varargin)
            % assertSet - Assert that a property was set.
            %
            %   testCase.assertSet(BEHAVIOR, DIAG) asserts that a property was set.
            %   DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       mock.PropertyFoo = 123;
            %
            %       % Passing
            %       testCase.assertSet(behavior.PropertyFoo);
            %       testCase.assertSet(behavior.PropertyFoo, 'PropertyFoo should have been set.');
            %
            %       % Failing
            %       testCase.assertSet(behavior.PropertyBar);
            %
            %   See also: matlab.mock.constraints.WasSet
            
            import matlab.mock.constraints.WasSet;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(WasSet, 'assertSet');
            testCase.assertThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function assertNotSet(testCase, behavior, varargin)
            % assertNotSet - Assert that a property was never set.
            %
            %   testCase.assertNotSet(BEHAVIOR, DIAG) asserts that a property was
            %   never set. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       mock.PropertyFoo = 123;
            %
            %       % Passing
            %       testCase.assertNotSet(behavior.PropertyBar);
            %
            %       % Failing
            %       testCase.assertNotSet(behavior.PropertyFoo);
            %       testCase.assertNotSet(behavior.PropertyFoo, 'PropertyFoo should have been set.');
            %
            %   See also: matlab.mock.constraints.WasSet
            
            import matlab.mock.constraints.WasSet;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(~WasSet, 'assertNotSet');
            testCase.assertThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function fatalAssertSet(testCase, behavior, varargin)
            % fatalAssertSet - Fatally assert that a property was set.
            %
            %   testCase.fatalAssertSet(BEHAVIOR, DIAG) fatally asserts that a property
            %   was set. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       mock.PropertyFoo = 123;
            %
            %       % Passing
            %       testCase.fatalAssertSet(behavior.PropertyFoo);
            %       testCase.fatalAssertSet(behavior.PropertyFoo, 'PropertyFoo should have been set.');
            %
            %       % Failing
            %       testCase.fatalAssertSet(behavior.PropertyBar);
            %
            %   See also: matlab.mock.constraints.WasSet
            
            import matlab.mock.constraints.WasSet;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(WasSet, 'fatalAssertSet');
            testCase.fatalAssertThat(behavior, decoratedConstraint, varargin{:});
        end
        
        function fatalAssertNotSet(testCase, behavior, varargin)
            % fatalAssertNotSet - Fatally assert that a property was never set.
            %
            %   testCase.fatalAssertNotSet(BEHAVIOR, DIAG) fatally asserts that a
            %   property was never set. DIAG is an optional test diagnostic.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       [mock, behavior] = testCase.createMock("AddedProperties",["PropertyFoo","PropertyBar"]);
            %       mock.PropertyFoo = 123;
            %
            %       % Passing
            %       testCase.fatalAssertNotSet(behavior.PropertyBar);
            %
            %       % Failing
            %       testCase.fatalAssertNotSet(behavior.PropertyFoo);
            %       testCase.fatalAssertNotSet(behavior.PropertyFoo, 'PropertyFoo should have been set.');
            %
            %   See also: matlab.mock.constraints.WasSet
            
            import matlab.mock.constraints.WasSet;
            import matlab.unittest.internal.constraints.AliasDecorator;
            
            validateattributes(behavior, {'matlab.mock.PropertyBehavior'}, {'scalar'});
            decoratedConstraint = AliasDecorator(~WasSet, 'fatalAssertNotSet');
            testCase.fatalAssertThat(behavior, decoratedConstraint, varargin{:});
        end
    end
end

% LocalWords:  abc unittest Teardown
