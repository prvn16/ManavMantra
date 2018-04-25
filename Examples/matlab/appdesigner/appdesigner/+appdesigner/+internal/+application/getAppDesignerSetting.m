function value = getAppDesignerSetting(subGroup, setting)
%GETAPPDESIGNERSETTING Returns setting SETTING for the setting under group
% SUBGROUP. If the setting or group do not exist then it returns empty.

% Copyright 2016 The MathWorks, Inc.

s = settings;

value = [];

% Does the subGroup exist?
if s.matlab.appdesigner.hasGroup(subGroup)
    node = s.matlab.appdesigner.(subGroup);

    % Get the value if the setting exists in the subGroup.
    if node.hasSetting(setting)
        value = node.(setting).ActiveValue;
    end
end

