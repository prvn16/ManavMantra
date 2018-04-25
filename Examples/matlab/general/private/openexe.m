function openexe(file)
%OPENEXE Opens a Microsoft DOS or Windows executable.

% Copyright 2004-2007 The MathWorks, Inc.

if ispc
    try
        winopen(file)
    catch exception %#ok
        edit(file)
    end
else
    edit(file)
end