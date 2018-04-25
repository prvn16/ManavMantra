function allValues(obj)
% ALLVALUES Display a table of all direct child settings with values at all the levels.
%

% Copyright 2015-2016 The MathWorks, Inc.

allSubgroupsSettingsList = properties(obj);
settingNames             = {};
% Properties under this settings group include direct child settings and
% settings groups that are 'visible'

% Obtain list of settings to display values
for i = 1:numel(allSubgroupsSettingsList)
    currentChildProp = obj.(allSubgroupsSettingsList{i});
    if strcmpi(class(currentChildProp), 'matlab.settings.Setting')
        settingNames = [settingNames, {allSubgroupsSettingsList(i)}]; %#ok<AGROW>
    end
end

% If no value is set by users, display <no value>

if ~isempty(settingNames)
    valueSize        = numel(settingNames);
    TemporaryValues  = cell(1,valueSize);
    PersonalValues   = cell(1,valueSize);
    FactoryValues    = cell(1,valueSize);
    ActiveValues     = cell(1,valueSize);
    for i=1:valueSize 
        TemporaryValues{i}    = '<no value>'; 
        PersonalValues{i}     = '<no value>'; 
        FactoryValues{i}      = '<no value>'; 
        ActiveValues{i}       = '<no value>'; 
        if obj.(settingNames{i}{:}).hasTemporaryValue()
            TemporaryValues{i}  = obj.(settingNames{i}{:}).TemporaryValue;
        end
        if obj.(settingNames{i}{:}).hasPersonalValue()
            PersonalValues{i}     = obj.(settingNames{i}{:}).PersonalValue;
        end
        if obj.(settingNames{i}{:}).hasFactoryValue()
            FactoryValues{i}  = obj.(settingNames{i}{:}).FactoryValue;
        end
        try
            ActiveValues{i} = obj.(settingNames{i}{:}).ActiveValue;
        catch
        end
    end

    % TO DO : Invetigate Updating allValues() method to use cell array display 
    % instead of table display if required for indentation issue
    % This should be compatible with settings/table datatypes decisions  
    
    % Store all values in MATLAB table - columns representing levels
    % At this point, settings datatype is restricted to be the same at all
    % levels.
    tableWithAllValues                          = table(ActiveValues', TemporaryValues', PersonalValues', FactoryValues');
    tableWithAllValues.Properties.RowNames      = [settingNames{:}];
    tableWithAllValues.Properties.VariableNames = {'ActiveValue', 'TemporaryValue', 'PersonalValue', 'FactoryValue'};
    strToDisplay = regexprep(evalc('disp(tableWithAllValues)'), '''<no value>''', ' <no value> ');
    fprintf(strToDisplay);
end
  
end

