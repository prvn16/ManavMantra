function tf = isWebAppServer
% isWebAppServer: Is the runtime executing in WebAppServer mode?
% This is an internal function calling an undocumented builtin. The interface
% to, or existence of this function could change at any time.
    tf = builtin('_is_web_app_server');
end
