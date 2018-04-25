%NET.NetException represents a .NET exception.
%  NET.NetException(MSGID, ERRMSG, EXCOBJ) captures information about a 
%  .NET error.  It is derived from matlab.exception.ExternalException and
%  contains no new properties or methods.
%
%  MSGID is the MException message identifier (a character string).
%  ERRMSG is the MException error message (a character string).
%  EXCOBJ is the .NET System.Exception object.
%
%  Default display of NetException contains the Message, Source and 
%  HelpLink fields of the System.Exception class that caused the 
%  exception.
%
%  Example:
%    try
%      NET.addAssembly('C:\Work\invalidfile.dll')
%    catch e
%      e.message
%      if(isa(e, 'NET.NetException'))
%        e.ExceptionObject
%      end
%    end

%   Copyright 2011 The MathWorks, Inc.
classdef NetException < matlab.exception.ExternalException
    methods
      function ct = NetException(id, msg, excObj)
          %call the base class constructor
          ct@matlab.exception.ExternalException(id, msg, excObj);
      end
    end
end