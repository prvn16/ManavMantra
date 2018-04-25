function spinmap(time,inc)
%SPINMAP Spin color map.
%   SPINMAP cyclically rotates the color map for about 3 seconds.
%   SPINMAP(T) rotates it for about T seconds.
%   SPINMAP(inf) is an infinite loop, break with <ctrl-C>.
%   SPINMAP(T,inc) uses the specified increment.  The default is
%   inc = 2, so inc = 1 is a slower rotation, inc = 3 is faster,
%   inc = -2 is the other direction, etc.
%
%
%   See also COLORMAP, RGBPLOT.

%   Copyright 1984-2017 The MathWorks, Inc. 

if nargin < 1
    time = 3;
end

if nargin < 2
    time = convertStringsToChars(time);
    inc = 2;
end

cm = colormap;
M = cm;

% Generate the rotated index vector; allow for negative inc.
m = size(M,1);
k = rem((m:2*m-1)+inc,m) + 1;

% Use while loop because time might be inf.
t = clock;
while etime(clock, t) < time
   M = M(k,:);
   colormap(M)
   drawnow('expose');
end

colormap(cm)
