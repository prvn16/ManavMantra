function [hRequire, hProvide] = getVariableUsage(hFunc)
%getVariableUsage Return the required and provided variables
%
%  [hRequired, hProvided] = getVariableUsage(hFunc) returns the set of
%  inputs that are required and the set of outputs that this function call
%  will provide.  Empty 1x0 matrix is returned for each if there are no
%  required or provided variables.

%  Copyright 2012-2014 The MathWorks, Inc.

% All inputs are required

if isempty(hFunc.Argin)
    hRequire = zeros(1,0);
else
    hRequire = hFunc.Argin;
end

% Only outputs that are not also inputs are provided
if isempty(hFunc.Argout)
    hProvide = zeros(1,0);
else
    hProvide = setdiff(hFunc.Argout, hFunc.Argin);
end
