function print(this)
%PRINT Handles Print to a Printer
%    Uses the getPrintToFigure method to get the print figure and passes it
%    on to the PRINTDLG

%   Copyright 2015 The MathWorks, Inc.

% Call the utility method to get the print figure
printFig = getPrintFigure(this);

printBackgroundColor = [1 1 1];
printTickColor = [0 0 0];
set(printFig,'Color',printBackgroundColor);

% Fix legend colors to be consistent with the axes
hLegends = findall(printFig,'Tag','legend');
set(hLegends, ...
    'Color',     printBackgroundColor, ...
    'EdgeColor', printTickColor, ...
    'TextColor', printTickColor);
  
% prepareForPrinter(this, printFig);

% Do not invert since custom inversion of axes is done within the display
% and because MATLAB's figure update does not propagate to panel colors.
set(printFig, 'InvertHardcopy', 'off');


% Pass the figure to Print dialog 
try
    printdlg(printFig);
catch me   
    close(printFig);
    rethrow(me);
end
close(printFig);