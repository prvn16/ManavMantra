function L = createListener(Src, Prop, eventName, callback)
% This undocumented function may be removed in a future release.

% createListener creates a listener and returns a reference to it.
% The listener's lifecycle is not tied to the lifecycle of the source
% object as is the case with addlistener.
%
% L = createListener(Src, event, callback)
% Creates a listener on each handle in Src where the listener
% will call callback when the event occurs.
%
% L = createListener(Src, Prop, event, callback)
% Create a listener on each property in Prop for each handle in Src.  Prop
% must be either a single string or cell array of strings, or an array of
% meta.property instances.

%   Copyright 2012-2013 The MathWorks, Inc.

    if isa(Src, 'double') && all(isgraphics(Src))
        Src = handle(Src);
    end
    if isa(Src, 'cell')
        error(message('MATLAB:class:RequireClass', 'object'));
    end
    
    if nargin == 3
        callback = eventName;
        eventName = Prop;
        
        if ~isa(eventName, 'char')
            error(message('MATLAB:class:RequireClass', 'char'));
        end

        oldEventNames = {
            'WindowButtonDown'
            'WindowButtonUp'
            'WindowButtonMotion'
            'Resize'
        };
        
        if any(strcmp(eventName, oldEventNames))
            error(message('MATLAB:class:invalidEvent', eventName, class(Src)));
        end
        
        if ~isa(callback, 'function_handle') 
            error(message('MATLAB:class:RequireClass', 'function_handle'));
        end
        
        if isa(Src, 'handle.handle') 
            L = handle.listener(Src, translateEventName(eventName), callback);
        else
            L = event.listener(Src, eventName, callback);
        end
    elseif nargin == 4
        if ~isa(eventName, 'char')
            error(message('MATLAB:class:RequireClass', 'char'));
        end
        
        if ~any(strcmp(eventName, {'PostSet';'PreSet';'PostGet';'PreGet'}))
            error(message('MATLAB:class:invalidEvent', eventName, 'meta.property'));
        end
        
        if ~isa(callback, 'function_handle') 
            error(message('MATLAB:class:RequireClass', 'function_handle'));
        end
        
        if iscell(Prop) && ~isempty(Prop)
            for k = 1:length(Prop)
                propObjects(k) = findprop(Src(1), Prop{k}); %#ok<AGROW>
            end
        elseif ischar(Prop)
            propObjects = findprop(Src(1), Prop);
        else
            propObjects = Prop;
        end
        
        if isa(Src, 'handle.handle')
            eventName = ['Property' eventName];
            L = handle.listener(Src, propObjects, eventName, callback);
        else
            L = event.proplistener(Src, propObjects, eventName, callback);
        end
    else
        error(message('MATLAB:minrhs'));
    end

end

function oldName = translateEventName(newName)
% Translate new event name into old event name for old-style objects.

    switch newName
        case 'WindowMousePress'
            oldName = 'WindowButtonDown';
        case 'WindowMouseRelease'
            oldName = 'WindowButtonUp';
        case 'WindowMouseMotion'
            oldName = 'WindowButtonMotion';
        case 'SizeChanged'
            oldName = 'Resize';
        otherwise
            oldName = newName;
    end
end
