function throw(err, varargin)
% Issue a user-visible error from the lazy evaluation framework.
%
% This constructs an error that both:
%  1. Is treated as a user-visible error. I.e. this will not be wrapped as
%     an "Internal Error".
%  2. Removes all internal frames from the stack trace of the error.
%
% Syntax:
%  matlab.bigdata.internal.throw(message(..)) issues a user-visible error
%  from the given message object.
%
%  matlab.bigdata.internal.throw(err) converts the error into a
%  user-visible error and throws it.
%
%  matlab.bigdata.internal.throw(..,name1,value1,..) provides additional
%  options that specify how the error is built. This includes:
%
%   IncludeCalleeStack: Include the part of stack trace from a caught error
%   from the callee downwards. This exists to allow stack traces of custom
%   code to be included in the error.

%   Copyright 2017 The MathWorks, Inc.

import matlab.bigdata.BigDataException;
options = iParseOptions(varargin{:});
err = BigDataException.build(err);
if options.IncludeCalleeStack
    err = markCalleeFramesAsUserVisible(err);
end
updateAndRethrow(err);

function options = iParseOptions(varargin)
p = inputParser();
p.addParameter('IncludeCalleeStack', false, @(x) islogical(x) && isscalar(x));
p.parse(varargin{:});
options = p.Results;
