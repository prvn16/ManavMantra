function epsBin = getEpsBin(dtContainerInfo)
%% GETEPSBIN function uses SimulinkFixedPoint.DTContainerInfo and returns the  
% log2 bin representing the epsValue
%
% dtContainerInfo - an instance of SimulinkFixedPoint.DTContainerInfo

%   Copyright 2016-2017 The MathWorks, Inc.

    epsBin = [];
    % validate DTContainerInfo 
    if isempty(dtContainerInfo) || ~isa(dtContainerInfo,'SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer')
        return;
    end
    
    if dtContainerInfo.isFixed
        Eps = dtContainerInfo.getEps;

        % find out the log2 bin which eps would represent
        epsBin = int32(log2(double(Eps)));
    end
end
