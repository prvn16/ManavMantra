function tsout = utArithCommonOutput(ts1,ts2,dataout,commomTimeVector,outprops,operator,warningFlag) 
%UTARITHCOMMONOUTPUT
%
 
% Copyright 2006-2012 The MathWorks, Inc.

% Build the output timeseries
tsout = ts1;
if ~ts1.IsTimeFirst && ~ts2.IsTimeFirst
    tsout = init(tsout,dataout,commomTimeVector,'IsTimeFirst',false,'Name','unnamed');
else
    tsout = init(tsout,dataout,commomTimeVector,'IsTimeFirst',true,'Name','unnamed');
end

% Merge timemetadata properties
tsout.TimeInfo.StartDate = outprops.ref;
tsout.TimeInfo.Units = outprops.outunits;
tsout.TimeInfo.Format = outprops.outformat;
% Merge datametadata properties
switch operator
    case '+'
        tsout.DataInfo = plus(ts1.DataInfo,ts2.DataInfo);
    case '-'
        tsout.DataInfo = minus(ts1.DataInfo,ts2.DataInfo);
    case '.*'
        tsout.DataInfo = times(ts1.DataInfo,ts2.DataInfo);
    case '*'
        tsout.DataInfo = mtimes(ts1.DataInfo,ts2.DataInfo);
    case './'
        tsout.DataInfo = rdivide(ts1.DataInfo,ts2.DataInfo);
    case '/'
        tsout.DataInfo = mrdivide(ts1.DataInfo,ts2.DataInfo);
    case '.\'
        tsout.DataInfo = ldivide(ts1.DataInfo,ts2.DataInfo);
    case '\'
        tsout.DataInfo = mldivide(ts1.DataInfo,ts2.DataInfo);
end
% Merge qualmetadata properties
if ~isempty(ts1.QualityInfo) && ~isempty(ts2.QualityInfo)
    tsout.QualityInfo = qualitymerge(ts1.QualityInfo,ts2.QualityInfo);
end
% Merge quality values: pick up minimums
if ~isempty(get(get(tsout,'QualityInfo'),'Code')) && ~isempty(ts1.Quality) && ...
        ~isempty(ts2.Quality)
    tsout.Quality = min(ts1.Quality,ts2.Quality);
end
% Merge events
tsout = addevent(tsout,horzcat(ts1.Events,ts2.Events));
% issue a warning if offset is used.
if warningFlag
    warning(message('MATLAB:timeseries:utArithCommonOutput:newtime'))    
end
