function hh = ylabel(varargin)
%YLABEL Y-axis label.
%   YLABEL('text') adds text beside the Y-axis on the current axis.
%
%   YLABEL('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the ylabel.
%
%   YLABEL(AX,...) adds the ylabel to the specified axes.
%
%   H = YLABEL(...) returns the handle to the text object used as the label.
%
%   See also XLABEL, ZLABEL, TITLE, TEXT.

%   Copyright 1984-2017 The MathWorks, Inc.

% if the input has a ylabel property which is a text object, use it to set
% the ylabel on.
[ax,args,nargs] = labelcheck('YLabel',varargin);

if nargs == 0 || (nargs > 1 && (rem(nargs-1,2) ~= 0))
  error(message('MATLAB:ylabel:InvalidNumberOfInputs'))
end

if isempty(ax)
    ax = gca;
    
    % Chart subclass support
    % Invoke ylabel method with same number of outputs to defer output arg
    % error handling to the method.
    if isa(ax,'matlab.graphics.chart.Chart')
        if(nargout == 1)
            hh = ylabel(ax,args{:});
        else
            ylabel(ax,args{:});
        end
        return
    end
end

string = args{1};
if isempty(string), string=''; end
pvpairs = args(2:end);

% get-set does not support strings as of now
pvpairs = matlab.graphics.internal.convertStringToCharArgs(pvpairs);

if isappdata(ax,'MWBYPASS_ylabel')
  h = mwbypass(ax,'MWBYPASS_ylabel',string,pvpairs{:});

  %---Standard behavior
else
    h = get(ax,'YLabel');
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
