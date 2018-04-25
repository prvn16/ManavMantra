function [MLDTOSetting,MLDTOAppliesToSetting] = eml_fipref_helper(dtoStr,dtoAppliesToStr)
% Helper function to be used only in fi constructor to modify DTO settings

%   Copyright 2006-2012 The MathWorks, Inc.
    
fp = fipref;
MLDTOSetting = fp.DataTypeOverride;
MLDTOAppliesToSetting = fp.DataTypeOverrideAppliesTo;

dtoStr = lower(dtoStr);
switch dtoStr
  case {'forceoff','off'}
    fp.DataTypeOverride = 'ForceOff';
  case 'scaleddoubles'
    fp.DataTypeOverride = 'ScaledDoubles';
  case 'truedoubles'
    fp.DataTypeOverride = 'TrueDoubles';
  case 'truesingles'
    fp.DataTypeOverride = 'TrueSingles';
  otherwise
    error(message('fixed:fipref:dtoSettingNotSupported', dtoStr));
end

dtoAppliesToStr = lower(dtoAppliesToStr);
switch dtoAppliesToStr
  case {'allnumerictypes'}
    fp.DataTypeOverrideAppliesTo = 'AllNumericTypes';
  case {'fixed-point'}
    fp.DataTypeOverrideAppliesTo = 'Fixed-point';
  case {'floating-point'}
    fp.DataTypeOverrideAppliesTo = 'Floating-point';
  otherwise
    error(message('fixed:fipref:dtoAppliesToSettingNotSupported', dtoAppliesToStr));
end
