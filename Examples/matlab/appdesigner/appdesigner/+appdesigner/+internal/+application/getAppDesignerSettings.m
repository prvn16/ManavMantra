function result = getAppDesignerSettings(entries)
%GETAPPDESIGNERSETTINGS Returns settings.
% - entries is a cell array of struct. 
%   The struct in cell array has two properties: subGroup and settingKey.

% Copyright 2016 The MathWorks, Inc.

s = settings;

result = struct;

for i = 1:length(entries)
    
    subGroup = entries(i).subGroup;
    settingKey = entries(i).settingKey;

    if s.matlab.appdesigner.hasGroup(subGroup)
        node = s.matlab.appdesigner.(subGroup);
        if node.hasSetting(settingKey)
            value = node.(settingKey).ActiveValue;
            if (~isfield(result, subGroup))
                result.(subGroup) = struct;
            end
            result.(subGroup).(settingKey)= value;
        end
    end
end    
end
