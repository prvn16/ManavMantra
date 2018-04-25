function out = printProfilerRefreshButton
%PRINTPROFILERREFRESHBUTTON Generate the HTML text of the refresh button

% Copyright 2016 The MathWorks, Inc.
    out =  ['<input type="submit" value="', getString(message('MATLAB:profiler:Refresh')), '"/>'];
end