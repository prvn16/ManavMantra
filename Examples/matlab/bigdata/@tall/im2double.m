function out = im2double(in, varargin)
%IM2DOUBLE Convert image to double precision.
%   I2 = im2double(I1)
%   RGB2 = im2double(RGB1)
%   I = im2double(BW)
%   X2 = im2double(X1,'indexed')
%
%   See also im2double, tall.

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(1,2);
tall.checkNotTall(mfilename, 1, varargin{:});
in  = tall.validateType(in, mfilename, {'numeric', 'logical'}, 1);
out = elementfun(@(in) im2double(in, varargin{:}), in);
out = setKnownType(out, 'double');
end
