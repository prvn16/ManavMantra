function hh = xlabel(varargin)
%XLABEL X-axis label.
%   XLABEL('text') adds text beside the X-axis on the current axis.
%
%   XLABEL('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the xlabel.
%
%   XLABEL(AX,...) adds the xlabel to the specified axes.
%
%   H = XLABEL(...) returns the handle to the text object used as the label.
%
%   See also YLABEL, ZLABEL, TITLE, TEXT.

%   Copyright 1984-2017 The MathWorks, Inc.

% if the input has an xlabel property which is a text object, use it to set
% the xlabel on.
[ax,args,nargs] = labelcheck('XLabel',varargin);

if nargs == 0 || (nargs > 1 && (rem(nargs-1,2) ~= 0))
  error(message('MATLAB:xlabel:InvalidNumberOfInputs'))
end

if isempty(ax)
    ax = gca;
    
    % Chart subclass support
    % Invoke xlabel method with same number of outputs to defer output arg
    % error handling to the method.
    if isa(ax,'matlab.graphics.chart.Chart')
        if(nargout == 1)
            hh = xlabel(ax,args{:});
        else
            xlabel(ax,args{:});
        end
        return
    end
end

string = args{1};
if isempty(string), string=''; end
pvpairs = args(2:end);

% get-set does not support strings as of now
pvpairs = matlab.graphics.internal.convertStringToCharArgs(pvpairs);

if isappdata(ax,'MWBYPASS_xlabel')
  h = mwbypass(ax,'MWBYPASS_xlabel',string,pvpairs{:});

  %---Standard behavior
else
    h = get(ax,'XLabel');
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
