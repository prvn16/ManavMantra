function out = properties(ts)
%PROPERTIES  Return a cell array of tscollection property names.
%
%   Names = PROPERTIES(TSC) returns a cell array of strings containing 
%   the names of the properties of tscollection TSC.

%   Copyright 2014 The MathWorks, Inc. 

out = fieldnames(ts);