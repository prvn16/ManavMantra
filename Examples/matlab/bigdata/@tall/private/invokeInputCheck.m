function args = invokeInputCheck(fcnInfo, varargin)
%invokeInputCheck Check inputs from builtin code

% Copyright 2016 The MathWorks, Inc.

args = varargin;
if ~isempty(fcnInfo{3})
    % constraint might be 'table', or 'numeric logical' etc.
    constraint = strsplit(fcnInfo{3});
    [args{:}] = tall.validateType(varargin{:}, fcnInfo{1}, constraint, 1:numel(varargin));
end
end
