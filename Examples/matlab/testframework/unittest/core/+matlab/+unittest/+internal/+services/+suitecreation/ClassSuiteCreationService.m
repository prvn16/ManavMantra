classdef ClassSuiteCreationService < matlab.unittest.internal.services.suitecreation.SuiteCreationService
    % This class is undocumented and will change in a future release.
    
    % ClassSuiteCreationService - Suite creation service for class-based tests.
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    methods (Access=protected)
        function selectFactory(~, liaison)
            import matlab.unittest.internal.ClassTestFactory;
            import matlab.unittest.internal.InvalidTestFactory;
            import matlab.unittest.internal.NonTestFactory;
            
            try
                testClass = meta.class.fromName(liaison.ParentName);
            catch me
                liaison.Factory = InvalidTestFactory(liaison.ParentName, me);
                return;
            end
            
            if ~isempty(testClass) && (testClass <= ?matlab.unittest.TestCase)
                if testClass.Abstract
                    exception = MException(message('MATLAB:unittest:TestSuite:AbstractTestCase', liaison.ParentName));
                    liaison.Factory = NonTestFactory(exception);
                    return;
                end
                
                liaison.Factory = ClassTestFactory(testClass);
            end
        end
    end
end



% LocalWords:  suitecreation
