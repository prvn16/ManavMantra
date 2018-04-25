classdef AssertionDelegate < matlab.unittest.internal.qualifications.QualificationDelegate
  
    % Copyright 2011-2015 The MathWorks, Inc.
    
    properties(Constant, Access=protected)
        Type = 'assert';
        IsTrueConstraint = matlab.unittest.internal.qualifications.QualificationDelegate.generateIsTrueConstraint('assert'); 
    end
    
    methods
        function doFail(~, qualificationFailedExceptionMarker)
            import matlab.unittest.qualifications.AssertionFailedException;
            
            msg = message('MATLAB:unittest:Assertable:AssertionFailed');
            ex = AssertionFailedException(msg.Identifier, msg.getString, qualificationFailedExceptionMarker);
            throw(ex);
        end
    end
end
