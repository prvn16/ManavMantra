function  [slope, int] = findedge(cent, nlin)
% [slope, int] = findedge(cent, nlin)
% fit linear equation to data, written to process edge location array
%   cent = array of (centroid) values
%   nlin = length of cent
%   slope and int are from the least-square fit
%    x = int + slope*cent(x)
%  Note that this is the inverse of the usual cent(x) = int + slope*x
%  form

% This code is a modified version of that found in:
%
% sfrmat3, Peter D. Burns(http://losburns.com/imaging/software/SFRedge/index.htm)
% 
% Copyright (c) 2007 Peter D. Burns, pdburns@ieee.org
% Licensed under the Simplified BSD License [see sfrmat3.rights]

 index = 0:nlin-1;
 [slope, int] = polyfit(index, cent, 1);            % x = f(y)
return
