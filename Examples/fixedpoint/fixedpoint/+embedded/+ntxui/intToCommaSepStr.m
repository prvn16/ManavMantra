function y = intToCommaSepStr(x,noCell)
%Format integers as strings with comma separators.
%  intToCommaSepStr(X) converts a vector X of integer values to a cell-
%  vector of strings formatted with commas after every 3 digits.  After ~20
%  digits, scientific notation is utilized without comma-separated digits.
%
%  intToCommaSepStr(X,1) returns a string instead of a cell-vector when
%  converting scalar values.  If X is a vector, or if 0 is passed as the
%  second argument, a cell-vector is returned.
%
% % Example: convert numbers containing 1 to 12 digits
% s = embedded.ntxui.intToCommaSepStr([1 12 123 1234 12345 123456 1234567 ...
%        12345678 123456789 1234567890 12345678901 ...
%        123456789012])

%   Copyright 2010 The MathWorks, Inc.

% Create a cellstr of strings
% Note: sprintfc is undocumented and unsupported
y = sprintfc('%d', x)';

% Insert commas
y = regexprep(y, '\d(?=(\d{3})+\>)', '$0,');

% Return a scalar string if appropriate
if nargin>1 && noCell && isscalar(x)
    y = y{1};
end
