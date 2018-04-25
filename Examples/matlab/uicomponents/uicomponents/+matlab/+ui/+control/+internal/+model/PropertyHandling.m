classdef (Hidden) PropertyHandling
    % This undocumented class may be removed in a future release.
    
    % PropertyHandling contains static methods for processing and
    % validating property values common to different visual components.
    
    % Copyright 2011-2017 The MathWorks, Inc.
    
    % ---------------------------------------------------------------------
    % Functions for use by Visual Components
    % ---------------------------------------------------------------------
    methods(Static)
        function exceptionObject = createException(component, mnemonicField, messageText, varargin)
            % CREATEEXCEPTION - This creates an exception object.  The
            % ErrorID is of the form
            % MATLAB:ui:ComponentName:ErrorDescription
            % For example:
            % MATLAB:ui:Gauge:invalidValue
            
            componentName = matlab.ui.control.internal.model.PropertyHandling.getComponentClassName(component);
            
            errId = ['MATLAB:ui:', componentName, ':', mnemonicField];
            exceptionObject = MException(errId, messageText, varargin{:});
        end
        
        function displayWarning(component, mnemonicField, messageText, varargin)
            % DISPLAYWARNING- This display a warning.
            % The warning as a msgID is of the form
            % MATLAB:ui:ComponentName:WarningDescription
            % For example:
            % MATLAB:ui:Slider:fixedHeight
            
            componentName = matlab.ui.control.internal.model.PropertyHandling.getComponentClassName(component);
            
            msgId = ['MATLAB:ui:', componentName, ':', mnemonicField];
            warning(msgId, messageText, varargin{:});
        end
        
        function messageWithDocLink = createMessageWithDocLink(errorText, linkId, docFunction)
            % CREATEMESSAGEWITHDOCLINK - This function will create a 
            % message object for cases where the default message has a 
            % hyperlink, but when hyperlinks are not available, there is a 
            % second message providing context that the link might have provided. 
            % For example:
            % With link (sprintf is link)
            % For more information on formatting operators, see sprintf. 
            % Without link, a little more context is provided so user can
            % find the same information without a link.
            % For more information on formatting operators, see the documentation for sprintf. 
            
                                   
            if matlab.internal.display.isHot
                % Create message object with link
                docReference = ['<a href="matlab: helpPopup(''', docFunction, ''')">', docFunction, '</a>'];
            else
               % Create message object without link
                docReference = docFunction;
            end
            
            messageObj = message(linkId, docReference);
            
            % Use string from object
            messageText = getString(messageObj);
            messageWithDocLink = sprintf('%s\n\n  %s', errorText, messageText);
                        
        end
        
        function className = getComponentClassName(component)
            % Returns the class name of a component.
            % The class name is stripped from the package name.
            % E.g.
            % The returned class name for an instance of the class
            % matlab.ui.control.Button is 'Button'
            
            if ischar(component)
                % The class name was given, not the instance. Return as is.
                className = component;
            else
                % Input was an instance
                
                % Full class name of component including package
                % information
                className = class(component);
                
                % Separate class name into separate strings that represent
                % the packages and class name
                packageStrings = regexp(className, '\.', 'split');
                
                % The Component Name is the
                className = packageStrings{end};
            end
        end
        
        function result = isString(value)
            % Returns whether value is a string.
            
            % Note: check for empty string separately because isrow
            % of empty string returns false
            result = ischar(value) && (isrow(value)||strcmp(value,''));
        end
        
        function isElementPresent = isElementPresent(array, element)
            % Checks if ELEMENT is in ARRAY, according to isequal(), and
            % returns true or false.
            %
            % Inputs:
            %
            %  ARRAY -  a 1xN array or cell array
            %
            %           All elements in the array must support isequal().
            %
            % Ouputs:
            %
            %  ISELEMENTPRESENT - true if ELEMENT was found in ARRAY,
            %                     according to isequal()
            narginchk(2, 2)
            
            if(isempty(array))
                isElementPresent = false;
                return;
            end
            
            if(iscell(array))
                if(isempty(element) && isa(element, 'double'))
                    isElementPresent = false;
                else
                    % Ex: array = {'a', 'b', 'c'}
                    isElementPresent = any(cellfun(@(x) isequal(x, element), array));
                end
            else
                % numeric array
                % Ex: array = [1 2 3]
                isElementPresent = any(arrayfun(@(x) isequal(x, element), array));
            end
        end
        
        function output = processCellArrayOfStrings(component, propertyName, input, sizeConstraints)
            % Validates that the input is a cell array of strings and
            % optionally, is of a certain size.
            %
            % The array is returned, where it is guaranteed to be a row
            % vector, if the original array was passed in as a column
            % vector.
            %
            % Inputs:
            %
            %  COMPONENT - handle to component model throwing the error
            %
            %  INPUT -  input to validate as a cell array of strings
            %
            %  SIZECONSTRAINTS - 1x2 vector representing the minimum and
            %                    maximum number of elements
            %
            % Ouputs:
            %
            %  OUTPUT - the INPUT array, but as a row vector if a column
            %           vector was passed in
            narginchk(4, 4);
            
            % Convert string to cell array of characters.
            if(isstring(input))
                input = cellstr(input);
            end
            
            % special check for {} because {} does not pass the test of
            % being a vector
            if(isempty(input) && iscell(input) && sizeConstraints(1) == 0)
                output = input;
                return;
            end
            
            % validate cell of all strings
            if(~iscellstr(input))
                messageObj = message('MATLAB:ui:components:InvalidInputNotACellOfStrings', propertyName);
                
                % MnemonicField is last section of error id
                mnemonicField = 'InvalidInputNotACellOfStrings';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            if iscell(input)
            
                % check sizes
                elements = numel(input);
                if sizeConstraints(1) == sizeConstraints(2) && elements ~=sizeConstraints(1)
                
                    messageObj = message('MATLAB:ui:components:InputSizeWrong', propertyName, num2str(sizeConstraints(1)));
                
                    % MnemonicField is last section of error id
                    mnemonicField = 'InputSizeWrong';
                
                    % Use string from object
                    messageText = getString(messageObj);
                
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                    throw(exceptionObject);
                elseif (elements < sizeConstraints(1))
                
                    messageObj = message('MATLAB:ui:components:InputSizeTooSmall', propertyName, num2str(sizeConstraints(1)));
                
                    % MnemonicField is last section of error id
                    mnemonicField = 'InputSizeTooSmall';
                
                    % Use string from object
                    messageText = getString(messageObj);
                
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                    throw(exceptionObject);
                
                elseif (elements > sizeConstraints(2))
                
                    messageObj = message('MATLAB:ui:components:InputSizeTooLarge', propertyName, num2str(sizeConstraints(2)));
                
                    % MnemonicField is last section of error id
                    mnemonicField = 'InputSizeTooLarge';
                
                    % Use string from object
                    messageText = getString(messageObj);
                
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                    throw(exceptionObject);
                
                end
            end
            
            % Verify that it is a vector and reshape
            validateattributes(input, ...
                {'cell'}, {'vector'});
            
            % reshape to row
            output = matlab.ui.control.internal.model.PropertyHandling.getOrientedVectorArray(input, 'horizontal');
        end
        
        function output = processEnumeratedString(component, input, availableStrings)
            % Validates that the given INPUT is a valid enumerated string
            % in the AVAILABLESTRINGS set.
            %
            % A string is valid if it is a full match, i.e. not a partial
            % match.  The case of INPUT is ignored.
            %
            % A string OUTPUT is returned, where it is guaranteed to be the
            % proper casing, if INPUT was not a direct case match.
            %
            % Inputs:
            %
            %  COMPONENT - handle to component model throwing the error
            %
            %  INPUT  - the input from a user to validate
            %
            %           An error is thrown if INPUT is not in AVAILABLESTRINGS.
            %
            %  AVAILABLESTRINGS - The set of strings to match INPUT
            %                     against
            %
            % Ouputs:
            %
            %  OUTPUT - the property value a component should store.
            %
            %           An example would be if the user typed 'Auto', and
            %           the component wants to store the proper value
            %           'auto'.
            
            % validate string:
            % - ensures INPUT is a string
            % - finds the best match
            % - however, works with partial matching
            output = validatestring(input,...
                availableStrings);
            
            % ensures that a partial match did not happen and case is
            % ignored
            if(~strcmpi(output, input))
                
                messageObj = message('MATLAB:ui:components:InvalidInputOnlyPartialMatch');
                
                % MnemonicField is last section of error id
                mnemonicField = 'InvalidInputOnlyPartialMatch';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
        end
        
        function output = validateCellArrayOfEnumeratedStringsOrNumbers(input, validStrings)
            % Validate that input is a vector cell of valid strings or positive numbers
            % If input is valid, an output is returned, where:
            % 
            %  - A nx1 vector is accepted and returned as 1xn
            %  - Partial match are converted to the full match
            %  - Case mismatch are converted to match the case in
            %  validStrings
            %
            %
            % e.g. 
            % input = {10,'Auto'}
            % validStrings = {'auto','grow'} 
            % is valid and returns {10,'auto'}
            %
            % e.g. 
            % input = {10;'au'}
            % validStrings = {'manual','auto'} 
            % is valid and returns {10,'auto'}
            
            
            if(iscell(input) && isempty(input))
                % Treat {} separately because it doesn't pass the test of
                % 'vector' in validateattribute
                output = input;
                return
            end
            
            % Verify that it is a vector 
            validateattributes(input, ...
                {'cell'}, ...
                {'vector'});
            
            % Reshape to row
            input = matlab.ui.control.internal.model.PropertyHandling.getOrientedVectorArray(input, 'horizontal');
            
            % Validate each element of the cell
            output = input;
            for k = 1:length(input)
                el = input{k};
                if isnumeric(el) && isreal(el) && isfinite(el) && ~isnan(el) && el >= 0 
                    output{k} = el;
                else
                    el = validatestring(el, validStrings);
                    output{k} = el;
                end
            end
            
        end
        
        function output = processMode(component, input)
            % Validates that the given input is a valid string for a
            % 'Mode' property.
            %
            % The original string is returned, where it is guaranteed to be
            % the property lower case value 'auto' or 'manual', if the
            % passed in input was not of the proper case.
            %
            % Inputs:
            %
            %  INPUT  - the input from a user to validate
            %
            %           An error is thrown if INPUT is not valid.
            %
            % Ouputs:
            %
            %  OUTPUT - the property value a component should store.
            %
            %           An example would be if the user typed 'Auto', and
            %           the component wants to store the proper value
            %           'auto'.
            output = matlab.ui.control.internal.model.PropertyHandling.processEnumeratedString(...
                component, ...
                input, ...
                {'auto', 'manual'});
        end
        
        function output = processItemsDataInput(component, propertyName, input, sizeConstraints)
            % Validates that the input is a vector array or vector cell array
            % An error is thrown if the input is not valid
            %
            % If the input is an Nx1 vector, it will be converted into
            % a 1xN vector
            %
            % Inputs:
            %
            %  COMPONENT - handle to component model throwing the error
            %
            %  INPUT  - the input from a user to validate
            %
            %  SIZECONSTRAINTS - 1x2 vector representing the minimum and
            %                    maximum number of elements
            %
            % Ouputs:
            %
            %  OUTPUT - the property value a component should store.
            %
            %           An example would be if the user entered a Nx1 cell,
            %           and the component wants to store it as a 1xN cell
            
            
            narginchk(4, 4);
            
            % special check for empty because ItemsData is always allowed
            % to be empty, regardless of the size constraints
            if (isempty(input))
                output = input;
                return;
            end
            
            % Verify that it is a vector
            if isvector(input)
                % reshape to row
                output = matlab.ui.control.internal.model.PropertyHandling.getOrientedVectorArray(input, 'horizontal');
            else
                messageObj = message('MATLAB:ui:components:InputNotAVector', propertyName);
                
                % MnemonicField is last section of error id
                mnemonicField = 'InputNotAVector';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                throw(exceptionObject);
            end
            
            % check sizes
            [~, columns] = size(output);
            if (columns < sizeConstraints(1))
                messageObj = message('MATLAB:ui:components:InputSizeTooSmall', ...
                    propertyName, num2str(sizeConstraints(1)));
                
                
                % MnemonicField is last section of error id
                mnemonicField = 'InputSizeTooSmall';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                throw(exceptionObject);
                
            elseif (columns > sizeConstraints(2))
                messageObj = message('MATLAB:ui:components:InputSizeTooLarge',...
                    propertyName, num2str(sizeConstraints(2)));
                
                % MnemonicField is last section of error id
                mnemonicField = 'InputSizeTooLarge';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                throw(exceptionObject);
            end
            
        end
        
        function [isValid, extraElement] = validateSubset(fullset, subset)
            % Returns whether the subset is a valid subset of the full set
            %
            % Example: if a string appears e.g. 3 times in the full set,
            % but appears more than 3 times in the subset, then the subset
            % is not valid
            %
            % The full set is an array or cell array
            
            
            if ~strcmp(class(fullset), class(subset))
                error('subset must be of same class than fullset');
            end
            
            % As we walk the subset, remove the elements from the
            % fullset. If at some point, an element cannot be found, it
            % means that the subset is not valid
            remainingElements = fullset;
            
            for k = 1:length(subset)
                % look for each element in subsetCell in remaining cell
                if(iscell(remainingElements))
                    ind = find(cellfun(@(x) isequal(x, subset{k}), remainingElements),1);
                else
                    ind = find(arrayfun(@(x) isequal(x, subset(k)), remainingElements),1);
                end
                
                if(isempty(ind))
                    % this element appeared more time in subset than in the
                    % full cell
                    isValid = false;
                    if(iscell(subset))
                        extraElement = subset{k};
                    else
                        extraElement = subset(k);
                    end
                    return;
                else
                    % remove it from remainingElements
                    remainingElements(ind) = [];
                end
            end
            
            isValid = true;
            extraElement = [];
        end
        
        function isElementAcceptable = validateStatesElement(element)
            % Validates that the given element is a valid element for a
            % State array.
            %
            % Inputs:
            %
            %  ELEMENT - the value to validate.  Acceptable values are:
            %            -- numeric scalar
            %            -- logical scalar
            %            -- 1xN char or ''
            %
            % Outputs:
            %
            %  ISELEMENTACCEPTABLE - true if the element was acceptable,
            %                        false otherwise
            
            % Numeric or Logical is acceptable if it is a scalar
            if(isnumeric(element) || islogical(element))
                isElementAcceptable = isscalar(element);
                return;
            end
            
            % String
            try
                % Verify that it is a string (1xN char or '')
                element = matlab.ui.control.internal.model.PropertyHandling.validateText(element);
                
                isElementAcceptable = true;
            catch %#ok<*CTCH>
                isElementAcceptable = false;
            end
            
        end
        
        function newValue = validateLogicalScalar(value)
            % Validates that VALUE is a logical scalar.
            % As per PRISM standards, also accept 0/1 and convert to logical scalar
            
            try
                % check for 0/1
                validateattributes(value,...
                    {'numeric'},...
                    {'scalar','integer','<=',1,'>=',0});
                
                % convert to the corresponding logical
                newValue = value == 1;
            catch
                % check for logical scalar
                validateattributes(value, ...
                    {'logical'}, ...
                    {'scalar'});
                
                newValue = value;
            end
        end
        
        function newValue = convertOnOffToTrueFalse(value)
            % Converts on/off to true/false
            %
            % This assumes that validation on value has already been done
            % so that value is either 'on' or 'off'
            
            newValue = strcmp(value, 'on');
            
        end
        
        function newValue = convertTrueFalseToOnOff(value)
            % Converts true/false to on/off
            
            if(value)
                newValue = 'on';
            else
                newValue = 'off';
            end
        end
        
        function labels = convertArrayToLabels(array)
            % Converts the given array to labels.
            %
            % Inputs:
            %
            %  ARRAY   - The array to convert to labels
            %
            % Outputs:
            %
            %  LABELS - a cell array of strings, the same size of array
            %
            % The following rules are used when converting ARRAY to
            % strings:
            %
            %   - numeric scalar   -> num2str()
            %
            %   - logical scalar   -> true becomes 'On'
            %                         false becomes 'Off'
            %
            %   - string           -> as is
            %
            % All other data types are not supported.
            %
            if(iscell(array))
                labels = cellfun(@convertElementToLabel, ...
                    array, 'UniformOutput', false);
            else
                labels = arrayfun(@convertElementToLabel, ...
                    array, 'UniformOutput', false);
            end
        end
        
        function newText = validateText(text)
            % Validates that TEXT is a valid string
            %
            % '' or a string like 'abc', "abc"
            %
            % Input:
            %
            % text - The user enetered value
            %
            % Output:
            %
            % newText - User entered value validated and converted to char
            %
            % Column - vector strings are dissallowed
            
            % Convert string input to char
            if((isstring(text) && isempty(text)))
                % Change text to '' if string.empty
                text = '';
            else
                % Convert string to char
                text = convertStringsToChars(text);
            end
            
            % Check for char empty which is allowed but needs to be handled
            % special
            isEmptyText = (isempty(text) && isa(text,'char'));

            if(isEmptyText)
                % Assign empty char as text
                newText = '';
            else
                % Check that it is a string row, like 'abc'
                validateattributes(text, ...
                    {'char'}, ...
                    {'row'});
                % Return validated text value
                newText = text;
            end
        end
        
        function rowVectorLimits = validateFiniteLimitsInput(component, limits)
            % Validates that the LIMITS is a valide 1X2 numeric array
            %
            %  component - handle to component model throwing the error
            %
            %  limits - An increasing 1X2 array, excluding -Inf and Inf
            
            try
                
                %  Ensure it's a valid limits
                rowVectorLimits = matlab.ui.control.internal.model.PropertyHandling.validateLimitsInput(component, limits);
                
                % Ensure no -Inf or Inf in limits
                matlab.ui.control.internal.model.PropertyHandling.validateNonInfElements(component, rowVectorLimits)
            catch
                messageObj = message('MATLAB:ui:components:invalidFiniteScaleLimits', ...
                    'Limits');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidFiniteScaleLimits';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
        end
        
        function rowVectorLimits = validateLimitsInput(component, limits)
            % VALIDATELIMITSINPUT
            %
            %  component - handle to component model throwing the error
            %
            %  limits - An increasing 1X2 array, excluding -Inf and Inf
            %
            
            try
                % Ensure the input is at least a double vector
                validateattributes(limits, ...
                    {'numeric'}, ...
                    {'vector', 'real', 'nonnan'});
                
                % reshape to row
                rowVectorLimits = matlab.ui.control.internal.model.PropertyHandling.getOrientedVectorArray(limits, 'horizontal');
            
                % Verify it is 1x2 row vector
                validateattributes(rowVectorLimits, ...
                    {'double'}, ...
                    {'size', [1 2]});
            catch
                messageObj = message('MATLAB:ui:components:invalidScaleLimits', ...
                    'Limits');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidLimits';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                throw(exceptionObject);
            end
            
            % Check that it is increasing
            if(limits(1) >= limits(2))
                messageObj = message('MATLAB:ui:components:invalidScaleLimits', ...
                    'Limits');
                
                
                % MnemonicField is last section of error id
                mnemonicField = 'notIncreasingLimits';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
        end
        
        function output = validateScalarOrIncreasingArrayOf2(input)
            % Validate that input is either a number, or a 1x2 array of
            % numbers where the first one is less than the second one.
            %
            % Returns output that is:
            % - either a scalar, excluding NaN and +/-Inf
            % - a 1x2 vector of increasing numbers
            
            
            % Ensure the input is at least a double vector with increasing
            % values
            validateattributes(input, ...
                {'numeric'}, ...
                {'vector', 'increasing', 'real', 'finite', 'nonnan','>',0});

            % Check that input has either one or two elements
            validateattributes(length(input),...
                {'double'},...
                {'>=',1,'<=',2});
            
            % Reshape to row
            output = matlab.ui.control.internal.model.PropertyHandling.getOrientedVectorArray(input, 'horizontal');
                        
        end
        
        function newTicks = validateTickArray(component, ticks, propertyName)
            % Verify that the ticks are numeric, vector, real, finite.
            
            % Check for [], which is allowed but needs to be handled
            % special
            isEmptyArray = isempty(ticks) && isa(ticks,'double');
            if(isEmptyArray)
                newTicks = ticks;
                return
            end
            
            % Validates that TICKS is a valid numeric, 1D, finite, real array
            messageId = '';
            if ~(isnumeric(ticks) && isvector(ticks))
                % If ticks are not numeric or 1xN/Nx1, throw generic error
                messageId = 'MATLAB:ui:components:invalidTicksNotNumericVector';
            elseif any(isinf(ticks)) || any(isnan(ticks))
                % Ticks should not contain NaN or Inf
                messageId = 'MATLAB:ui:components:invalidTicksNotFinite';
            elseif ~isreal(ticks(:))
                % Ticks should not contain complex values
                messageId = 'MATLAB:ui:components:invalidTicksNotReal';
            end
            
            % Throw error if messageId was populated
            if ~isempty(messageId)
                messageObj = message(messageId, propertyName);
                
                % MnemonicField is last section of error id
                mnemonicField = ['invalid', propertyName];
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                
                % Let error seem like it's coming from the setter
                throwAsCaller(exceptionObject);
            end
            
            % Perform updates on ticks to fix minor inconsistencies to
            % the expectations for ticks.
            ticks = matlab.ui.control.internal.model.PropertyHandling.getSortedUniqueVectorArray(ticks, 'horizontal');
            newTicks = double(ticks);
        end
        
        function array = getSortedUniqueVectorArray(array, direction)
            % GETSORTEDUNIQUEVECTORARRAY
            % This utility assumes that the input valid.  It sorts the
            % array in ascending order, removes duplicates and returns the
            % vector in a consistent direction
            
            if ~isempty(array)
                % Unique may change the size of the array from 0x0 to 0x1
                % Avoid unique if array is empty
                
                % Remove duplicates 
                array = unique(array);
            
                % Sort in ascending order
                array = sort(array);
            end
            % Orient array
            array = matlab.ui.control.internal.model.PropertyHandling.getOrientedVectorArray(array, direction);
                                    
        end
        
        function array = getOrientedVectorArray(array, direction)
            % GETSORTEDUNIQUEVECTORARRAY
            % This utility assumes that the input is a valid vector array.  
            % It returns the vector in a consistent direction            
            
            % Orient array
            if strcmp(direction, 'horizontal') && iscolumn(array) || ...
               strcmp(direction, 'vertical') && isrow(array)
                    array = array';
            end
                
                           
        end
        function validateNonInfElements(component, array)
            % Validates that each element in the ARRAY is not -Inf or Inf
            %
            %
            %  component - handle to component model throwing the error
            %
            % a valid number
            %
            
            % Check that it is increasing
            if(any(array(:) == Inf) || any(array(:) == -Inf))
                
                messageObj = message('MATLAB:ui:components:InvalidInputContainingInf');
                
                % MnemonicField is last section of error id
                mnemonicField = 'InvalidInputContainingInf';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
        end
        
        function newText = validateMultilineText(text)
            % Validates that TEXT is a valid multiline string
            % representation:
            %
            % - Regular String
            % - Cell array of strings:
            %		A Nx1 cell of strings will be accepted as is
            %		A 1xN cell of strings will be transposed
            %		A MxN cell of strings will throw an error
            
            % convert string array to cell array of char vectors before
            % validating
            text = convertStringsToChars(text);
            
            if(iscellstr(text))
                % validate the cell array is of the form 1xN or Nx1
                validateattributes(text,...
                    {'cell'}, ...
                    {'vector'});
                
                % validate each element of the cell is a string
                validationFcn = @(text)matlab.ui.control.internal.model.PropertyHandling.validateText(text);
                text = cellfun(validationFcn, text, 'UniformOutput', false);

                % at this point, it is a valid cell array
                % transpose to Nx1
                newText = matlab.ui.control.internal.model.PropertyHandling.getOrientedVectorArray(text,'vertical');

            else
                % validate as a regular string
                newText = matlab.ui.control.internal.model.PropertyHandling.validateText(text);
            end
        end
        
        function newColor = validateColorSpec(component, color)
            % Validates that COLOR is a valid Colorspec
            %
            %  component - handle to component model throwing the error
            %
            % - RGB Triple
            % - One of 16 magic color strings (the short or long versions)
            
            %convert string to char
            color = convertStringsToChars(color);
            
            if(ischar(color))
                % Magic String Case
                switch(lower(color))
                    case {'y', 'yellow'}
                        newColor = [1 1 0];
                    case {'m', 'magenta'}
                        newColor = [1 0 1];
                    case {'c', 'cyan'}
                        newColor = [0 1 1];
                    case {'r', 'red'}
                        newColor = [1 0 0];
                    case {'g', 'green'}
                        newColor = [0 1 0];
                    case {'b', 'blue'}
                        newColor = [0 0 1];
                    case {'w', 'white'}
                        newColor = [1 1 1];
                    case {'k', 'black'}
                        newColor = [0 0 0];
                    otherwise
                        
                        messageObj = message('MATLAB:ui:components:InvalidColorString');
                        
                        % MnemonicField is last section of error id
                        mnemonicField = 'InvalidColorString';
                        
                        % Use string from object
                        messageText = getString(messageObj);
                        
                        % Create and throw exception
                        exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, messageText);
                        throw(exceptionObject);
                        
                end
            else
                % RGB Matrix Case
                
                % Verify that its 1x3 each element between [0 ... 1]
                validateattributes(color, ...
                    {'numeric'}, ...
                    {'size', [1,3], '>=', 0, '<=', 1});
                
                newColor = color;
            end
            
        end
        
        function newColors = validateColorsArray(component, colorArray)
            % Validates that COLORARRAY is a valid array of color
            % specifications and returns an updated version NEWCOLORS that
            % should be stored in a visual component.
            %
            % COLORARRAY can be any of the following:
            %
            % - Nx3 array of RGB values
            % - 1xN or Nx1 cell array, where each element is an RGB triple or color
            %   name. Color name can be a character vector or string.
            % - an empty [] or {} array
            %
            % NEWCOLORS will always be an Nx3 array.
            
            narginchk(2, 2)
            
            % convert colorArray to char if string
            colorArray = convertStringsToChars(colorArray);
            
            % Check for {} and []
            %
            % Need to explicitly check for:
            % - empty
            % - numeric for [], or cell for {}
            if(isempty(colorArray) && (isnumeric(colorArray) || iscell(colorArray)))
                newColors = [];
                return;
            end
            
            if(iscell(colorArray))
                % The input must be something like one of the following:
                %
                % {'red', 'green', 'blue'}
                % {'red', [.4 .2 .9], 'green'}
                validateattributes(colorArray, ...
                    {'cell'}, ...
                    {'vector'});
                
                % Validate each element and converts
                validationFcn = @(colorArray)matlab.ui.control.internal.model.PropertyHandling.validateColorSpec(component, colorArray);
                cellArrayOfRGBTriples = cellfun(validationFcn, colorArray, 'UniformOutput', false);
                
                % At this point, 'newColors' is a cell array of RGB values,
                % ex:
                %
                % {[1 0 0], [0 1 1]}
                %
                % Turn into Nx3 double matrix by stacking the RGB triples
                % on top of each other
                newColors = vertcat(cellArrayOfRGBTriples{:});
            else
                % The input must be something like:
                %
                % [  0    1   0
                %    0.5  1   0
                %    0    1   0 ]
                
                % This validates the entire array.
                %
                % NaN in validate attributes means "don't worry about this
                % dimension."
                validateattributes(colorArray, ...
                    {'numeric'}, ...
                    {'size', [NaN,3], '>=', 0, '<=', 1});
                
                newColors = colorArray;
            end
        end
        
        function convertedFormatString = validateDisplayFormat(component, newFormatString, propertyName, currentValue)
            % Validates that NEWFORMATSTRING is a valid sprintf string for
            % formatting a value
            %
            % Inputs:
            %
            %  component - handle to component model throwing the error
            %
            %  newFormatString     - The user entered string to validate
            %
            %  propertyName        - The property name being validated
            %                        (Used for error messages)
            %
            %  currentValue        - current value to format, used to
            %                        double check that it can be formatted
            %
            % Output:
            % 
            % convertedFormatString - User entered string validated and converted to char
            %
            % Callers of this function should wrap the call in a try/catch,
            % and re-throw the error message with their own error ID.
            
            % check it is a char or a string
            if(~ischar(newFormatString) && ~isstring(newFormatString))
                
                messageObj = message('MATLAB:ui:components:invalidDisplayFormat', propertyName);
                
                % Use string from object
                messageText = getString(messageObj);
                
                docLinkId = 'MATLAB:ui:components:sprintfDocLink';
                messageText = matlab.ui.control.internal.model.PropertyHandling.createMessageWithDocLink(messageText, docLinkId, 'sprintf');

                % MnemonicField is last section of error id
                mnemonicField = 'invalidDisplayFormat';
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, '%s', messageText);
                throw(exceptionObject);
                
            end
            
            % validate and convert newFormatString to char
            convertedFormatString = matlab.ui.control.internal.model.PropertyHandling.validateText(newFormatString);
			
            % Verify that the format string is correct by making sure it
            % can properly format the current Value
            [~,  errorMessage] = sprintf(convertedFormatString, currentValue);
            
            if(~isempty(errorMessage))
                sprintfLink = '<a href="matlab: help(''sprintf'')">help sprintf</a>';
                
                messageObj = message('MATLAB:ui:components:misformattedDisplayFormat', propertyName, sprintfLink);
                
                % MnemonicField is last section of error id
                mnemonicField = 'misformattedDisplayFormat';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(component, mnemonicField, '%s', messageText);
                throw(exceptionObject);
                
            end
            
        end
        
        function messageObj = createColorSpecMessage(propertyName, messageId)
            % Returns a message object for properties that work with Nx3
            % color arrays
            %
            % messageId is the main message to be displayed, e.g.
            % 'MATLAB:ui:components:invalidColorArray'
            
            colorSpecHelpPath =  fullfile(docroot, 'matlab', 'ref', 'colorspec.html');
            
            colorSpecDocLink = sprintf('<a href="matlab: helpview(''%s'')">Colorspec</a>', colorSpecHelpPath);
            
            messageObj =  message(messageId, propertyName, colorSpecDocLink);
            
        end
        
        function newValue = calibrateValue(limits, value)
            % Given the scale limits, and value, recalibrates the value to
            % ensure that it is within the limits.
            %
            % If the value is above the limits, then it will be calibrated
            % to the upper limit.
            %
            % If the value is below the limits, then it will be calibrated
            % to the lower limit.
            
            
            if(value < limits(1))
                % current value is below the new limits
                newValue = limits(1);
            elseif(value > limits(2))
                % current value is above the existing limits
                newValue = limits(2);
            else
                newValue = value;
            end
        end
        
        function dataTickDelta = findDataTickDelta(lower, upper, width)
            % find the spacing between ticks in data units
            % lower and upper are the data bounds
            % width is the number of pixels the ruler is to span
            
            % how many ticks should there be?
            
            % no more than 20 pixels apart
            minNumberOfTicksPossible = width / 30;
            if (minNumberOfTicksPossible < 1)
                minNumberOfTicksPossible = 1;
            end
            
            % no less than 15 pixels apart
            maxNumberOfTicksPossible = width / 18;
            if (maxNumberOfTicksPossible < 2)
                maxNumberOfTicksPossible = 2;
            end
            
            % What is the range that tick spacing could take?
            range = abs(upper - lower);
            
            
            % Handle numbers smaller than 1, Multiply them so they are in
            % a larger range so the tick calculation is more consistent
            factor = 1;
            while (abs(factor * range) < 10.0)
                % Get into the range 1 < factor*range
                factor = factor * 10;
            end
            if (abs(factor * range) < 20.0)
                factor = factor * 2;
            end
            range = range*factor;
            
            % rate the ticks on their potential to be good rounding
            % low number means that they divide well
            % when rating is 0 that's perfect divisibility
            possibleTicks = round(minNumberOfTicksPossible):round(maxNumberOfTicksPossible);
            dividableRating = range./possibleTicks - round(range./possibleTicks);
            
            % Handle case where ticks can be evenly divided
            validTicks = possibleTicks(dividableRating == 0);
            
            if ~isempty(validTicks)
                % There is a tick that can be evenly divided into the range
                % Choose the larger number of ticks if there are multiple
                % valid evenly divisible ticks.
                dataTickDelta = range/validTicks(end);
                dataTickDelta = dataTickDelta/factor;
            else
                
                % Sort ratins so there is a criteria to pick one
                [~, index] = sort(abs(dividableRating));
                validTicks = possibleTicks(index);
                
                % What is the range that tick spacing could take?
                dataTickDelta = range/validTicks(1);
                
                % Clean up dataTickDelta so that it's a round number
                % If for example, the dataTickDelta value is 76.5, we want
                % it to be something more even like 80.
                dataTickFactor = 1;
                while (abs(dataTickFactor * dataTickDelta) > 10.0)
                    dataTickFactor = dataTickFactor / 10;
                end
                
                dataTickDelta = round(dataTickDelta*dataTickFactor)/dataTickFactor/factor;
            end
            
        end
        
        
        
        
        
        function [autoModeProperties, siblingAutoProperties, manualModeProperties, siblingManualProperties] = getModeProperties(propertyValuesStruct)
            % Given a struct of property names, property values... returns
            % a list of mode properties and their corresponding sibling
            % properties
            %
            % Ex:
            %
            %   s.Foo = 1;
            %   s.FooMode = 'auto';
            %   s.Bar = 2;
            %   s.Baz = 3;
            %   s.BazMode = 'manual';
            %
            % getModeProperties(s) will return the following:
            %
            %   autoModeProperties = {'FooMode'}
            %   siblingAutoProperties = {'Foo'}
            %   manualModeProperties = {'BazMode'}
            %   siblingManualProperties = {'Baz'}
            %
            % Beacuse the 'Bar' property did not have a mode, it is ignored
            
            propertyNames = fieldnames(propertyValuesStruct);
            
            % Finds all properties ending in 'Mode'
            cellArrayOfIndices = regexp(propertyNames, 'Mode$');
            modePropertyIndices = cellfun(@(x) ~isempty(x), cellArrayOfIndices);
            modePropertyNames = propertyNames(modePropertyIndices);
            
            % Preassign values for the auto / manual things that will be
            % calculated
            autoModeProperties = {};
            siblingAutoProperties = {};
            manualModeProperties = {};
            siblingManualProperties = {};
            
            for idx = 1:length(modePropertyNames)
                % Ex: XLimMode
                modePropertyName = modePropertyNames{idx};
                
                % Ex: XLim
                siblingPropertyName = modePropertyName(1 : end - 4);
                
                % Determine if the value is currently auto
                isAuto = strcmp(propertyValuesStruct.(modePropertyName), 'auto');
                
                if(isAuto)
                    % Add to the autos
                    autoModeProperties{end+1} = modePropertyName;
                    siblingAutoProperties{end+1} = siblingPropertyName;
                else
                    % Add to the manuals
                    manualModeProperties{end+1} = modePropertyName;
                    siblingManualProperties{end+1} = siblingPropertyName;
                end
            end
        end
        
        function [siblingProperties, modeProperties] = getPropertiesWithMode(objectClassName, propertyValuesStruct, includeHiddenProperty)
            % Given a struct of property names, property values... returns
            % a list of properties that have a corresponding mode property
            % on the object (whether it is in the propertyValuesStruct or not)
            % Also returns the mode properties themselves
            %
            % Ex:
            %
            %   s.MajorTicks = 1:10;
            %   s.MajorTicksMode = 'manual';
            %   s.MinorTicks = 1:5:10;
            %   s.Limits = [0, 10];
            %
            % getPropertiesWithMode(s) will return the following:
            %
            %   propertiesWithMode = {'MajorTicks', 'MinorTicks'};
            %   modeProperties = {'MajorTicksMode', 'MinorTicksMode'};
            %
            % Because 'MajorTicks' and 'MinorTicks' have a corresponding
            % mode property on the model itself            
           
            % Gather all properties on the object
            mc = meta.class.fromName(objectClassName);
            objectPropertyNames = {mc.PropertyList.Name};
            
            % Array for the properties in propertyValuesStruct that have a mode
            % property
            siblingProperties = {};
            % Array for the mode properties
            modeProperties = {};
            
            propertyNamesToIntrospect = fieldnames(propertyValuesStruct);
            
            for idx = 1:length(propertyNamesToIntrospect)
                % Property of the structure, e.g. MajorTicks
                propertyName = propertyNamesToIntrospect{idx};
                
                % Corresponding mode property if there was one
                modePropertyName = strcat(propertyName, 'Mode');
                
                % Find the meta prop
                modeMetaProperty = mc.PropertyList(strcmp(modePropertyName, objectPropertyNames));
                
                % We want to include the property as a valid mode if and
                % only if:
                %
                % - It exists (obviously)
                %
                % - It is not Hidden and is part of the public API
                %   HG Object use backing Mode properties for every
                %   property, regardless if the XXXMode property is part of
                %   the public API.
                %
                %   Things like property edits and code generation, they
                %   are only concerned with Modes related to the public
                %   API.
                isValidModeProperty = ...
                    ... % Property Exists
                    ~isempty(modeMetaProperty) && ...
                    ... % Property is not Hidden
                    (includeHiddenProperty || (~includeHiddenProperty && ~modeMetaProperty.Hidden));
                
                if(isValidModeProperty)
                    % The mode property does exist on the object
                    siblingProperties{end+1} = propertyName;  %#ok<AGROW>
                    modeProperties{end+1} = modePropertyName; %#ok<AGROW>
                end
            end
        end
        
        
        function shiftedPVPairs = shiftOrderDependentProperties(pvPairs, orderDependentProperties, parameterList)
            % SHIFTORDERDEPENDENTPROPERTIES - Shift any order dependent properties to
            % the end of the pvPair list while preserving the order of the
            % orderDependentProperties
            % This will filter duplicate entries in the pvPairs if there
            % are multiple property names for a given
            % orderDependentProperty.  The last matching pvPair will the
            % one preserved. For example, if the end user has specified multiple
            % 'Parent' values, all but the last one will be filtered out.
            % An example of why you would want to move properties to the
            % end is that for some components the 'Value' entry is
            % dependent on the configuration of the component, ListBox for
            % example.  The 'Value' needs to be set after the other entries
            % in the PVPairs have been applied.
            %
            % pvPairs: a cell array containing any combination of proper
            % {'Property', Value} pairs or structs.  HG constructors and
            % set methods accept structs as a valid way to specify PV pairs
            %
            % orderDependentProperties: a cell array of char arrays or a
            % string array that contains property names that will be found
            % and pushed to the end of the cell array of pvPairs.
            %
            % parameterList: a cell array of char arrays or a string array
            % that contains valid properties associated with the component
            % getting the pvPairs.  This is used because the inputparser
            % supports partial matching and without additional parameters
            % to set context, the partial matching could provide results
            % different than the component constructor.
            %
            % SET UP PARSER OBJECT
            inputParserObj = inputParser;
            inputParserObj.KeepUnmatched = true;
            
            for index = 1:numel(parameterList)
                % Adding parameters makes partial matching in the
                % inputParser more robust
                inputParserObj.addParameter(parameterList{index},[], @(thisValue)true)
            end
            
            inputParserObj.parse(pvPairs{:});
 
            % Remove orderDependentProperties not in property list (for
            % completeness)
            for odpIndex = numel(orderDependentProperties):-1:1
                
                % boolean vector locating prop in parameterList
                comparison = parameterList.contains(orderDependentProperties{odpIndex});
                
                if ~any(comparison)
                    % Remove property from list
                    orderDependentProperties(odpIndex) = [];  
                end
            end

            % The successful parse serves as proof that the pvPairs are
            % well formatted.  We can assume they are of the format
            % {'PropertyName', value} or struct, or a cell array containing
            % a combination of the two.
            filteredPvPairs = [];  % pvPairs without orderdependent
            % unmatchedFields represent properties that either don't match
            % the parameters at all, or where the match was ambigous
            % between two similar property names (ex. 'MajorTicks',
            % 'MajorTicksMode')
            unmatchedFields = string(fieldnames(inputParserObj.Unmatched));

            % Filter properties from pvPairs that match order dependent
            % properties
            while numel(pvPairs) > 0
    
                % HANDLE STRUCT INPUT
                if isstruct(pvPairs{1})
                    structValue = pvPairs{1};
                    fieldNames = fieldnames(structValue);
        
                    % Remove field if it doesn't match the 'unmatched'
                    % fields and matches an order dependent property
                    for index = 1:numel(fieldNames)
                        
                        % per g1576792, struct input does not support
                        % partial matching, thus match cannot be ambiguous
                        odMatchFound = any(strcmpi(fieldNames{index}, orderDependentProperties));
                        
                        if  odMatchFound
               
                            % Remove option from input, add to odp Inputs
                            structValue = rmfield(structValue, fieldNames{index});                            
                        end
                    end
        
                    if ~isempty(fields(structValue))
                        filteredPvPairs = [filteredPvPairs, {structValue}];
                    end
                    pvPairs(1) = [];
        
                else
                    % HANDLE PV PAIR INPUT
                    if any(strcmp(unmatchedFields, pvPairs(1)))
                        % Property name was not a match to the parameter
                        % list or the orderDependentProperties (this will
                        % likely result in a runtime set error)
                        filteredPvPairs = [filteredPvPairs, pvPairs(1:2)];
            
                    else
                        % Property name was a match to exactly one in the 
                        % parameter list.  There are multiple scenarios:
                        % 1. The pvName exactly matches something in the 
                        %    propList and there is only one potential match.   
                        % 2. The pvName exactly matches and there are other 
                        %    partial matches: pvName is 'Value', propList 
                        %    has 'Value', 'ValueChanging' etc.
                        % 3. The pvName partially matches some property, 
                        %    but the match is not ambiguous,
                        
                                             
                        if any(strcmpi(pvPairs{1}, parameterList))
                            % pvName matches exactly to parameterList
                            % Case #1 and #2
                            matchedName = pvPairs{1};
                        else
                            % matchedName is expected to be scalar because
                            % the pvName was already checked for exact
                            % match and ambigous match.  It should only 
                            % return one value for 'startsWith'.
                            % Case #3
                            matchedName = parameterList(startsWith(parameterList, pvPairs{1}, 'IgnoreCase', true));
                        end
                            
                            
                        if ~any(strcmpi(matchedName, orderDependentProperties))
                            % pvPair name exactly matches a property and
                            % does not match an orderDependentProperty
                            filteredPvPairs = [filteredPvPairs, pvPairs(1:2)];
                        end 
            
                    end
                    pvPairs(1:2) = [];
                end
    
            end

            % If PropertyName is not the default (it is specified in the pvPair list)
            % add it to the end of the pvPair list
            shiftedPVPairs = [];
            for index = 1:numel(orderDependentProperties)
                if ~any(strcmp(orderDependentProperties{index}, inputParserObj.UsingDefaults))
                    shiftedPVPairs = [shiftedPVPairs, {orderDependentProperties{index}, inputParserObj.Results.(orderDependentProperties{index})}];
                end
            end

            shiftedPVPairs = [filteredPvPairs, shiftedPVPairs];
    
        end
    end
end

% ---------------------------------------------------------------------
% Private Helper Methods for the PropertyHandling functions
% ---------------------------------------------------------------------

function [isUnique, firstNonUniqueElement]= areElementsUnique(anArray)
% Checks if elements in array are unique, according to isequal
%
% ARRAY may be a numeric array, logical array, or 1xN cell
% array of strings, logicals, and numerics
% - numeric scalar
% - logical scalar
% - 1xN char
%
% isUnique - true if all elements are unique
%
% firstNonUniqueElement - the first element found that was not unique.
% this is empty if there are all unique elements.

if(~iscell(anArray))
    % treat everything as a cell array so that it can be iterated over more
    % easily.
    anArray = num2cell(anArray);
end

% Ex: array = {'a', 'b', 'c'}
for idx = 1:length(anArray)
    
    thisElement = anArray{idx};
    
    if(isnan(thisElement))
        % First check if the element is NaN.
        % Treat the NaN case separately because we can't compare the
        % current element to the other ones using isequal since
        % isequal of NaN and itself returns false.
        
        nanElements = cellfun(@(x) isnan(x), anArray);
        if(sum(nanElements)>1)
            % There are more than 1 NaN element in anArray
            isUnique = false;
            
            % Return the non-unique element
            firstNonUniqueElement = NaN;
            return;
        end
        
        continue;
    end
    
    matchingIndices = cellfun(@(x) isequal(x, thisElement), anArray);
    numberOfMatches = sum(matchingIndices);
    
    if(numberOfMatches ~= 1)
        % Not unique
        isUnique = false;
        
        % Return the non-unique element
        firstNonUniqueElement = thisElement;
        return;
    end
end

firstNonUniqueElement = [];
isUnique = true;

end

% ---------------------------------------------------------------------
function label = convertElementToLabel(element)
if(isnumeric(element))
    
    label = sprintf('%1.4g', element);
    return;
elseif(ischar(element))
    % take the string as is
    label = element;
    return;
elseif(islogical(element))
    % true = 'On'
    % false = 'Off'
    if(element)
        label = getString(message('MATLAB:ui:defaults:trueStateLabel'));
    else
        label = getString(message('MATLAB:ui:defaults:falseStateLabel'));
    end
    return;
end

% Some unexpected type
assert(false, 'The given data type was not expected');
end

function pvPair = convertStructToPvPairs(value)
% CONVERTSTRUCTTOPVPAIRS - Takes input 'value' which is a struct, and
% converts it to pvPair cell array
% struct('Field1', value1, 'Field2', value2) turns into
% {'Field1', value1, 'Field2', value2}

pvPair = {};
for propertyName = fields(value)'
    pvPair = [pvPair, {propertyName{1}, value.(propertyName{1})}];
end

end
% ---------------------------------------------------------------------



