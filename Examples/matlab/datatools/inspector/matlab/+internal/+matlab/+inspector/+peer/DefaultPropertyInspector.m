classdef DefaultPropertyInspector < handle
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % The Default Matlab roperty inspector class.  This class can be
    % used to open the Property Inspector to inspect an object.
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties(Constant)
        % Default Property Inspector Application name
        Application = 'default';
        
        % Default Property Inspector Channel
        PeerModelChannel = '/PropertyInspector';
    end
    
    properties (SetAccess = protected, GetAccess = protected)
        % Internal handle to Default InspectorManager class
        InspectorManager_I;
    end
    
    properties (SetAccess = protected, Dependent=true)
        % Default InspectorManager class
        InspectorManager;
    end
    
    methods
        function storedValue = get.InspectorManager(this)
            % Get the InspectorManager.  Create it using the
            % InspectorFactory if necessary
            if isempty(this.InspectorManager_I) || ...
                    ~isvalid(this.InspectorManager_I)
                % Create the InspectorManager
                this.InspectorManager_I =...
                    internal.matlab.inspector.peer.InspectorFactory.createInspector(...
                    internal.matlab.inspector.peer.DefaultPropertyInspector.Application,...
                    internal.matlab.inspector.peer.DefaultPropertyInspector.PeerModelChannel);
            end
            storedValue = this.InspectorManager_I;
        end
        
        function set.InspectorManager(this, newValue)
            % Set the InspectorManager.
            reallyDoCopy = ~isequal(this.InspectorManager_I, newValue);
            if reallyDoCopy
                this.InspectorManager_I = newValue;
            end
        end
    end
    
    properties (Dependent=true, Hidden=false)
        % Documents property
        Documents;
    end
    
    methods
        function storedValue = get.Documents(this)
            % Get the InspectorManager Documents
            storedValue = this.InspectorManager.Documents;
        end
    end
    
    methods (Access = protected)
        function this = DefaultPropertyInspector()
            % Constructor, create the DefaultPropertyInspector
            this.InspectorManager_I =...
                internal.matlab.inspector.peer.InspectorFactory.createInspector(...
                internal.matlab.inspector.peer.DefaultPropertyInspector.Application,...
                internal.matlab.inspector.peer.DefaultPropertyInspector.PeerModelChannel);
        end
    end
    
    % Public Static Methods
    methods (Static)
        
        function obj = getInstance(varargin)
            % Get an instance of the DefaultPropertyInspector
            
            mlock; % Keep persistent variables until MATLAB exits
            persistent managerInstance;
            if isempty(managerInstance)
                % Create the DefaultPropertyInspector instance
                managerInstance = ...
                    internal.matlab.inspector.peer.DefaultPropertyInspector();
            end
            obj = managerInstance;
        end
        
        function startup()
            % Makes sure the peer manager for the variable editor exists
            [~] = internal.matlab.inspector.peer.DefaultPropertyInspector.getInstance;
        end
        
        function varargout = inspect(varargin)            
            % Inspect passthrough to manager inspect
            manager = internal.matlab.inspector.peer.DefaultPropertyInspector.getInstance().InspectorManager;
            if (nargout > 0)
                % Call inspect on the manager, and set the varargout
                output = manager.inspect(varargin{:});
                varargout{1} = output;
            else
                % Call inspect on the manager
                manager.inspect(varargin{:});
            end
        end
    end
end
