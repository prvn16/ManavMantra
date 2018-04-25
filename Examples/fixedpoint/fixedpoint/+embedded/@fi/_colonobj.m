function y = colonobj(varargin)
%COLONOBJ  Colon indexing for fi objects used in a for-loop, subsref, or subsasgn expression.
%
%   See also COLON.

%   Copyright 2013 The MathWorks, Inc.
    y = colon(varargin{:});
end
