classdef Grader < handle
    
    properties  (Access=private)
        isCorrect           %Was the user correct or not
    end
    
    properties
        testFolder = fullfile(tempdir,'.training','.tests');
    end
    
    properties (Constant)
        MAX_JSON_RESULTS_SIZE = 24900
    end
    
    methods
        
        function obj = Grader        
            obj.isCorrect = false;
        end
                        
        function setCorrectness(obj,isCorrect)
            obj.isCorrect = isCorrect;
        end
        
        function isCorrect = getCorrectness(obj)
            isCorrect = obj.isCorrect;
        end
        
        function emptyTestFolder(obj)
            delete(fullfile(obj.testFolder,'*.*'))
        end
        
    end
    
end

