function [this,k] = firstobj(varargin)
%FIRSTOBJ First instance of FI object from input arguments
%   C = FIRSTOBJ(X1, X2, ...) returns the first instance of a FI
%   object from the input list into C.  This helper function is used
%   in HORZCAT, VERTCAT, etc. to determine the attributes of their
%   output types.
%
%   [C,K] = COPYFIRSTOBJ(X1, X2, ...) also returns the position K in
%   the input argument list of the found object.

%   Thomas A. Bryan, 6 February 2003
%   Copyright 2003-2012 The MathWorks, Inc.

% Loop over all input arguments and return the first FI.
for k=1:nargin
  if isfi(varargin{k})
    this = varargin{k};
    break
  end
end

% LocalWords:  COPYFIRSTOBJ
