classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, ConstructOnLoad=true) NamedVariable < handle
    % NAMEDVARIABLE
    % An abstract class defining the methods for a Named Variable
    % A named variable is a variable with a name and workspace.
    
    % Copyright 2013 The MathWorks, Inc.

    % Name
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=false, Hidden=false)
        % Name Property
        Name;
    end %properties
    methods
        function storedValue = get.Name(this)
            storedValue = this.Name;
        end
        
        function set.Name(this, newValue)
            reallyDoCopy = ~isequal(this.Name, newValue);
            if reallyDoCopy
                this.Name = newValue;
            end
        end
    end

    % Workspace
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=false, Hidden=false)
        % Workspace Property
        Workspace;
    end %properties
    methods
        function storedValue = get.Workspace(this)
            storedValue = this.Workspace;
        end
        
        function set.Workspace(this, newValue)
            reallyDoCopy = ~isequal(this.Workspace, newValue);
            if reallyDoCopy
                this.Workspace = newValue;
            end
        end
    end

end %classdef
