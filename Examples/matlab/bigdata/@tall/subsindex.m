function idx = subsindex(~)
%SUBSINDEX Subscript index. Not supported for tall arrays.

% Copyright 2016 The MathWorks, Inc.

idx = 0; %#ok<NASGU>
error(message('MATLAB:bigdata:array:SubsindexNotSupported'));
end
