%matlab.exception.JavaException represents a Java exception.
%  matlab.exception.JavaException(MSGID, ERRMSG, EXCOBJ) captures 
%  information about an exception thrown from Java called from MATLAB.  
%
%  MSGID is the MException message identifier (a character string).
%  ERRMSG is the MException error message (a character string).
%  EXCOBJ is the java.lang.Throwable object.
%
%  JavaException is derived from MException and has the same methods and
%  properties plus the additional property:
%
%    ExceptionObject: Java exception object that caused the error.
%
%  Example:
%    try
%      java.lang.Class.forName('foo');
%    catch e
%      e.message
%      if(isa(e, 'matlab.exception.JavaException'))
%        ex = e.ExceptionObject;
%        assert(isJava(ex));
%        ex.printStackTrace;
%      end
%    end

%   Copyright 2011-2013 The MathWorks, Inc.
classdef JavaException < matlab.exception.ExternalException
    methods
      function ct = JavaException(id, msg, excObj)
          % See if excObj implements MatlabIdentified
          if (isa(excObj, 'com.mathworks.util.MatlabIdentified'))
              % A MatlabIdentified exception replaces the id and msg with
              % that obtained from the exception object
              id = char(excObj.getMessageID);
              msg = char(excObj.getLocalizedMessage);
          end
          % call the base class constructor
          ct@matlab.exception.ExternalException(id, msg, excObj);
      end
      function report = getReport(obj, type, key, val)
          % On each call to getReport, recomputes the message
          % in the same way that we or native code obtains it the first time.
          % This is because the message needs to be translated at the point of 
          % display, in the current locale.  
          if (isa(obj.ExceptionObject, 'com.mathworks.util.MatlabIdentified'))
              % if it has a custom ID, message is the plain localized message
              obj.message = char(obj.ExceptionObject.getLocalizedMessage);
          else
              % OpaqueJavaInterface returns message plus stack trace,
              % invoking getLocalizedMessage in the ExceptionObject.
              import com.mathworks.jmi.OpaqueJavaInterface;
              obj.message = char(OpaqueJavaInterface.getExceptionMessage(obj.ExceptionObject));
          end
          switch nargin
              case 1
                  report = getReport@matlab.exception.ExternalException(obj);
              case 2
                  report = getReport@matlab.exception.ExternalException(obj, type);
              otherwise
                  report = getReport@matlab.exception.ExternalException(obj, type, key, val);
          end
      end
    end
    methods (Static)
      function rval = loadobj(obj)
          % Deserialization needs to re-localize the message in the current
          % locale if we did that originally.
          if (isa(obj.ExceptionObject, 'com.mathworks.util.MatlabIdentified'))
              obj.message = char(obj.ExceptionObject.getLocalizedMessage);
          end
          rval = obj;
      end
    end
end
