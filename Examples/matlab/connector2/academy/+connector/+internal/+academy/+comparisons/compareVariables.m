function comparisonObj = compareVariables(solVar,submissionVar,solVarName,submissionVarName)
% Compares the variable of interest from the student and solution
% workspaces.
%
% This function should not be used for checking equality of the variables.
% It is meant to help in generating correct feedback. Ideally, it should be
% called when the variables are NOT equal.
% 
% The result is a cell array of Comparison objects meant for a specific
% type of comparison. For example, if the output is of type
% 'existenceComparison', that means that one of the inputs does not exist.
%
% If the result is empty cell array, that means that either the variables are equal or
% we cound't find a suitable comparison object.
import connector.internal.academy.comparisons.*;

comparisonObj = {};
if nargin < 3 || isempty(solVar) || isempty(solVarName) || isempty(submissionVar)
    return;
end

% If the function called for script grading, there will be only three
% inputs since the variable name in the solution and submission workspace
% will be the same
if nargin == 3
    if strcmp(submissionVar,'_does_not_exist')
       submissionVarName = '_does_not_exist'; 
    else
       submissionVarName = solVarName;
    end
end

solutionVarInfo.name = solVarName;
solutionVarInfo.existence = ~isempty(solVar);
solutionVarInfo.type = class(solVar);
solutionVarInfo.size = size(solVar);
solutionVarInfo.value = solVar;

submissionVarInfo.name = submissionVarName;
submissionVarInfo.existence = ~isequaln(submissionVar,'_does_not_exist');
submissionVarInfo.type = class(submissionVar);
submissionVarInfo.size = size(submissionVar);
submissionVarInfo.value = submissionVar;

% Set Priority to different possible comparisons.
% 1 : true, 0 : false, -1 : don't care

% Any given comparison will match to one of the rows of the priority
% matrix. A match is defines as: non -1 elements match.

%   existance typeMatch isNum isCell isStruct isTable isChar sizeMatch isScalar isVector valueMatch    priority
P = {
    0         -1        -1    -1     -1       -1      -1     -1        -1       -1       -1            @ExistenceComparison;
    1          0        -1    -1     -1       -1      -1     -1        -1       -1       -1            @BasicTypeComparison;
    1          1        -1    -1     -1       -1      -1      0        -1       -1       -1            @BasicSizeComparison;
    1          1         0    -1     -1       -1      -1      1        -1       -1        0            @BasicValueComparison;
    1          1         1    -1     -1       -1      -1      1        -1       -1        0            @NumericComparison;
    1          1        -1    -1     -1       -1       1      1        -1       -1        0            @CharComparison;
    1          1         0     0      1        0       0      1        -1       -1        0            @StructComparison;
    1          1         0     0      0        1       0      1        -1       -1        0            @TableComparison;
    };

P = cell2table(P,'VariableNames',{'existance' 'typeMatch' 'isNum' 'isCell' 'isStruct' 'isTable' 'isChar',...
    'sizeMatch' 'isScalar' 'isVector' 'valueMatch' 'priority'});

% Using varInfo, create a row vector whose elements represent the columns
% of the above table

varState = [submissionVarInfo.existence,...
    strcmp(solutionVarInfo.type,submissionVarInfo.type),...
    isnumeric(submissionVarInfo.value),...
    iscell(submissionVarInfo.value),...
    isstruct(submissionVarInfo.value),...
    istable(submissionVarInfo.value),...
    ischar(submissionVarInfo.value),...
    isequaln(size(solutionVarInfo.value),size(submissionVarInfo.value)),...
    isscalar(submissionVarInfo.value),...
    isvector(submissionVarInfo.value),...
    isequaln(solutionVarInfo.value,submissionVarInfo.value)];

priorityMatrix = P{:,1:end-1};

% Compare only the non -1 elements
matchingRow = false(size(priorityMatrix,1),1);
for i=1:size(priorityMatrix,1)
    priorityColumns = priorityMatrix(i,:) ~= -1;
    matchingRow(i) = all(varState(priorityColumns) == priorityMatrix(i,priorityColumns));
end

% If none of the rows match, return
if ~any(matchingRow)
    return;
end

% Call the appropriate hint generating functions from the priority matrix
objectsToCreate = P.priority(matchingRow);
comparisonObj = cellfun(@(x)x(solVar,submissionVar,solVarName,submissionVarName),objectsToCreate,'UniformOutput',false); 

end