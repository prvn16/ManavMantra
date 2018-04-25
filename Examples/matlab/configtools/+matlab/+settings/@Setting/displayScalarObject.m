function displayScalarObject(obj)
%DISPLAYSCALAROBJECT    Display a scalar Setting object

%   Copyright 2015-2018 The MathWorks, Inc.

    SettingFullName = obj.SettingFullName;
    if numel(SettingFullName) >= 5 && strcmp(SettingFullName(1:5), 'root.')
        SettingFullName(1:5)= '';
    end

    sp = matlab.internal.display.formatSpacing;

    if strcmp(sp,'loose')
        cr = newline;
    else
        cr = '';
    end

    settingHeader = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);

    m = message('MATLAB:ObjectText:DISPLAY_AND_DETAILS_SCALAR_WITH_PROPS', [settingHeader, ' ','''' SettingFullName '''']);
    fprintf('%s%c%c', getString(m), cr, newline);
            
    propNames  = { 'ActiveValue', 'TemporaryValue', 'PersonalValue', 'FactoryValue'};
    levelNames = { 'Active', 'Temporary', 'Personal', 'Factory' };
    values     = cellfun(@(x) getValueAtLevel(obj, x), levelNames, 'UniformOutput', false);
    propValues = cell2struct(values,propNames,2); %#ok<NASGU>

    strToDisplay = regexprep(evalc('disp(propValues)'), '''<no value>''' , '<no value>');
    fprintf('%s',strToDisplay);
    
end

function value = getValueAtLevel(obj, levelname)
if strcmp(levelname, 'Temporary')
    if(~obj.hasTemporaryValue)
        value = '<no value>';
    else
        value = obj.TemporaryValue;
    end
elseif strcmp(levelname, 'Personal')
    if(~obj.hasPersonalValue)
        value = '<no value>';
    else
        value = obj.PersonalValue;
    end
elseif strcmp(levelname, 'Factory')
    if(~obj.hasFactoryValue)
        value = '<no value>';
    else
        value = obj.FactoryValue;
    end
elseif strcmp(levelname, 'Active')
    try
    value = obj.ActiveValue;
    catch
        value = '<no value>';
    end
end

end
