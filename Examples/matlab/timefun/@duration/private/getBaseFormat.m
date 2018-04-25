function [fmt,allowFractionalSeconds] = getBaseFormat(fmt)
% Get the Format without fractional seconds.

% Copyright 2017 MathWorks, Inc.
allowFractionalSeconds = contains(fmt,"S");
fmt = replace(fmt,[".S","S"],"");
end

