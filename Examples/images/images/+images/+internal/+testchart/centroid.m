function [loc] = centroid(x)
% function [loc] = centroid(x)
%  Returns centroid location of a vector
%   x = vector
%   loc = centroid in units of array index
%       = 0 error condition avoids division by zero, often due to clipping

% This code is a modified version of that found in:
%
% sfrmat3, Peter D. Burns(http://losburns.com/imaging/software/SFRedge/index.htm)
% 
% Copyright (c) 2007 Peter D. Burns, pdburns@ieee.org
% Licensed under the Simplified BSD License [see sfrmat3.rights]

n   = 1:length(x);
sumx = sum(x);
if sumx < 1e-4
    loc = 0;
else
    loc = sum(n*x)/sumx;
end
