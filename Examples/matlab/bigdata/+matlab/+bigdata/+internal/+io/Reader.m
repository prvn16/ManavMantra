%Reader
% The interface used by matlab.bigdata.internal.executor.convertToIndependentTasks
% to read data stored at a shuffle point.
%

%   Copyright 2016 The MathWorks, Inc.

classdef (Abstract) Reader < handle
    methods (Abstract)
        %HASDATA Query whether any more data exists
        %
        % This returns true if and only if there exists more data that can
        % be read.
        %
        out = hasdata(obj);
        
        %READ Read the next chunk of data
        %
        data = read(obj);
    end
end
