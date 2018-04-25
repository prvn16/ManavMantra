function varargout = uifigure(varargin)
%UIFIGURE Create UI figure window
%    UIFIGURE creates a UI figure using default property values configured
%    for building apps in App Designer.
%
%    UIFIGURE(Name, Value) specifies properties using one or more Name,
%    Value pair arguments.
%
%    fig = UIFIGURE(___) returns the figure object, fig. Use this
%    option with any of the input argument combinations in the previous
%    syntaxes.
%
%    Example 1: Create Default UI figure
%       uifigure;
%
%    Example 2: Create a UI figure with a specific title.
%       fig = uifigure('Name', 'Plotted Results');
%
%    See also UIPANEL, UITAB, UITABGROUP, UIBUTTONGROUP

%    Copyright 2015-2017 The MathWorks, Inc.

nargoutchk(0,1);

% Call the uifigureImpl function to create the uifigure
window = matlab.ui.internal.uifigureImpl(varargin{:});

if (nargout > 0)
    varargout{1} = window;

end
