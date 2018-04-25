function executeResolve(obj, isCaseSensitive)
    try
        isValidExpression = mtree(obj.topicInput).mtfind('Kind', 'ERR').isempty;
        
        if nargin == 1
            obj.isCaseSensitive = true;
            obj.doResolve(obj.topicInput, isValidExpression);
            
            if ~obj.isResolved
                obj.isCaseSensitive = false;
                obj.doResolve(obj.topicInput, isValidExpression);
            end
            
            if ~obj.isResolved
                obj.underqualifiedResolve(obj.topicInput);
            end
            
            if ~obj.isResolved
                obj.resolveWithTypos;
            end
        else
            obj.isCaseSensitive = isCaseSensitive;
            obj.doResolve(obj.topicInput, isValidExpression);
        end
    catch
        obj.classInfo    = [];
        obj.nameLocation = '';
        obj.whichTopic   = '';
    end
end

%   Copyright 2013 The MathWorks, Inc