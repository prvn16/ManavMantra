function [varargout] = subsrefRecurser(a,s)
%SUBSREFRECURSER Utility for overloaded subsref method in @table.

%   Copyright 2012-2014 The MathWorks, Inc.

[varargout{1:nargout}] = subsref(a,s);
