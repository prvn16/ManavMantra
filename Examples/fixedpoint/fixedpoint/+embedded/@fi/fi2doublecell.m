function c = fi2doublecell(varargin)
%FI2DOUBLECELL FI to cell array of doubles
%   C = FI2DOUBLECELL(F1,F2,...) converts fixed-point objects
%   F1, F2, ... to a cell array of doubles C = {D1, D2, ...}
%   respectively.  Any input that is not a FI object is passed through
%   to the output.
%
%   Helper function for converting fixed-point objects to double.

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2012 The MathWorks, Inc.

c = varargin;
for k=1:nargin
  if isfi(varargin{k})
    c{k} = double(varargin{k});
  end
end
