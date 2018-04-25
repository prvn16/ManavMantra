function iptremovecallback(h, callback, id)
%IPTREMOVECALLBACK Delete function handle from callback list.
%   IPTREMOVECALLBACK(H, CALLBACK, ID) deletes a callback from the list of
%   callback functions created by IPTADDCALLBACK for the object with
%   handle H and the associated callback string CALLBACK. ID is the
%   identifier for the callback to be deleted; it is the value returned
%   by IPTADDCALLBACK.
%
%   Example
%   -------
%
%       h = figure;
%       f1 = @(varargin) disp('Callback 1');
%       f2 = @(varargin) disp('Callback 2');
%       f3 = @(varargin) disp('Callback 3');
%       id1 = iptaddcallback(h, 'WindowButtonMotionFcn', f1);
%       id2 = iptaddcallback(h, 'WindowButtonMotionFcn', f2);
%       id3 = iptaddcallback(h, 'WindowButtonMotionFcn', f3);
%
%       iptremovecallback(h, 'WindowButtonMotionFcn', id2);
%
%       Now, whenever MATLAB detects mouse motion over the figure,
%       function handles f1 and f3 are called in that order.
%
%   See also IPTADDCALLBACK.

%   Copyright 1993-2017 The MathWorks, Inc.

callback = matlab.images.internal.stringToChar(callback);

if ishghandle(h)
    cbFun = get(h, callback);
    if isa(cbFun, 'function_handle') && ...
            strcmp(func2str(cbFun), 'iptaddcallback/callbackProcessor')
        cbFun('delete', id);
    end
end

