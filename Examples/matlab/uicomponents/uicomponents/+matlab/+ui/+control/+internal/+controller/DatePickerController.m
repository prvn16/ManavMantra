classdef (Hidden) DatePickerController < matlab.ui.control.internal.controller.ComponentController
    % DatePickerController class is the controller class for the DatePicker
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        function obj = DatePickerController(varargin)
            obj@matlab.ui.control.internal.controller.ComponentController(varargin{:});
        end
    end
    
    methods(Access = 'protected')
        
        function propertyNames = getAdditionalPropertyNamesForView(obj)
            % Get additional properties to be sent to the view
            
            propertyNames = getAdditionalPropertyNamesForView@matlab.ui.control.internal.controller.ComponentController(obj);
            
            % Non - public properties that need to be sent to the view
            propertyNames = [propertyNames; {...
                'ViewLanguage';...
                'InputFormat';...
                }];
        end
        
        function viewPvPairs = getPropertiesForView(obj, propertyNames)
            % GETPROPERTIESFORVIEW(OBJ, PROPERTYNAME) returns view-specific
            % properties, given the PROPERTYNAMES
            %
            % Inputs:
            %
            %   propertyNames - list of properties that changed in the
            %                   component model.
            %
            % Outputs:
            %
            %   viewPvPairs   - list of {name, value, name, value} pairs
            %                   that should be given to the view.
            
            viewPvPairs = {};
            
            % Properties from Super
            viewPvPairs = [viewPvPairs, ...
                getPropertiesForView@matlab.ui.control.internal.controller.ComponentController(obj, propertyNames), ...
                ];
            
            % Handle Items/ItemsData
            if(any(ismember({'Value'}, propertyNames)))
                
                if isnat(obj.Model.Value)
                    % The peernode controller doesn't handle NaT or NaN
                    % We're going to check and replace NaT here  (datetime
                    % NaN to represent Month, Day, Year value when date is NaT.
                    % This functionality should be handled by the
                    % appdes.services.  When the inspector needs to
                    % be supported, this workflow will naturally migrate.
                    viewPvPairs = [viewPvPairs, ...
                        {'Value', 'NaT'} ...
                        ];
                    
                else
                    
                    viewPvPairs = [viewPvPairs, ...
                        {'Value',  getDateForView(obj.Model.Value)} ...
                        ];
                    
                end
                
                if(any(ismember({'ViewLanguage'}, propertyNames)))
                    
                    s = settings;
                    displayLanguage = s.matlab.datetime.DisplayLocale.ActiveValue;
                    viewPvPairs = [viewPvPairs, ...
                        {'ViewLanguage',  displayLanguage} ...
                        ];
                    
                end
            end
            
            if(any(ismember({'DisabledDates'}, propertyNames)))
                
                viewPvPairs = [viewPvPairs, ...
                    {'DisabledDates', getDateForView(obj.Model.DisabledDates)} ...
                    ];
                
            end
            
            if(any(ismember({'Limits'}, propertyNames)))
                % Limits must be of size 1x2
                viewPvPairs = [viewPvPairs, ...
                    {'Limits',  getDateForView(obj.Model.Limits)} ...
                    ];
            end
            
            if(any(ismember({'DisplayFormat'}, propertyNames)))
                % Limits must be of size 1x2
                viewPvPairs = [viewPvPairs, ...
                    {'InputFormat',  getInputFormatForView(obj.Model.DisplayFormat)} ...
                    ];
            end
        end
        
        function handleEvent(obj, src, event)
            % Allow super classes to handle their events
            handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);
            
            if(strcmp(event.Data.Name, 'ValueChanged'))
                % Handles when the user commits new text in the ui
                % Emit both 'ValueChanged' and 'ValueChanging' events
                
                % Get the previous value
                previousValue = obj.Model.Value;
                
                if strcmp(event.Data.Value, 'NaT')
                    newValue = NaT('Format', obj.Model.DisplayFormat);
                else
                    % Get the new value
                    newValue = datetime([event.Data.Value.Year, event.Data.Value.Month, event.Data.Value.Day],'Format', obj.Model.DisplayFormat);
                end
                
                % Create event data for 'ValueChanged'
                valueChangedEventData = matlab.ui.eventdata.ValueChangedData(newValue, previousValue);
                
                % Update the model and emit both 'ValueChanged' and
                % 'ValueChanging' which will in turn trigger the callbacks
                obj.handleUserInteraction('ValueChanged', ...
                    {'ValueChanged', valueChangedEventData, 'PrivateValue', newValue});
                
            end
        end
    end
    
end

function dateStruct = getDateForView(dateArray)

dateStruct = struct('Month', [dateArray(:).Month]',...
    'Day', [dateArray(:).Day]',...
    'Year', [dateArray(:).Year]');


end

function inputFormat = getInputFormatForView(displayFormat)
% GETINPUTFORMATFORVIEW - Compute the format the end user will use when
% entering dates in the edit field

s = settings;
defaultFormat = matlab.internal.datetime.filterTimeIdentifiers(...
    s.matlab.datetime.DefaultDateFormat.FactoryValue);

% if the format is the factory default or all numeric, use that
if isNumericOnly(displayFormat)
    
    % Display Format is all numeric
    inputFormat = displayFormat;
else
    
    % Display Format has alpha representation of month or day
    % Use Localized numeric representation of component
    if isNumericOnly(defaultFormat)
        inputFormat = defaultFormat;
    else
        % Since CJK is numeric, if the default is not numeric, the default
        % is US (dd-MMM-uuuu)
        inputFormat = 'MM/dd/uuuu';
    end
end

end

function isNumericOnly = isNumericOnly(format)
% ISNUMERICONLY - returns true if the format is rendered without day or
% month names in localized text

tempDate = datetime('today', 'Format', format);
if isempty(regexprep(char(tempDate), '[\W\d]', ''))
    isNumericOnly = true;
else
    isNumericOnly = false;
end

end