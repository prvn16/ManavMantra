function varargout = separateOptimStruct(myStruct)
%

% SEPARATEOPTIMSTRUCT takes a problem structure and returns individual fields of
%   the structure to the caller. The caller (always a solver) information is 
%   found from the 'solver' field in 'myStruct'.

%   Copyright 2005-2013 The MathWorks, Inc.

% Determine the caller name; Make sure that the problem structure is valid
callStack = dbstack;
[~,caller] = fileparts(callStack(2).file);
requiredFields = {'solver','options'};
validValues = {fieldnames(createProblemStruct('solvers')), {} };
[validProblemStruct,errmsg,myStruct] = validOptimProblemStruct(myStruct,requiredFields,validValues);

if validProblemStruct
    solver = myStruct.solver;
else
    error('MATLAB:separateOptimStruct:InvalidStructInput',...
        getString(message('MATLAB:optimfun:separateOptimStruct:InvalidStructInput', errmsg)));
end
% Make sure that 'solver' is same as the caller
if ~strcmpi(caller,solver)
    error('MATLAB:separateOptimStruct:InvalidSolver',...
        getString(message('MATLAB:optimfun:separateOptimStruct:InvalidSolver', upper( solver ))));
end
options = myStruct.options; % Take out options field
myStruct = createProblemStruct(solver,[],myStruct); % Second argument is required but can be []
probFieldNames = fieldnames(myStruct);
% Extract values of all the fields
for i = 1:length(probFieldNames) - 1 % Last field is the 'solver' field
    varargout{i} = myStruct.(probFieldNames{i});
end
varargout{end+1} = options; % Stuff options as the last field
