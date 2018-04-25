%CustomReadException  Capture error information from errors executing custom Datastore ReadFcn
%
%   CustomReadException methods:
%      throw         - Issue exception and terminate function
%      rethrow       - Reissue existing exception and terminate function
%      throwAsCaller - Issue exception as if from calling function
%      addCause      - Record additional causes of exception
%      getReport     - Get error message for exception
%      last          - Return last uncaught exception
%
%   CustomReadException properties:
%      identifier  - Character string that uniquely identifies the error
%      message     - Formatted error message that is displayed
%      cause       - Cell array of MExceptions that caused the error
%      HiddenCause - Underlying wrapped cause, not displayed by getReport
%      stack       - Structure containing stack trace information
%
%   See also try, catch, MException, BigDataException

%   Copyright 2017 The MathWorks, Inc.
classdef CustomReadException < MException

    properties( SetAccess = private )
        HiddenCause;
    end
    
    methods( Hidden )
        
        % Construct new exception for custom read errors
        %
        % Creates a new exception and stores the original cause as a
        % property. The cause can be accessed but is not displayed in the
        % error report.
        function obj = CustomReadException( cause, varargin )
            obj = obj@MException(varargin{:});
            obj.HiddenCause = cause;
        end
        
    end
    
end