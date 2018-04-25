classdef CallbackErroredData < event.EventData
    % CALLBACKERROREVENTDATA Event data class for 'CallbackErrored' events

    % Copyright 2014 - 2016 The MathWorks, Inc.

   properties
      Exception
      AppFullFileName
   end

   methods
      function data = CallbackErroredData(exception, appFullFileName)
         data.Exception = exception;
         data.AppFullFileName = appFullFileName;
      end
   end
end
