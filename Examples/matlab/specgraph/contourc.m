%CONTOURC Contour computation.
%   CONTOURC computes the contour matrix C for use by CONTOUR,
%       CONTOUR3, or CONTOURF to draw the actual contour plot.
%
%   C = CONTOURC(Z) computes the contour matrix for a contour plot
%      of matrix Z treating the values in Z as heights above a plane.  A
%      contour plot is the set of level curves of Z for some values V.  The
%      values V are chosen automatically.
%
%   C = CONTOURC(X, Y, Z), where X and Y are vectors, specifies the X-
%      and Y-axes limits for Z.
%
%   CONTOURC(Z, N) and CONTOURC(X, Y, Z, N) compute N contour lines,
%      overriding the automatic value.
%
%   CONTOURC(Z, V) and CONTOURC(X, Y, Z, V) compute LENGTH(V) contour lines
%      at the values specified in vector V.  Use CONTOURC(Z, [v, v]) or
%      CONTOURC(X, Y, Z, [v, v]) to compute a single contour at the level v.
%
%   The contour matrix C is a two row matrix of contour lines. Each
%   contiguous drawing segment contains the value of the contour,
%   the number of (x, y) drawing pairs, and the pairs themselves.
%   The segments are appended end-to-end as
%
%       C = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
%            pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
%
%   See also CONTOUR, CONTOURF, CONTOUR3.

%   Copyright 1984-2010 The MathWorks, Inc.
%   Built-in function.

