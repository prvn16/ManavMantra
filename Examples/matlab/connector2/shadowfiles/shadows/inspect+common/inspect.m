function varargout = inspect(varargin)
    % INSPECT Open the property inspector and inspect object properties
    %
    %   INSPECT (h) edits all properties of the given object whose handle
    %   is h, using a property-sheet-like interface.
    %
    %   INSPECT ([h1, h2]) edits both objects h1 and h2; any number of
    %   objects can be edited this way.  If you edit two or more objects of
    %   different types, the inspector might not be able to show any
    %   properties in common.
    %
    %   INSPECT (o, workspace) edits all properties of object, whose name
    %   is o, which exists in the workspace specified.
    %
    %   INSPECT with no argument launches a blank inspector window.
    %
    %   Note that "INSPECT h" edits the string 'h', not the object whose
    %   handle is h.
    
    %   Copyright 2015 The MathWorks, Inc.

    persistent origInspect;

    if ~internal.matlab.variableeditor.peer.PeerUtils.isPrototype || ...
            ~isequal(exist('internal.matlab.inspector.Inspector', 'class'), 8)
        % Invoke the regular inspector script
        
        if isempty(origInspect)
            % First, disable shadow warnings
            warningState = warning('off', 'MATLAB:dispatcher:nameConflict');
            originalDir = cd(fullfile(matlabroot, 'toolbox', 'matlab', 'uitools'));
            origInspect = @inspect;
            cd(originalDir);
            warning(warningState);
        end
        
        % Run the regular inspect command
        if nargout > 0
            varargout = {origInspect(varargin{:})};
        else
            origInspect(varargin{:});
        end
    else
        workspace = [];
        if nargin == 0
            % For no arguments, open an empty Property Inspector
            obj = internal.matlab.inspector.EmptyObject;
        elseif nargin == 1
            if ischar(varargin{1}) || isstring(varargin{1})
                peerInspector = ...
                    internal.matlab.inspector.peer.InspectorFactory.createInspector(...
                    'PropertyInspector', '/PropertyInspector');
                switch(varargin{1})
                    case '-close'
                        % Close the Property Inspector
                        peerInspector.closeAllVariables
                        return;
                        
                    case '-isopen'
                        % Check to see if the Property Inspector is open
                        varargout = {~isempty(peerInspector.Documents)};
                        return;
                        
                    otherwise
                        obj = [];
                end
            else
                % Argument should be an object or object array
                obj = varargin{1};
                if isempty(obj)
                    obj = internal.matlab.inspector.EmptyObject;
                elseif ~isa(obj, 'handle')
                    % assume caller workspace if it isn't specified
                    workspace = 'caller';
                    variableName = inputname(1);
                end
            end
        elseif nargin == 2
            % Look for object and workspace
            variableName = varargin{1};
            workspace = varargin{2};
            try
                obj = evalin(workspace, variableName);
            catch
                error(getString(message(...
                    'MATLAB:uitools:inspector:invalidarguments')));
            end
        else
            error(getString(message(...
                'MATLAB:uitools:inspector:invalidinputnotobject')));
        end
        
        % Must have a valid object to inspect
        if ~isobject(obj) || (isa(obj, 'handle') && any(~isvalid(obj)))
            if isjava(obj)
                % Java objects are not supported
                error(getString(message(...
                    'MATLAB:uitools:inspector:invalidobject')));
            else
                error(getString(message(...
                    'MATLAB:uitools:inspector:invalidinputnotobject')));
            end
        end
        
        if isempty(workspace)
            % Open the property inspector.  If obj is a value object, it is
            % assumed to be in the base workspace
            inspector = ...
                internal.matlab.inspector.peer.DefaultPropertyInspector.inspect(obj);
        else
            % Workspace is specified, so fully specify other arguments
            inspector = ...
                internal.matlab.inspector.peer.DefaultPropertyInspector.inspect(obj, ...
                internal.matlab.inspector.MultiplePropertyCombinationMode.getDefault, ...
                internal.matlab.inspector.MultipleValueCombinationMode.getDefault, ...
                workspace, variableName);
        end
        
        if nargout == 1
            % Return the inspector instance if an argument is expected
            varargout = {inspector};
        end
    end
end
