function dualCommand = makeDualCommand(command, arg)
    if ~isempty(regexp(arg, '^\(|[ '',;\n-\r]', 'once')) || ~isempty(strfind(command,'.'))
        arg = mat2str(arg);
        dualCommand = sprintf('%s(%s)', command, arg);
    else
        dualCommand = [command ' ' arg];
    end

%   Copyright 2007 The MathWorks, Inc.
