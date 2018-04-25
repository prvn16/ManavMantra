function me = msg2exception(id,varargin)
%MSG2EXCEPTION Create an MException from a message ID.

%   Copyright 2013 The MathWorks, Inc.

msg = message(id,varargin{:});
me = MException(id,getString(msg));
