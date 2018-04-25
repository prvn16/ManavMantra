classdef(Hidden) ThrowingQualifiable < matlab.unittest.qualifications.Assertable & ...
                                       matlab.unittest.qualifications.Assumable & ...
                                       matlab.unittest.qualifications.FatalAssertable & ...
                                       matlab.unittest.internal.Loggable
    % This class is undocumented and may change in a future release.
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods
        function onFailure(throwingQualifiable, task)
            onFailure@matlab.unittest.qualifications.Assertable(throwingQualifiable, task);
            onFailure@matlab.unittest.qualifications.FatalAssertable(throwingQualifiable, task);            
            onFailure@matlab.unittest.qualifications.Assumable(throwingQualifiable, task);
        end
    end  
end

% LocalWords:  Loggable