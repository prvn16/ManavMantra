classdef (Hidden) ComponentCreation
    %COMPONENTCREATION Suite of functions to assist with informal object
    %creation.
    %
    % Static Methods:
    %
    %  createComponent - Creates a single component given the class name
    %                    and PV Pairs.
    %
    %  createComponentInFamily - Creates a single component that lives in a
    %                            family of components, given the class name
    %                            and the user specified style string.        
    
    methods(Static)
        function component = createComponent(className, functionName, varargin)
            % Helper used by informal functions to create a single
            % component that is not in a family.
            %
            % This should be used by convenience functions that support the following
            % syntaxes:
            %
            %   obj = fun('PropertyName1', value1, 'PropertyName2', value2, ...)
            %
            %   obj = fun(parentHandle, ...)
            %
            % Inputs:
            %
            %   See createComponentInFamily() for the input descriptions.
            
            import matlab.ui.control.internal.model.*;
            
            narginchk(2, Inf)
            
            styles = {};
            
            classNames = {};
            
            component = ComponentCreation.createComponentInFamily(styles, classNames, className, functionName, varargin{:});
            
        end
        
        function component = createComponentInFamily(styles, classNames, defaultClassName, functionName, varargin)
            % Helper used by informal functions to create components
            % that live in a family of components
            %
            % This should be used by convenience functions that support the following
            % syntaxes:
            %
            %   obj = fun('PropertyName1', value1, 'PropertyName2', value2, ...)
            %
            %   obj = fun(style, ...)
            %
            %   obj = fun(parentHandle, ...)
            %
            %   obj = fun(parentHandle, style, ...)
            %
            % Inputs:
            %
            %  styles - a cell array of strings for each available style
            %
            %           Ex: {'foo', 'bar'}
            %
            %  classNames - a cell array of strings, each of which is a fully qualified
            %               MATLAB class.  Each class path corresponds to an element in
            %               STYLES, meaning when a user specifies the iTH style, and
            %               iTH class will be created.
            %
            %               All objects are assumed to:
            %                 - have a public constructor
            %                 - takes no args as well as PV pairs
            %
            %               If a style is not specified, then the DEFAULTCLASSNAME.
            %
            %               Ex: {'matlab.FooComponent', 'matlab.BarComponent'}
            %
            %  defaultClassName - a fully qualified MATLAB class to be created when
            %                     the user does not specify a style within STYLES.
            %
            %                     Ex: {'matlab.FooComponent'}
            %
            %  functionName - name of the function actually called by the caller
            %
            %                 Used for error messages.
            %
            %                 Ex: uifcn
            %
            %  varargin - The user entered arguments that were passed into the
            %             convenience function, as a cell array
            %
            %                       Ex: {'foo', 'SomeProperty', [1 2 3]}
            %
            % Outputs:
            %
            %  component - The created component, whose class will match the given
            %              style if specified, and whos properties will be set to all
            %              specified PV pairs.
            %
            %
            % Example: A function that can create 'foo' or 'bar' objects
            %
            %   function obj = uihelper(varargin)
            %
            %     component = matlab.ui.control.internal.createComponentInFamily(...
            %                       {'foo', 'bar'}, ...
            %                       {'matlab.FooComponent', 'matlab.BarComponent'}, ...
            %                       'uifcn',  ...
            %                       varargin{:}
            %                       );
            
            % Copyright 2011-2015 The MathWorks, Inc.
            
            import matlab.ui.control.internal.model.*;
            
            narginchk(4, Inf)
            
            % Use validator to tease apart inputs and throw specific error
            % messages
            [classNameToCreate, constructorArgs] = ComponentCreation.uiFunctionValidator(styles, classNames, defaultClassName, functionName, varargin{:});
            
            % create the component
            component = ComponentCreation.doCreateComponent(classNameToCreate, functionName, constructorArgs{:});
            
            % If the user did not set Parent through PV Pairs, then set it
            % to a new parent
            if(isempty(component.Parent))
                parentHandle = ComponentCreation.createDefaultParent(functionName);
                component.Parent = parentHandle;
            end
            
        end
        
    end
    
    methods(Static, Access = 'private')
        
        function component = doCreateComponent(classNameToCreate, functionName, varargin)
            
            try
                % Creates the component and passes all PV pairs
                component = feval(classNameToCreate, varargin{:});
                
            catch ex
                
                % There are several well established generic error messages
                % that are useful to users because they represent a well 
                % known specific issue.  A few of the popular ones are
                % worth looking out for and passing on as is as opposed to
                % the general uifunction error message that just says
                % there's a problem somewhere.
                if startsWith(ex.identifier, 'MATLAB:InputParser:')
                
                    messageObj =  message('MATLAB:ui:components:invalidConvenienceSyntax', ...
                        functionName);
                
                    % MnemonicField is last section of error id
                    mnemonicField = 'invalidConvenienceSyntax';
                
                    % Use string from object
                    messageText = getString(messageObj);
                
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(functionName, mnemonicField, messageText);
                    throw(exceptionObject);
                else
                    throw(ex);
                   
                end
                
            end
        end
        
        function parentHandle = createDefaultParent(functionName)
            % Returns the handle to the parent to use when no
            % parent is specified
            
            if(strcmp(functionName,'uitogglebutton') || strcmp(functionName,'uiradiobutton'))
                % Radio and toggle buttons have to be parented to a button
                % group. When no parent is specified, return a button group
                % created inside an uifigure
                parentHandle = matlab.ui.container.ButtonGroup('Parent', uifigure);                
                    
            elseif(strcmp(functionName,'uitreenode'))
                % TreeNodes have to be parented to a Tree and not directly
                % to a uifigure.
                parentHandle = matlab.ui.container.Tree('Parent', uifigure);
                
            else
                % In all other cases, return an uifigure
                parentHandle = uifigure;
            end
        end
        
        function [classNameToCreate, constructorArgs] = uiFunctionValidator(styles, classNames, defaultClassName, functionName, varargin)
            % UIFUNCTIONVALIDATOR - see help for createComponentInFamily for extensive
            % details on expected input arguments
            
            % Returns true if input is valid, otherwise false
            import matlab.ui.control.internal.model.*;
			parentValidator = @(component)...
				isobject(component) && ...
				(ishghandle(component));
            
            % Returns true if input is in styles, otherwise false
            styleValidator = @(styleInput)any(strcmpi(styles, styleInput));
            
            % Validate for valid parent
            parseObj = inputParser;
            parseObj.KeepUnmatched = true;
            parseObj.addOptional('convenienceParent', [], parentValidator)
            
            inputs = varargin;
            
            convenienceParent = [];
            style = '';
            
            if numel(inputs) >= 1
                try
                    
                    parseObj.parse(inputs{1});
                    
                    % Check for equality before assuming that not erroring
                    % out meant the parser found a parent
                    % If inputs{1} is a struct, the parser treats that
                    % input differently and does not error out.
                    if isequal(inputs{1}, parseObj.Results.convenienceParent)
                        
                        convenienceParent = parseObj.Results.convenienceParent;
                         
                        % Remove convenience parent from inputs array
                        inputs = inputs(2:end);
                    end
                    
                catch me
                    % First argument was not a proper parent
                    % If the inputs are empty, do not throw an error, it
                    % means that the function was called like: uibutton()
                    if ~isempty(inputs) && ~ischar(inputs{1}) && ~isstring(inputs{1})
                        % First argument must be a parent or a string.  Style and first
                        % entry of PVPairs are all expected to be strings.
                        
                        messageObj =  message('MATLAB:ui:components:invalidParent', ...
                            'Parent');
                        
                        % MnemonicField is last section of error id
                        mnemonicField = 'invalidParent';
                        
                        % Use string from object
                        messageText = getString(messageObj);
                        
                        % Create and throw exception
                        exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(functionName, mnemonicField, messageText);
                        throw(exceptionObject);
                    end
                end
            end
            
            % Create classNameToCreate
            classNameToCreate = defaultClassName;
                
            % Criteria for throwing a style related error:
                    % 1. The first argument is not empty
                    % 2. Component actually has styles
                    % 3. The first argument is a string
                    
            if numel(inputs) >= 1 && ~isempty(styles)&& (ischar(inputs{1}) || isstring(inputs{1}))
                % Validate for valid style
                parseObj = inputParser;
                parseObj.KeepUnmatched = true;
                parseObj.addOptional('Style', [], styleValidator);
                
                
                try
                    parseObj.parse(inputs{1});
                   
                    
                    % Check for equality before assuming that not erroring
                    % out meant the parser found a style
                    % If inputs{1} is a struct, the parser treats that
                    % input differently and does not error out.
                    if isequal(inputs{1}, parseObj.Results.Style)
                        
                        style = parseObj.Results.Style;
                         
                        % Remove style from inputs array
                        inputs = inputs(2:end);
                    end
                    
                catch me
                    
                    % if the style is a string, but doesn't match any 
                    % properties in the component class. Throw a style 
                    % specific error.
                                       
                    % Introspect on class properties to see if first input
                    % matches one.
                    propertyNames =  properties(classNameToCreate);
                
                    % Get indices of any properties that start with the
                    % string.  This simulates partial property name matching.
                    index = startsWith(string(propertyNames), inputs{1}, 'IgnoreCase', true);
                    
                    throwStyleError = ...
                        numel(styles) > 1 ... % At least one style supported
                        && ~any(index);...   % No(partially) matching property was found
                                          
                    if throwStyleError
                        % If the component supports styles and the 
                        % string specified is not a style match
                        % and the string does not match any property names
                        % throw error for invalid style.
                          
                        % 'style1'
                        initialStyleOptions = ['''', styles{1}, ''''];
                        
                        if numel(styles) > 2
                            % String array of style char arrays
                            remainingStyles = string(styles(2:end-1));
                            
                            % Add comma and single quotes to each style
                            % ", 'style2'"         ", 'style3'"
                            middleStyles = ', ''' + remainingStyles + '''';
                            
                            % Concatinate first and middle style options
                            initialStyleOptions = [initialStyleOptions, char(middleStyles.join(''))];
                        end
                                               
                        lastStyleOption = ['''', styles{end}, ''''];
                        messageObj =  message('MATLAB:ui:components:invalidStyleString', ...
                            inputs{1},...
                            functionName,...
                            initialStyleOptions,...
                            lastStyleOption);
                        % MnemonicField is last section of error id
                        mnemonicField = 'invalidStyleString';
                        
                        % Use string from object
                        messageText = getString(messageObj);
                    
                        % Create and throw exception
                        exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(functionName, mnemonicField, messageText);
                        throw(exceptionObject);
                    end
                end

            end
            if ~isempty(style)
                
                % Find which class the style corresponds to
                matchesStyle = strcmpi(style, styles);
                
                % The first argument matched one of the style strings
                classNameToCreate = classNames{matchesStyle};
                
            end
            
            % Add Parent to pvPairs now that style is processed
            % Parent is prepended to preserve the original order
            if ~isempty(convenienceParent)
                inputs = [{'Parent', convenienceParent}, inputs];
            end
            
            constructorArgs = inputs;           
        end
    end
    
end