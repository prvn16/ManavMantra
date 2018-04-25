function choiceNum = getChoice(choice,choices,choiceNums)

%   Copyright 2014-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.stringToLegacyText

choice = stringToLegacyText(choice);

try

choiceNum = choiceNums(strncmpi(choice,choices,max(length(choice),1)));
if isscalar(choiceNum)
    % OK
elseif isempty(choiceNum)
    if isCharString(choice)
        error(message('MATLAB:datetime:UnrecognizedInput',choice));
    else
        error(message('MATLAB:datetime:InvalidInput'));
    end
else
    if all(choiceNum == choiceNum(1))
        choiceNum = choiceNum(1);
    else
        error(message('MATLAB:datetime:AmbiguousInput',choice));
    end
end

catch ME
    throwAsCaller(ME);
end
