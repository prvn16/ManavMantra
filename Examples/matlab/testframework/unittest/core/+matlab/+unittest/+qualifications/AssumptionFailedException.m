classdef AssumptionFailedException < matlab.unittest.internal.qualifications.QualificationFailedException
    % AssumptionFailedException - Exception used for assumption failures.
    %
    %   This class is meant to be used exclusively by the 'assume'
    %   qualification type in matlab.unittest.
    %
    %   See also
    %       matlab.unittest.qualifications.Assumable
    
    % Copyright 2010-2015 The MathWorks, Inc.
    
    methods (Access=?matlab.unittest.internal.qualifications.AssumptionDelegate)
        function exception = AssumptionFailedException(id, message, marker)
            exception = exception@matlab.unittest.internal.qualifications.QualificationFailedException(id, message, marker);
        end
    end
end
