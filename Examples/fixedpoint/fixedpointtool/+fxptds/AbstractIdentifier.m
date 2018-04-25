classdef AbstractIdentifier < handle & matlab.mixin.Copyable
% ABSTRACTIDENTIFIER Class definition that provides a unique identifier for
% an entity in either MATLAB or Simulink.
    
% Copyright 2013-2016 The MathWorks, Inc.

    properties(SetAccess = protected, GetAccess = public)
        UniqueKey = '';
    end

    methods
        function b = eq(this, other)
        % Override the behavior of == operator for this class
            b = checkForEquality(this, other);
        end
        
        function b = isequal(this, other)
        % Override the isequal behavior for this class
            b = checkForEquality(this, other);
        end        
        
        function relativePath = getRelativePath(this)
            % get the relative path of the object
            relativePath = this.getDisplayName();
        end
        
        
    end
    
    methods(Access=private)
        function b = checkForEquality(this, other)
            b = false;
            if isscalar(this) && isscalar(other)
                b = strcmp(this.UniqueKey, other.UniqueKey);
            else
                if all(size(this) == size(other))
                    totalElements = numel(this);
                    thisReshaped = reshape(this, 1, totalElements);
                    otherReshaped = reshape(other, 1, totalElements);
                    b = true;
                    for elementIdx = 1:totalElements
                        if ~strcmp(thisReshaped(elementIdx).UniqueKey, otherReshaped(elementIdx).UniqueKey)
                            b = false;
                            break;
                        end
                    end
                end
            end
        end
    end
    
    methods (Access=protected, Abstract)
        % Calculate the unique key for an identifier. All children classes 
        % must implement this method and use it to set the UniqueKey
        % property in their constructor.
        key = calcUniqueKey(this);
    end
    
    methods (Abstract)
        % Get the string that will be displayed for a result that this
        % identifier is associatyed with. If the optional identifier object
        % is provided as an input argument, the display name should be
        % relative to that. For example, strings relative to a given subsystem
        name = getDisplayName(this, varargin);
        
        % Get the name of the element that this identifier corresponds to.
        elementName = getElementName(this);
        
        % Determine if the entity described by this identifier is within the
        % scope of the provided identifier. For example, block within a
        % subsystem
        b = isWithinProvidedScope(this, IdentifierObj);
        
        % Get the top most model that stores the FPT repository for this identifier. 
        b = getHighestLevelParent(this);
        
        % Determine if the entity represented by this identifier is still valid.
        b = isValid(this);
        
        % Hilite behavior for this identifier.
        hiliteInEditor(this);
        
        % Unhilite behavior for this identifier.
        unhilite(this);
    end
end

