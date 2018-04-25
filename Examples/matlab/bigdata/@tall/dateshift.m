function tc = dateshift(tt,varargin)
%DATESHIFT Shift tall datetimes or generate sequences according to a calendar rule.
%   Supported syntaxes for tall DATETIME:
%   T2 = DATESHIFT(T,'start',UNIT)
%   T2 = DATESHIFT(T,'end',UNIT)
%   T2 = DATESHIFT(T,'dayofweek',DOW)
%   T2 = DATESHIFT(T,...,RULE)
%
%   See also DATETIME/DATESHIFT.

%   Copyright 2015-2017 The MathWorks, Inc.

narginchk(3,4);
tall.checkNotTall(upper(mfilename), 1, varargin{1:2});
tt = tall.validateType(tt, mfilename, {'datetime'}, 1);
if nargin > 3 && istall(varargin{3})
    tallrule = tall.validateType(varargin{3}, mfilename, {'numeric'}, 3);
    tc = elementfun(@(x, y) dateshift(x, varargin{1:2}, y), tt, tallrule);
else
    tc = elementfun(@(x) dateshift(x, varargin{:}), tt);
end
% Output adaptor should be same as input but with new size
tt_adap = matlab.bigdata.internal.adaptors.getAdaptor(tt);
tc.Adaptor = copySizeInformation(tt_adap, tc.Adaptor);
end
