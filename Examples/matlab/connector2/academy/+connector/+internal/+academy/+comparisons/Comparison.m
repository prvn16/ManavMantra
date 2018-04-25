classdef (Abstract) Comparison
    properties (SetAccess=protected)
        solutionVar        
        submissionVar
        solVarName
        submissionVarName
    end
    
    methods        
        feedback = generateFeedback(cObj);
    end
end