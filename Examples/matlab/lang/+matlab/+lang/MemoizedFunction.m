classdef (Sealed) MemoizedFunction < handle & ...
        matlab.mixin.internal.indexing.Paren & ...
        matlab.mixin.internal.Scalar & ...
        matlab.mixin.internal.indexing.DotNotOverloaded
    % MEMOIZEDFUNCTION caches results of executing the function for a set of inputs.
    %
    % Use the MEMOIZE function to create instances of this class.
    %
    % MEMOIZEDFUNCTION objects have the same calling syntax as matlab
    % function handles.
    % To call the function referred to by a MemoizedFunction, use ordinary
    % parenthesis notation. That is, specify the MemoizedFunction variable
    % followed by a common-separated list of input arguments enclosed in
    % parenthesis. For example,  OBJECT(ARG1, ARG2, ...). To call a
    % function with no arguments, use empty parenthesis, e.g.,
    % OBJECT().
    %
    % The MemoizedFunction will return cached results when it has been
    % called previously with the same inputs and same number of outputs.
    %
    % It will execute the function and cache the results when it is called
    % with a fresh set of inputs, and/or with a different number of outputs
    % than seen before.
    %
    % Example:
    % % Creation
    % mf = memoize(@plus);
    % % Use
    % y = mf(10, 10); % Calls plus and caches result.
    % z = mf(10, 10); % Does not call plus, and returns cached result.
    %
    % A MemoizedFunction M has properties that control its behavior.  Access or
    % assign to a property using P = M.Property or M.Property = P.
    %
    % MemoizedFucntion properties:
    %  Function   - (Read-only) identifies the matlab function referred
    %               to by the MemoizedFunction.
    %  Enabled    - (Logical) State of MemoizedFunction. Use this property
    %               to toggle memoization. When set to false, the object
    %               will behave just like the underlying function handle.
    %               Default value of true.
    %  CacheSize  - (Double) Number specifying the maximum number of input and
    %               output combinations that can be cached.
    %               Default value of 10.
    %
    % MemoizedFunction methods:
    %  clearCache - Clears the cache.
    %  stats      - Returns struct with some statistics along with all the
    %               cached contents. Use this method to build any
    %               diagnostics on usage.
    %
    % Example:
    %         mf.Enabled = false;
    %         mf.CacheSize = 123;
    %         mf.clearCache();
    %         s = mf.stats();
    %
    % Notes:
    % 1. MemoizedFunction objects pointing to the same matlab function
    %       are the same object.
    %       For Example:
    %           obj1 = memoize(@plus);
    %           obj2 = memoize(@plus);
    %           obj1 == obj2
    %           ans =
    %                  1
    %
    % 2. MemoizedFunction objects are persistent to a session of MATLAB.
    %       For Example:
    %           f = memoize(@plus);
    %           f.Enabled = 0; % By default, Enabled == true
    %           clear f; % Only clears the object f.
    %           h = memoize(@plus);
    %           isequal( h.Enabled, false ); % State that was set by 'f'
    %
    %    This behavior allows for MemoizedFunctions that exist in function
    %    scopes to reuse results from previous runs of the parent function.
    %       For Example:
    %           function output = foo(input1, input2)
    %               mfPlus = memoize(@plus);
    %               output = mfPlus(input1, input2);
    %           end
    % 
    %           foo(ones(10), eye(10)); % First use will cache these inputs
    %           foo(ones(10), eye(10)); % Second call will reuse results
    %                                from last call
    % 
    % 3. MemoizedFunctions cache their inputs and outputs. Inherently this
    %       can use a lot of memory. To reclaim memory without calling
    %       "clear all", use the MATLAB function "clearAllMemoizedCaches"
    %       to clear caches of all MemoizedFunctions that exist in the current
    %       session of MATLAB. All the MemoizedFunctions that exist are
    %       still usable after calls to this function.
    %
    % 4. Clear functions, will also clear all the caches but will have the
    %       side effect of deleting all existing MemoizedFunctions.
    %
    % See also: MEMOIZE, CLEARALLMEMOIZEDCACHES, FUNCTION_HANDLE
    
    % Copyright 2016 The MathWorks, Inc.
    
    
    %% Properties
    properties (SetAccess = private)
        % FUNCTION  MATLAB function_handle referenced.
        Function function_handle;
    end
    
    properties
        % ENABLED  Logical value indicating state of MemoizedFunction. Use this property to toggle memoization.
        Enabled logical = true;
    end
    
    properties (Dependent)
        % CACHESIZE  Double value indicating maximum number of cached input and output combinations.
        CacheSize;
    end
    
    properties (Access = private)
        % Holds all cached data
        Cache;
        
        % Default cache size
        PrivateCacheSize double = 10;
        
        % Controls printing of debugging information
        TracingEnabled logical = false;
        
    end
    
    properties (Access = private)
        % Versioning to maintain backwards compabitbility
        Version double = 1.0;
    end
    
    properties (Hidden)
        % Default caching policy
        CachingPolicy char = 'CB';
        
    end
    
    %% Public get and set methods for properties
    methods
        function set.Enabled(obj, state)
            % Setter method for Enabled
            validateattributes(state, {'logical'}, {'scalar','nonnan'});
            obj.Enabled = state;
        end
        
        function cSize = get.CacheSize(obj)
            % Getter method for CacheSize
            cSize = obj.PrivateCacheSize;
        end
        
        function set.CacheSize(obj, val)
            % Setter method for CacheSize
            validateattributes(val, {'numeric'},{'scalar', 'positive', 'nonnan', 'integer'});
            obj.updateCacheSize(val);
        end
        
        function set.CachingPolicy(obj, policy)
            % Setter method for CachePolicy
            validatestring(policy, {'CB', 'LFU', 'NONE'});
            obj.CachingPolicy = policy;
        end
        
        function clearCache(obj)
            % Clears cache held by MemoizedFunction.
            obj.initCache();
        end
        
        function output = stats(obj)
            % Returns cached values along with some statistics on the usage.
            
            % Give users access to cache.
            objCache = obj.Cache;
            output.Cache = rmfield(objCache,{'Load'});
            
            output.CacheHitRatePercent   = objCache.TotalHits /(objCache.TotalHits + objCache.TotalMisses) * 100;
            output.CacheOccupancyPercent = objCache.Load/obj.PrivateCacheSize*100;
            
            if isnan(output.CacheHitRatePercent)
                output.CacheHitRatePercent = 0;
            end
            
            output.MostHitCachedInput = [];
            if output.CacheHitRatePercent ~= 0
                [output.MostHitCachedInput.Hits, idx] = max(objCache.HitCount);
                output.MostHitCachedInput.Input = [objCache.Inputs{idx}];
            end
            
            % Arrange fields with structs on top, followed by percentages.
            output = orderfields(output, ...
                {'Cache', 'MostHitCachedInput', 'CacheHitRatePercent', 'CacheOccupancyPercent'});
        end
        
    end
    
    %% Protected methods
    methods (Access = {?matlab.lang.internal.Memoizer})
        function obj = MemoizedFunction(handleToMemoize, maxCacheSize)
            % Constructor, only accessible from the Memoizer
            
            % Uncomment following line to filter unbound function handles
            % obj.disallowUnboundFunctionHandles(handleToMemoize);
            obj.Function = handleToMemoize;
            
            if nargin == 2
                obj.PrivateCacheSize = maxCacheSize;
            end
            obj.initCache();
        end
        
        function delete(~)
            % Hiding deletion, as deleting one handle will invalidate all
            % other handles that exist for the same function
        end
        
    end
    
    %% Hidden methods
    methods (Hidden)
        
        function varargout = parenReference(obj,varargin)
            % Overloading parenReference to mimic function call syntax
            try
                
                if ~obj.Enabled
                    [varargout{1:nargout}] = obj.execute(varargin);
                    return;
                end
                
                % local variables for commonly used values.
                load = obj.Cache.Load;
                
                if load > 0
                    for i = load : -1 : 1 % Iterate backwards
                        if isequaln(varargin,obj.Cache.Inputs{i}) ...
                                && nargout == obj.Cache.Nargout(i)
                            % Cache hit!
                            varargout = obj.Cache.Outputs{i};
                            obj.Cache.HitCount(i) = obj.Cache.HitCount(i) + 1;
                            obj.Cache.TotalHits = obj.Cache.TotalHits + 1;
                            obj.trace(['Using cached result for : ' func2str(obj.Function)]);
                            return
                        end
                    end
                end
               
                % Call the function
                [varargout{1:nargout}] = obj.execute(varargin);
                obj.Cache.TotalMisses = obj.Cache.TotalMisses + 1;
               
                % Refresh load variable
                load = obj.Cache.Load;

                % Cache result
                if obj.PrivateCacheSize == 0
                    % Accounts for cache misses
                    return;
                elseif load < obj.PrivateCacheSize
                    % remember input/output combination for next time
                    obj.trace('Inserting last value to Cache');
                    obj.Cache.Inputs{end+1}  = varargin;
                    obj.Cache.Nargout(end+1) = nargout;
                    obj.Cache.Outputs{end+1} = varargout;
                    obj.Cache.HitCount(end+1) = 0;
                    obj.Cache.Load = load + 1;
                    
                else % check against cache policy
                    obj.trace('Cache full');
                    
                    switch obj.CachingPolicy
                        case 'CB'
                            % Circular Buffer
                            obj.Cache.Inputs  = {obj.Cache.Inputs{2:end}, varargin};
                            obj.Cache.Nargout = [obj.Cache.Nargout(2:end), nargout];
                            obj.Cache.Outputs = {obj.Cache.Outputs{2:end}, varargout};
                            obj.Cache.HitCount = [obj.Cache.HitCount(2:end), 0];
                            obj.trace('CB policy');
                            
                        case 'LFU'
                            % Least Frequently Used
                            [hitCount, idx] = min(obj.Cache.HitCount);
                            obj.Cache.Inputs{idx}  = varargin;
                            obj.Cache.Outputs{idx} = varargout;
                            obj.Cache.Nargout(idx) = nargout;
                            obj.Cache.HitCount(idx) = 0;
                            obj.trace(['LFU policy: replacing entry with ' num2str(hitCount) 'hits']);
                            
                        case 'NONE'
                            % Once the Cache is full, no more cache entries will be
                            % added
                            obj.trace('Cache unchanged');
                        otherwise
                            error(message('MATLAB:MemoizedFunction:InvalidCachePolicy'));
                    end
                end
            catch err
                % Throw as caller to hide this class from stack
                throwAsCaller(err);
            end
        end
        
        function varargout = feval(obj, varargin)
            % FEVAL a MemoizedFunction
            [varargout{1:nargout}] = parenReference(obj,varargin{:});
        end

        function varargout = repmat(obj, varargin)
            % REPMAT always errors
            try
                obj(2) = obj; %#ok Mimic array formation error message.
            catch err
                throwAsCaller(err)
            end
        end
        
        function state = toggleTracing(obj)
            % Toggles printing of various debugging information
            state = obj.TracingEnabled;
            obj.TracingEnabled = ~obj.TracingEnabled;
        end
        
    end
    %% Static Methods
    methods (Static, Hidden)
        function rval = loadobj(obj)
            % Loading a MemoizedFunction overwrites existing MemoizedFunctions
            % with the same function_handle
            
            % Ask the memoizer for MemoizedFunction with the same handle.
            % Replace the cache of the returned MemoizedFunction with
            % object being loaded
            
            memoizer = matlab.lang.internal.Memoizer.getInstance();
            [rval, previouslyCached] = memoizer.getMemoizedFunction(obj.Function);
            
            if previouslyCached
                warning(message('MATLAB:MemoizedFunction:OverwriteOnLoad', func2str(obj.Function)));
            end
            
            % Set the state to the object being loaded.
            rval = copyState(obj, rval);
            
        end
    end
    
    %% Private methods
    methods (Access = private)
        
        function trace(obj, str)
            % Prints debugging text when tracer is enabled
            if obj.TracingEnabled
                disp(str);
            end
        end
        
        function copy = copyState(obj, copy)
            % Copy state from one object to another.
            assert(isa(copy,'matlab.lang.MemoizedFunction'));
            
            % To maintain backwards compatibility, each case in the switch
            % encodes conversion from the version number in the case
            % to the current version
            switch obj.Version
                case 1
                    % Conversion from Version 1 to Current Version
                    copy = copyStateFromVersion1(obj,copy);
                    
                otherwise
                    % Add cases to handle conversions from older versions
                    % User must never hit this error.
                    error(message('MATLAB:MemoizedFunction:InvalidVersion'));
            end
        end
        
        function copy = copyStateFromVersion1(obj, copy)
            % Helper to copy state information from objects of Version 1
            assert(obj.Version == 1);
            
            copy.Enabled = obj.Enabled;
            copy.Cache = obj.Cache;
            copy.CacheSize = obj.CacheSize;
            copy.TracingEnabled = obj.TracingEnabled;
            copy.CachingPolicy = obj.CachingPolicy;
        end
        
        function initCache(obj)
            % Initializes an empty cache.
            obj.Cache.Inputs  = {};
            obj.Cache.Nargout = [];
            obj.Cache.Outputs = {};
            obj.Cache.HitCount = [];
            obj.Cache.Load = 0;
            obj.Cache.TotalHits = 0;
            obj.Cache.TotalMisses = 0;
        end
        
        function varargout = execute(obj, inputs)
            % Execute without using cache
            obj.trace(['Executing fcn ' func2str(obj.Function)])
            [varargout{1:nargout}] = obj.Function(inputs{:});
        end
        
        function updateCacheSize(obj, cacheSize)
            % Updates cache size
            obj.trace([' Updating cache to ' num2str(cacheSize) ' elements']);
            if cacheSize < obj.Cache.Load
                % If cacheSize is smaller, truncate cache by dropping
                % trailing entries
                obj.Cache.Inputs  = obj.Cache.Inputs(1:cacheSize);
                obj.Cache.Nargout = obj.Cache.Nargout(1:cacheSize);
                obj.Cache.Outputs = obj.Cache.Outputs(1:cacheSize);
                obj.Cache.HitCount = obj.Cache.HitCount(1:cacheSize);
                obj.Cache.Load = cacheSize;
            end
            
            obj.PrivateCacheSize = cacheSize;
        end
        
        function disallowUnboundFunctionHandles(~, handleToMemoize)
            % Helper function which could be used to disallow unbound
            % function handles.
            % Unbound function handles have special semantics whereby the
            % functions they point to, do not exist on the path when they
            % are created, and point to a function when it comes onto the
            % path.
            % It was decided that to simplify matters, those who use
            % unbound function handles know their semantics and should be
            % able to memoize with those semantics in mind.
            hProp = functions(handleToMemoize);
            if strcmpi(hProp.type,'simple')
                if isempty(hProp.file)
                    pathToFile = which(hProp.function);
                    isbuiltin = strfind(pathToFile, 'built-in');
                    if isempty(isbuiltin) || ~isbuiltin
                        error(message('MATLAB:MemoizedFunction:UnsupportedHandle'));
                    end
                end
            end
        end
        
    end
end

