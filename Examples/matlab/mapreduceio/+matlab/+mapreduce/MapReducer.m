classdef (Abstract) MapReducer < handle & matlab.mapreduce.internal.SoftReferableMixin
%MAPREDUCER Declares the interface expected of mapreducer.
%   This class captures the interface expected of mapreducer. MapReducers
%   are the execution environment for evaluating mapreduce.
%
%   See also mapreduce, mapreducer.

%   Copyright 2014-2016 The MathWorks, Inc.

    properties
        % A flag that determines if this object can become the current global MapReducer instance.
        ObjectVisibility = 'On';
    end
    
    properties (SetAccess = immutable, Hidden)
        % The stack node representing this MapReducer in the MapReducer manager.
        MapReducerStackNode;
    end
    
    properties (Access = private)
        % A PartitionedArrayExecutor that can execute tall expressions.
        PartitionedArrayExecutor;
        
        % A cache of the memento data so that we can reset the partitioned
        % array executor if the mapreducer has changed.
        CachedMemento;
    end
    
    methods (Access = protected)
        % Protected constructor that ensures the current MapReducer system
        % is aware of this object.
        function obj = MapReducer()
            import matlab.mapreduce.internal.MapReducerStackNode;
            obj.MapReducerStackNode = MapReducerStackNode.hBuildNode(obj);
        end
    end
    
    methods
        % Object setters
        function set.ObjectVisibility(obj, value)
            obj.ObjectVisibility = validatestring(value, {'On', 'Off'}, 'MapReducer', 'ObjectVisibility');
        end
    end
    
    methods (Sealed, Hidden = true)
        % Get the PartitionedArrayExecutor associated with this MapReducer
        % that will evaluate tall expressions.
        function executor = getPartitionedArrayExecutor(this)
            import matlab.bigdata.internal.executor.PartitionedArrayExecutorReference;
            
            memento = this.getMemento();
            if isempty(this.PartitionedArrayExecutor) || ~isequal(memento, this.CachedMemento)
                this.PartitionedArrayExecutor = [];
                this.PartitionedArrayExecutor = this.createPartitionedArrayExecutor();
                this.CachedMemento = memento;
            end
            
            executor = PartitionedArrayExecutorReference(...
                this.PartitionedArrayExecutor, ...
                memento);
        end
        
        % Get a struct of properties that can be used to recreate an
        % instance of the given MapReducer.
        function m = getMemento(obj)
            m = obj.doGetMemento();
            m.Classname = class(obj);
        end
    end
    
    methods (Hidden = true)
        % Check if this MapReducer is valid to be used as the current MapReducer.
        function isValid = isValidForCurrentMapReducer(obj)
            isValid = strcmp(obj.ObjectVisibility, 'On');
        end
    end
    
    methods (Hidden = true, Static)
        % Create a MapReducer object from a memento struct. This can return
        % empty if it is not possible to create the mapreducer.
        function obj = createFromMemento(m)
            name = m.Classname;
            createFcn = [name, '.doCreateFromMemento'];
            obj = feval(createFcn, m);
        end
    end
    
    methods (Hidden = true, Abstract = true)
        outputds = execMapReduce(this, inputds, mapFcn, redFcn, settings);
    end
    
    methods (Access = protected)
        % Get the PartitionedArrayExecutor associated with this MapReducer
        % that will evaluate tall expressions.
        function executor = createPartitionedArrayExecutor(~) %#ok<STOUT>
            % The default behavior is to error. Implementations of
            % MapReducer must override this method to support tall.
            error(message('MATLAB:bigdata:executor:EnvironmentDoesNotSupportTall'));
        end
        
        % The default implementation of getMemento. This can be overridden
        % by subclasses.
        function m = doGetMemento(obj)
            propnames = properties(obj);
            for ii = 1:numel(propnames)
                m.(propnames{ii}) = obj.(propnames{ii});
            end
        end
    end
    
    methods (Access = protected, Static)
        % The default implementation of createFromMemento. This can be
        % overridden by subclasses.
        function obj = doCreateFromMemento(m)
            name = m.Classname;
            m = rmfield(m, 'Classname');
            obj = feval(name, m);
        end
    end
end
