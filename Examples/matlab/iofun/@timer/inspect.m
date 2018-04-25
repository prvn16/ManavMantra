function inspect(obj)
%INSPECT Open the inspector and inspect timer object properties.

%    RDD 11-20-2001
%    Copyright 2001-2003 The MathWorks, Inc.

% Error checking.
if length(obj) ~= 1
    error(message('MATLAB:timer:singletonrequired'));
end

if ~isvalid(obj)
   error(message('MATLAB:timer:invalid'));
end

inspect(obj.getJobjects);
% Open the inspector.
