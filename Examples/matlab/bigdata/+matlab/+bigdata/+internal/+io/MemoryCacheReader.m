%MemoryCacheReader
% An implementation of the Reader interface that returns chunks from a
% memory cache entry.
%

%   Copyright 2016 The MathWorks, Inc.

classdef MemoryCacheReader < matlab.bigdata.internal.io.Reader
    properties (SetAccess = immutable)
        % The underlying data for the memory cache entry.
        Data;
    end
    
    properties (SetAccess = private)
        % The last index to be returned by read.
        LastReadIndex = 0;
    end
    
    methods
        % The main constructor.
        function obj = MemoryCacheReader(data)
            obj.Data = data;
        end
    end
    
    methods
        %HASDATA Query whether any more data exists
        function tf = hasdata(obj)
            tf = obj.LastReadIndex < numel(obj.Data);
        end
        
        %READ Read the next chunk of data
        function data = read(obj)
            obj.LastReadIndex = obj.LastReadIndex + 1;
            data = obj.Data{obj.LastReadIndex};
        end
    end
end
