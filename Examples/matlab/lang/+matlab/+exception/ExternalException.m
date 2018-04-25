%matlab.exception.ExternalException represents an exception thrown from another language
%  matlab.exception.ExternalException(MSGID, ERRMSG, EXCOBJ) captures 
%  information about the exception.  It is derived from MException.
%
%  MSGID is the MException message identifier (a character string).
%  ERRMSG is the MException error message (a character string).
%  EXCOBJ is the exception object in the other language.
%
%  In addition to the MException properties, ExternalException has 
%  the following property:
%
%    ExceptionObject: language-specific exception that caused the error.
%                     For example, if it's a Java exception, it will be a Java 
%                     java.lang.Throwable or a subclass.
%
%  Example:
%    try
%      java.lang.Class.forName('foo');
%    catch e
%      e.message
%      if(isa(e, 'matlab.exception.ExternalException'))
%        ex = e.ExceptionObject;
%        if (isjava(ex)) ex.printStackTrace;
%      end
%    end

%   Copyright 2011 The MathWorks, Inc.
classdef ExternalException < MException
    properties (SetAccess = private)
        ExceptionObject = [];
    end
    methods
      function ct = ExternalException(id, msg, excObj)
          %call the base class constructor
          ct@MException(id, '%s', msg);
          %set the exception object
          ct.ExceptionObject = excObj;
      end
    end
end