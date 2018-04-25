function status = isAbsolute(file)
%ISABSOLUTE Determines if a filename is absolute.
%
%   ISABSOLUTE returns true if FILE is an absolute name.

%   Copyright 2004 The MathWorks, Inc.
if ispc
   status = ~isempty(regexp(file,'^[a-zA-Z]*:\/','once')) ...
            || ~isempty(regexp(file,'^[a-zA-Z]*:\\','once')) ...
            || strncmp(file,'\\',2) ...
            || strncmp(file,'//',2);
else
   status = strncmp(file,'/',1);
end

