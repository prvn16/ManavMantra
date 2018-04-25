function [xcolname, ycolname] = bfitdatastatsgetcolnames(dataHandle)
%BFITDATASTATSGETCOLNAMES gets columns labels to use in the Data Statistics GUI

%   Copyright 1984-2010 The MathWorks, Inc.

dh = handle(dataHandle);

xcolname = 'X';
ycolname = 'Y';
 
if isprop(dh, 'XDataSource') && ~isempty(get(dh, 'XDataSource'))
    xcolname = get(dh, 'XDataSource');
end
if isprop(dh, 'YDataSource') && ~isempty(get(dh, 'YDataSource'))
    ycolname = get(dh, 'YDataSource');
end
