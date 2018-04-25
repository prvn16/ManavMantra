classdef (Sealed) Memoizer < handle
    % Singleton class to manage functions memoized through the MEMOIZE
    % interface
    % See also: MEMOIZE, MATLAB.LANG.MEMOIZEDFUNCTION, CLEARALLMEMOIZEDCACHES
    %
    % Copyright 2016 The MathWorks, Inc.
    
    %% Properties
    properties (Access = private)
        % Cell array of MemoizedFunctions created
        MemoizedFunctionCache cell;
        Tracer logical = false;
    end
    
    %% Public Methods
    methods (Static)
        function instance = getInstance()
            % Create or get an instance of MEMOIZER using getInstance
            persistent singletonObj
            if isempty(singletonObj) || ~isvalid(singletonObj)
                singletonObj = matlab.lang.internal.Memoizer;
            end
            instance = singletonObj;
        end
    end
    
    methods (Access = public)
        function delete(obj)
            % Called with clear functions, clear all, clear Memoizer
            
            % Delete all the handles managed by the Memoizer.
            % This avoids leaking unmanaged MemoizedFunctions
            cellfun(@delete, obj.MemoizedFunctionCache);
        end
        
        function clearCacheAll(obj)
            cellfun(@clearCache, obj.MemoizedFunctionCache);
        end
        
        function [memoizedFcn, previouslyCached] = getMemoizedFunction(obj, ...
                fcnHandleToMemoize)
            % Create or return already exisiting MemoizedFunction
            previouslyCached = true;
            memoizedFcn = obj.lookupCache(fcnHandleToMemoize);
            if isempty(memoizedFcn)
                memoizedFcn = matlab.lang.MemoizedFunction(fcnHandleToMemoize);
                % add to list of memoizedFunctions
                obj.MemoizedFunctionCache{end+1} = memoizedFcn;
                previouslyCached = false;
            end
        end
    end
    %% Private helper functions
    methods (Access = private)
        function obj = Memoizer
            % Private constructor
            obj.MemoizedFunctionCache = {};
        end
        function memoizedFcnHandle = lookupCache(obj, fcnHandleToMemoize)
            % Return handle to MemoizedFunction if already cached.
            localList = obj.MemoizedFunctionCache;
            for fcn = localList
                cachedFcnHandle = fcn{1}.Function;
                if isequal(cachedFcnHandle, fcnHandleToMemoize)
                    memoizedFcnHandle = fcn{1};
                    return;
                end
            end
            memoizedFcnHandle = [];
        end
    end
end
