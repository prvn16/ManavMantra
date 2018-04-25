function fixtoolbar(fig)
%FIXTOOLBAR  Plot Editor helper function

%   Copyright 1984-2002 The MathWorks, Inc.   

if ~isempty(findall(fig,'Tag','ScribeSelectToolBtn'))
   set(fig, 'Toolbar', 'figure');
end