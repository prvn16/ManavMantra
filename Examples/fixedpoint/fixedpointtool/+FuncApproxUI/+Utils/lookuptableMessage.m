function [msg, id] = lookuptableMessage(id, varargin)
    % LOOKUPTABLEMESSAGE retrieves the message string from the lookuptable
    % resource catalog for a specified id
    
    % Copyright 2017 The MathWorks, Inc.
    
    % Build up the ID.
    id = ['FixedPointTool:lookUpTable:' id];
    % Get the Message catalog object.
    mObj = message(id,varargin{:});
    % Get the individual message.
    msg  = mObj.getString();
end

