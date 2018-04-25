function out = regexprep(in, expr, rep, varargin)
%REGEXPREP Replace string using regular expression.
%   S = REGEXPREP(STRING,EXPRESSION,REPLACE)
%   S = REGEXPREP(STRING,EXPRESSION,REPLACE,OPTION)
%
%   See also TALL/STRING.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(3,4);

% First input must be a tall string.
if ~istall(in)
    error(message('MATLAB:bigdata:array:ArgMustBeTall', 1, upper(mfilename)));
end
in = tall.validateType(in, mfilename, {'string','cellstr'}, 1);

% Remaining arguments must not be tall and EXPR and REP must be valid
% text inputs (char row, string, cellstr).
tall.checkNotTall(upper(mfilename), 1, expr, rep, varargin{:});
expr = iCheckAndMaybeWrapChar(expr, 'PATTERN');
rep = iCheckAndMaybeWrapChar(rep, 'REPLACE');

% Just in case the user function samples random numbers, fix the RNG state.
% (regexprep can execute arbitrary code so might use RAND)
opts = matlab.bigdata.internal.PartitionedArrayOptions('RequiresRandState', true);

% Element-wise in first input, with all others bound in.
out = elementfun(opts, @(x) regexprep(x,expr,rep,varargin{:}), in);
% Output is same size and type as input (cellstr or string)
out.Adaptor = in.Adaptor;

end

function x = iCheckAndMaybeWrapChar(x, name)
% Wrap char arrays in cells to ensure they are treated as scalar
if ischar(x)
    if ~isrow(x) && ~isequal(size(x),[0 0])
        error(message('MATLAB:REGEXP:invalidInputs',name));
    end
    x = {x};
elseif ~iscellstr(x) && ~isstring(x)
    % Not a valid text input
    error(message('MATLAB:REGEXP:invalidInputs',name));
end
end
