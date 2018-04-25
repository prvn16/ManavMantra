function c = emptyfirstobj(varargin)
%EMPTYFIRSTOBJ Copy the attributes of first instance of FI into empty FI
%     C = EMPTYFIRSTOBJ(X1, X2, ...) creates a FI object C that has
%     empty data with the attributes of the first instance of a FI
%     object from the input list.  This helper function is used
%     in HORZCAT, VERTCAT, etc. to determine the attributes of their
%     output types.

%   Thomas A. Bryan, 6 February 2003
%   Copyright 2004-2012 The MathWorks, Inc.

% Loop over all input arguments and return a copy of the first FI.
for k=1:nargin
  if isfi(varargin{k})
    x = varargin{k};
    xFimathIsLocal = isfimathlocal(x);
    if xFimathIsLocal
        c = embedded.fi([],numerictype(x),fimath(x));
    else
        c = embedded.fi([],numerictype(x),false);
    end
    break
  end
end
