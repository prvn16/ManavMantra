classdef (Hidden) TabCompletion
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    methods (Static)
        function names = nameChoicesFromPartialMatch(test)
            import matlab.unittest.internal.TabCompletion;
            
            parentName = regexp(test, '^[^/\[]*', 'match', 'once');
            names = TabCompletion.nameChoices(parentName);
        end
        
        function names = nameChoices(test)
            suite = testsuite(test);
            names = {suite.Name};
        end
        
        function parameterNames = parameterNameChoices(test)
            suite = testsuite(test);
            parameters = [suite.Parameterization];
            parameterNames = unique({parameters.Name});
        end
        
        function parameterProperties = parameterPropertyChoices(test)
            suite = testsuite(test);
            parameters = [suite.Parameterization];
            parameterProperties = unique({parameters.Property});
        end
        
        function tags = tagChoices(test)
            suite = testsuite(test);
            tags = unique([suite.Tags]);
        end
        
        function procedureNames = procedureNameChoices(test)
            suite = testsuite(test);
            procedureNames =unique({suite.ProcedureName});
        end
        
        function verbosity = verbosityChoices
            verbosity = {'Terse', 'Concise', 'Detailed', 'Verbose'};
        end
        
        function superclassNames = superclassChoices(tests)
            suite = testsuite(tests);
            testClassesCell = unique(cellstr([suite.TestClass]));
            superclassNames = cellfun(@superclasses, testClassesCell, 'UniformOutput',false);
            superclassNames = unique(vertcat(superclassNames{:}));
        end
    end
end

% LocalWords:  unittest testsuite
