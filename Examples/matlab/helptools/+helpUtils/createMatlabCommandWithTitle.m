function result = createMatlabCommandWithTitle(allowHotlinks, message, action, item)

    command = helpUtils.makeDualCommand(action, item);
    
    if allowHotlinks
        result = sprintf('    %s\n       <a href="matlab:%s">%s</a>\n\n', message, command, command);
    else
        result = sprintf('    %s\n       %s\n\n', message, command);
    end
end

%   Copyright 2015 The MathWorks, Inc.
