function y = leftJustifyCellStrs(x)
% Combine all strings in cell-vector x into a single, carriage-return
% delimited string that contains left-justified strings from x.

%   Copyright 2010 The MathWorks, Inc.

% Return length of longest string
% Useful right-justified formatting
N = numel(x);
xlen = cellfun(@numel,x);
cr = sprintf('\n');
y = blanks(sum(xlen)+N);
j=1;
for i=1:N
    ni = xlen(i);
    y(j:j+ni-1) = x{i};
    j=j+ni+1;
    if i<N
        y(j-1) = cr;
    end
end
