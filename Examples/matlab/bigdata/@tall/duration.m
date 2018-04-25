function d = duration(varargin)
%DURATION Create a tall array of durations.
%   D = DURATION(H,MI,S)
%   D = DURATION(H,MI,S,MS)
%   D = DURATION(DV)
%   D = DURATION(...,'Format',FMT)
%
%   See also DURATION/DURATION.
        
%   Copyright 2016 The MathWorks, Inc.

narginchk(1,6)
d = slicefun(@(varargin) duration(varargin{:}), varargin{:});
d = setKnownType(d, 'duration');
end
