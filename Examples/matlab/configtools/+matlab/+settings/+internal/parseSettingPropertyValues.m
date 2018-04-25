function [results,defaults] = parseSettingPropertyValues(varargin)
% Parse the name/value pairs associated with creating a setting

%   Copyright 2015-2018 The MathWorks, Inc.

    persistent propSettingsValueParser;
    if(isempty(propSettingsValueParser))
        propSettingsValueParser = inputParser;
        % add required input groupName
        propSettingsValueParser.addRequired('Name', @isvarname);
        % add optional Property-Value pairs to inputParser
        propSettingsValueParser.addParameter('Hidden', false, @islogical);
        propSettingsValueParser.addParameter('ReadOnly', false, @islogical);
        propSettingsValueParser.addParameter('PersonalValue',[]);
        propSettingsValueParser.addParameter('ValidationFcn', []);   
    end
    propSettingsValueParser.parse(varargin{:}{:});
    results  = propSettingsValueParser.Results;
    results.Name = char(results.Name);
    assert(isscalar(results.Hidden), message('MATLAB:settings:LogicalScalarHidden'));
    assert(isscalar(results.ReadOnly), message('MATLAB:settings:LogicalScalarReadOnly'));
    defaults = cell2struct(cell([1 numel(fields(results))]),fieldnames(results),2);
    def_fieldnames = propSettingsValueParser.UsingDefaults;
    
    % Set the field of defaults to true if it is included in propGroupValueParser.UsingDefaults
    for i=1:numel(def_fieldnames)
        defaults.(def_fieldnames{i}) = true;
    end
    
    % Set the field of defaults to false if not included in propGroupValueParser.UsingDefaults
    idx = structfun(@(x)isempty(x),defaults);
    def_fieldnames = fieldnames(defaults);
    
    for i=1:numel(def_fieldnames)
        if(idx(i))
            defaults.(def_fieldnames{i}) = false;
        end
    end
    
    % If ReadOnly is set to true, then PersonalValue must be specified. If
    % not, throw an error
    if(results.ReadOnly && (sum(arrayfun(@(x)strcmp(x,'PersonalValue'),propSettingsValueParser.UsingDefaults)) == 1))
        error(message('MATLAB:settings:config:ReadOnlySettingMustSpecifyPersonalValue',results.Name));
    end 
end
