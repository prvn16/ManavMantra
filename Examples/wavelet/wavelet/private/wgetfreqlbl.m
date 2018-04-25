function xlbl = wgetfreqlbl(xunits)
%WGETFREQLBL Returns a label for the frequency axis.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

options = wgetfrequnitstrs;

xlbl = options{1};
for i = length(options):-1:1,
    if strfind(options{i}, xunits),
        xlbl = options{i};
    end
end

% [EOF]
