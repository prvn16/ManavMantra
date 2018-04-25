%DebugSession
% Debug session that handles attaching annotations to the execution
% environment and piping the events to client listeners.

%   Copyright 2017 The MathWorks, Inc.

classdef (Sealed) DebugSession < handle
    properties (Access = private, Transient)
        % An array of soft references to the DebugListener objects attached
        % to this session.
        %
        % We hold soft references so that if a DebugListener object falls
        % out of scope, it is automatically detached from the session.
        ListenerReferences = matlab.mapreduce.internal.SoftReference.empty(0, 1);
        
        % This is the cleanup object that reverts the Executor to the
        % non-annotated version.
        ExecutorCleanup = [];
        
        % A strong reference to DebugListeners for use when listeners have
        % been brought into a different process than their actual owner.
        % This is empty in the client MATLAB process.
        Listeners = {};
    end
    
    methods
        function listener = attach(obj)
            % Attach the debug annotations onto the execution environment
            % and return a listener object that will receive its events.
            %
            % This can be called multiple times within the client MATLAB.
            import matlab.bigdata.internal.debug.DebugExecutorDecorator;
            import matlab.bigdata.internal.debug.DebugListener;
            import matlab.bigdata.internal.executor.PartitionedArrayExecutor;
            
            if isempty(obj.ListenerReferences)
                executor = DebugExecutorDecorator(PartitionedArrayExecutor.default(), obj);
                oldOverride = PartitionedArrayExecutor.override(executor);
                obj.ExecutorCleanup = onCleanup(@() PartitionedArrayExecutor.override(oldOverride));
            end
            
            listener = DebugListener();
            addlistener(listener, 'ObjectBeingDestroyed', @obj.removeListener);
            obj.ListenerReferences(end + 1, 1) = hGetSoftReference(listener);
        end
        
        function notifyDebugEvent(obj, eventName, varargin)
            % Notify that a tall array event has occurred. This is called
            % by the various Debug annotation classes.
            fcnName = [eventName, 'Fcn'];
            for ii = 1 : numel(obj.ListenerReferences)
                listener = get(obj.ListenerReferences(ii));
                if ~isempty(listener) && isvalid(listener)
                    listener.(fcnName)(varargin{:});
                end
            end
        end
        
        function sObj = saveobj(obj)
            % Custom serialize implementation that carries across all owned
            % DebugListener objects. This is necessary when working with
            % the parallel back-ends because event listeners do not
            % serialize.
            sObj = arrayfun(@get, obj.ListenerReferences, 'UniformOutput', false);
            sObj(cellfun(@isempty, sObj), :) = [];
        end
    end
    
    methods (Static)
        function obj = getCurrentDebugSession()
            % Get the current debug session for the client MATLAB process.
            persistent singleton;
            if isempty(singleton)
                singleton = matlab.bigdata.internal.debug.DebugSession;
                mlock;
            end
            obj = singleton;
        end
        
        function obj = loadobj(sObj)
            % Custom serialize implementation that carries across all owned
            % DebugListener objects. This is necessary when working with
            % the parallel back-ends because event listeners do not
            % serialize.
            import matlab.bigdata.internal.debug.DebugSession;
            obj = DebugSession();
            obj.ListenerReferences = [obj.ListenerReferences; cellfun(@hGetSoftReference, sObj)];
            % We need to ensure a strong reference to the DebugListener
            % objects because their actual owner will be in a different
            % process.
            obj.Listeners = sObj;
        end
    end
    
    methods (Access = private)
        function obj = DebugSession()
            % Private constructor for the singleton logic.
        end
        
        function removeListener(obj, listener, ~)
            % Remove a DebugListener from this object. This is invoked on a
            % ObjectBeingDestroyed event from the DebugListener.
            reference = hGetSoftReference(listener);
            for ii = 1:numel(obj.ListenerReferences)
                if obj.ListenerReferences(ii) == reference
                    obj.ListenerReferences(ii, :) = [];
                    break;
                end
            end
            
            if isempty(obj.ListenerReferences)
                obj.ExecutorCleanup = [];
            end
        end
    end
end
