function u = lowerbound(T) %#codegen
% LOWERBOUND Lower bound of the range of an embedded.numerictype object
%     L = lowerbound(A) returns the lower bound of the range of an
%     embedded.numerictype object.
%     If L = lowerbound(A) and U = upperbound(A) then [L, U] = range(A). 
%  
%     See also embedded.numerictype/upperbound, embedded.numerictype/range,
%     embedded.fi/lowerbound
%
%     Copyright 2017 The MathWorks, Inc.
  u = lowerbound(fi([],T));
end