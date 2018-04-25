%IM2FRAME Convert indexed image into movie format.
%   F = IM2FRAME(X,MAP) converts the indexed image X and
%   associated colormap MAP into a movie frame F.  If X is
%   a truecolor (MxNx3) image, then MAP is optional and has
%   no effect.
%
%     M(1) = im2frame(X1,map);
%     M(2) = im2frame(X2,map);
%      ...
%     M(n) = im2frame(Xn,map);
%     movie(M)
%
%   F = IM2FRAME(X) converts the indexed image X into a movie
%   frame F using the current colormap if X contains an 
%   indexed image.
%     
%   See also FRAME2IM, MOVIE, GETFRAME.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.
