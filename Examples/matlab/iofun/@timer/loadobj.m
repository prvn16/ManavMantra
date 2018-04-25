function obj = loadobj(B)
%LOADOBJ Load filter for timer objects.
%
%   OBJ = LOADOBJ(B) is called by LOAD when a timer object is 
%   loaded from a .MAT file. The return value, OBJ, is subsequently 
%   used by LOAD to populate the workspace.  
%
%   LOADOBJ will be separately invoked for each object in the .MAT file.
%

%    Copyright 2001-2017 The MathWorks, Inc.

    %The check for a struct is to support old style Timers. (Version 1)
    if (isstruct(B) && isfield(B, 'jobject') && all(isJavaTimer(B.jobject)))
        obj = timer(B);
    else
        obj = B;
    end

