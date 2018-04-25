function varargout = printToFigure(this, varargin)
%PRINT Handles Print to Figure
%   Uses the getPrintToFigure method to get the print figure and displays
%   the figure.

%   Copyright 2015, The MathWorks, Inc.

openFigure = true;
if nargin == 2
    openFigure = varargin{1};
end

% Call the utility method to get the print figure
printFig = getPrintFigure(this);

if openFigure
    movegui(printFig, 'center');
    % Display the print figure;
    set(printFig, 'Visible', 'on');
end

if nargout
    varargout = {printFig};
end