function out = totalNumPasses(in)
%TOTALNUMPASSES
% A getter/setter to static state that counts the number of full passes
% launched by this MATLAB process.

%   Copyright 2016 The MathWorks, Inc.

persistent value;
if isempty(value)
    value = 0;
    mlock;
end

if nargout
    out = value;
end

if nargin
    value = in;
end
