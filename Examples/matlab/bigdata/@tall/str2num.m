function o = str2num(~) %#ok<STOUT>
%STR2NUM Convert string matrix to numeric array.
%
% This function is not supported for tall arrays.

%   Copyright 2016 The MathWorks, Inc.

error(message('MATLAB:bigdata:array:Str2numNotSupported'));