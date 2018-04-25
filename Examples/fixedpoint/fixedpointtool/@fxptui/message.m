function [msg,id] = message(id, varargin)
%MESSAGE  Return the message given the id.

%   Copyright 2011 The MathWorks, Inc.

% Build up the ID.
id = ['FixedPointTool:fixedPointTool:' id];

% Get the Message catalog object.
mObj = message(id,varargin{:});

% Get the individual message.
msg  = mObj.getString();

% [EOF]
