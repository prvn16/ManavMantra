function opendoc(file)
%OPENDOC Opens a Microsoft Word file.

% Copyright 1984-2017 The MathWorks, Inc.

try
    if ispc
        winopen(file)
    elseif ismac
        unix(['open "' file '" &']);
    else
        edit(file);
    end
catch
    edit(file)
end
