classdef AcademyTrimmedException < MException
    
    properties(Access=private)
        shortStack
    end
    
    methods
        function trimmed = AcademyTrimmedException(other)
            trimmed = trimmed@MException(other.identifier, '%s', other.message);
            trimmed.type = other.type;
            trimmed.shortStack = trimmed.shortenStack(other.getStack);
            for idx = 1:numel(other.cause)
                trimmed = trimmed.addCause(other.cause{idx});
            end
        end
    end
    
    methods(Access=protected)
        function stack = getStack(trimmed)  
            stack = trimmed.shortStack;
        end
        
        function stack = shortenStack(~, fullStack)        
            files = {fullStack.file};
            j = 0;
            for i = 1:numel(files)
                isNotAcademyFrame = ~any(strfind(files{i}, 'AcademyScriptTestCaseProvider'));
                if isNotAcademyFrame
                    j = j+1;
                    stack(j) = fullStack(i); %#ok<AGROW>
                end
            end
        end      
    end         
    
end
