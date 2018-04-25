function millis = tryTextFormats(data,formats,allowFractionalSeconds)
% Convert using the first format which succeeds for any of the data.

% Copyright 2017 MathWorks, Inc.

if ischar(data), data = {data};end
if nargin < 3 
    allowFractionalSeconds = true;
end

literalNaNs = strcmpi(data,'nan')...
    | strcmpi(data,'+nan')...
    | strcmpi(data,'-nan')...
    | (strlength(data) == 0)...
    | ismissing(data);

millis(literalNaNs) = NaN;
for i = 1:numel(formats)
    d = matlab.internal.duration.createFromString(data(~literalNaNs),formats{i},allowFractionalSeconds);
    if isempty(d) || ~all(isnan(d(:)))
        % something worked, return data.
        millis(~literalNaNs) = d;
        millis = reshape(millis,size(data));
        return
    end
end
error(message('MATLAB:duration:AutoConvertString',data{find(~literalNaNs,1)}));
end

