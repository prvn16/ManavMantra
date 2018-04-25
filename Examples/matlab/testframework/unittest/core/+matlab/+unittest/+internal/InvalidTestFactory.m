classdef InvalidTestFactory < matlab.unittest.internal.TestSuiteFactory
    % This class is undocumented.
    
    % InvalidTestFactory - Factory for creating suites for invalid test entities.
    
    %  Copyright 2014-2015 The MathWorks, Inc.
    
    properties(Constant)
        CreatesSuiteForValidTestContent = false;
    end
    
    properties (Access=private)
        ParentName
        Exception
    end
    
    methods
        function factory = InvalidTestFactory(parentName, exception)
            factory.ParentName = parentName;
            factory.Exception = exception;
        end
        
        function suite = createSuiteExplicitly(factory, ~) %#ok<STOUT>
            throwAsCaller(factory.Exception);
        end
        
        function suite = createSuiteImplicitly(factory, ~)
            import matlab.unittest.internal.diagnostics.indent;
            import matlab.unittest.internal.whichFile;
            
            try
                file = whichFile(factory.ParentName);
            catch
                file = factory.ParentName;
            end
            
            warning(message('MATLAB:unittest:TestSuite:FileExcluded', ...
                file, indent(factory.Exception.message)));
            
            suite = matlab.unittest.Test.empty;
        end
    end
end

