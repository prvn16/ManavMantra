function list = parselist(listin)
%Parse comma separated list into a cell array

%   Copyright 1984-2013 The MathWorks, Inc.

if (isempty(listin))
    list = {};
else
    % Return a row vector.
    list = textscan(listin, '%s', 'delimiter', ',');
    list = list{1}';
end
