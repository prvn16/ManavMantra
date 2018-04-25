%CMDLNEND Cleans up after command line demos called after CMDLNBGN.
%
%   See also DEMO, CMDLNBGN

%   Ned Gulley, 6-21-93
%   Copyright 1984-2014 The MathWorks, Inc.

oldFigNumber = findobj('Type', 'figure', 'Name', 'Command Line Demos');
watchoff(oldFigNumber);
