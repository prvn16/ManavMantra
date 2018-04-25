classdef VerificationDelegate < matlab.unittest.internal.qualifications.QualificationDelegate
    % Copyright 2011-2012 The MathWorks, Inc.
    
    properties(Constant, Access=protected)
        Type = 'verify';
        IsTrueConstraint = matlab.unittest.internal.qualifications.QualificationDelegate.generateIsTrueConstraint('verify'); 
    end
    
    
    methods        
        function doFail(~, ~)
        end
    end
end




