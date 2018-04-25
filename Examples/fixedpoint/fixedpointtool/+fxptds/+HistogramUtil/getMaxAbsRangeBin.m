function maxAbsRangeBin = getMaxAbsRangeBin(dtContainerInfo)
%% GETMAXABSRANGEBIN function uses SimulinkFixedPoint.DTContainerInfo and returns the  
% log2 bin representing the max representable range of the container
%
% dtContainerInfo - an instance of SimulinkFixedPoint.DTContainerInfo

%   Copyright 2016-2017 The MathWorks, Inc.

    maxAbsRangeBin = [];
    
    % validate DTContainerInfo 
    if isempty(dtContainerInfo) || ~isa(dtContainerInfo,'SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer')
        return;
    end
    
    if dtContainerInfo.isFixed
        % find out the max absolute range representable by the given
        % dtContainer
        maxAbsRange = max(abs([dtContainerInfo.min, dtContainerInfo.max]), [], 2);

        % compute the histogram bin where the max absolute representable range
        % will fall into
        maxAbsRangeBin = ceil(log2(double(maxAbsRange)));
    end
end