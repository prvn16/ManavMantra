function str = deblankAndStripNulls(str)
%deblankAndStripNulls  Deblank a string, treating char(0) as a blank.

% Copyright 2017 The MathWorks, Inc.

if (isempty(str))
    return
end

while (~isempty(str) && (str(end) == 0))
    str(end) = '';
end

str = deblank(str);
end
