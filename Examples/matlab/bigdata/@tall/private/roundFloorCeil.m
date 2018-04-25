function out = roundFloorCeil(fcn, narginUBNumeric, narginUBDuration, in, varargin)
%roundFloorCeil Shared implementation for ROUND, FLOOR, and CEIL
%   fcn: the underlying function to call
%   narginUBNumeric: the upper bound on NARGIN for numeric/logical/char
%   narginUBDuration: the upper bound on NARGIN for duration
%   in, varargin: the original inputs to the function

% Copyright 2017 The MathWorks, Inc.

try
    tall.checkNotTall(func2str(fcn), 1, varargin{:});
    in = tall.validateType(in, func2str(fcn), {'numeric', 'logical', 'char', 'duration'}, 1);
   
    % Call helper function that calls the right invocation of NARGINCHK
    if strcmp(tall.getClass(in), 'duration')
        iCallNarginChk(narginUBDuration, varargin{:});
    else
        iCallNarginChk(narginUBNumeric, varargin{:});
    end
    
    out = elementfun(@(x) fcn(x, varargin{:}), in);
    out = invokeOutputInfo('preserveLogicalCharToDouble', out, {in});
    out.Adaptor = copySizeInformation(out.Adaptor, in.Adaptor);
catch E
    % Ensure all errors appear to come from outer function
    throwAsCaller(E);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a slight contortion to allow us to use NARGINCHK outside the original
% context.
function iCallNarginChk(narginUB, varargin)
narginchk(1, narginUB);
end
