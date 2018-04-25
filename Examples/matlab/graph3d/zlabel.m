function hh = zlabel(varargin)
%ZLABEL Z-axis label.
%   ZLABEL('text') adds text above the Z-axis on the current axis.
%
%   ZLABEL('txt','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the zlabel.
%
%   ZLABEL(AX,...) adds the zlabel to the specified axes.
%
%   H = ZLABEL(...) returns the handle to the text object used as the label.
%
%   See also XLABEL, YLABEL, TITLE, TEXT.

%   Copyright 1984-2017 The MathWorks, Inc.

% if the input has a zlabel property which is a text object, use it to set
% the zlabel on.
[ax,args,nargs] = plotedit({'labelcheck','ZLabel',varargin});

if isempty(ax)
    ax = gca;
end

if nargs == 0 || (nargs > 1 && (rem(nargs-1,2) ~= 0))
  error(message('MATLAB:zlabel:InvalidNumberOfInputs'))
end

string = args{1};
if isempty(string), string=''; end
pvpairs = args(2:end);

% get-set does not support strings as of now
pvpairs = matlab.graphics.internal.convertStringToCharArgs(pvpairs);

if isappdata(ax,'MWBYPASS_zlabel')
    fcn = getappdata(ax,'MWBYPASS_zlabel');
    h = feval(fcn{:},string,pvpairs{:});

  %---Standard behavior
else
    h = get(ax,'ZLabel');
    set(h,'FontSizeMode','auto',...
        'FontUnitsMode','auto',...
        'FontWeight',get(ax,'FontWeight'),...
        'FontAngle',get(ax,'FontAngle'),...
        'FontName',get(ax,'FontName'));
    set(h, 'String', string, pvpairs{:});
   
end

if nargout > 0
  hh = h;
end
