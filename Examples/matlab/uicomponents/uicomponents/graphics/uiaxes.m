function ax = uiaxes(varargin)
%UIAXES Create a UIAxes object
%   ax = UIAXES creates a UIAxes object in a new UI figure window using the
%   default property values.
%
%   ax = UIAXES(parent) creates the UIAxes object in the container
%   specified by parent. The parent must be a UI figure, or a container
%   within a UI figure.
%
%   ax = UIAXES( ___ ,Name,Value) specifies UIAxes property values using
%   one or more Name,Value pair arguments. Use this option with any of the
%   input argument combinations in the previous syntaxes.
%
%   Example: Plot into a UIAxes
%      ax = uiaxes;
%      x = -pi:pi/10:pi;
%      y = tan(sin(x)) - sin(tan(x));
%      plot(ax,x,y)
%
%   See also UIFIGURE, APPDESIGNER.

%   Copyright 2015-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

className = 'matlab.ui.control.UIAxes';
messageCatalogID = 'uiaxes';

if nargin >= 1 && isa(varargin{1}, 'matlab.ui.control.UIAxes')
    error(message('MATLAB:ui:uiaxes:InvalidParent'));
end

try
    ax = matlab.ui.control.internal.model.ComponentCreation.createComponent(...
        className, ...
        messageCatalogID,...
        varargin{:});
catch ex
    if strcmp(ex.identifier,'MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality')
        id = ex.identifier;
    else
        id = 'MATLAB:ui:UIAxes:unknownInput';
    end
    
    error(id, '%s', ex.message);
end

end
