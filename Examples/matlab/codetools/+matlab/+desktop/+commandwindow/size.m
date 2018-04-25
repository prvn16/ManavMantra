function val = size 
%matlab.desktop.commandwindow.size Number of characters and lines that can display in the Command Window
%   VAL = matlab.desktop.commandwindow.size returns a two element vector
%   containing the number of columns and number of rows that display 
%   in the Command Window given its current size.  The units are characters.
%   When the matrix display width preference is set to 80 columns, the 
%   number of columns returned is always 80.

%  Copyright 2013 The MathWorks, Inc.

if isdeployed
    cols = 80;
    rows = 25;
else
    cols = builtin('_getcmdwincols');
    rows = builtin('_getcmdwinrows');
end
val = [cols rows];
end