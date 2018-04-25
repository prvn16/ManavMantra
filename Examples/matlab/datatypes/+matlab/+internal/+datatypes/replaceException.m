function ME = replaceException(ME,oldMsgID,newMsg,varargin)

%   Copyright 2017, The MathWorks, Inc.
if ~isa(newMsg,'message')
    % input is not a message, but should be a message ID, create a new
    % message with arguments.
    newMsg = message(newMsg,varargin{:});
end
% If the exception is one of the specified errors, return the desired one instead
matches = strcmp(ME.identifier,oldMsgID);
if any(matches(:))
   ME = MException(newMsg);
end

