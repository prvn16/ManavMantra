%ContextClassLoaderGuard
% Helper class to ensure the thread context ClassLoader is correct whenever
% accessing HDFS from MATLAB.

%   Copyright 2015 The MathWorks, Inc.

classdef (Sealed, Hidden) ContextClassLoaderGuard < handle
    properties (SetAccess = immutable, Transient)
        Guard;
    end
    
    methods
        % The main constructor.
        function obj = ContextClassLoaderGuard()
            obj.Guard = com.mathworks.storage.hdfs.ContextClassLoaderGuard();
        end
        
        % Scope cleanup of the guard.
        function delete(obj)
            if ~isempty(obj.Guard)
                close(obj.Guard);
            end
        end
    end
end
