function millis = detectFormatFromData(data,template)
% Use the format of the data first, before using the auto-detect formats

% Copyright 2017 MathWorks, Inc.
data = cvt2cellstr(data);
fmts = getDetectionFormats(data);

if contains(template.fmt,':')
    % if the format is a timer format, use the base format (minus
    % fractional seconds, since they are always detected. Try the
    % template-format first for hh:mm or mm:ss
    fmts = unique([replace({template.fmt},{'.','S'},''); fmts],'stable');
end

% Try each format, use the one that works.
millis = tryTextFormats(data,fmts);
end

function data = cvt2cellstr(data)
try
    data = convertStringsToChars(data);
    if matlab.internal.datatypes.isCharStrings(data), data = cellstr(data); end % cellstr makes {"..."} into {'...'} which we don't want.
    assert(iscellstr(data)); %#ok<ISCLSTR>
catch
    % something in the cell wasn't a char. Error for general cell case.
    error(message('MATLAB:duration:InvalidComparison','duration', class(data)));
end
end