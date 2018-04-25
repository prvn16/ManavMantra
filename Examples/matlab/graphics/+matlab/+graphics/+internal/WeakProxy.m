classdef WeakProxy < handle
    % This undocumented class may be removed in a future release.
    
    %WeakProxy
    %
    %  WeakProxy is a class that implements a weak reference to a target.
    %  As long as the target is not destroyed, you can acquire a handle to
    %  it using the get method of this proxy.  
    %
    %  A side-effect of this proxy is that its own lifetime is tied to the
    %  target and so you must explicitly delete it when you no longer need
    %  it.  To avoid this issue, use the WeakReference wrapper class.
    %
    %  See also: WeakReference
    
    %  Copyright 2015 The MathWorks, Inc.
    
    properties(Access=private, Transient, NonCopyable)
        % Property which is used to temporarily store the target while it
        % is in the process of being acquired
        HandleReturn = [];
    end
    
    events(NotifyAccess=private)
        % Event which is sent when we need to get access to the target
        % handle
        RequestHandle
    end
     
    methods
        function ref = WeakProxy(target)
            %WeakProxy  Construct a new WeakProxy instance
            %
            %   WeakProxy(hTarget) creates a new WeakProxy instance wich
            %   provides access to hTarget.
            
            if nargin
                % Set up a weak reference link
                ref.createBackRef(target);
            end
        end
        
        function target = getHandle(ref)
            %getHandle Return a handle to the target
            %
            %  getHandle(weakref) returns a handle to the target of the
            %  WeakProxy if it still exists.  If the target has been
            %  deleted then an empty matrix will be returned.
                 
            % Make sure the return store is clear
            ref.HandleReturn = [];
            
            % Request that the back-reference listener set the handle
            notify(ref, 'RequestHandle');
            
            % Get the result of the listener execution (if any)
            target = ref.HandleReturn;
            
            % Make sure we don't keep hold of an extra copy of the handle
            % ourselves.
            ref.HandleReturn = [];
        end
        
        function oldtarget = reset(ref, newtarget)
            %reset Switch the WeakProxy to a new target
            %
            %  reset(weakref, newtarget) switches the weak proxy to refer
            %  to a new target.  The existing target, if it still exists,
            %  is returned.
            
            oldtarget = ref.deleteBackRef();
            ref.createBackRef(newtarget);
        end
        
        function delete(ref)
            %delete Delete the WeakProxy object
            % Remove the listener reference from the target
            ref.deleteBackRef();
        end
    end
    
    methods(Access=private)
        function createBackRef(ref, target)
            % Add a listener to the target that will let us request its
            % reference in future.
            
            if ~isempty(target)
                if ~isprop(target, 'WeakProxyListener')
                    % Add a property to store our listener on the target.  All
                    % wek references to this target will reuse the same
                    % listener
                    p = addprop(target, 'WeakProxyListener');
                    p.Transient = true;
                    p.NonCopyable = true;
                    p.Hidden = true;
                end
                
                L = target.WeakProxyListener;
                if isempty(L) || ~isvalid(L)
                    % Create a listener
                    L = event.listener(ref, 'RequestHandle', localCreateBackRefFunction(target));
                    target.WeakProxyListener = L;
                else
                    % Add this reference as a new source on the existing
                    % listener
                    L.Source = [L.Source; {ref}];
                end
            end
        end
        
        function target = deleteBackRef(ref)
            % Remove ourselves as a listener source if it exists    
            target = getHandle(ref);
            if ~isempty(target)
                % Remove the current reference as an event source
                L = target.WeakProxyListener;
                L.Source = L.Source([L.Source{:}]~=ref);
            end
        end
    end
end

function func = localCreateBackRefFunction(target)
func = @nReturnTarget;
    function nReturnTarget(src, ~)
        src.HandleReturn = target;
    end
end
