function comp = plotbrowser (varargin)
% PLOTBROWSER  Show or hide the plot browser for a figure.
%    PLOTBROWSER ON shows the browser for the current figure.
%    PLOTBROWSER OFF hides the browser.
%    PLOTBROWSER TOGGLE toggles the visibility of the browser.
%    PLOTBROWSER with no arguments is the same as ON.
%
% The first argument may be the handle to a figure, like so:
%    PLOTBROWSER (h, 'on')
% 
% See also FIGUREPALETTE, PROPERTYEDITOR, and PLOTTOOLS.

%   Copyright 1984-2006 The MathWorks, Inc.

narginchk(0,2)
compTmp = showplottool (varargin{:}, 'plotbrowser');
if (nargout > 0)
    comp = compTmp;
end
