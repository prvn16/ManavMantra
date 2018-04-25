function setAppDesignerSetting(subGroup, setting, val)
%SETAPPDESIGNERSETTING Sets the setting specified by SUBGROUP and SETTING to
% the value VAL.

% Copyright 2016 The MathWorks, Inc.

s = settings;

% Does the subGroup exist?
if s.matlab.appdesigner.hasGroup(subGroup)
    node = s.matlab.appdesigner.(subGroup);

    % Set the value if the setting exists in the subGroup.
    if node.hasSetting(setting)
        node.(setting).PersonalValue = val;
    else
        error(message('MATLAB:appdesigner:appdesigner:SetInvalidSetting', subGroup, setting));
    end
end
