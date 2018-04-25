function varargout = range(T) %#codegen
% RANGE Numerical range of an embedded.numerictype object
%       range(A), for an embedded.numerictype object, returns a fi object
%       with the minimum and maximum possible representable by A. 
%
%       [U, V] = range(A) returns the minimum and maximum values
%       representable by A in separate output variables.
%
%       See also embedded.numerictype/upperbound,
%       embedded.numerictype/lowerbound
%
%       Copyright 2017 The MathWorks, Inc.
  [varargout{1:nargout}] = range(fi([],T));
end