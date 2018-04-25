function a_arrayProps = mergeArrayProps(a_arrayProps,b_arrayProps)
% Use b's per-array property values where a's were empty.

%   Copyright 2012-2016 The MathWorks, Inc. 

if isempty(a_arrayProps.Description) && ~isempty(b_arrayProps.Description)
    a_arrayProps.Description = b_arrayProps.Description;
end
if isempty(a_arrayProps.UserData) && ~isempty(b_arrayProps.UserData)
    a_arrayProps.UserData = b_arrayProps.UserData;
end
