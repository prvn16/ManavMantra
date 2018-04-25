classdef (Hidden) MockContext < handle
    % This class is undocumented and will change in a future release.
    
    % MockContext - Context to create mock objects.
    %
    %   Use MockContext to construct a mock object subclass for a
    %   specified class. The mock object subclass implements all abstract
    %   methods of the specified superclass with configurable behavior. The
    %   context also records information about interactions with the methods of
    %   the mock for later qualification.
    %
    %   By default, the mock object is tolerant, meaning that interactions with
    %   the mock object that have no predefined behavior return a value of []
    %   (empty double) for each output argument. Create a strict mock by
    %   specifying the Strict name/value pair. For a strict mock, interactions
    %   with the mock that have no predefined behavior produce an assertion
    %   failure.
    %
    %   MockContext methods:
    %       MockContext   - Class constructor
    %       constructMock - Construct mock object
    %
    %   MockContext properties:
    %       Strict                - Boolean indicating if the mock is strict or tolerant
    %       AddedMethods          - Methods added to the mock object subclass
    %       AddedProperties       - Properties added to the mock object
    %       ConstructorInputs     - Cell array of input arguments passed to superclass constructor
    %       DefaultPropertyValues - Struct specifying property default values
    %       Behavior              - Object used to specify mock object behavior and verify interactions
    %       Mock                  - Mock object subclass instance
    %
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Strict - Boolean indicating if the mock is strict or tolerant
        %
        %   The Strict property is a Boolean indicating if the mock is strict or
        %   tolerant. By default, the mock is tolerant. Set the value of the
        %   Strict property through the constructor using the Strict name/value
        %   pair.
        %
        Strict logical;
        
        % AddedMethods - Methods added to the mock object
        %
        %   The AddedMethods property is a string array representing the names of
        %   methods implemented by the mock object subclass. By default, the
        %   context adds no additional methods to the mock. Set the value of
        %   AddedMethods through the MockContext constructor using the AddedMethods
        %   name/value pair.
        AddedMethods string;
        
        % AddedProperties - Properties added to the mock object
        %
        %   The AddedProperties property is a string array representing the names
        %   of properties implemented by the mock object. By default, the context
        %   adds no additional properties to the mock object. Set the value of
        %   AddedProperties through the MockContext constructor using the
        %   AddedProperties name/value pair.
        AddedProperties string;
        
        % ConstructorInputs - Cell array of input arguments passed to superclass constructor
        %
        %   The ConstructorInputs property is a cell array of input arguments which
        %   are passed to the mock object's superclass constructor when
        %   constructing the mock object instance. By default, the context passes
        %   no arguments to the constructor. Set the value of the ConstructorInputs
        %   property through the MockContext constructor using the
        %   ConstructorInputs name/value pair.
        ConstructorInputs cell;
        
        % DefaultPropertyValues - Struct specifying property default values
        %
        %   The DefaultPropertyValues property is a scalar structure where each
        %   field refers to the name of a property implemented on the mock class,
        %   and the corresponding value represents the default value for that
        %   property.
        DefaultPropertyValues (1,1) struct
    end
    
    properties (SetAccess=private, Transient)
        % Behavior - Object used to specify mock object behavior and verify interactions
        %
        %   The Behavior is an object that implements all methods of the mock
        %   object for which behavior can be defined and interactions can be
        %   observed. Behavior methods return a MethodCallBehavior instance that is
        %   used to define behavior for mock object methods and properties. The
        %   MethodCallBehavior is also used to qualify mock object method and
        %   property interactions.
        %
        %   See also:
        %       matlab.mock.MethodCallBehavior
        Behavior;
        
        % Mock - Mock object subclass instance
        %
        %   The Mock instance performs behaviors and records interactions. The
        %   class of the Mock is a subclass of the class passed to the MockContext
        %   constructor.
        %
        Mock;
    end
    
    properties (Constant, Access=private)
        Parser (1,1) inputParser = createParser;
        BehaviorPackage = 'matlab.mock.classes';
        MockPackage = 'matlab.mock.classes';
    end
    
    properties (Constant, Hidden)
        IgnoredMethodAttributes = ["Abstract", "Access", "DefiningClass", "Description", "DetailedDescription", ...
            "ExplicitConversion", "Hidden", "InputNames", "Name", "OutputNames", "Sealed", "Static"];
        IgnoredPropertyAttributes = ["Abstract", "DefaultValue", "DefiningClass", "Dependent", "Description", ...
            "DetailedDescription", "GetAccess", "GetMethod", "HasDefault", "Name", "SetAccess", "SetMethod", "Validation"];
    end
    
    properties (Access=private, Transient)
        ClassContext matlab.mock.internal.ClassContext;
        StaticMethodNames (1,:) string;
    end
    
    properties (Access=private)
        Assertable matlab.unittest.qualifications.Assertable;
        SuperclassNames (1,:) string;
    end
    
    properties (Access=private, Dependent)
        Superclasses (1,:) meta.class;
        AbstractProperties (1,:) meta.method;
        AbstractMethods (1,:) meta.method;
        OverridableConcreteMethods (1,:) meta.method;
        MockMethodInformation (1,:) matlab.mock.internal.MethodInformation;
        BehaviorMethodInformation (1,:) matlab.mock.internal.MethodInformation;
        MockPropertyInformation (1,:) matlab.mock.internal.PropertyInformation;
        BehaviorPropertyInformation (1,:) matlab.mock.internal.PropertyInformation;
    end
    
    methods
        function context = MockContext(assertable, varargin)
            % MockContext - Class constructor
            %
            %   context = MockContext(assertable) constructs a mock context. The mock
            %   object has no superclasses, methods, or properties.
            %
            %   context = MockContext(assertable, ?MyClass) constructs a context that
            %   defines a mock subclass of MyClass.
            %
            %   context = MockContext(__, 'Strict', true) constructs a
            %   context that defines a strict mock subclass of MyClass.
            %
            %   context = MockContext(__, 'AddedMethods', {'method1', 'method2', ...})
            %   constructs a context that adds method1, method2, etc. to the mock
            %   subclass.
            %
            %   context = MockContext(__, 'AddedProperties', {'Prop1', 'Prop2', ...})
            %   constructs a context that adds Prop1, Prop2, etc. to the mock object.
            %
            %   context = MockContext(__, 'ConstructorInputs', {in1, in2, ...})
            %   constructs a context that passes in1 as the first input, in2 as
            %   the second input, etc. to the MyClass constructor when constructing the
            %   MyClass mock object subclass instance.
            %
            %   context = MockContext(__, 'DefaultPropertyValues,struct('Prop1',value1, 'Prop2',value2, ...))
            %   constructs a context where property Prop1 is assigned a default value
            %   value1, property Prop2 is assigned a default value value2, etc.
            %
            
            context.Assertable = assertable;
            
            parser = context.Parser;
            
            % onCleanup to avoid holding a reference to any DefaultPropertyValues handle objects
            c = onCleanup(@()parser.parse);
            parser.parse(varargin{:});
            
            metaclasses = parser.Results.Superclass;
            strict = parser.Results.Strict;
            addedMethods = parser.Results.AddedMethods;
            addedProperties = parser.Results.AddedProperties;
            constructorInputs = parser.Results.ConstructorInputs;
            defaultPropertyValues = parser.Results.DefaultPropertyValues;
            
            validateMetaclassValue(metaclasses);
            validateAbstractProperties(metaclasses);
            validateAbstractMethods(metaclasses);
            validateAddedMethodsValue(addedMethods, metaclasses);
            validateAddedPropertiesValue(addedProperties, metaclasses);
            validateDefaultPropertyValuesValue(defaultPropertyValues, addedProperties, metaclasses);
            
            context.Superclasses = metaclasses;
            context.Strict = strict;
            context.AddedMethods = addedMethods;
            context.AddedProperties = addedProperties;
            context.ConstructorInputs = constructorInputs;
            context.DefaultPropertyValues = defaultPropertyValues;
        end
        
        function constructMock(context)
            import matlab.mock.internal.UniqueMarker;
            import matlab.mock.internal.validateMethodAttributes;
            import matlab.mock.internal.validatePropertyAttributes;
            
            catalog = context.createCatalog;
            marker = UniqueMarker;
            
            context.createBehavior(catalog, marker);
            
            context.defineDefaultActionsForOverriddenMethods(catalog);
            context.defineDefaultActionsForNewlyImplementedMethods(catalog);
            context.defineDefaultActionsForNewlyImplementedProperties;
            
            context.createMockObject(catalog, marker);
            
            superclassMetaMethods = [context.AbstractMethods, context.OverridableConcreteMethods];
            validateMethodAttributes(superclassMetaMethods, context.Mock, context.IgnoredMethodAttributes);
            
            validatePropertyAttributes(context.AbstractProperties, context.Mock, context.IgnoredPropertyAttributes);
            
            % For performance reasons, determine and store the list of static
            % method names for efficient lookup at mock method invocation time
            staticMethods = superclassMetaMethods.findobj('Static',true);
            context.StaticMethodNames = {staticMethods.Name};
        end
        
        function delete(context)
            arrayfun(@destroyAllInstances, context.ClassContext);
        end
        
        function metaclasses = get.Superclasses(context)
            metaclasses = arrayfun(@meta.class.fromName, context.SuperclassNames, ...
                'UniformOutput',false);
            metaclasses = toRow([meta.class.empty, metaclasses{:}]);
        end
        
        function set.Superclasses(context, metaclasses)
            context.SuperclassNames = {metaclasses.Name};
        end
        
        function abstractProperties = get.AbstractProperties(context)
            % Note: this method returns all abstract properties looking at
            % each superclass individually. It does not consider a property
            % which is abstract in one superclass and concrete in another.
            
            abstractProperties = getAbstractProperties(context.Superclasses);
        end
        
        function methods = get.AbstractMethods(context)
            % Note: this method returns all abstract methods looking at
            % each superclass individually. It does not consider a method
            % which is abstract in one superclass and concrete in another.
            
            methods = arrayfun(@(cls)toRow(cls.MethodList.findobj('Abstract',true)), ...
                context.Superclasses, 'UniformOutput',false);
            methods = [meta.method.empty(1,0), methods{:}];
        end
        
        function methods = get.OverridableConcreteMethods(context)
            methods = arrayfun(@getAllOverridableConcreteMethods, context.Superclasses, ...
                'UniformOutput',false);
            methods = [meta.method.empty(1,0), methods{:}];
            
            % Only consider one method for each unique name
            [~, uniqueIdx] = unique({methods.Name});
            methods = methods(uniqueIdx);
            
            function allMethods = getAllOverridableConcreteMethods(mcls)
                allMethods = getAllVisibleSuperclassMethods(mcls);
                allMethods = allMethods.findobj('Sealed',false, 'Static',false, 'Abstract',false, ...
                    '-not','Name','subsref');
                
                if mcls <= ?handle
                    allMethods = allMethods.findobj('-not','Name','delete');
                end
                if mcls <= ?MException
                    allMethods = allMethods.findobj('-not','Name','BuiltinThrow');
                end
                
                isAccessible = true(size(allMethods));
                for idx = 1:numel(allMethods)
                    access = allMethods(idx).Access;
                    if iscell(access)
                        isAccessible(idx) = any(mcls <= [meta.class.empty, access{:}]);
                    end
                end
                
                allMethods = toRow(allMethods(isAccessible));
            end
        end
        
        function info = get.MockMethodInformation(context)
            import matlab.mock.internal.MethodInformation;
            
            % Added methods have default values for all method attributes
            addedMethods = arrayfun(@MethodInformation, context.AddedMethods, ...
                'UniformOutput',false);
            
            superclassMetaMethods = [context.AbstractMethods, context.OverridableConcreteMethods];
            superclassMethodInfo = cell(1, numel(superclassMetaMethods));
            
            for idx = 1:numel(superclassMetaMethods)
                thisMetaMethod = superclassMetaMethods(idx);
                thisMethodInfo = MethodInformation(thisMetaMethod.Name);
                
                % Match the attributes defined in the superclass
                thisMethodInfo.Hidden = thisMetaMethod.Hidden;
                thisMethodInfo.Static = thisMetaMethod.Static;
                thisMethodInfo.ExplicitConversion = thisMetaMethod.ExplicitConversion;
                
                superclassMethodInfo{idx} = thisMethodInfo;
            end
            
            info = [MethodInformation.empty(1,0), addedMethods{:}, superclassMethodInfo{:}];
        end
        
        function info = get.BehaviorMethodInformation(context)
            % Behavior implements the same methods as the mock but with
            % ExplicitConversion always false.
            info = context.MockMethodInformation;
            [info.ExplicitConversion] = deal(false);
        end
        
        function info = get.MockPropertyInformation(context)
            import matlab.mock.internal.PropertyInformation;
            
            % Added properties have default values for all property attributes
            addedProperties = arrayfun(@PropertyInformation, context.AddedProperties, ...
                'UniformOutput',false);
            
            superclassProperties = context.AbstractProperties;
            superclassPropertyInfo = cell(1, numel(superclassProperties));
            for idx = 1:numel(superclassProperties)
                thisMetaProperty = superclassProperties(idx);
                thisPropertyName = thisMetaProperty.Name;
                thisPropertyInfo = PropertyInformation(thisPropertyName);
                
                % Match the attributes defined in the superclass
                thisPropertyInfo.Transient = thisMetaProperty.Transient;
                thisPropertyInfo.Hidden = thisMetaProperty.Hidden;
                thisPropertyInfo.GetObservable = thisMetaProperty.GetObservable;
                thisPropertyInfo.SetObservable = thisMetaProperty.SetObservable;
                thisPropertyInfo.AbortSet = thisMetaProperty.AbortSet;
                thisPropertyInfo.NonCopyable = thisMetaProperty.NonCopyable;
                thisPropertyInfo.PartialMatchPriority = thisMetaProperty.PartialMatchPriority;
                thisPropertyInfo.NeverAmbiguous = thisMetaProperty.NeverAmbiguous;
                
                superclassPropertyInfo{idx} = thisPropertyInfo;
            end
            
            info = [PropertyInformation.empty(1,0), addedProperties{:}, superclassPropertyInfo{:}];
            
            % Assign default values
            defaultPropertyNames = fieldnames(context.DefaultPropertyValues);
            defaultPropertyValues = struct2cell(context.DefaultPropertyValues);
            [~, infoIdx, propIdx] = intersect([info.Name], defaultPropertyNames);
            defaultPropertyValues = defaultPropertyValues(propIdx);
            [info(infoIdx).DefaultValue] = defaultPropertyValues{:};
        end
        
        function info = get.BehaviorPropertyInformation(context)
            import matlab.mock.internal.PropertyInformation;
            
            % Added properties have default values for all property attributes
            addedProperties = arrayfun(@PropertyInformation, context.AddedProperties, ...
                'UniformOutput',false);
            
            superclassProperties = context.AbstractProperties.findobj('Constant',false);
            superclassPropertyInfo = cell(1, numel(superclassProperties));
            for idx = 1:numel(superclassProperties)
                thisMetaProperty = superclassProperties(idx);
                thisPropertyName = thisMetaProperty.Name;
                thisPropertyInfo = PropertyInformation(thisPropertyName);
                
                % Match the attributes defined in the superclass
                thisPropertyInfo.Hidden = thisMetaProperty.Hidden;
                
                superclassPropertyInfo{idx} = thisPropertyInfo;
            end
            
            info = [PropertyInformation.empty(1,0), addedProperties{:}, superclassPropertyInfo{:}];
        end
    end
    
    methods (Access=private)
        function catalog = createCatalog(context)
            import matlab.mock.internal.InteractionCatalog;
            
            mockClassName = context.createUniqueClassName(context.MockPackage, 'Mock');
            
            methodInfo = context.MockMethodInformation;
            visibleMethodNames = [string.empty, methodInfo(~[methodInfo.Hidden]).Name];
            
            propertyInfo = context.MockPropertyInformation;
            visiblePropertyNames = [string.empty, propertyInfo(~[propertyInfo.Hidden]).Name];
            
            catalog = InteractionCatalog(mockClassName, visibleMethodNames, visiblePropertyNames);
        end
        
        function createBehavior(context, catalog, marker)
            import matlab.mock.internal.ClassContext;
            import matlab.mock.internal.BehaviorRole;
            
            behaviorClassName = context.createUniqueClassName(context.BehaviorPackage, 'Behavior');
                
            classContext = ClassContext(context.BehaviorPackage, behaviorClassName, ...
                string.empty, context.BehaviorMethodInformation, @behaviorMethodCallback, context.BehaviorPropertyInformation, ...
                @behaviorPropertyGetCallback, @behaviorPropertySetCallback, BehaviorRole(marker, catalog)); %#ok<CPROPLC>
            context.ClassContext(end+1) = classContext;
            context.Behavior = classContext.createInstance;
            
            function behaviorMethodCallback(methodCallData)
                import matlab.mock.MethodCallBehavior;
                
                methodName = methodCallData.Name;
                inputs = methodCallData.Inputs;
                
                validateAnyArgumentsUsage(inputs);
                validateBehaviorUsage(methodName, inputs);
                validateScalarBehavior(methodName, inputs);
                
                methodCallData.Outputs{1} = MethodCallBehavior(catalog, methodName, ...
                    context.isStatic(methodName), inputs);
                methodCallData.ReturnAns = true;
            end
            
            function behavior = behaviorPropertyGetCallback(name, ~)
                import matlab.mock.PropertyBehavior;
                behavior = PropertyBehavior(catalog, name);
            end
            
            function behaviorPropertySetCallback(~, ~, ~)
                error(message('MATLAB:mock:MockContext:ModifyProperties', 'Behavior'));
            end
        end
        
        function createMockObject(context, catalog, marker)
            import matlab.mock.internal.ClassContext;
            import matlab.mock.internal.MockObjectRole;
            
            className = catalog.MockObjectSimpleClassName;
            
            classContext = ClassContext(context.MockPackage, className, context.SuperclassNames, ...
                context.MockMethodInformation, @mockMethodCallback, context.MockPropertyInformation, ...
                @mockPropertyGetCallback, @mockPropertySetCallback, MockObjectRole(marker, catalog)); %#ok<CPROPLC>
            context.ClassContext(end+1) = classContext;
            context.Mock = classContext.createInstance(context.ConstructorInputs{:});
            
            function mockMethodCallback(methodCallData)
                import matlab.mock.history.MethodCall;
                import matlab.mock.history.SuccessfulMethodCall;
                import matlab.mock.history.UnsuccessfulMethodCall;
                
                methodName = methodCallData.Name;
                static = context.isStatic(methodName);
                inputs = methodCallData.Inputs;
                numOutputs = methodCallData.NumOutputs;
                
                lookup = MethodCall(className, methodName, static, inputs, numOutputs);
                
                % Find the action to perform
                actionEntry = catalog.lookupMethodSpecification(lookup);
                action = actionEntry.Value.Action;
                actionEntry.Value.Action = action.NextAction;
                
                methodCallRecordEntry = catalog.addMethodEntry(lookup);
                try
                    [outputs{1:numOutputs}] = action.callMethod(className, methodName, static, inputs{:});
                catch exception
                    methodCallRecordEntry.Value = UnsuccessfulMethodCall(className, methodName, static, inputs, numOutputs, exception);
                    rethrow(exception);
                end
                methodCallRecordEntry.Value = SuccessfulMethodCall(className, methodName, static, inputs, numOutputs, outputs);
                
                methodCallData.Outputs = outputs;
            end
            
            function value = mockPropertyGetCallback(name, obj)
                import matlab.mock.history.PropertyAccess;
                import matlab.mock.history.SuccessfulPropertyAccess;
                import matlab.mock.history.UnsuccessfulPropertyAccess;
                
                lookup = PropertyAccess(className, name);
                
                % Find the action to perform
                actionEntry = catalog.lookupPropertyGetSpecification(lookup);
                action = actionEntry.Value.Action;
                actionEntry.Value.Action = action.NextAction;
                
                propertyGetEntry = catalog.addPropertyGetEntry(lookup);
                try
                    value = action.getProperty(className, name, obj);
                catch exception
                    propertyGetEntry.Value = UnsuccessfulPropertyAccess(className, name, exception);
                    rethrow(exception);
                end
                propertyGetEntry.Value = SuccessfulPropertyAccess(className, name, value);
            end
            
            function mockPropertySetCallback(name, obj, value)
                import matlab.mock.history.PropertyModification;
                import matlab.mock.history.SuccessfulPropertyModification;
                import matlab.mock.history.UnsuccessfulPropertyModification;
                
                % Record the interaction
                lookup = PropertyModification(className, name, value);
                
                % Find the action to perform
                actionEntry = catalog.lookupPropertySetSpecification(lookup);
                action = actionEntry.Value.Action;
                actionEntry.Value.Action = action.NextAction;
                
                propertySetEntry = catalog.addPropertySetEntry(lookup);
                try
                    action.setProperty(className, name, obj, value);
                catch exception
                    propertySetEntry.Value = UnsuccessfulPropertyModification(className, name, value, exception);
                    rethrow(exception);
                end
                propertySetEntry.Value = SuccessfulPropertyModification(className, name, value);
            end
        end
        
        function uniqueClassName = createUniqueClassName(context, packageName, roleName)
            import matlab.unittest.internal.getSimpleParentName;
            import matlab.lang.makeUniqueStrings;
            
            package = meta.package.fromName(packageName);
            existingClasses = [package.ClassList, meta.class.empty];
            existingClassNames = cellfun(@getSimpleParentName, {existingClasses.Name}, ...
                'UniformOutput',false);
            className = '';
            if ~isempty(context.SuperclassNames)
                className = getSimpleParentName(context.SuperclassNames{1});
            end
            desiredName = [className, roleName];
            uniqueClassName = makeUniqueStrings(desiredName, existingClassNames, namelengthmax);
        end
        
        function defineDefaultActionsForNewlyImplementedMethods(context, catalog)
            import matlab.mock.MethodCallBehavior;
            import matlab.mock.AnyArguments;
            
            for method = context.AbstractMethods
                when(MethodCallBehavior(catalog, method.Name, method.Static, {AnyArguments}), ...
                    context.getDefaultMethodCallActionFor(method.Name));
            end
            
            for methodName = context.AddedMethods
                when(MethodCallBehavior(catalog, methodName, false, {AnyArguments}), ...
                    context.getDefaultMethodCallActionFor(methodName));
            end
        end
        
        function varargout = produceAssertionFailure(context, msg) %#ok<STOUT>
            import matlab.unittest.internal.diagnostics.MessageDiagnostic;
            context.Assertable.assertFail(MessageDiagnostic(msg));
        end
        
        function action = getDefaultMethodCallActionFor(context, method)
            import matlab.mock.internal.actions.Invoke;
            import matlab.mock.internal.actions.ReturnEmptyDouble;
            
            if context.Strict
                action = Invoke(@(varargin)context.produceAssertionFailure(message( ...
                    'MATLAB:mock:MockContext:UnexpectedMethodCallForStrictMock', method)));
            else
                action = ReturnEmptyDouble;
            end
        end
        
        function defineDefaultActionsForNewlyImplementedProperties(context)
            for property = context.BehaviorPropertyInformation
                propName = property.Name;
                when(get(context.Behavior.(propName)), ...
                    context.getDefaultPropertyGetActionFor(propName));
                when(set(context.Behavior.(propName)), ...
                    context.getDefaultPropertySetActionFor(propName));
            end
        end
        
        function action = getDefaultPropertyGetActionFor(context, property)
            import matlab.mock.internal.actions.Invoke;
            import matlab.mock.actions.ReturnStoredValue;
            
            if context.Strict
                action = Invoke(@(varargin)context.produceAssertionFailure(message( ...
                    'MATLAB:mock:MockContext:UnexpectedPropertyAccessForStrictMock', property)));
            else
                action = ReturnStoredValue;
            end
        end
        
        function action = getDefaultPropertySetActionFor(context, property)
            import matlab.mock.internal.actions.Invoke;
            import matlab.mock.actions.StoreValue;
            
            if context.Strict
                action = Invoke(@(varargin)context.produceAssertionFailure(message( ...
                    'MATLAB:mock:MockContext:UnexpectedPropertySetForStrictMock', property)));
            else
                action = StoreValue;
            end
        end
        
        function defineDefaultActionsForOverriddenMethods(context, catalog)
            import matlab.mock.MethodCallBehavior;
            import matlab.mock.AnyArguments;
            import matlab.mock.internal.actions.CallSuperclass;
            
            for method = context.OverridableConcreteMethods
                action = CallSuperclass(method.DefiningClass);
                when(MethodCallBehavior(catalog, method.Name, false, {AnyArguments}), action);
            end
        end
        
        function bool = isStatic(context, methodName)
            bool = any(context.StaticMethodNames == methodName);
        end
    end
end

function parser = createParser
parser = matlab.unittest.internal.strictInputParser;
parser.addOptional('Superclass', meta.class.empty, @validateMetaclassInput);
parser.addParameter('Strict', false, @validateStrictInput);
parser.addParameter('AddedMethods', string.empty, @validateAddedMethodsInput);
parser.addParameter('AddedProperties', string.empty, @validateAddedPropertiesInput);
parser.addParameter('ConstructorInputs', {}, @validateConstructorInputs);
parser.addParameter('DefaultPropertyValues', struct, @validateDefaultPropertyValues);

    function validateMetaclassInput(mcls)
        if isempty(mcls) && ~isempty(metaclass(mcls)) && (metaclass(mcls) <= ?meta.class)
            error(message('MATLAB:mock:MockContext:ClassNotFound'));
        end
        validateattributes(mcls, {'meta.class'}, {'scalar'});
    end

    function validateStrictInput(strict)
        validateattributes(strict, {'logical'}, {'scalar'});
    end

    function validateAddedMethodsInput(addedMethods)
        validateStringOrCellstrInput('AddedMethods', addedMethods);
        addedMethods = string(addedMethods);
        
        % Valid method names consist of an arbitrarily long list of MATLAB variable
        % names joined with dots (for converter methods).
        for thisMethod = addedMethods
            parts = strsplit(thisMethod, '.', 'CollapseDelimiters',false);
            allPartsValid = cellfun(@isvarname, cellstr(parts));
            if ~all(allPartsValid)
                error(message('MATLAB:mock:MockContext:InvalidMethodName', thisMethod));
            end
        end
        
        % Added methods must not contain repetitions
        duplicate = findFirstDuplicate(addedMethods);
        if ~isempty(duplicate)
            error(message('MATLAB:mock:MockContext:RepeatedAddedMethod', ...
                duplicate, 'AddedMethods'));
        end
    end

    function validateAddedPropertiesInput(addedProperties)
        validateStringOrCellstrInput('AddedProperties', addedProperties);
        addedProperties = string(addedProperties);
        
        % Property names must be valid identifiers
        for prop = addedProperties
            if ~isvarname(prop)
                error(message('MATLAB:mock:MockContext:InvalidPropertyName', prop));
            end
        end
        
        % Added properties must not contain repetitions
        duplicate = findFirstDuplicate(addedProperties);
        if ~isempty(duplicate)
            error(message('MATLAB:mock:MockContext:RepeatedAddedProperty', ...
                duplicate, 'AddedProperties'));
        end
    end

    function validateDefaultPropertyValues(defaultPropertyValues)
        validateattributes(defaultPropertyValues, {'struct'}, {'scalar'});
    end

    function validateStringOrCellstrInput(name, value)
        if ~isequal(value,{}) && ~isequal(value, string.empty)
            validateattributes(value, {'cell', 'string'}, {'row'});
        end
        if ~isstring(value) && ~(iscellstr(value) && all(cellfun(@isrow, value(:))))
            error(message('MATLAB:mock:MockContext:MustBeStringOrCellOfCharacterVectors', name));
        end
        if any(ismissing(string(value)))
            error(message('MATLAB:mock:MockContext:MissingString'));
        end
    end
end

function validateMetaclassValue(metaclasses)
for mcls = metaclasses
    if metaclass(mcls) ~= ?meta.class
        error(message('MATLAB:mock:MockContext:ClassHasCustomMetaclass', ...
            mcls.Name));
    end
end
end

function validateAbstractProperties(metaclasses)
for mcls = metaclasses
    abstractProperties = mcls.PropertyList.findobj('Abstract',true);
    for prop = toRow(abstractProperties)
        if ~isempty(prop.Validation)
            error(message("MATLAB:mock:MockContext:PropertyValidationNotSupported", mcls.Name, prop.Name));
        end
    end
end
end

function validateAbstractMethods(metaclasses)
% Mock object superclasses cannot specify an Abstract subsref method.

for mcls = metaclasses
    abstractMethods = mcls.MethodList.findobj('Abstract',true);
    if ~isempty(abstractMethods.findobj('Name','subsref'))
        error(message('MATLAB:mock:MockContext:ForbiddenAbstractMethod', ...
            mcls.Name, 'subsref'));
    end
end
end

function validateAddedMethodsValue(addedMethods, metaclasses)
if isempty(addedMethods)
    % Early return when no validation is needed
    return;
end

if ismember("subsref", addedMethods)
    error(message('MATLAB:mock:MockContext:UnableToAddMethod', 'AddedMethods', 'subsref'));
end

for mcls = metaclasses
    existingNonPrivateMethods = getAllVisibleSuperclassMethods(mcls);
    repeatedMethods = intersect(addedMethods, {existingNonPrivateMethods.Name});
    if ~isempty(repeatedMethods)
        error(message('MATLAB:mock:MockContext:UnableToAddExistingMethod', ...
            'AddedMethods', repeatedMethods{1}, mcls.Name));
    end
end
end

function validateAddedPropertiesValue(addedProperties, metaclasses)
if isempty(addedProperties)
    % Early return when no validation is needed
    return;
end

for mcls = metaclasses
    existingNonPrivateProperties = mcls.PropertyList.findobj('-not', ...
        {'GetAccess','private','-and',{'SetAccess','private','-or','SetAccess','immutable','-or','SetAccess','none'}});
    repeatedProperties = intersect(addedProperties, {existingNonPrivateProperties.Name});
    if ~isempty(repeatedProperties)
        error(message('MATLAB:mock:MockContext:UnableToAddExistingProperty', ...
            'AddedProperties', repeatedProperties{1}, mcls.Name));
    end
end
end

function validateDefaultPropertyValuesValue(defaultPropertyValues, addedPropertyNames, metaclasses)
abstractProperties = getAbstractProperties(metaclasses);
abstractPropertyNames = {abstractProperties.Name};

defaultPropertyNames = toRow(fieldnames(defaultPropertyValues));
extraProperties = setdiff(defaultPropertyNames, [abstractPropertyNames, addedPropertyNames]);

if ~isempty(extraProperties)
    error(message('MATLAB:mock:MockContext:UnableToSpecifyDefaultValueForNonexistentProperty', ...
        "DefaultPropertyValues", extraProperties{1}));
end
end

function duplicate = findFirstDuplicate(str)
[~, uniqueIdx] = unique(str);
mask = true(1,numel(str));
mask(uniqueIdx) = false;
duplicate = str(find(mask,1));
end

function validateConstructorInputs(value)
if ~isequal(value,{})
    validateattributes(value, {'cell'}, {'row'});
end
end

function allMethods = getAllVisibleSuperclassMethods(mcls)
import matlab.unittest.internal.getSimpleParentName;

allMethods = mcls.MethodList.findobj('-not','Access','private', ...
    '-not','Name',getSimpleParentName(mcls.Name));
end

function abstractProperties = getAbstractProperties(mcls)
abstractProperties = arrayfun(@(cls)toRow(cls.PropertyList.findobj('Abstract',true)), ...
    mcls, 'UniformOutput',false);
abstractProperties = [meta.property.empty(1,0), abstractProperties{:}];
end

function validateAnyArgumentsUsage(inputs)
for idx = 1:numel(inputs)-1
    if builtin('metaclass',inputs{idx}) == ?matlab.mock.AnyArguments
        error(message('MATLAB:mock:MockContext:AnyArgumentsMustBeLast', 'AnyArguments'))
    end
end
end

function validateBehaviorUsage(methodName, inputs)
for idx = 1:numel(inputs)
    label = builtin('matlab.mock.internal.getLabel', inputs{idx});
    if isa(label, 'matlab.mock.internal.MockObjectRole')
        error(message('MATLAB:mock:MockContext:UnexpectedInput', ...
            'Mock', methodName, 'Behavior'));
    end
end
end

function validateScalarBehavior(methodName, inputs)
for idx = 1:numel(inputs)
    label = builtin('matlab.mock.internal.getLabel', inputs{idx});
    if isa(label, 'matlab.mock.internal.BehaviorRole') && ~isequal(builtin('size',inputs{idx}), [1,1])
        error(message('MATLAB:mock:MockContext:NonScalarInput', 'Behavior', methodName));
    end
end
end

function value = toRow(value)
value = reshape(value, 1, []);
end

% LocalWords:  mcls lang Overridable overridable isstring assertable CPROPLC
% LocalWords:  superclass's ismissing metaclasses cls func unittest Cancelable
% LocalWords:  strsplit
