function controls = validateFindControls( Fig )
%validateFindControls Return uicontrol handles given a figure.

%   Copyright 2012-2015 The MathWorks, Inc.

uichandles = findall(Fig, 'Visible', 'on');
controls = [];
for i = 1:length(uichandles)
    hc = handle(uichandles(i));
    if (isa(hc, 'matlab.ui.control.UIControl') || ...
            isa(hc, 'matlab.ui.control.Table') || ...
            isa(hc, 'matlab.ui.container.internal.JavaWrapper'))
        controls = [controls; uichandles(i)]; %#ok<AGROW>
    end
end
