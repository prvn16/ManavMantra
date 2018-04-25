function tf = isdecompositionorthogonal(varargin)
%Internal helper function

% Copyright 2013 The MathWorks, Inc.

se = strel(varargin{:});
tf = se.isdecompositionorthogonal;
end