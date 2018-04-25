classdef(Sealed) FatalAssertionFailedException < matlab.unittest.internal.qualifications.QualificationFailedException
    % FatalAssertionFailedException - MException used for fatal assertions failures.
    %
    %   This class is meant to be used exclusively by the fatal assert
    %   qualification type in matlab.unittest.
    %
    %   See also
    %      matlab.unittest.qualifications.FatalAssertable
    
    % Copyright 2010-2015 The MathWorks, Inc.
    
    methods (Access=?matlab.unittest.internal.qualifications.FatalAssertionDelegate)
        function exception = FatalAssertionFailedException(id, message, marker)
            exception = exception@matlab.unittest.internal.qualifications.QualificationFailedException(id, message, marker);
        end
    end
end
