classdef WeakReference < handle
    % This undocumented class may be removed in a future release.
    
    %WeakReference
    %
    %  WeakReference is a class that implements the ability to refer to
    %  another object without holding a reference that prevents it from
    %  being deleted.  The target obejct amy be any kind of graphics
    %  handle.
    %
    %  Example:
    %    
    %    % Create a parent-less line.  This object is only valid due to the
    %    % handle in the local workspace
    %    h = plot(1:10, 'Parent', []);
    %
    %    % Create a reference to the line
    %    ref = matlab.graphics.internal.WeakReference(h);
    %    
    %    % While the line is valid, ref.get() returns it
    %    ref.get()==h    
    %
    %    % If the line handle is cleared, the reference no longer returns it.
    %    clear h
    %    ref.get()
    
    %  Copyright 2015 The MathWorks, Inc.
    
    properties(Access=private)
        % Proxy object that implements the weak reference to the target 
        WeakProxy
    end
    
    methods
        function ref = WeakReference(varargin)
            %WeakReference Create a new WeakReference instance
            %
            %  WeakReference(target) creates a new reference to a target
            %  handle.  The reference may be used to refer to the target
            %  without maintaining a link which prevents the target being
            %  destroyed.
            %  
            %  The weak reference is not dseigned to persist when saved.
            %  If the WeakReference is saved and reloaded, it will always
            %  return an empty target.
            
            if nargin
                validateTarget(varargin{1});
            end
            ref.WeakProxy = matlab.graphics.internal.WeakProxy(varargin{:});
        end
        
        function delete(ref)
            %delete Delete the WeakReference
            
            % Explicitly delete the proxy
            delete(ref.WeakProxy);
        end
        
        function target = get(ref)
            %get Get the target handle
            %
            %  get(weakref) returns a handle to the target of the
            %  WeakReference if it still exists.  If the target has been
            %  deleted then an empty matrix will be returned.
            
            target = ref.WeakProxy.getHandle();
        end
        
        function oldtarget = reset(ref, newtarget)
            %reset Switch the WeakReference to a new target
            %
            %  reset(weakref, newtarget) switches the reference to refer to
            %  a new target.  The existing target, if it still exists, is
            %  returned.
            
            validateTarget(newtarget)
            oldtarget = ref.WeakProxy.reset(newtarget);
        end
    end
end

function validateTarget(target)
if ~isempty(target) &&  (~isscalar(target) || ~isa(target, 'matlab.graphics.Graphics'))
    error(message('MATLAB:graphics:internal:WeakReference:InvalidTargetType'));
end
end
