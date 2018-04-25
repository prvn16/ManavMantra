function tt = makeTallTimetableWithDimensionNames(dimNames, rowtimes, varnames, szMismatchException, varargin)
% Construct a tall timetable with a specific DimensionNames.
% If 'szMismatchException' is empty, no error checking is done on the sizes of the
% variables. Otherwise, it is presumed to be an MException to be thrown.

% Copyright 2016-2017 The MathWorks, Inc.

% Setup the call with a specific DimensionNames.
ttablefcn = @(rt, varargin) mytimetable(dimNames, rt, varnames, szMismatchException, varargin{:});
% Construct a tall timetable.
tt = slicefun(ttablefcn, rowtimes, varargin{:});
% Construct the appropriate adaptor.
adaptors = cellfun(@(tx) tx.Adaptor, varargin, 'UniformOutput', false);
unsizedAdaptor = matlab.bigdata.internal.adaptors.TimetableAdaptor(varnames, adaptors, ...
         dimNames, rowtimes.Adaptor);
tt.Adaptor = copySizeInformation(unsizedAdaptor, tt.Adaptor);
end

function t = mytimetable(dimNames, rowtimes, varnames, szMismatchException, varargin)
% timetable does not provide a syntax to construct a timetable with a
% specific DimensionNames. We need to first construct the timetable, then
% update the properties.
if ~isempty(szMismatchException)
    rtHeight = size(rowtimes, 1);
    if ~all(cellfun(@(v) size(v, 1) == rtHeight, varargin))
        throw(szMismatchException);
    end
end
t = matlab.bigdata.internal.util.makeTabularChunk(...
    @timetable, varargin, {'RowTimes', rowtimes, 'VariableNames', varnames});
t.Properties.DimensionNames = dimNames;
end
