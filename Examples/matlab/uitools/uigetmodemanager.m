function mmgr = uigetmodemanager(varargin)
% This function is undocumented and will change in a future release

% Returns the mode manager associated with the current figure

%   Copyright 2005-2014 The MathWorks, Inc.

if nargin == 0
    hFig = gcf;
elseif nargin == 1
    hFig = varargin{1};
else
    error(message('MATLAB:uigetmodemanager:TooManyArguments'));
end

if ~ishghandle(hFig,'figure')
    error(message('MATLAB:uigetmodemanager:InvalidFirstArgument'));
end

[ lmsg, lid ] = lastwarn;
ws = warning('query','MATLAB:hg:DoubleToHandleConversion');
warning('off','MATLAB:hg:DoubleToHandleConversion')

hFig = handle(hFig);

warning(ws.state,ws.identifier)
lastwarn( lmsg, lid );

if ~isempty(hFig.findprop('ModeManager'))
   mmgr = hFig.ModeManager;
else
   mmgr = [];
end

% Call the appropriate uimodemanager constructor
if isempty(mmgr) || ((~isobject(mmgr) || ~isvalid(mmgr)) && ~ishandle(mmgr))
    mmgr = matlab.uitools.internal.uimodemanager(hFig);
end
