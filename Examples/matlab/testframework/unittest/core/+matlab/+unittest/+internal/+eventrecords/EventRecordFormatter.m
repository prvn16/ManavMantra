classdef EventRecordFormatter
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016 The MathWorks, Inc.
    methods(Abstract)
        str = getFormattedExceptionReport(formatter, eventRecord);
        str = getFormattedQualificationReport(formatter, eventRecord);
        str = getFormattedLoggedReport(formatter, eventRecord);
    end
end

% LocalWords:  formatter