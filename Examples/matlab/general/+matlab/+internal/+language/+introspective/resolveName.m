function nameResolver = resolveName(topicInput, helpPath, justChecking, wsVariables, fixTypos)

    if nargin < 2
        helpPath = ''; 
    end

    if nargin < 3
       justChecking = true; 
    end

    if nargin < 4
       wsVariables = struct('name', {}); 
    end

    if nargin < 5
       fixTypos = false;
    end

    nameResolver = matlab.internal.language.introspective.NameResolver(topicInput, helpPath, justChecking, wsVariables, fixTypos);
    nameResolver.executeResolve();
end