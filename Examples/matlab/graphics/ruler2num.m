function n = ruler2num(d, ruler)
%ruler2num Convert ruler-specific data type to numeric array
%     NUM = ruler2num(DATA, RULER) converts non-numeric DATA to NUM depending
%     on the x-axis, y-axis or z-axis object RULER. The class of the RULER 
%     deterimines the allowed datatype of DATA and the mapping to numeric 
%     values. The DatetimeRuler and DurationRuler classes expect DATA to be
%     datetime and duration arrays, respectively. If DATA is numeric then
%     NUM = DATA. If the RULER class is NumericRuler and DATA is
%     non-numeric then NUM = full(double(DATA)).
%
%     Examples:
% 
%      ax = axes;
%      ruler2num([1 2 3], ax.XAxis) % returns [1 2 3]
%
%      t = datetime(2015,1,1:10);
%      plot(t,1:10) % makes the x-axis into a DatetimeRuler
%      ruler2num(t(1:3), ax.XAxis) % returns [0 1 2]
%
%     See also num2ruler, axes, datetime, duration

%   Copyright 2016 The MathWorks, Inc.

narginchk(2,2)

if ~isa(ruler, 'matlab.graphics.axis.decorator.Ruler')
    error(message('MATLAB:graphics:num2ruler:RulerExpected'))
end

if isnumeric(d)
    n = d;
elseif isa(ruler, 'matlab.graphics.axis.decorator.NumericRuler')
    n = full(double(d));
else
    n = ruler.makeNumeric(d);
end
