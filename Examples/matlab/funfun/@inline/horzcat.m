function c = horzcat(varargin)
%HORZCAT Horizontal concatenation of inline objects (disallowed)

%   Steven L. Eddins, August 1995
%   Copyright 1984-2011 The MathWorks, Inc. 

error(message('MATLAB:Inline:horzcat:notAllowed'));
