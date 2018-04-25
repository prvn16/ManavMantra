classdef (ConstructOnLoad=true) DatePicker < ...
        matlab.ui.control.internal.model.ComponentModel & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent & ...
        matlab.ui.control.internal.model.mixin.EnableableComponent & ...
        matlab.ui.control.internal.model.mixin.BackgroundColorableComponent & ...
        matlab.ui.control.internal.model.mixin.VisibleComponent
    %
    
    % Do not remove above white space
    % Copyright 2017 The MathWorks, Inc.
    
    properties(Dependent)
        Value = NaT('Format', 'defaultDate');
        DisplayFormat = 'dd-MMM-uuuu';
        DisabledDates = datetime.empty();
        DisabledDaysOfWeek = [];
        Limits = [datetime(0000, 1, 1), datetime(9999, 12, 31)];
        Editable@matlab.graphics.datatype.on_off = 'on';   
    end
    
    properties(NonCopyable, Dependent)
        ValueChangedFcn@matlab.graphics.datatype.Callback = [];
    end
    properties(Hidden)
        DisplayFormatMode@matlab.graphics.datatype.AutoManual = 'auto';
    end
    properties(Access = {?appdesservices.internal.interfaces.controller.AbstractController})
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateValue = NaT('Format', 'defaultDate');
        PrivateDisplayFormat = 'dd-MMM-uuuu';
        PrivateDisabledDates = datetime.empty();
        PrivateDisabledDaysOfWeek = [];
        PrivateLimits = [datetime(0000, 1, 1, 'Format', 'defaultDate'), datetime(9999, 12, 31, 'Format', 'defaultDate')];
        PrivateEditable@matlab.graphics.datatype.on_off = 'on';  
        PrivateDisplayFormatMode@matlab.graphics.datatype.AutoManual = 'auto';
    end
    
    properties(NonCopyable, Access = {?matlab.ui.control.DatePicker, ...
            ?appdesservices.internal.interfaces.controller.AbstractController})
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateValueChangedFcn@matlab.graphics.datatype.Callback = [];
    end
    
    events(NotifyAccess = {?matlab.ui.control.internal.controller.ComponentController})
        ValueChanged
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = DatePicker(varargin)
            %
            
            % Do not remove above white space
            % Defaults
            defaultPosition = [20, 300, 150, 22];
            obj.PrivateInnerPosition = defaultPosition;
            obj.PrivateOuterPosition = defaultPosition;

            obj.Type = 'uidatepicker';
            
            % Use session datetime default setting for dates
            s = settings;
            filteredFormat = matlab.internal.datetime.filterTimeIdentifiers(...
                s.matlab.datetime.DefaultDateFormat.ActiveValue);
            obj.PrivateDisplayFormat = filteredFormat;
            
            if strcmp(obj.Editable, 'off')
                % Set default BackgroundColor
                obj.BackgroundColor = obj.DefaultGray;
            end
            
            parsePVPairs(obj,  varargin{:});
            
            % Wire callbacks
            obj.attachCallbackToEvent('ValueChanged', 'PrivateValueChangedFcn');
        end
        % ----------------------------------------------------------------------
        
        function set.Value(obj, newValue)
            
            % Error Checking
            try
                validateattributes(newValue, ...
                    {'datetime'}, {'nonempty', 'scalar'}); 
            
            catch %#ok<CTCH>
                
                messageObj = message('MATLAB:ui:components:valueNotValid', ...
                    'Value', 'Limits');
                
                % MnemonicField is last section of error id
                mnemonicField = 'valueNotValid';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end      
            
            % Remove time
            newValue = obj.processComponentDateTimeObjects(newValue);
            
            if ~isnat(newValue)
                try
                    % Value is within limits
                    assert(newValue >= obj.Limits(1) && newValue <= obj.Limits(2), 'Value was not within limits')
                    
                catch %#ok<CTCH>
                    
                    messageObj = message('MATLAB:ui:components:valueNotValid', ...
                        'Value', 'Limits');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'valueNotValid';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                end
                
                try
                    % Value conflicts with disabledDates
                    assert(~any(obj.DisabledDates == newValue), 'Value conflicts with disabledDates')
                catch %#ok<CTCH>
                    
                    messageObj = message('MATLAB:ui:components:valueConflictsWithDisabledDates', ...
                        'Value', 'DisabledDates');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'valueConflictsWithDisabledDates';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                end
                
                try
                    %Value conflicts with disabledDaysOfWeek
                    assert(~any(obj.DisabledDaysOfWeek == day(newValue, 'dayofweek')), 'Value conflicts with disabledDaysOfWeek')
                    
                catch %#ok<CTCH>
                    
                    messageObj = message('MATLAB:ui:components:valueConflictsWithDisabledDaysOfWeek', ...
                        'Value', 'DisabledDaysOfWeek');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'valueConflictsWithDisabledDaysOfWeek';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                end
            end 
            
            valuesToMarkDirty = {'Value'};
            expectedFormat = obj.DisplayFormat;
            if strcmp(obj.PrivateDisplayFormatMode, 'auto')
                
                filteredFormat = matlab.internal.datetime.filterTimeIdentifiers(newValue.Format);
                
                % If the Value's format is different than the DisplayFormat
                % update component to use Value's format
                if ~strcmp(filteredFormat, obj.DisplayFormat)
                    
                    % Update Component DisplayFormat if it has never been set
                    obj.PrivateDisplayFormat = filteredFormat;
                    valuesToMarkDirty(end + 1) = {'DisplayFormat'};
                    
                    expectedFormat = filteredFormat;
                end                
            end
            
            % Update value format if it is different than DisplayFormat
            if ~strcmp(newValue.Format, expectedFormat)
                newValue.Format = obj.DisplayFormat;
            end
                
            % Property Setting
            obj.PrivateValue = newValue;
                
            % Update View
            markPropertiesDirty(obj, valuesToMarkDirty);
        end
        
        function value = get.Value(obj)
            value = obj.PrivateValue;
        end
        
        % ----------------------------------------------------------------------
        
        function set.DisplayFormat(obj, newValue)
            % Error Checking
            narginchk(2, 2);
                            
            try                
                newValue = matlab.ui.control.internal.model.PropertyHandling.validateText(newValue);
                
                % Capture information about whether value contains minutes
                originalValueContainedMinutes = obj.formatContainsMinutes(newValue);
                
                if originalValueContainedMinutes
                    newValue = obj.replaceMinutesIndicatorWithMonths(newValue);
                end
                % Remove time portion to avoid mm/MM warnings and time
                % related validation errors:
                newValue = matlab.internal.datetime.filterTimeIdentifiers(newValue);
                
                % Make sure that Format is valid.  Use new datetime object
                % so that the component data is not corrupted
                [~] = datetime('today', 'Format', newValue);
                 
            catch me
                
                
                % Throw useful error message based on dateshift fail
                
                switch (me.identifier)
                    case {'MATLAB:datetime:UnsupportedSymbol', 'MATLAB:datetime:UnsupportedIdentifier'}
                        %The DisplayFormat character vector contains an unsupported format symbol.
                        
                        messageObj = message('MATLAB:ui:components:displayFormatUnsupported', ...
                            'DisplayFormat');
                        
                        
                    otherwise % property handling or 'MATLAB:datetime:UnrecognizedFormat'
                        
                        messageObj = message('MATLAB:ui:components:displayFormatInvalid', ...
                            'DisplayFormat');
                end
                              
                
                % MnemonicField is last section of error id
                mnemonicField = 'displayFormatInvalid';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            if originalValueContainedMinutes
                % DisplayFormat has 'm' symbol in a location that is
                % likely to indicate user error like 'mm/dd/yyyy'.
                % 'm' is the symbol for minutes, not months.
                % Throw warning after all potential errors have been
                % thrown
                
                messageObj = message('MATLAB:ui:components:displayFormatContainsmm', ...
                            'DisplayFormat');
                warning('MATLAB:ui:DatePicker:displayFormatContainsmm', messageObj.getString());
            end
            
            % Property Setting
            obj.PrivateDisplayFormat = newValue;
            
            if isequal(obj.PrivateDisplayFormatMode, 'auto')
                obj.PrivateDisplayFormatMode = 'manual';
                markPropertiesDirty(obj, {'DisplayFormat', 'DisplayFormatMode'});
            else
                
                % Update View
                markPropertiesDirty(obj, {'DisplayFormat'});
            end
            
        end
        
        function value = get.DisplayFormat(obj)
            value = obj.PrivateDisplayFormat;
        end
        
        function set.PrivateDisplayFormat(obj, newValue)
            % Error Checking
            narginchk(2, 2);
            
            obj.PrivateDisplayFormat = newValue;
            
            % update datetime objects stored in component
            obj.PrivateValue.Format = newValue;
            obj.PrivateLimits.Format = newValue;
            obj.PrivateDisabledDates.Format = newValue;
        end
        % ----------------------------------------------------------------------
        function set.DisplayFormatMode(obj, newValue)
            
            % Property Setting
            obj.PrivateDisplayFormatMode = newValue;
            
            % Value will not be marked dirty
        end
        % ----------------------------------------------------------------------
        function formatMode = get.DisplayFormatMode(obj)
            formatMode = obj.PrivateDisplayFormatMode;
        end
        % ----------------------------------------------------------------------
        
        function set.Limits(obj, newValue)
            
            % Error Checking
            narginchk(2, 2);
            
            try
                
                % Ensure the input is at least a double vector
                validateattributes(newValue, ...
                    {'datetime'}, ...
                    {'vector', 'numel', 2});
            
                % Remove time
                newValue = obj.processComponentDateTimeObjects(newValue, obj.DisplayFormat);
            
                % Orient array
                newValue = matlab.ui.control.internal.model.PropertyHandling.getOrientedVectorArray(newValue, 'horizontal');
                
                assert(newValue(1) <= newValue(2), 'Limits were not increasing');
                assert(all(newValue >= datetime(0000, 1, 1)), 'Limit cannot be negative.')
                assert(all(newValue <= datetime(9999, 12, 31)), 'First limit cannot be greater than 10000.')
            catch %#ok<CTCH>
                
                
                messageObj = message('MATLAB:ui:components:dateLimitsInvalid', ...
                    'Limits');
                
                % MnemonicField is last section of error id
                mnemonicField = 'dateLimitsInvalid';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateLimits = newValue;
            
            % UpdateValue if it is no longer valid
            if obj.Value < newValue(1) || obj.Value > newValue(2)
                obj.PrivateValue = NaT;
                % Dirty
                obj.markPropertiesDirty({'Limits', 'Value'});
            else
                % Dirty
                obj.markPropertiesDirty({'Limits'});
            end
            
        end
        
        function value = get.Limits(obj)
            value = obj.PrivateLimits;
        end
        
        % ----------------------------------------------------------------------
        
        function set.DisabledDates(obj, newValue)
            
            narginchk(2, 2)
            
            % newValue must be a datetime
            % newValue can be empty or a vector
            if ~(isa(newValue, 'datetime') && (isempty(newValue) || isvector(newValue)))               
                
                messageObj = message('MATLAB:ui:components:disabledDatesInvalid', ...
                    'DisabledDates');
                
                % MnemonicField is last section of error id
                mnemonicField = 'disabledDatesInvalid';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
                        
            % Ensure the input has no NaT values
            if any(isnat(newValue))                
                
                messageObj = message('MATLAB:ui:components:disabledDatesContainsNaT', ...
                    'DisabledDaysOfWeek');
                
                % MnemonicField is last section of error id
                mnemonicField = 'disabledDatesContainsNaT';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Remove time
            newValue = obj.processComponentDateTimeObjects(newValue, obj.DisplayFormat);
                
            % Sort and remove duplicates
            newValue = matlab.ui.control.internal.model.PropertyHandling.getSortedUniqueVectorArray(newValue, 'vertical');
            
            % Property Setting
            obj.PrivateDisabledDates = newValue;
            
            % UpdateValue if it is no longer valid
            if any(obj.DisabledDates == obj.Value)
                obj.PrivateValue = NaT('Format', obj.DisplayFormat);
                % Dirty
                obj.markPropertiesDirty({'DisabledDates', 'Value'});
            else
                % Dirty
                obj.markPropertiesDirty({'DisabledDates'});
            end
            
        end
        
        function value = get.DisabledDates(obj)
            value = obj.PrivateDisabledDates;
        end
        
        % ----------------------------------------------------------------------
        
        function set.DisabledDaysOfWeek(obj, newValue)
            narginchk(2, 2)
            
            newValue = convertStringsToChars(newValue);
            
            % Handle empty case
            if isempty(newValue)
                obj.PrivateDisabledDaysOfWeek = [];
                % Dirty
                obj.markPropertiesDirty({'DisabledDaysOfWeek'});
                return;
            end
            
            if isnumeric(newValue)
                try
                    
                    % Ensure the input is at least a double vector
                    validateattributes(newValue, ...
                        {'numeric'}, ...
                        {'vector', 'integer', '>=', 1, '<=', 7});
                    
                catch %#ok<CTCH>
                    
                    messageObj = message('MATLAB:ui:components:disabledDaysOfWeekInvalid', ...
                        'DisabledDaysOfWeek');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'disabledDaysOfWeekInvalid';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                end
                
            else
                if ~iscell(newValue)
                    newValue = {newValue};
                end
                
                try
                    % Value is not numeric, so validate that it is a cell array of
                    % strings
                    newValue = matlab.ui.control.internal.model.PropertyHandling.processCellArrayOfStrings(obj, 'DisabledDaysOfWeek', newValue, [0, Inf]);
                catch %#ok<CTCH>
                    
                    messageObj = message('MATLAB:ui:components:disabledDaysOfWeekInvalid', ...
                        'DisabledDaysOfWeek');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'disabledDaysOfWeekInvalid';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                end
                
                % newValue is a cell array of strings and has passed basic
                % validation.  Now give datetime specific error messages or
                % convert valid values.
                dayindex = [];
                for index = 1:numel(newValue)
                    try
                        shiftedDate = dateshift(datetime('today'), 'dayofweek', newValue{index});
                        dayindex(end+1) = day(shiftedDate, 'dayofweek');
                    catch me
                        
                        % Throw useful error message based on dateshift fail
                        
                        switch (me.identifier)
                            case 'MATLAB:datetime:dateshift:InvalidDOW'
                                %'Day of week must be a number from 1 to 7, or a day name.'
                                
                                %dayname was not recognized
                                
                                messageObj = message('MATLAB:ui:components:disabledDaysOfWeekDayNameInvalid', ...
                                    newValue{index});
                            case 'MATLAB:datetime:AmbiguousInput'
                                %'Ambiguous input: 'S'.'
                                % Name matched multiple possibilities
                                messageObj = message('MATLAB:ui:components:disabledDaysOfWeekDayNameAmbiguous', ...
                                    newValue{index});
                        end
                        
                        % MnemonicField is last section of error id
                        mnemonicField = 'disabledDaysOfWeekInvalid';
                        
                        % Use string from object
                        messageText = getString(messageObj);
                        
                        % Create and throw exception
                        exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                        throw(exceptionObject);
                    end
                end
                newValue = dayindex;
            end
            
            % Sort and remove duplicates
            newValue = matlab.ui.control.internal.model.PropertyHandling.getSortedUniqueVectorArray(newValue, 'horizontal');
            
            % Property Setting
            obj.PrivateDisabledDaysOfWeek = newValue;
            
            % UpdateValue if it is no longer valid
            if any(obj.DisabledDaysOfWeek == day(obj.Value, 'dayofweek'))
                obj.PrivateValue = NaT;
                % Dirty
                obj.markPropertiesDirty({'DisabledDaysOfWeek', 'Value'});
            else
                % Dirty
                obj.markPropertiesDirty({'DisabledDaysOfWeek'});
            end
            
        end
        
        function value = get.DisabledDaysOfWeek(obj)
            value = obj.PrivateDisabledDaysOfWeek;
        end
        % ----------------------------------------------------------------------
      
        
        function set.Editable(obj, newValue)
            
            % Error Checking done through the datatype specification
            
            % If the user has not updated the color, change the color to
            % the factory default when togglign the Editable property
            if strcmp(newValue, 'on') && strcmp(obj.PrivateEditable, 'off')...
                    && isequal(obj.BackgroundColor, obj.DefaultGray)
                obj.BackgroundColor = obj.DefaultWhite;
            elseif strcmp(newValue, 'off') && strcmp(obj.PrivateEditable, 'on')...
                    && isequal(obj.BackgroundColor, obj.DefaultWhite)
                obj.BackgroundColor = obj.DefaultGray;
            end
            
            % Property Setting
            obj.PrivateEditable = newValue;          
            
            % marking dirty to update view
            obj.markPropertiesDirty({'Editable'});
        end
        
        function value = get.Editable(obj)
            value = obj.PrivateEditable;
        end

        
        
        
        % ----------------------------------------------------------------------
        function set.ValueChangedFcn(obj, newValue)
            % Property Setting
            obj.PrivateValueChangedFcn = newValue;
            
            % Dirty
            obj.markPropertiesDirty({'ValueChangedFcn'});
        end
        
        function value = get.ValueChangedFcn(obj)
            value = obj.PrivateValueChangedFcn;
        end
        
        % ----------------------------------------------------------------------
        
    end
    
    % ---------------------------------------------------------------------
    % Custom Display Functions
    % ---------------------------------------------------------------------
    methods(Access = protected)
        
        function names = getPropertyGroupNames(obj)
            % GETPROPERTYGROUPNAMES - This function returns common
            % properties for this class that will be displayed in the
            % curated list properties for all components implementing this
            % class.
            
            names = {'Value',...
                'DisplayFormat', ...
                ...Callbacks
                'ValueChangedFcn'};
            
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            str = '';
            if ~ismissing(obj.Value)
                str = char(string(obj.Value));
            end
        end
    end
    
    methods (Static, Access = private)
        function containsMinutes = formatContainsMinutes(newValue)
            
            % mm:dd:yyyy
            expr1 = '[m]+[^a-zA-Z0-9 \f\n\r\t\v][yudD]+';
            index1 = regexp(newValue, expr1, 'once');
            
            %dd:mm
            expr2 = '[yudD]+[^a-zA-Z0-9 \f\n\r\t\v][m]+';
            index2 = regexp(newValue, expr2, 'once');
            
            % format contains a confused m if either one of the expressions
            % matches.  Matching means the index will be non-empty
            containsMinutes = ~isempty(index1) || ~isempty(index2);
        end
        
        function updatedValue = replaceMinutesIndicatorWithMonths(newValue)
            
            % mm:dd:yyyy
            expr1 = '[m]+[^a-zA-Z0-9 \f\n\r\t\v][yudD]+';
            [startIndex,endIndex] = regexp(newValue, expr1);
            
            for index = 1:numel(startIndex)
                newValue(startIndex(index):endIndex(index)) = ...
                    replace(newValue(startIndex(index):endIndex(index)), 'm', 'M');
            end
            
            %dd:mm
            expr2 = '[yudD]+[^a-zA-Z0-9 \f\n\r\t\v][m]+';
            [startIndex,endIndex] = regexp(newValue, expr2);
            
            for index = 1:numel(startIndex)
                newValue(startIndex(index):endIndex(index)) = ...
                    replace(newValue(startIndex(index):endIndex(index)), 'm', 'M');
            end
            
            % updatedValue will have replaced lower case m with upper case
            % M if the m appears in a sequence that seems like a date (near
            % d, D, u or y)
            updatedValue = newValue;
        end
        
        function dateArray = processComponentDateTimeObjects(dateArray, format)
            
            
            % Remove time and time zone data.
            dateArray = dateshift(dateArray, 'start', 'day');
            dateArray.TimeZone = '';
            
            if nargin == 2
                filteredFormat = matlab.internal.datetime.filterTimeIdentifiers(format);
                dateArray.Format = filteredFormat;
            end
        end
    end
end

