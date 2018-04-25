function assignSharedVariables(sharedVariables)
% Assign the variables in the sharedVariables struct into the calling
% workspace. 

%  Copyright 2015 The MathWorks, Inc.

names = fieldnames(sharedVariables);
for idx=1:numel(names)
    assignin('caller', names{idx}, sharedVariables.(names{idx}));
end
    
end