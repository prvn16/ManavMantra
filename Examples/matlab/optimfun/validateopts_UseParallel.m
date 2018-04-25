function [value,valid] = validateopts_UseParallel(value,throwerr,updateValue)

% Validate UseParallel option and optionally throw error.
% value: the value set for UseParallel option.
% throwerr: logical to indicate if the caller wants to throw error from
% this function if value is not correct.
% updateValue: logical to indicate if the caller wants to convert old-style
% string values to logical.
%
% returns modified value (if needed) and a boolean flag to indicate if
% value is not acceptable.


%   Copyright 2013-2017 The MathWorks, Inc.

% Quickly check the valid cases and then dive into error checking
valid = isscalar(value) && ...
    (islogical(value) || (isnumeric(value) && (value == 0 || value == 1)));
if valid
  value = logical(value);
  return;
end
% This option also accepts specific strings
deprecated_values = {'always','never'};
valid = (ischar(value) || isstring(value)) && any(strcmpi(value,deprecated_values));
if valid && updateValue
  if strcmpi(value,'never')
    value = false;
  elseif strcmpi(value,'always')
    value = true;
  end
end
  
% Throw error or return now
if valid || ~throwerr
   return;
end
msgid = 'MATLAB:optimfun:optimoptioncheckfield:NotLogicalScalar';
errid = 'MATLAB:validateopts_UseParallel:NotLogicalScalar';
errmsg = getString(message(msgid, 'UseParallel'));
error(errid,errmsg)
