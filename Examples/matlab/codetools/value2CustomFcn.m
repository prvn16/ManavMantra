function [DataRange, Value2] = value2CustomFcn(DataRange)
% VALUE2CUSTOMFCN Used in scripts created from the Import Tool to parse
% Excel dates
% A function handle reference to this function can be passed as an input to
% xlsread to obtain the Value2 property of the Excel COM client RangeData
% object as the custom output of XLSREAD. The custom output is returned as
% a cell array the same size as the raw data, which is non-empty wherever
% the Excel RangeData object has differing Value and Value2 properties.

%   Copyright 2011 The MathWorks, Inc.

values = DataRange.Value;
values2 = DataRange.Value2;
Value2 = cell(size(values));
for row=1:size(Value2,1)
   for col=1:size(Value2,2)
       if ~isequaln(values{row,col},values2{row,col})
           Value2{row,col} = values2{row,col};
       end
   end
end