function [f1,f2] = freqspace(n,flag)
%FREQSPACE Frequency spacing for frequency response.
%   FREQSPACE returns the implied frequency range for equally spaced
%   frequency responses.  FREQSPACE is useful when creating desired
%   frequency responses for FSAMP2, FWIND1, and FWIND2 as well as
%   for various 1-D applications.
%
%   [F1,F2] = FREQSPACE(N) returns the 2-D frequency range vectors
%   F1 and F2 for an N-by-N matrix.
%   [F1,F2] = FREQSPACE([M N]) returns the 2-D frequency range
%   vectors for an M-by-N matrix.
%
%   For N odd,  both F1 and F2 are equal to (-1+1/n:2/n:1-1/n).
%   For N even, both F1 and F2 are equal to (-1    :2/n:1-2/n).
%
%   [F1,F2] = FREQSPACE(...,'meshgrid') is equivalent to
%       [F1,F2] = freqspace(...);
%       [F1,F2] = meshgrid(F1,F2);
%
%   F = FREQSPACE(N) returns the 1-D frequency vector F assuming N
%   equally spaced points around the unit circle. For N even or odd,
%   F = (0:2/N:1). For N even, F contains (N+2)/2 points. For N odd,
%   F contains (N+1)/2 points.
%
%   F = FREQSPACE(N,'whole') returns all N equally spaced points
%   around the unit circle. In this case, F = (0:2/N:2*(N-1)/N).
%
%   Class support for inputs M,N:
%      float: double, single
%
%   See also FSAMP2, FWIND1, FWIND2.
%
%   Note: FSAMP2, FWIND1 and FWIND2 are in the Image Processing Toolbox.

%   Copyright 1984-2017 The MathWorks, Inc.

if length(n)==1 && nargout>1
    n = [n n];
end
if nargin>1
    if ~ischar(flag) && ~(isstring(flag) && isscalar(flag))
        error(message('MATLAB:freqspace:Arg2NotStr'));
    end
end

if nargout>1
    f1 = ((0:n(2)-1)-floor(n(2)/2))*(2/(n(2)));
    f2 = ((0:n(1)-1)-floor(n(1)/2))*(2/(n(1)));
    if nargin>1
        [f1,f2] = meshgrid(f1,f2);
    end
else
    if nargin>1
        f1 = (0:2/n:2*(n-1)/n);
    else
        if length(n)==1 && n==0
            f1 = zeros(1,0,class(n));
        else
            f1 = (0:2/n:1);
        end
    end
end
