function htmlOut = makeprofilerheader()
%MAKEPROFILERHEADER Make the HTML header text of profiler

%   Copyright 1984-2016 The MathWorks, Inc.

    s = {};
    s{end+1} = makeheadhtml;
    s{end+1} = ['<title>', getString(message('MATLAB:profiler:ProfileSummaryName')), '</title>'];
    s{end+1} = '</head>';
    s{end+1} = '<body>';
    htmlOut= [s{:}];
end