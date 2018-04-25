function s = extractBetween(str,startStr,endStr,varargin)
%EXTRACTBETWEEN Create a string from part of a larger string.
%   S = EXTRACTBETWEEN(STR, START, END)
%   S = EXTRACTBETWEEN(..., 'Boundaries', B)
%
%   EXTRACTBETWEEN on tall string arrays does not support expansion in the
%   first dimension.
%
%   See also TALL/STRING.

%   Copyright 2016 The MathWorks, Inc.

narginchk(3,5);

% First input must be tall string.
if ~istall(str)
    error(message('MATLAB:bigdata:array:ArgMustBeTall', 1, upper(mfilename)));
end
str = tall.validateType(str, mfilename, {'string'}, 1);

% Treat all inputs slice-wise, wrapping char arrays if used. We allow
% expansion or contraction in small dimensions, but not the tall dim.
startStr = wrapCharInput(startStr);
endStr = wrapCharInput(endStr);
s = slicefun(@(a,b,c) iSubstring(a,b,c,varargin{:}), str, startStr, endStr);

% The output is the same type as the input. Use the size set up by SLICEFUN.
s.Adaptor = copySizeInformation(str.Adaptor, s.Adaptor);
end


function out = iSubstring(in, varargin)
% Call substring and check that it acted slice-wise.

% Take care over empty partitions. We need to return something that will
% successfully concatenate regardless of how the other partitions expand.
if size(in,1)==0
    out = string.empty(0,0);
    return;
end

out = extractBetween(in, varargin{:});

if size(out,1) ~= size(in,1)
    % Tried to change the tall size
    if isscalar(in) && isempty(out)
        % If the input was scalar and there was no match we get a 0x1 empty instead
        % of a 1x0. Fix that now.
        out = reshape(out, [1,0]);
    else
        % If not empty then we must be trying to return multiple matches
        error(message('MATLAB:bigdata:array:MultipleSubstrings'));
    end
end
end
