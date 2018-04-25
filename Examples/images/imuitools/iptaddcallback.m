function id_out = iptaddcallback(h, callback, func_handle)
%IPTADDCALLBACK Add function handle to callback list.
%   ID = IPTADDCALLBACK(H, CALLBACK, FUNC_HANDLE) adds the function handle
%   FUNC_HANDLE to the list of functions to be called when the callback
%   specified by CALLBACK executes. CALLBACK is a string specifying the
%   name of a callback property of the Handle Graphics object specified by
%   the handle H.
%
%   IPTADDCALLBACK returns a unique callback identifier, ID, that can be
%   used with IPTREMOVECALLBACK to remove the function from the callback
%   list.
%
%   IPTADDCALLBACK can be useful when you need to notify more than one tool
%   about the same callback event for a single object.
%
%   Note
%   ----
%   Callback functions that have already been added to an object using the
%   SET command continue to work after calling IPTADDCALLBACK. The first
%   time you call IPTADDCALLBACK for a given object and callback, the
%   function checks to see if a different callback function is already
%   installed. If there is, IPTADDCALLBACK replaces that callback function
%   with the IPTADDCALLBACK callback processor, and then adds the
%   pre-existing callback function to the IPTADDCALLBACK list.
%
%   Example
%   -------
%       % Callbacks f1 and f2 are called for mouse motion over a
%       % figure. The functions are called in the order they
%       % are added to the list.
%       h = figure;
%       f1 = @(varargin) disp('Callback 1');
%       f2 = @(varargin) disp('Callback 2');
%       iptaddcallback(h, 'WindowButtonMotionFcn', f1);
%       iptaddcallback(h, 'WindowButtonMotionFcn', f2);
%
%   See also IPTREMOVECALLBACK.

%   Copyright 1993-2017 The MathWorks, Inc.

if (numel(h) ~= 1) || ~ishghandle(h)
    error(message('images:iptaddcallback:invalidHandle'));
end

callback = matlab.images.internal.stringToChar(callback);

validateattributes(callback, {'char'}, {'row'}, mfilename, ...
    'CALLBACK', 2);

% Note that the variable func_handle can also be a char or cell array. This is
% primarily for backwards compatibility with users who may have a preexisting
% callback specified in one of these old-style ways. Since we don't advocate
% these programming patterns anymore, the documentation above only refers to
% function handles. The main way a char or cell array callback would come into
% the callback processor is as a preexisting callback that a user set via the
% SET command prior to some subsequent call to IPTADDCALLBACK.
validateattributes(func_handle, {'function_handle','char','cell'},...
    {'vector'}, mfilename, 'FUNC_HANDLE', 3);

% disable any potentially active figure mode.  This avoids complications
% where figure modes such as zoom/pan/rotate3D interfere with IPT callback
% functions.  'WindowButtonMotionFcn' remains independent of the mode
% manager so we do not clear active modes for it.
if strcmpi(get(h,'type'),'figure') && ~strcmpi(callback,'WindowButtonMotionFcn')
    % disable the active mode
    activateuimode(h,'');
end

% State for callbackProcessor nested function.  There will be one of
% these callback lists for each H/CALLBACK combination.
callback_list = struct('func', {}, 'id', {});
next_available_id = 1;

% If the currently installed callback is not a function handle to
% callbackProcessor, then remember the currently installed callback,
% set the callback to @callbackProcessor, and then add the current
% callback to the callback list using a recursive call to iptaddcallback.
current_callback = get(h, callback);
if ~( isa(current_callback, 'function_handle') && ...
        strcmp(func2str(current_callback), 'iptaddcallback/callbackProcessor') )
    set(h, callback, @callbackProcessor);
    if ~isempty(current_callback)
        iptaddcallback(h, callback, current_callback);
    end
end

% Get the particular callbackProcessor function handle in use for this
% H/CALLBACK combination and use its 'add' syntax to add the new function
% handle to the callback list.
cpFun = get(h, callback);
id_out = cpFun('add', func_handle);

    function varargout = callbackProcessor(varargin)
        %   id = callbackProcessor('add', func_handle) adds the function
        %   handle to the callback list.
        %
        %   callbackProcessor('delete', id) deletes the callback with the
        %   associated identifier from the callback list.  id is the value
        %   returned by iptaddcallback.  If no matching callback is found,
        %   return silently.
        %
        %   list = callbackProcessor('list') returns the callback list.
        %   This syntax is provided as a debugging and testing aid.
        %
        %   With any other form of input arguments, callbackProcessor
        %   invokes each entry in the callback list in turn, passing the
        %   input arguments along to them.

        if ischar(varargin{1}) && strcmp(varargin{1}, 'add')
            % Syntax: callbackProcessor('add', func_handle)
            callback_list(end+1).func = varargin{2};
            id = next_available_id;
            next_available_id = next_available_id + 1;
            callback_list(end).id = id;
            varargout{1} = id;

        elseif ischar(varargin{1}) && strcmp(varargin{1}, 'delete')
            % Syntax: callbackProcessor('delete', func_handle)
            id = varargin{2};
            for k = 1:numel(callback_list)
                if callback_list(k).id == id
                    callback_list(k) = [];
                    % remove callback if list is now empty
                    if isempty(callback_list)
                        set(h,callback,'');
                    end
                    return;
                end
            end

        elseif ischar(varargin{1}) && strcmp(varargin{1}, 'list')
            % Syntax: list = callbackProcessor('list')
            varargout{1} = callback_list;

        else
            % All other syntaxes.
            
            % Create a local copy of the callback list to avoid issues that
            % arise when a callback actually modifies the list when it is
            % executed.
            local_callback_list = callback_list;
            for k = 1:numel(local_callback_list)
                fun = local_callback_list(k).func;
                if ischar(fun)
                    evalin('base',fun);
                elseif iscell(fun)
                    fun{1}(varargin{:},fun{2:end});
                else
                    fun(varargin{:});
                end
            end
        end

    end % callbackProcessor

end % iptaddcallback
