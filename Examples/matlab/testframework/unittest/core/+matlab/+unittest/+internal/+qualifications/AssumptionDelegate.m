classdef AssumptionDelegate < matlab.unittest.internal.qualifications.QualificationDelegate
    
    % Copyright 2011-2015 The MathWorks, Inc.
        
    properties(Constant, Access=protected)
        Type = 'assume';
        IsTrueConstraint = matlab.unittest.internal.qualifications.QualificationDelegate.generateIsTrueConstraint('assume'); 
    end
    
    methods        
        function doFail(~, qualificationFailedExceptionMarker)
            import matlab.unittest.qualifications.AssumptionFailedException;
            
            msg = message('MATLAB:unittest:Assumable:AssumptionFailed');
            ex = AssumptionFailedException(msg.Identifier, msg.getString, qualificationFailedExceptionMarker);
            throw(ex);
        end
    end
end

