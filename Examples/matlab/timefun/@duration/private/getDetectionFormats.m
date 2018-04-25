function [fmts,numColons] = getDetectionFormats(data)
% Get the Format without fractional seconds.
if ischar(data)
    data = cellstr(data);
end
d = data(contains(data,':'));
if ~isempty(d) 
    numColons = nnz(d{1}==':');
else
    numColons = 0;
end
if numColons == 3
    fmts = {'dd:hh:mm:ss';'hh:mm:ss'};
else
    fmts = {'hh:mm:ss';'dd:hh:mm:ss'};
end
end