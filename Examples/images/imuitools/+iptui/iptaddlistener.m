function result_listener = iptaddlistener(varargin)
% This undocumented function may be removed in a future release.

% iptaddlistener creates a listener and returns the reference to it.
%
%  lh = iptui.iptaddlistener(hObj,'EventName',callbackFun);
%  lh = iptui.iptaddlistener(Hobj,'Property','[Post|Pre]Set',@callbackFun)

%   Copyright 2008-2010 The MathWorks, Inc.


src = varargin{1};
if all(ishandle(src)) && all(isobject(src))
    
    %  MCOS listener syntaxes
    %  ============================
    %  lh = event.listener(Hobj,'EventName',@CallbackFunction)
    %  lh = event.proplistener(Hobj,Properties,'PropEvent',@CallbackFunction)
    
    if nargin == 3
        result_listener = event.listener(varargin{:});
    elseif nargin == 4
        prop = src(1).findprop(varargin{2});
        result_listener = event.proplistener(src, prop, varargin{3:end});
    else
        error(message('images:iptaddlistener:invalidSyntax'));
    end
    
elseif all(ishandle(src)) && all(~isobject(src))
    
    %  UDD listener syntaxes
    %  ========================
    %  src = handle(source_obj);
    %  lh = handle.listener(src,'ObjectBeingDestroyed',@callback_fcn);
    %  lh = handle.listener(src, src.findprop('propname'),...
    %     'PropertyPostSet', @callback_fcn);
    
    src = handle(src);
    if nargin == 3
        evt = xlateToUDDEventName(varargin{2});
        fun = varargin{3};
        result_listener = handle.listener(src,evt,fun);
    elseif nargin == 4
        property = src(1).findprop(varargin{2});
        evt_time = sprintf('Property%s',varargin{3});
        fun = varargin{4};
        result_listener = handle.listener(src,property,evt_time,fun);
    else
        error(message('images:iptaddlistener:invalidSyntax'));
    end
    
else
    error(message('images:iptaddlistener:invalidObject'));
    
end % iptaddlistener


function udd_name = xlateToUDDEventName(mcos_name)

switch mcos_name
    case 'WindowMousePress'
        udd_name = 'WindowButtonDown';
    case 'WindowMouseRelease'
        udd_name = 'WindowButtonUp';
    case 'WindowMouseMotion'
        udd_name = 'WindowButtonMotion';
    case 'SizeChanged'
        udd_name = 'Resize';
    otherwise
        udd_name = mcos_name;
end

