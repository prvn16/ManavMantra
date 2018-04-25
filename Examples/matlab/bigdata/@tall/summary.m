function out = summary(t)
%SUMMARY Display summary information about tall table or tall timetable
%   SUMMARY(TT) displays a summary of all the variables in tall table or tall
%   timetable TT. This will take a long time to execute if there is a large
%   amount of data in TT.

% Copyright 2015-2017 The MathWorks, Inc.

import matlab.bigdata.internal.util.formatBigSize

t = tall.validateType(t, mfilename, {'table', 'timetable'}, 1);

gotSummary = false;
metadata = hGetMetadata(hGetValueImpl(t));
if ~isempty(metadata)
    [gotSummary, summaryInfo] = getValue(metadata, 'TableSummary');
end

if ~gotSummary
    summaryInfo = gather( aggregatefun( ...
        @matlab.bigdata.internal.util.calculateLocalSummary, ...
        @matlab.bigdata.internal.util.reduceSummary, ...
        t) );
end

tableProperties = subsref( t, substruct( '.', 'Properties' ) );
if nargout == 0
    matlab.bigdata.internal.util.printSummary( summaryInfo, tableProperties );
else
    out = matlab.bigdata.internal.util.emitSummary( summaryInfo, tableProperties );
end

end
