function d = num2ruler(n, ruler)
%num2ruler Convert numeric array to ruler-appropriate array datatype
%     DATA = num2ruler(NUM, RULER) converts numeric NUM to DATA depending
%     on the x-axis, y-axis or z-axis object RULER. The class of the RULER 
%     deterimines the datatype of DATA.
%     The NumericRuler class sets DATA = NUM.
%
%     Examples:
% 
%      ax = axes;
%      num2ruler([1 2 3], ax.XAxis) % returns [1 2 3]
%
%      t = datetime(2015,1,1:10);
%      plot(t,1:10) % makes the x-axis into a DatetimeRuler
%      num2ruler([1 2 3], ax.XAxis) % returns [2015-1-1 2015-1-2 ...]      
%
%     See also ruler2num, axes, datetime, duration

%   Copyright 2016 The MathWorks, Inc.

narginchk(2,2)

if ~isa(ruler, 'matlab.graphics.axis.decorator.Ruler')
    error(message('MATLAB:graphics:num2ruler:RulerExpected'))
end
if ~isnumeric(n)
    error(message('MATLAB:graphics:num2ruler:NumericExpected'))
end

if isa(ruler, 'matlab.graphics.axis.decorator.NumericRuler')
    d = n;
else
    d = ruler.makeNonNumeric(n);
end
