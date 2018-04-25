function c = cat(varargin)
%CAT    N-D concatenation of inline objects (disallowed)

%   Steven L. Eddins, August 1995
%   Copyright 1984-2011 The MathWorks, Inc. 

error(message('MATLAB:Inline:cat:notAllowed'));
