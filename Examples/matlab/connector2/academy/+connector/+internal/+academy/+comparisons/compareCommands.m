function response = compareCommands(submissionString,correctAnswerString)
%Returns a string which provides a hint towards how the submission string
%(which is assumed to be a MATLAB command) could be modified to be closer
%to the correct answer string (also assumed to be a MATLAB command).
%
%function response = gradeAnswer(submissionString,correctAnswerString)
%    submissionString - MATLAB command to be graded
%    correctAnswerString - MATLAB command which is the solution

%The general process for determining this string is as follows:
% 1. Create mtree representation of both submission command and correct
%    answer command.
% 2. Compare trees together to determine differences between them.  The
%    comparison is performed both ways (both comparing A to B, and B to A)
% 3. Determine which node in the two trees should be used as the basis for
%    the response. Generally, this is based on what differences exist between
%    the trees, which node type (CALL, INT, LB, etc) the nodes are, and the
%    depth of the nodes.
% 3a. (TODO) Determine if the node selected is worth providing a human-readable
%    response to. Certain situations are not handled well by the algorithm,
%    especially when the answers are extremely far apart.
% 4. Create a human-readable string stating the differences in the node
%    that was chosen in step #3.

%A quick example
%
%Consider these inputs...
%  submission:  x = 5 + 4
%  correctAns:  x = sin(5)
%
%Step 1 produces mtree representations...
% >> dumptree(mtree('x = 5+4'))            >> dumptree(mtree('x = sin(5)'))
%   1  *<root>:  PRINT:   1/03               1  *<root>:  PRINT:   1/03 
%   2     *Arg:  EQUALS:   1/03              2     *Arg:  EQUALS:   1/03 
%   3        *Left:  ID:   1/01  (x)         3        *Left:  ID:   1/01  (x)
%   4        *Right:  PLUS:   1/06           4        *Right:  CALL:   1/08 
%   5           *Left:  INT:   1/05  (5)     5           *Left:  ID:   1/05  (sin)
%   6           *Right:  INT:   1/07  (4)    6           *Right:  INT:   1/09  (5)
%
%Step 2 would find unmatched nodes in both trees (indicated by x's)
% >> dumptree(mtree('x = 5+4'))            >> dumptree(mtree('x = sin(5)'))
%   -  *<root>:  PRINT:   1/03               -  *<root>:  PRINT:   1/03 
%   -     *Arg:  EQUALS:   1/03              -     *Arg:  EQUALS:   1/03 
%   -        *Left:  ID:   1/01  (x)         -        *Left:  ID:   1/01  (x)
%   x        *Right:  PLUS:   1/06           x        *Right:  CALL:   1/08 
%   -           *Left:  INT:   1/05  (5)     x           *Left:  ID:   1/05  (sin)
%   x           *Right:  INT:   1/07  (4)    -           *Right:  INT:   1/09  (5)
%
%Step 3 would determine which node is the most important difference to
%describe to the user. In this case, we have an unmatched, fairly high
%priority node in the correct answer string (the call to sin), so that is
%chosen
% >> dumptree(mtree('x = 5+4'))            >> dumptree(mtree('x = sin(5)'))
%   -  *<root>:  PRINT:   1/03               -  *<root>:  PRINT:   1/03 
%   -     *Arg:  EQUALS:   1/03              -     *Arg:  EQUALS:   1/03 
%   -        *Left:  ID:   1/01  (x)         -        *Left:  ID:   1/01  (x)
%   -        *Right:  PLUS:   1/06           -        *Right:  CALL:   1/08 
%   -           *Left:  INT:   1/05  (5)     x           *Left:  ID:   1/05  (sin)
%   -           *Right:  INT:   1/07  (4)    -           *Right:  INT:   1/09  (5)
%
%Step 4 would then put into human-readable words the difference selected
% "Try using the sin function"
%
%Hopefully then the user would actually use the sin function, and upon 
%the next sumbission they might either get the answer correct or move on to
%being notified about a lower priority difference.

import connector.internal.academy.i18n.FeedbackTemplates;

% Default inputs
debugMode = false;
if nargin < 1
    submissionString = 'result = Germany - mean(4.38)';
end
if nargin < 2
    correctAnswerString = 'result = Germany - mean(Germany)';
end

%Print separator
if debugMode
    fprintf('\n\n-----------\n');
end

%% Preprocess correctAnswer to normalize intermediate variables in anonymous functions
submissionString = normalizeAnonymousFunctionInputs(submissionString);
correctAnswerString = normalizeAnonymousFunctionInputs(correctAnswerString);

%% Step 1: Parse submission and answer into mtree objects
submission = mtree(submissionString);
correctAnswer = mtree(correctAnswerString);
if debugMode
    fprintf('Submission:  %s\n',submissionString);
    fprintf('Correct   :  %s\n',correctAnswerString);
end

%% Step 2: Compare trees both ways
%  1. Finding differences in the submission tree
%  2. Finding differences in the correctAnswer tree
%An unmatched node in the correctAnswerDifferences structure means that
%there is something in the correctAnswer tree that does not exist in the
%submission tree.
submissionComparisons = compareTrees(submission,correctAnswer);
correctAnswerComparisons = compareTrees(correctAnswer,submission);

%% Step 2a: Obtain node purposes
%For each comparison, see if we can extract some purpose about the original
%intent of the node
submissionComparisons = addNodePurposes(submission,submissionComparisons);
correctAnswerComparisons = addNodePurposes(correctAnswer,correctAnswerComparisons);
if debugMode
    for i = 1:numel(submissionComparisons)
        fprintf('Submission difference:');
        disp(submissionComparisons(i));
    end
    for i = 1:numel(correctAnswerComparisons)
        fprintf('Correct answer difference:');
        disp(correctAnswerComparisons(i));
    end
end

%% Step 3: Determine node to report on
%Now we start the task of determining which node we should use to create
%the report of how to improve the submission. The node types are given
%priorities as shown below.  Node kinds in the first group will be
%prioritized over node types in the last group.  Within a group, other
%characteristics (depth, types of differences) will determine which actual
%node gets chosen
nodeKindPriorities = {
    {'ANON','CALL','SUBSCR','CELL','DCALL','LB','LC','DOT',...
    'DOTLP','COLON','ANONID','MINUS','MUL','DIV',...
    'LDIV','EXP','DOTMUL','DOTDIV','DOTLDIV','DOTEXP','ANDAND',...
    'OROR','LT','GT','LE','GE','PLUS','AND','OR','EQ','NE'},...
    
    {'DOTTRANS','TRANS'},...
    
    {'EQUALS','BREAK','CONTINUE','RETURN'},...
    
    {'NOT','UMINUS','UPLUS','AT',...
    'PARENS','ID','INT','DOUBLE','STRING','BANG','EXPR','PRINT'}...
    };

%Go through each node group and see if you can find the appropriate
%response for some node within that group.
highestPriorityNodeComparison = [];
for i = 1:numel(nodeKindPriorities)
    highestPriorityNodeComparison = prioritizeNodeDifferences(correctAnswerComparisons,submissionComparisons,nodeKindPriorities{i});
    if ~isempty(highestPriorityNodeComparison)
        break;
    end
end


%% Step 4: Create the response string
response = '';
if ~isempty(highestPriorityNodeComparison)
    if highestPriorityNodeComparison.isSubmission
        response = createOutputString(submission,highestPriorityNodeComparison.comparison,true);
    else
        response = createOutputString(correctAnswer,highestPriorityNodeComparison.comparison,false);
    end
end


%% Special case - User entered something like 'mean[p]'
%Currently this isn't caught automatically as a syntax error, but instead gets reported by mtree as
%  1  *<root>:  DCALL:   1/01 
%  2     *Left:  ID:   1/01  (mean)
%  3     *Right:  LB:   1/05 
%  4        *Arg:  ROW:   1/06 
%  5           *Arg:  ID:   1/06  (p)
%So, we just look for patterns in the submission where there is a DCALL
%node whose Right child is a LB, and then we tell them to use proper
%indexing syntax (normally, DCALL's should have STRING nodes as their Right
%child).
%
%Note that sometimes, such as 'x = mean[p]', mtree does catch this as 
%invalid syntax (though the error message could be improved)

%Note - We must be careful not to assume that parentheses is the answer,
%since this can actually causes confusion. For instance, if the user 
%enters "x[8,2,-4]" instead of "x=[8,2,-4]", the autohint recommends 
%parentheses, which is clearly not right. I'm going to let this default to 
%a syntax error for now, which will then cause the default hint to be
%provided.
dcallNodes = mtfind(submission,'Kind','DCALL');
badDcallNodes = mtfind(dcallNodes,'Right.Kind','LB');
if (badDcallNodes.count > 0)
    badDcallNode = badDcallNodes.select(find(badDcallNodes.getIX));
    indexValue = tree2str(badDcallNode.Right);
    indexValue = indexValue(2:end-1);
    indexTarget = badDcallNode.Left.string;
    response = FeedbackTemplates.language.templates.syntaxError;
end


%% Special case - Large (relatively) string is missing in one of the trees
%If this is the case, but the string exists within the other tree, then
%give a generic response about using single quotes correctly
for i = 1:numel(correctAnswerComparisons)
    if strcmp(correctAnswerComparisons(i).kind,'STRING')
        if ~isempty(correctAnswerComparisons(i).deviations)
            devs = correctAnswerComparisons(i).deviations;
            if strcmp(devs{1}.problem,'NotFound')
                stringNode = correctAnswer.select(correctAnswerComparisons(i).nodeIdx);
                theString = stringNode.string;
                theString = theString(2:end-1);
                if ~isempty(strfind(submissionString,theString))
                    if numel(theString) > 4
                        response = FeedbackTemplates.constructFeedback('missingSingleQuotes',theString);
                    end
                end
            end
        end
    end
end

%% Special case - Submission syntax is invalid
%If the user's submission is syntactically incorrect, we tell them that. If
%their submission would be correct if they swapped [] for (), then we'll
%prod them a bit to see if they are indexing improperly.
if ~isnull(mtfind(submission,'Kind','ERR'))
    
    potentialFix = strrep(submissionString,'[','(');
    potentialFix = strrep(potentialFix,']',')');
    fixTree = mtree(potentialFix);
    
    if isnull(mtfind(fixTree,'Kind','ERR'))
        response = [FeedbackTemplates.language.templates.syntaxError FeedbackTemplates.language.templates.squareBracketForArrayAccess];
    else
        response = FeedbackTemplates.language.templates.syntaxError;
    end
end

%% Tie up loose ends
%If we've made it this far and we still haven't come up with something
%important to say to improve the submission, then the submission is
%probably correct.
if isempty(response)
    response = FeedbackTemplates.language.templates.correct;
end

if debugMode
    fprintf('Response:  %s\n',response);
    fprintf('-----------\n\n');
end


end

%% Find highest priority difference node
% Returns empty if no differences exist for the subset of node kinds
% searched
function highestPriorityDifference = prioritizeNodeDifferences(correctAnswerComparisons,submissionComparisons,nodeKinds)

import connector.internal.academy.i18n.FeedbackTemplates;

%Find shallowest unmatched node
%This would be something like
%
%  Correct answer: >> 4*sin(x+2)
%  Submission:     >> 4*x
%
% In this case, there is a CALL to sin and a PLUS that is missing from the
% solution. We want to report the sin node first, so we find the shallowest
% missing node.
highestDepth = 100;
shallowestUnmatchedNode = [];
for i = 1:numel(correctAnswerComparisons)
    if ~isempty(correctAnswerComparisons(i).deviations)
        devs = correctAnswerComparisons(i).deviations;
        if (correctAnswerComparisons(i).depth < highestDepth)
            for j = 1:numel(devs)
                if strcmp(devs{j}.problem,'NotFound')
                    cmp = strcmp(correctAnswerComparisons(i).kind,nodeKinds);
                    if any(cmp)
                        highestDepth = correctAnswerComparisons(i).depth;
                        shallowestUnmatchedNode.comparison = correctAnswerComparisons(i);
                        shallowestUnmatchedNode.isSubmission = false;
                    end
                end
            end
        end
    end
end

%Find deepest node that has a match with some differences
lowestDepth = -1;
deepestMatchedDifferenceNode = [];
for i = 1:numel(correctAnswerComparisons)
    if ~isempty(correctAnswerComparisons(i).deviations)
        devs = correctAnswerComparisons(i).deviations;
        if (correctAnswerComparisons(i).depth > lowestDepth)
            for j = 1:numel(devs)
                if isempty(strfind(devs{j}.problem,'NotFound'))
                    cmp = strcmp(correctAnswerComparisons(i).kind,nodeKinds);
                    if any(cmp)
                        lowestDepth = correctAnswerComparisons(i).depth;
                        deepestMatchedDifferenceNode.comparison = correctAnswerComparisons(i);
                        deepestMatchedDifferenceNode.isSubmission = false;
                    end
                end
            end
        end
    end
end

%Find shallowest unmatched node in submission tree
highestDepth = 100;
shallowestUnmatchedNodeInSubmission = [];
for i = 1:numel(submissionComparisons)
    if ~isempty(submissionComparisons(i).deviations)
        devs = submissionComparisons(i).deviations;
        if (submissionComparisons(i).depth < highestDepth)
            for j = 1:numel(devs)
                if ~isempty(strfind(devs{j}.problem,'NotFound'))
                    cmp = strcmp(submissionComparisons(i).kind,nodeKinds);
                    if any(cmp)
                        highestDepth = submissionComparisons(i).depth;
                        shallowestUnmatchedNodeInSubmission.comparison = submissionComparisons(i);
                        shallowestUnmatchedNodeInSubmission.isSubmission = true;
                    end
                end
            end
        end
    end
end

%Choose one of the three high-priority differences we've found so far -
%either the deepest matched difference, the shallowest unmatched node in
%the correct answer, or the shallowest unmatched node in the submission.
%The choice we are currently making is just a heuristic which seems to work
%reasonably well, except for some edge cases which are handled at another
%level.
highestPriorityDifference = [];
if ~isempty(shallowestUnmatchedNode)
    if ~isempty(deepestMatchedDifferenceNode)
        %If there is an unmatched node in the correct answer, and a node
        %with a difference to report, then prioritize whichever is the
        %shallowest (the "highest" level)
        if deepestMatchedDifferenceNode.comparison.depth < shallowestUnmatchedNode.comparison.depth
            highestPriorityDifference = deepestMatchedDifferenceNode;
        else
            highestPriorityDifference = shallowestUnmatchedNode;
        end
    else
        %If there is an unmatched node in correct answer, always report it
        %if there is no other node with a difference
        highestPriorityDifference = shallowestUnmatchedNode;
    end
else
    %If there is no unmatched node in the correct answer, then it's down to
    %one of the other two options
    if ~isempty(shallowestUnmatchedNodeInSubmission) && ~isempty(deepestMatchedDifferenceNode)
        %If both exist, then choose based upon depth
        if deepestMatchedDifferenceNode.comparison.depth >= shallowestUnmatchedNodeInSubmission.comparison.depth
            highestPriorityDifference = deepestMatchedDifferenceNode;
        else
            highestPriorityDifference = shallowestUnmatchedNodeInSubmission;
        end
        %Otherwise, choose based upon which exists
    elseif ~isempty(deepestMatchedDifferenceNode)
        highestPriorityDifference = deepestMatchedDifferenceNode;
    elseif ~isempty(shallowestUnmatchedNodeInSubmission)
        highestPriorityDifference = shallowestUnmatchedNodeInSubmission;
    end
end

end



%% Create output string based on a node's reported differences
function str = createOutputString(srcTree,comparison,isSubmissionTree)
import connector.internal.academy.i18n.FeedbackTemplates;

str = '';
devs = comparison.deviations;
n = numel(devs);
node = srcTree.select(comparison.nodeIdx);

if (n == 1) && strcmp(devs{1}.problem,'NotFound')
    unmatched = true;
else
    unmatched = false;
end

%The only thing we report from the submission tree is unmatched nodes, so
%error if there is a matched node that is part of the submission tree
if ~unmatched && isSubmissionTree
    %warning('Unsupported sequence');
end


switch comparison.kind
    
    case {'CALL','SUBSCR','CELL','DCALL'}
        if unmatched
            if isMATLABFunction(tree2str(node.Left))
                fcnStr = ['<a target="_blank" href="' getHelpURLForFunction(tree2str(node.Left)) '">' tree2str(node.Left) '</a>'];            
            else
                fcnStr = tree2str(node.Left);
            end
            switch comparison.purpose
                case 'calling a function'
                    if isSubmissionTree
                        str = FeedbackTemplates.constructFeedback('shouldNotCallAFunction',fcnStr);
                    else
                        str = FeedbackTemplates.constructFeedback('shouldCallAFunction',fcnStr);
                    end
                case 'accessing array elements'
                    if isSubmissionTree
                        str = FeedbackTemplates.constructFeedback('shouldNotIndexIntoVariable',fcnStr);
                    else
                        str = FeedbackTemplates.constructFeedback('shouldIndexIntoVariable',fcnStr);
                        str = [str FeedbackTemplates.language.templates.example '<br /><span class="code">>> ... = ' fcnStr '(1,3)</span>'];
                    end
                case 'accessing an array'
                    if isSubmissionTree
                        str = FeedbackTemplates.constructFeedback('shouldNotUseVariable',fcnStr);
                    else
                        str = FeedbackTemplates.constructFeedback('shouldUseVariable',fcnStr);
                        str = [str FeedbackTemplates.language.templates.example '<br /><span class="code">>> ... = ' fcnStr '</span>'];
                    end
                case 'modifying an array'                    
                    if isSubmissionTree
                        str = FeedbackTemplates.constructFeedback('shouldNotModifyVariable',fcnStr);
                    else
                        str = FeedbackTemplates.constructFeedback('shouldModifyVariable',fcnStr);
                        str = [str FeedbackTemplates.language.templates.example '<br /><span class="code">>> ' fcnStr '(3) = ...</span>'];
                    end
                case 'assigning a variable'                
                    if isSubmissionTree
                        str = FeedbackTemplates.constructFeedback('shouldNotModifyVariable',fcnStr);
                    else
                        str = FeedbackTemplates.constructFeedback('shouldModifyVariable',fcnStr);
                        str = [str FeedbackTemplates.language.templates.example '<br /><span class="code">>> ' fcnStr ' = ...</span>'];
                    end
                case 'accessing cell contents'               
                    if isSubmissionTree
                        str = FeedbackTemplates.constructFeedback('shouldNotExtractContentFrom',fcnStr);
                    else
                        str = FeedbackTemplates.constructFeedback('shouldExtractContentFrom',fcnStr);
                        str = [str FeedbackTemplates.language.templates.example '<br /><span class="code">>> ... = ' fcnStr '{1,3}</span>'];
                    end
                case 'modifying cell contents'            
                    if isSubmissionTree
                        str = FeedbackTemplates.constructFeedback('shouldNotModifyContentWithin',fcnStr);
                    else
                        str = FeedbackTemplates.constructFeedback('shouldModifyContentWithin',fcnStr);
                        str = [str FeedbackTemplates.language.templates.example '<br /><span class="code">>> ' fcnStr '{3} = ...</span>'];
                    end
            end
        else
            if isMATLABFunction(tree2str(node.Left))
                fcnStr = ['<a target="_blank" href="' getHelpURLForFunction(devs{1}.properties.identifierBeingCalled) '">' ...
                    devs{1}.properties.identifierBeingCalled '</a>'];
            else
                fcnStr = devs{1}.properties.identifierBeingCalled;
            end
            if strcmp(comparison.purpose,'calling a function')
                isFcnCall = true;
            else
                isFcnCall = false;
            end
            if strcmp(devs{1}.problem,'WrongIndexOrCallTechnique')
                %newDeviation.problem = 'WrongIndexOrCallTechnique';
                %newDeviation.properties.expectedTechnique = '{}';
                %newDeviation.properties.identifierBeingCalled = leftString;
                if strcmp(devs{1}.properties.expectedTechnique,'{}')
                    str = FeedbackTemplates.constructFeedback('indexShouldUseCurlyBraces',fcnStr);
                else
                    if isFcnCall
                        str = FeedbackTemplates.constructFeedback('functionCallShouldUseParentheses',fcnStr);
                    else
                        str = FeedbackTemplates.constructFeedback('indexShouldUseParentheses',fcnStr);
                    end
                end
            else
                %Can assume difference is referring to the correct answer tree
                if strcmp(devs{1}.problem,'WrongNumArguments')
                    %newDeviation.problem = 'WrongNumArguments';
                    %newDeviation.properties.expectedNumArgs = nOrig;
                    %newDeviation.properties.identifierBeingCalled = node.Left.string;
                    if isFcnCall
                        str = FeedbackTemplates.constructFeedback('callShouldHaveDifferentNumberOfInputs',fcnStr,num2str(devs{1}.properties.expectedNumArgs));
                    else
                        str = FeedbackTemplates.constructFeedback('indexShouldHaveDifferentNumberOfInputs',fcnStr,num2str(devs{1}.properties.expectedNumArgs));
                    end
                else
                    %Incorrect arguments is deviations{1}
                    %newDeviation.problem = 'IncorrectArguments';
                    %newDeviation.properties.identifierBeingCalled = node.Left.string;
                    str = [FeedbackTemplates.constructFeedback('inputsAreIncorrect',fcnStr) '<br />'];
                    
                    str = [str '<ul>'];
                    for i = 2:numel(devs)
                        if strcmp(devs{i}.problem,'MissingArgument')
                            %newDeviation.problem = 'MissingArgument';
                            %newDeviation.properties.argNumber = i;
                            %newDeviation.properties.expectedValue = argStringsOrig{i};
                            str = [str '<li>' ...
                                FeedbackTemplates.constructFeedback('inputWasExpectedToBeDifferent', ...
                                getLinguisticOrdinal(devs{i}.properties.argNumber), ...
                                devs{i}.properties.expectedValue) '</li>'];
                        end
                        if strcmp(devs{i}.problem,'BadArgumentOrder')
                            %newDeviation.problem = 'BadArgumentOrder';
                            %newDeviation.properties.origArgNumber = i;
                            %newDeviation.properties.newArgNumber = newLoc(1);
                            %newDeviation.properties.argString = argStringsOrig{i};
                            str = [str '<li>' FeedbackTemplates.constructFeedback('inputArgumentIsNotInCorrectSpot', ...
                                devs{i}.properties.argString, ...
                                getLinguisticOrdinal(devs{i}.properties.origArgNumber), ...
                                getLinguisticOrdinal(devs{i}.properties.newArgNumber)) '</li>'];
                        end
                    end
                    str = [str '</ul>'];
                    
                end
            end
            
        end
        
    case {'LC','LB'}
        if strcmp(comparison.kind,'LC')
            textName = 'curly braces';
            symbols = '{}';
            operationName = comparison.purpose;
        else
            textName = 'square brackets';
            symbols = '[]';
            operationName = comparison.purpose;
        end
        if unmatched
            if isSubmissionTree
                switch comparison.purpose
                    case 'obtaining multiple output arguments'
                        str = FeedbackTemplates.language.templates.noNeedToObtainMultipleOutputArguments;
                    case 'manually creating arrays'
                        str = FeedbackTemplates.language.templates.noNeedToManuallyCreateArray;
                    case 'removing array elements'
                        str = FeedbackTemplates.language.templates.noNeedToRemoveArrayElements;
                    case 'creating empty arrays'
                        str = FeedbackTemplates.language.templates.noNeedToCreateAnEmptyArray;
                    case 'manually creating cell arrays'
                        str = FeedbackTemplates.language.templates.noNeedToManuallyCreateCellArray;
                    case 'creating empty cell arrays'
                        str = FeedbackTemplates.language.templates.noNeedToCreateEmptyCellArray;
                end
            else
                switch comparison.purpose
                    case 'obtaining multiple output arguments'
                        str = FeedbackTemplates.language.templates.shouldObtainMultipleOutputArguments;
                    case 'manually creating arrays'
                        str = FeedbackTemplates.language.templates.shouldManuallyCreateArray;
                    case 'removing array elements'
                        str = FeedbackTemplates.language.templates.shouldRemoveArrayElements;
                    case 'creating empty arrays'
                        str = FeedbackTemplates.language.templates.shouldCreateAnEmptyArray;
                    case 'manually creating cell arrays'
                        str = FeedbackTemplates.language.templates.shouldManuallyCreateCellArray;
                    case 'creating empty cell arrays'
                        str = FeedbackTemplates.language.templates.shouldCreateEmptyCellArray;
                end
            end
        else
            switch comparison.purpose
                case 'obtaining multiple output arguments'
                    strStart = FeedbackTemplates.language.templates.incorrectUseOfMultipleOutputArgs;
                case 'manually creating arrays'
                    strStart = FeedbackTemplates.language.templates.incorrectUseOfManuallyCreatingArrays;
                case 'removing array elements'
                    strStart = FeedbackTemplates.language.templates.incorrectUseOfRemovingArrayElements;
                case 'creating empty arrays'
                    strStart = FeedbackTemplates.language.templates.incorrectUseOfCreatingEmptyArray;
                case 'manually creating cell arrays'
                    strStart = FeedbackTemplates.language.templates.incorrectUseOfManuallyCreatingCellArrays;
                case 'creating empty cell arrays'
                    strStart = FeedbackTemplates.language.templates.incorrectUseOfCreatingEmptyCellArray;
            end
            
            strEnd = '';
            if strcmp(devs{1}.problem,'WrongNumberOfRows')
                %newDeviation.problem = 'WrongNumberOfRows';
                %newDeviation.properties.expectedNumRows = numel(nColsOrig);
                strStart = [strStart FeedbackTemplates.constructFeedback(...
                    'expectedMRows', num2str(devs{1}.properties.expectedNumRows))];
                if ~isequal(devs{1}.properties.expectedNumRows,1)
                    strEnd = [strEnd '<br />' FeedbackTemplates.language.templates.rowSeparationTip '<br />' ...
                        FeedbackTemplates.language.templates.example '<span class="code">' symbols(1) 'a;b' symbols(2) '</span> '];
                end
            else
                %newDeviation.problem = 'WrongNumberOfColumns';
                %newDeviation.properties.expectedNumCols = nColsOrig(k);
                %newDeviation.properties.rowNumber = k;
                strStart = [strStart '<ul>'];
                for i = 1:numel(devs)
                    if strcmp(devs{i}.problem,'WrongNumberOfColumns')
                        strStart = [strStart '<li>' FeedbackTemplates.constructFeedback(...
                            'expectedNColumns', getLinguisticOrdinal(devs{i}.properties.rowNumber), ...
                            num2str(devs{i}.properties.expectedNumCols)) '</li>'];
                        strEnd = [strEnd '<br />' FeedbackTemplates.language.templates.columnSeparationTip '<br />' ...
                            FeedbackTemplates.language.templates.example '<span class="code">' symbols(1) 'a b' symbols(2) '</span> '];
                    end
                    if strcmp(devs{i}.problem,'MissingArgument')
                        %newDeviation.problem = 'MissingArgument';
                        %newDeviation.properties.argNumber = i;
                        %newDeviation.properties.expectedValue = argStringsOrig{i};
                        %newDeviation.properties.rowNumber = k;
                        strStart = [strStart '<li>' FeedbackTemplates.constructFeedback(...
                            'expectedDifferentRowArgument', getLinguisticOrdinal(devs{i}.properties.argNumber), ...
                            getLinguisticOrdinal(devs{i}.properties.rowNumber), ...
                            devs{i}.properties.expectedValue) '</li>'];
                    end
                    if strcmp(devs{i}.problem,'BadArgumentOrder')
                        %newDeviation.problem = 'BadArgumentOrder';
                        %newDeviation.properties.origArgNumber = i;
                        %newDeviation.properties.newArgNumber = newLoc(1);
                        %newDeviation.properties.argString = argStringsOrig{i};
                        %newDeviation.properties.rowNumber = k;
                        strStart = [strStart '<li>' FeedbackTemplates.constructFeedback(...
                            'switchedArgumentOrderInRow', getLinguisticOrdinal(devs{i}.properties.rowNumber), ...
                            devs{i}.properties.argString, getLinguisticOrdinal(devs{i}.properties.origArgNumber)), ...
                            '</li>'];
                    end
                end
                strStart = [strStart '</ul>'];
            end
            str = [strStart,strEnd];
            
        end
        
    case 'COLON'
        colonLink = ['<a target="_blank" href="' getHelpURLForFunction('colon') '">:</a>'];
        if unmatched
            if isSubmissionTree
                str = FeedbackTemplates.language.templates.shouldNotUseColon;
            else
                switch comparison.purpose
                    case 'accessing all elements of an array'
                        str = [FeedbackTemplates.constructFeedback('useColonToAccessAllElements',colonLink) '<br />' ...
                            FeedbackTemplates.language.templates.example '<span class="code">x(:)</span>'];
                    case 'accessing all rows'
                        str = [FeedbackTemplates.constructFeedback('useColonToAccessAllRows',colonLink) '<br />' ...
                            FeedbackTemplates.language.templates.example '<span class="code">x(:,3)</span>'];
                    case 'accessing all columns'
                        str = [FeedbackTemplates.constructFeedback('useColonToAccessAllColumns',colonLink) '<br />' ...
                            FeedbackTemplates.language.templates.example '<span class="code">x(3,:)</span>'];
                    case 'accessing all elements of a particular dimension'
                        str = [FeedbackTemplates.constructFeedback('useColonToAccessAllElementsOfADimension',colonLink) '<br />' ...
                            FeedbackTemplates.language.templates.example '<span class="code">x(2,3,:)</span>'];
                    case 'creating vectors'
                        str = [FeedbackTemplates.constructFeedback('useColonToCreateVector',colonLink) '<br />' ...
                            FeedbackTemplates.language.templates.example '<span class="code">x = 0:5:50</span>'];
                end
            end
        else
            for i = 1:numel(devs)
                if strcmp(devs{i}.problem,'NoLoneColonFound')
                    % newDeviation.problem = 'NoLoneColonFound';
                    str = [str FeedbackTemplates.constructFeedback('needToUseALoneColon',colonLink)];
                end
                if strcmp(devs{i}.problem,'LoneColonNotExpected')
                    % newDeviation.problem = 'LoneColonNotExpected';
                    str = [str FeedbackTemplates.constructFeedback('needToSpecifyInitialAndFinalValue',colonLink)];
                end
                if strcmp(devs{i}.problem,'BadStartValue')
                    % newDeviation.problem = 'BadStartValue';
                    % newDeviation.properties.expectedValue = abdxOrig.a;
                    str = [str FeedbackTemplates.constructFeedback('badStartValueInColonExpression', ...
                        num2str(devs{i}.properties.expectedValue)) '<br />' ...
                        FeedbackTemplates.language.templates.example '<span class="code">' ...
                        num2str(devs{i}.properties.expectedValue) ':dx:b</span><br />'];
                end
                if strcmp(devs{i}.problem,'BadSpacingValue')
                    % newDeviation.problem = 'BadSpacingValue';
                    % newDeviation.properties.expectedValue = abdxOrig.dx;
                    str = [str FeedbackTemplates.constructFeedback('badSpacingValueInColonExpression', ...
                        num2str(devs{i}.properties.expectedValue)) '<br />' ...
                        FeedbackTemplates.language.templates.example '<span class="code">a:' ...
                        num2str(devs{i}.properties.expectedValue) ':b</span><br />'];
                end
                if strcmp(devs{i}.problem,'BadEndValue')
                    % newDeviation.problem = 'BadEndValue';
                    % newDeviation.properties.expectedValue = abdxOrig.b;
                    str = [str FeedbackTemplates.constructFeedback('badEndValueInColonExpression', ...
                        num2str(devs{i}.properties.expectedValue)) '<br />' ...
                        FeedbackTemplates.language.templates.example '<span class="code">a:dx:' ...
                        num2str(devs{i}.properties.expectedValue) '</span><br />'];
                end
            end
        end
        
    case {'BREAK','CONTINUE','RETURN'}
        fcnLink = ['<a target="_blank" href="' getHelpURLForFunction(lower(comparison.kind)) '">' lower(comparison.kind) '</a>'];
        if isSubmissionTree
            str = FeedbackTemplates.constructFeedback('unnecessaryStatement',fcnLink);
        else
            str = FeedbackTemplates.constructFeedback('missingStatement',fcnLink);
        end
        
    case {'DOT','DOTLP'}
        if unmatched
            if isSubmissionTree
                str = FeedbackTemplates.language.templates.noNeedToUseDotOperator;
            else
                str = FeedbackTemplates.language.templates.shouldUseDotOperator;
            end
        else
            if strcmp(devs{1}.problem, 'WrongVarName')
                %newDeviation.problem = 'WrongVarName';
                %newDeviation.properties.expectedValue = node.Left.string;
                str = FeedbackTemplates.constructFeedback('useDotOperatorOnVariable',devs{1}.properties.expectedValue);
                if isequal(comparison.kind,'DOT')
                    str = [str '<br />' FeedbackTemplates.language.templates.example '<span class="code">' ...
                        devs{1}.properties.expectedValue '.fieldName</span> '];
                else
                    str = [str '<br />' FeedbackTemplates.language.templates.example '<span class="code">' ...
                        devs{1}.properties.expectedValue '.(fieldName)</span> '];
                end
                if devs{1}.properties.capitalizationFlag
                    str = [str FeedbackTemplates.language.templates.checkVariableNameCapitalization];
                end
            end
            if strcmp(devs{1}.problem, 'WrongFieldName')
                %newDeviation.problem = 'WrongFieldName';
                %newDeviation.properties.expectedValue = node.Right.string;
                str = FeedbackTemplates.constructFeedback('useDotOperatorForField',devs{1}.properties.expectedValue);
                if isequal(comparison.kind,'DOT')
                    str = [str '<br />' FeedbackTemplates.language.templates.example '<span class="code">varName.' ...
                        devs{1}.properties.expectedValue '</span> '];
                else
                    str = [str '<br />' FeedbackTemplates.language.templates.example '<span class="code">varName.(' ...
                        devs{1}.properties.expectedValue ')</span> '];
                end
                if devs{1}.properties.capitalizationFlag
                    str = [str FeedbackTemplates.language.templates.checkVariableNameCapitalization];
                end
            end
        end
        
    case 'EQUALS'
        if unmatched
            if isSubmissionTree
                str = FeedbackTemplates.language.templates.noAssignmentNecessary;
            else
                str = [FeedbackTemplates.constructFeedback('shouldUseAssignment',tree2str(node.Left)) ...
                    '<br/>' FeedbackTemplates.language.templates.example '<span class="code">&gt;&gt; ' tree2str(node.Left) ' = ...</span>'];
            end
        else
            for i = 1:numel(devs)
                if strcmp(devs{i}.problem,'BadArgument')
                    %newDeviation.problem = 'BadArgument';
                    %newDeviation.properties.whichArg = 'right';
                    %newDeviation.properties.expectedValue = rso;
                    if strcmp(devs{i}.properties.whichArg,FeedbackTemplates.language.templates.right)
                        str = [str FeedbackTemplates.language.templates.valueAssignedIncorrect];
                    end
                    if strcmp(devs{i}.properties.whichArg,FeedbackTemplates.language.templates.left)
                        str = [str FeedbackTemplates.constructFeedback(...
                            'wrongVariableInAssignment',devs{i}.properties.expectedValue)];
                    end
                    if devs{i}.properties.capitalizationFlag
                        str = [str FeedbackTemplates.language.templates.checkVariableNameCapitalization];
                    end
                end
                if strcmp(devs{i}.problem,'SwitchedArgument')
                    %newDeviation.problem = 'SwitchedArgument';
                    %newDeviation.properties.whichArg = 'right';
                    %newDeviation.properties.expectedValue = rso;
                    if strcmp(devs{i}.properties.whichArg,'both')
                        str = [str FeedbackTemplates.constructFeedback(...
                            'switchedAssignmentOrder',devs{i}.properties.expectedValue)];
                    end
                    if strcmp(devs{i}.properties.whichArg,FeedbackTemplates.language.templates.left)
                        str = [str FeedbackTemplates.constructFeedback(...
                            'valueBeingAssignedShouldBeOutput',devs{i}.properties.expectedValue)];
                    end
                    if strcmp(devs{i}.properties.whichArg,FeedbackTemplates.language.templates.right)
                        str = [str FeedbackTemplates.constructFeedback(...
                            'outputShouldBeValueBeingAssigned',devs{i}.properties.expectedValue)];
                    end
                end
            end
        end
        
    case {'MINUS','MUL','DIV','LDIV','EXP','DOTMUL','DOTDIV',...
            'DOTLDIV','DOTEXP','ANDAND','OROR','LT','GT','LE','GE',...
            'PLUS','AND','OR','EQ','NE'}
        if unmatched
            if isSubmissionTree
                str = FeedbackTemplates.constructFeedback('noNeedToUseOperator',...
                    getOperatorName(comparison.kind), ...
                    getHelpURLForFunction(getOperatorFcnName(comparison.kind)), ...
                    getOperatorSymbol(comparison.kind));
            else
                str = FeedbackTemplates.constructFeedback('shouldUseOperator',...
                    getOperatorName(comparison.kind), ...
                    getHelpURLForFunction(getOperatorFcnName(comparison.kind)), ...
                    getOperatorSymbol(comparison.kind));
            end
        else
            for i = 1:numel(devs)
                if strcmp(devs{i}.problem,'BadArgument')
                    %newDeviation.problem = 'BadArgument';
                    %newDeviation.properties.whichArg = 'right';
                    %newDeviation.properties.expectedValue = rso;
                    str = [str FeedbackTemplates.constructFeedback('badOperatorArgument', ...
                        devs{i}.properties.whichArg, ...
                        getOperatorName(comparison.kind), ...
                        devs{i}.properties.expectedValue)];
                end
                if strcmp(devs{i}.problem,'SwitchedArgument')
                    %newDeviation.problem = 'SwitchedArgument';
                    %newDeviation.properties.whichArg = 'right';
                    %newDeviation.properties.expectedValue = rso;
                    if strcmp(devs{i}.properties.whichArg,'both')
                        str = [str FeedbackTemplates.constructFeedback('switchedBothOperatorArguments', ...
                            getOperatorName(comparison.kind), ...
                            devs{i}.properties.expectedValue)];
                    end
                    if strcmp(devs{i}.properties.whichArg,FeedbackTemplates.language.templates.left)
                        str = [str FeedbackTemplates.constructFeedback('switchedOneOperatorArgument', ...
                            FeedbackTemplates.language.templates.right, getOperatorName(comparison.kind), ...
                            devs{i}.properties.expectedValue, FeedbackTemplates.language.templates.left)];
                    end
                    if strcmp(devs{i}.properties.whichArg,FeedbackTemplates.language.templates.right)
                        str = [str FeedbackTemplates.constructFeedback('switchedOneOperatorArgument', ...
                            FeedbackTemplates.language.templates.left, getOperatorName(comparison.kind), ...
                            devs{i}.properties.expectedValue, FeedbackTemplates.language.templates.right)];
                    end
                end
            end
        end
        
    case {'NOT','UMINUS','UPLUS','DOTTRANS','TRANS','AT','PARENS','BANG'}
        if unmatched
            if isSubmissionTree
                str = FeedbackTemplates.constructFeedback('noNeedToUseOperator',...
                    getOperatorName(comparison.kind), ...
                    getHelpURLForFunction(getOperatorFcnName(comparison.kind)), ...
                    getOperatorSymbol(comparison.kind));
            else
                str = FeedbackTemplates.constructFeedback('shouldUseOperator',...
                    getOperatorName(comparison.kind), ...
                    getHelpURLForFunction(getOperatorFcnName(comparison.kind)), ...
                    getOperatorSymbol(comparison.kind));
            end
        else
            for i = 1:numel(devs)
                if strcmp(devs{i}.problem,'BadArgument')
                    %newDeviation.problem = 'BadArgument';
                    %newDeviation.properties.expectedValue = rso;
                    str = FeedbackTemplates.constructFeedback('badOperatorArgument', ...
                        '', getOperatorName(comparison.kind), ...
                        devs{i}.properties.expectedValue);
                end
            end
        end
        
    case {'ID','INT','DOUBLE','STRING'}
        str = '';
        for i = 1:numel(devs)
            if isequal(comparison.kind,'INT')                
                if isSubmissionTree
                    str = FeedbackTemplates.constructFeedback('shouldUseInt',...
                        devs{i}.properties.expectedValue);
                else                    
                    str = FeedbackTemplates.constructFeedback('noNeedToUseInt',...
                        devs{i}.properties.expectedValue);
                end
            end
            if isequal(comparison.kind,'DOUBLE')             
                if isSubmissionTree
                    str = FeedbackTemplates.constructFeedback('shouldUseDouble',...
                        devs{i}.properties.expectedValue);
                else                    
                    str = FeedbackTemplates.constructFeedback('noNeedToUseDouble',...
                        devs{i}.properties.expectedValue);
                end
            end
            if isequal(comparison.kind,'STRING')             
                if isSubmissionTree
                    str = FeedbackTemplates.constructFeedback('shouldUseString',...
                        devs{i}.properties.expectedValue);
                else                    
                    str = FeedbackTemplates.constructFeedback('noNeedToUseString',...
                        devs{i}.properties.expectedValue);
                end
            end
            if isequal(comparison.kind,'ID')             
                if isSubmissionTree
                    str = FeedbackTemplates.constructFeedback('shouldUseId',...
                        devs{i}.properties.expectedValue);
                else                    
                    str = FeedbackTemplates.constructFeedback('noNeedToUseId',...
                        devs{i}.properties.expectedValue);
                end
            end
        end
        
    case 'ANON'
        anonFcnLink = ['<a target="_blank" href="http://www.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html">' ...
            FeedbackTemplates.language.templates.anonymousFunction '</a>'];
        if unmatched
            if isSubmissionTree
                str = FeedbackTemplates.constructFeedback('anonymousFunctionUnnecessary',anonFcnLink);
            else
                str = [FeedbackTemplates.constructFeedback('tryUsingAnonymousFunction',anonFcnLink) ...
                    '<br />' FeedbackTemplates.language.templates.example '<span class="code">f = @(x,y) x+y+2;</span>'];
            end
        else
            for i = 1:numel(devs)
                if strcmp(devs{i}.problem,'WrongNumArguments')
                    %newDeviation.problem = 'WrongNumArguments';
                    %newDeviation.properties.expectedNumArgs = nOrig;
                    str = FeedbackTemplates.constructFeedback('tryUsingAnonymousFunction',...
                        num2str(devs{i}.properties.expectedNumArgs));
                end
            end
        end
        
    otherwise
        %Leave string as blank?  Or maybe error?
        error('Unanticipated case');
end

end

%% Determine if something is a standard MATLAB function
function r = isMATLABFunction(str)
    r = false;
    try
        w = which(str);
        if ~isempty(strfind(w,'built-in'))
            r = true;
        end
        if ~isempty(strfind(w,'toolbox/matlab'))
            r = true;
        end
        if ~isempty(strfind(w,'toolbox\matlab'))
            r = true;
        end
        %Override for hidden functions - see g1133079
        if any(strcmp(str,{'clc','doc'}))
            r = true;
        end
    catch
        r = false;
    end
end

%% Get URL for help page to a function
function url = getHelpURLForFunction(fcn)
    url = ['http://www.mathworks.com/help/matlab/ref/',fcn,'.html'];
end

%% Get operator name
%'PLUS' will return 'addition operator'
function name = getOperatorName(kind)
import connector.internal.academy.i18n.FeedbackTemplates;
switch kind
    case {'MINUS','MUL','DIV','LDIV','EXP','DOTMUL','DOTDIV','DOTLDIV',...
            'DOTEXP','ANDAND','OROR','LT','GT','LE','GE','PLUS','AND',...
            'OR','EQ','NE','NOT','UMINUS','UPLUS','DOTTRANS','TRANS',...
            'AT','BANG'}        
        name = FeedbackTemplates.language.templates.(kind);
    otherwise
        name = '';
end
end

%% Get operator symbol
%'PLUS' will return '<span class="code">+</span>'
function res = getOperatorSymbol(kind)
switch kind
    case 'MINUS',        res = '-';
    case 'MUL',          res = '*';
    case 'DIV',          res = '/';
    case 'LDIV',         res = '\';
    case 'EXP',          res = '^';
    case 'DOTMUL',       res = '.*';
    case 'DOTDIV',       res = './';
    case 'DOTLDIV',      res = '.\';
    case 'DOTEXP',       res = '.^';
    case 'ANDAND',       res = '&&';
    case 'OROR',         res = '||';
    case 'LT',           res = '<';
    case 'GT',           res = '>';
    case 'LE',           res = '<=';
    case 'GE',           res = '>=';
    case 'PLUS',         res = '+';
    case 'AND',          res = '&';
    case 'OR',           res = '|';
    case 'EQ',           res = '==';
    case 'NE',           res = '~=';
    case 'NOT',          res = '~';
    case 'UMINUS',       res = '-';
    case 'UPLUS',        res = '+';
    case 'DOTTRANS',     res = '.''';
    case 'TRANS',        res = '''';
    case 'AT',           res = '@';
    case 'BANG',         res = '!';
    otherwise,           res = '';
end
res = ['<span class="code">' res '</span>'];
end

%% Get link to operator help doc
%'MUL' will return 'mtimes'
function fcnName = getOperatorFcnName(kind)
switch kind
    case 'MINUS',        fcnName = 'minus';
    case 'MUL',          fcnName = 'mtimes';
    case 'DIV',          fcnName = 'mrdivide';
    case 'LDIV',         fcnName = 'mldivide';
    case 'EXP',          fcnName = 'mpower';
    case 'DOTMUL',       fcnName = 'times';
    case 'DOTDIV',       fcnName = 'rdivide';
    case 'DOTLDIV',      fcnName = 'ldivide';
    case 'DOTEXP',       fcnName = 'power';
    case 'ANDAND',       fcnName = 'and';
    case 'OROR',         fcnName = 'or';
    case 'LT',           fcnName = 'lt';
    case 'GT',           fcnName = 'gt';
    case 'LE',           fcnName = 'le';
    case 'GE',           fcnName = 'ge';
    case 'PLUS',         fcnName = 'plus';
    case 'AND',          fcnName = 'and';
    case 'OR',           fcnName = 'or';
    case 'EQ',           fcnName = 'eq';
    case 'NE',           fcnName = 'ne';
    case 'NOT',          fcnName = 'not';
    case 'UMINUS',       fcnName = 'uminus';
    case 'UPLUS',        fcnName = 'uplus';
    case 'DOTTRANS',     fcnName = 'transpose';
    case 'TRANS',        fcnName = 'ctranspose';
    case 'AT',           fcnName = 'function_handle';
    case 'BANG',         fcnName = 'system';
    otherwise,           fcnName = '';
end
end


%% Compare two mtree objects
% origTree - Tree which is treated as the original tree
% newTree - Tree which is treated as the modified tree
%All comparisons are reported assuming origTree is the original.
%The resulting nodeComparisons data structure looks like this:
%
%  nodeComparisons[]
%    |- nodeIdx                 : index of origTree
%    |- bestMatchingNodeIdx     : closes matching index of newTree
%    |- kind                    : mtree node kind ('CALL','CELL','INT',etc.)
%    |- depth                   : numeric value for how many layers deep in the tree the node is
%    |- deviations[]
%        |- problem             : unique identifier for type of deviation
%        |- properties          : flexible structure that contains additional information about the problem
function nodeComparisons = compareTrees(origTree, newTree)

%Store deviations, and best potential match (node number and depth).
%Group the deviations by node.  So, a single CALL node in the one
%tree might have several "deviations", and there may be multiple nodes
%with deviations
nodeComparisons = struct('nodeIdx',{},'bestMatchingNodeIdx',{},'kind',{},'deviations',{},'depth',{});
for i = indices(origTree)
    %Grab the current node
    currentNode = origTree.select(i);
    currentKind = currentNode.kind;
    
    %Populate the comparisons structure with initial data
    nodeComparisons(i).nodeIdx = i;
    nodeComparisons(i).kind = currentKind;
    nodeComparisons(i).depth = getNodeDepth(currentNode);
    deviations = {};
    bestMatchingNodeIdx = [];
    
    try
    
        %See if there are any of those kind of nodes in the other tree
        switch currentKind

            case {'CALL','SUBSCR','CELL','DCALL'}
                %Left contains name of function or variable, Right and Next
                %contain arguments of the call
                [deviations,bestMatchingNodeIdx] = ...
                    findLeftRightNextDeviations(currentNode,newTree);

                %For LB nodes
                % 1. See if an open bracket exists
                % 2. Check number of rows and cols of each open bracket to see if
                %    any match.
                % 3. For each row, check argument list along columns and report
                %    deviations
            case {'LB','LC'}
                [deviations,bestMatchingNodeIdx] = ...
                    findBracketOrCurlyBracesDeviations(currentNode,newTree);

            case 'ROW'
                %No checks, as this is handled by the higher-level nodes LB and LC

            case 'EQUALS'
                [deviations,bestMatchingNodeIdx] = ...
                    findDeviationsOfBinaryOrderedNode(currentNode,newTree);

                %Mtree bug override: Mtree's tree2str function has a bug where 
                % [a,b] = min(x)
                %will return "[a;b] = min(x)". So here, we swap semicolons for
                %commas in these situations
                try %#ok
                    if isequal(numel(deviations),1)
                        if isfield(deviations{1}, 'properties')
                            props = deviations{1}.properties;
                            if isfield(props,'whichArg')
                                if strcmp(props.whichArg,FeedbackTemplates.language.templates.left)
                                    deviations{1}.properties.expectedValue = ...
                                        strrep(deviations{1}.properties.expectedValue,';',',');
                                end
                            end
                        end
                    end
                end

            case 'DOT'
                %>> x.p = 5;
                %DOT node has a LEFT child for the variable name, and a RIGHT
                %child of kind FIELD that contains the subscript
                [deviations,bestMatchingNodeIdx] = ...
                    findDeviationsOfSubscriptNode(currentNode,newTree);

            case 'DOTLP'
                %>> x.('p') = 5;
                %DOTLP node has a LEFT child for the variable name and a RIGHT
                %child of kind STRING for the subscript.
                [deviations,bestMatchingNodeIdx] = ...
                    findDeviationsOfSubscriptNode(currentNode,newTree);

            case 'FIELD'
                %No checks, as this is handled by the higher-level DOT node

            case 'ANON'
                %>> @(x,y) x + y
                %ANON has a LEFT and NEXT child representing the x,y arguments.
                %Then, it's RIGHT argument is the actual function expression
                [deviations,bestMatchingNodeIdx] = ...
                    findLeftNextDeviations(currentNode,newTree);

            case 'ANONID'
                %Generally, these are handled in the ANON node
                %These get tricky because the command essentially contains intermediate variables the way a script would...
                %>> dumptree(mtree('fh = @(x,y) x+y * 2'))
                % To deal with them, we normalize the inputs so that they
                % always use the same variable names. For instance, @(x) and
                % @(y) both become @(anonymousInput1)

            case 'COLON'
                %COLON can be used like
                %  a(:)  -  COLON node has no children
                %  1:4   -  COLON has left and right child
                %  1:2:8 -  COLON has left and right child, and left child is
                %  another COLON
                %  General strategy is to handle each COLON node at it's top
                %  COLON level, and ensure start/end points are same, and
                %  midpoint (if any) is same
                [deviations,bestMatchingNodeIdx] = ...
                    findDeviationsOfColonNode(currentNode,newTree);


            case {'BREAK','CONTINUE','RETURN'}
                %Single nodes with no descendents
                [deviations,bestMatchingNodeIdx] = ...
                    findDeviationsOfNodesWithoutDescendents(currentNode,newTree);

            case {'EXPR','PRINT'}
                %Top level root nodes that we won't worry about

            case 'ERR'
                %Error in the syntax. This is typically the only node in the
                %tree. We don't compare errors - we just report what the error
                %was.

            case {'NOT','UMINUS','UPLUS','DOTTRANS','TRANS','AT','PARENS','ID','INT','DOUBLE','STRING','BANG'}
                [deviations,bestMatchingNodeIdx] = ...
                    findDeviationsOfUnaryNode(currentNode,newTree);

            case {'MINUS','MUL','DIV','LDIV','EXP','DOTMUL','DOTDIV',...
                    'DOTLDIV','DOTEXP','ANDAND','OROR','LT','GT','LE','GE'}
                [deviations,bestMatchingNodeIdx] = ...
                    findDeviationsOfBinaryOrderedNode(currentNode,newTree);

            case {'PLUS','AND','OR','EQ','NE'}
                [deviations,bestMatchingNodeIdx] = ...
                    findDeviationsOfBinaryUnorderedNode(currentNode,newTree);

                %We'll worry about these later...
            case 'COMMENT'
            case 'CELLMARK'
            case 'QUEST'
            case 'GLOBAL'
            case 'PERSISTENT'
            case 'IF'
            case 'IFHEAD'
            case 'ELSEIF'
            case 'ELSE'
            case 'SWITCH'
            case 'CASE'
            case 'OTHERWISE'
            case 'WHILE'
            case 'FOR'
            case 'PARFOR'
            case 'SPMD'
            case 'TRY'
            case 'FUNCTION'
            case 'CLASSDEF'
            case 'ATTRIBUTES'
            case 'ATTR'
            case 'PROPERTIES'
            case 'METHODS'
            case 'ENUMERATION'
            case 'EVENTS'
            case 'ATBASE'
            case 'PROTO'
            case 'BLKCOM'

            otherwise
                [deviations,bestMatchingNodeIdx] = ...
                    findDeviationsOfNodesWithoutDescendents(currentNode,newTree);
        end
    catch
        %Error in finding deviations, so lets leave it empty
    end
    
    %Add any deviation information to the main structure
    nodeComparisons(i).deviations = deviations;
    nodeComparisons(i).bestMatchingNodeIdx = bestMatchingNodeIdx;
    
end

end


%% Add "purpose" to node
%Add an internal representation of each node's "purpose" which will be
%later used for providing the output string. Typically this is not much
%more interesting than the node kind itself, though in some crucial cases
%(such as the use of : or []) it can be very different
function comparisons = addNodePurposes(nodeTree,comparisons)

for i = 1:numel(comparisons)
    node = nodeTree.select(comparisons(i).nodeIdx);
    purpose = '';
    
    %See if node is on left or right of equals sign
    rightOfEqualsSign = true;
    equalsSignMatch = mtfind(nodeTree,'Kind','EQUALS');
    if ~isnull(equalsSignMatch)
        leftSideIdxs = equalsSignMatch.Left.Tree.getIX;
        thisNodeIdx = node.getIX;
        if any(thisNodeIdx & leftSideIdxs)
            rightOfEqualsSign = false;
        end
    end
    
    %Determine number of node children
    numChildren = nnz(node.Tree.getIX) - 1;
    
    %In certain cases, determine if the identifier being referenced is a
    %function or variable name
    if isMATLABFunction(tree2str(node.Left))
        isFunctionName = true;
    else
        isFunctionName = false;
    end
    
    switch node.kind
        
        case 'CALL'
            if rightOfEqualsSign
                if isFunctionName
                    purpose = 'calling a function';
                else
                    if numChildren == 1
                        purpose = 'accessing an array';
                    else
                        purpose = 'accessing array elements';
                    end
                end
            else
                if numChildren == 1
                    purpose = 'assigning a variable';
                else
                    purpose = 'modifying an array';
                end
            end
            
        case 'SUBSCR'    
            if rightOfEqualsSign
                purpose = 'accessing array elements';
            else
                purpose = 'modifying an array';
            end
            
        case 'CELL'  
            if rightOfEqualsSign
                purpose = 'accessing cell contents';
            else
                purpose = 'modifying cell contents';
            end
            
        case 'DCALL'
            purpose = 'calling a function';
            
        case 'LB'
            %Empty brackets [] have only one child element (an empty ROW)
            isEmptyBracket = numChildren == 1;
            parentIsEquals = strcmp(node.Parent.kind,'EQUALS');
            
            if ~rightOfEqualsSign
                purpose = 'obtaining multiple output arguments';
            else
                if ~isEmptyBracket
                    purpose = 'manually creating arrays';
                else
                    if (parentIsEquals && isEmptyBracket)
                        purpose = 'removing array elements';
                    else
                        purpose = 'creating empty arrays';
                    end
                end
            end
            
        case 'LC'
            %Empty braces only have two elements
            isEmptyBraces = numChildren == 1;
            
            if ~isEmptyBraces
                purpose = 'manually creating cell arrays';
            else
                purpose = 'creating empty cell arrays';
            end           
            
        case 'ROW'
        case 'EQUALS'
        case 'DOT'
            if rightOfEqualsSign
                purpose = 'accessing field of a structure';
            else
                purpose = 'modifying field of a structure';
            end
        case 'DOTLP'
        case 'FIELD'
        case 'ANON'
        case 'ANONID'
        case 'COLON'
            
            if numChildren == 0
                subscriptNode = node.trueparent;
                oneArgument = isnull(subscriptNode.Next);
                if oneArgument
                    purpose = 'accessing all elements of an array';
                else
                    if any(subscriptNode.Right.getIX & node.getIX)
                        %Left argument
                        purpose = 'accessing all rows';
                    elseif any(subscriptNode.Next.getIX & node.getIX)
                        %Right argument
                        purpose = 'accessing all columns';
                    else
                        %Higher dimension argument
                        purpose = 'accessing all elements of a particular dimension';
                    end
                end
            else
                purpose = 'creating vectors';
            end
            
        case 'BREAK'
        case 'CONTINUE'
        case 'RETURN'
        case 'EXPR'
        case 'PRINT'
        case 'ERR'
        case 'NOT'
        case 'UMINUS'
        case 'UPLUS'
        case 'DOTTRANS'
        case 'TRANS'
        case 'AT'
        case 'PARENS'
        case 'ID'
        case 'INT'
        case 'DOUBLE'
        case 'STRING'
        case 'BANG'
        case 'MINUS'
        case 'MUL'
        case 'DIV'
        case 'LDIV'
        case 'EXP'
        case 'DOTMUL'
        case 'DOTDIV'
        case 'DOTLDIV'
        case 'DOTEXP'
        case 'ANDAND'
        case 'OROR'
        case 'LT'
        case 'GT'
        case 'LE'
        case 'GE'            
        case 'PLUS'
        case 'AND'
        case 'OR'
        case 'EQ'
        case 'NE'
            
        %Ignore for now
        case 'COMMENT'
        case 'CELLMARK'
        case 'QUEST'
        case 'GLOBAL'
        case 'PERSISTENT'
        case 'IF'
        case 'IFHEAD'
        case 'ELSEIF'
        case 'ELSE'
        case 'SWITCH'
        case 'CASE'
        case 'OTHERWISE'
        case 'WHILE'
        case 'FOR'
        case 'PARFOR'
        case 'SPMD'
        case 'TRY'
        case 'FUNCTION'
        case 'CLASSDEF'
        case 'ATTRIBUTES'
        case 'ATTR'
        case 'PROPERTIES'
        case 'METHODS'
        case 'ENUMERATION'
        case 'EVENTS'
        case 'ATBASE'
        case 'PROTO'
        case 'BLKCOM'
            
        otherwise
            
    end
    
    comparisons(i).purpose = purpose;
end

end


%% Get depth of a node
function depth = getNodeDepth(node)

depth = 0;
node = node.Parent;
while (~node.isnull)
    depth = depth + 1;
    node = node.Parent;
end

end


%% Returns n - the number of arguments in a particular CALL (or similar) node
%  sortrows(x,3) has two arguments in the call to sortrows
function n = getNumberOfRightNextArguments(node)

n = 0;
r = node.Right;
if isnull(r)
    return;
else
    n = n+1;
end

while ~isnull(r.Next)
    r = r.Next;
    n = n + 1;
end

end

%% Returns n - the number of arguments in a particular ANON (or similar) node
%  @(x,3) has two arguments
function n = getNumberOfLeftNextArguments(node)

n = 0;
L = node.Left;
if isnull(L)
    return;
else
    n = n+1;
end

while ~isnull(L.Next)
    L = L.Next;
    n = n + 1;
end

end


%% Returns n - an array (1 for each ROW node) of numbers representing how many columns in each row
%  [1,2,3;4,5,6] would return [3,3], and [1,2,3;secondRow] would return [3,1]
function n = getNumberOfColsInEachRow(lbNode)
n = [];

%Special case for output arguments ( [a,b] = min(..) ). These situations do
%not have ROW nodes breaking up their rows, so we should treat these as a
%single row and just count the number of elements
if isnull(mtfind(lbNode.Tree,'Kind','ROW'))
    cnt = 0;
    col = lbNode.Arg;
    while ~isnull(col)
        cnt = cnt+1;
        col = col.Next;
    end
    n(end+1) = cnt;
    return;
end

%Normal (common) case where rows are separated by ROW nodes
row = lbNode.Arg;
while ~isnull(row)
    cnt = 0;
    col = row.Arg;
    while ~isnull(col)
        cnt = cnt+1;
        col = col.Next;
    end
    n(end+1) = cnt;
    row = row.Next;
end

end


%% Returns all arguments of a particular CALL node
%  sortrows(x,3) would return an ID node for x and an INT node for 3
function nodes = getRightNextArguments(callNode)

idx = [];
r = callNode.Right;
if ~isnull(r)
    idx = find(r.getIX);
    
    while ~isnull(r.Next)
        r = r.Next;
        idx = [idx find(r.getIX)];
    end
end

nodes = callNode.Tree.select(idx);

end


%% Returns all arguments of a particular ROW node
%  [1,2,3] would return an ID node for 1, 2, and 3
function nodes = getArgNextArguments(rowNode)

idx = [];
a = rowNode.Arg;
if ~isnull(a)
    idx = find(a.getIX);
    
    while ~isnull(a.Next)
        a = a.Next;
        idx = [idx find(a.getIX)];
    end
end

nodes = rowNode.Tree.select(idx);

end



%% Compares two subtrees in a flat manner
function deviations = compareSubtreesFlat(subOrig,subNew)

deviations = {};

idxOrig = find(subOrig.getIX);
idxNew = find(subNew.getIX);

argStringsOrig = cell(numel(idxOrig),1);
for i = 1:numel(idxOrig)
    argStringsOrig{i} = tree2str(subOrig.select(idxOrig(i)));
end

argStringsNew = cell(numel(idxNew),1);
for i = 1:numel(idxNew)
    argStringsNew{i} = tree2str(subNew.select(idxNew(i)));
end

for i = 1:numel(argStringsOrig)
    newLoc = find(strcmp(argStringsOrig{i},argStringsNew));
    if isempty(newLoc)
        newDeviation.problem = 'MissingArgument';
        newDeviation.properties.argNumber = i;
        newDeviation.properties.expectedValue = argStringsOrig{i};
        deviations{end+1} = newDeviation;
    else
        if all(newLoc ~= i)
            newDeviation.problem = 'BadArgumentOrder';
            newDeviation.properties.origArgNumber = i;
            newDeviation.properties.newArgNumber = newLoc(1);
            newDeviation.properties.argString = argStringsOrig{i};
            deviations{end+1} = newDeviation;
        end
    end
end

end



%% Compare ordered binary nodes
% Things like minus, colon, and greater than are ordered binary operators.
% Things like mtimes, plus, and equalTo are unordered (commutative)
function deviations = compareBinaryOrderedNodes(origNode,newNode)
import connector.internal.academy.i18n.FeedbackTemplates;

lso = tree2str(origNode.Left);
rso = tree2str(origNode.Right);

lsn = tree2str(newNode.Left);
rsn = tree2str(newNode.Right);

deviations = {};
if strcmp(lsn,lso) && strcmp(rsn,rso)
    %Both args match. Leave deviations untouched
else
    if strcmp(lsn,lso)
        %Right doesn't match, but left does
        newDeviation.problem = 'BadArgument';
        newDeviation.properties.whichArg = FeedbackTemplates.language.templates.right;
        newDeviation.properties.expectedValue = rso;        
        newDeviation.properties.capitalizationFlag = strcmpi(rso,rsn);
        deviations{end+1} = newDeviation;
    elseif strcmp(rsn,rso)
        %Left doesn't match, but right does
        newDeviation.problem = 'BadArgument';
        newDeviation.properties.whichArg = FeedbackTemplates.language.templates.left;
        newDeviation.properties.expectedValue = lso;
        newDeviation.properties.capitalizationFlag = strcmpi(lso,lsn);
        deviations{end+1} = newDeviation;
    else
        %Neither matches
        if strcmp(lsn,rso) && strcmp(rsn,lso)
            %Both args switched
            newDeviation.problem = 'SwitchedArgument';
            newDeviation.properties.whichArg = 'both';
            newDeviation.properties.expectedValue = tree2str(origNode);
            deviations{end+1} = newDeviation;
        else
            if strcmp(lsn,rso)
                %Right argument of orig tree is the left of the new tree.
                %Also, left argument of orig tree does not have a match in
                %the new tree
                newDeviation.problem = 'SwitchedArgument';
                newDeviation.properties.whichArg = FeedbackTemplates.language.templates.right;
                newDeviation.properties.expectedValue = rso;
                deviations{end+1} = newDeviation;
                
                newDeviation.problem = 'BadArgument';
                newDeviation.properties.whichArg = FeedbackTemplates.language.templates.left;
                newDeviation.properties.expectedValue = lso;
                newDeviation.properties.capitalizationFlag = false;
                deviations{end+1} = newDeviation;
            elseif strcmp(rsn,lso)
                %Left argument of orig tree is the right of the new tree.
                %Also, right argument of orig tree does not have a match in
                %the new tree
                newDeviation.problem = 'SwitchedArgument';
                newDeviation.properties.whichArg = FeedbackTemplates.language.templates.left;
                newDeviation.properties.expectedValue = lso;
                deviations{end+1} = newDeviation;
                
                newDeviation.problem = 'BadArgument';
                newDeviation.properties.whichArg = FeedbackTemplates.language.templates.right;
                newDeviation.properties.expectedValue = rso;
                newDeviation.properties.capitalizationFlag = false;
                deviations{end+1} = newDeviation;
            else
                %Both args incorrect
                newDeviation.problem = 'BadArgument';
                newDeviation.properties.whichArg = FeedbackTemplates.language.templates.left;
                newDeviation.properties.expectedValue = lso;
                newDeviation.properties.capitalizationFlag = false;
                deviations{end+1} = newDeviation;
                
                newDeviation.problem = 'BadArgument';
                newDeviation.properties.whichArg = FeedbackTemplates.language.templates.right;
                newDeviation.properties.expectedValue = rso;
                newDeviation.properties.capitalizationFlag = false;
                deviations{end+1} = newDeviation;
            end
        end
    end
end

end



%% Compare unordered binary nodes
% Things like minus, colon, and greater than are ordered binary operators.
% Things like plus and equalTo are unordered (commutative)
function deviations = compareBinaryUnorderedNodes(origNode,newNode)

lso = tree2str(origNode.Left);
rso = tree2str(origNode.Right);

lsn = tree2str(newNode.Left);
rsn = tree2str(newNode.Right);

deviations = {};
if strcmp(lsn,lso) && strcmp(rsn,rso)
    %Both args match. Leave deviations untouched
else
    if strcmp(lsn,lso)
        %Right doesn't match, but left does
        newDeviation.problem = 'BadArgument';
        newDeviation.properties.whichArg = FeedbackTemplates.language.templates.right;
        newDeviation.properties.expectedValue = rso;
        newDeviation.properties.capitalizationFlag = strcmpi(rso,rsn);
        deviations{end+1} = newDeviation;
    elseif strcmp(rsn,rso)
        %Left doesn't match, but right does
        newDeviation.problem = 'BadArgument';
        newDeviation.properties.whichArg = FeedbackTemplates.language.templates.left;
        newDeviation.properties.expectedValue = lso;
        newDeviation.properties.capitalizationFlag = strcmpi(lso,lsn);
        deviations{end+1} = newDeviation;
    else
        %Neither matches
        if strcmp(lsn,rso) && strcmp(rsn,lso)
            %Both args switched, which is ok for commutative operators
        else
            if strcmp(lsn,rso)
                %Right argument of orig tree is the left of the new tree.
                %Also, left argument of orig tree does not have a match in
                %the new tree
                newDeviation.problem = 'BadArgument';
                newDeviation.properties.whichArg = FeedbackTemplates.language.templates.left;
                newDeviation.properties.expectedValue = lso;
                newDeviation.properties.capitalizationFlag = strcmpi(lso,rsn);
                deviations{end+1} = newDeviation;
            elseif strcmp(rsn,lso)
                %Left argument of orig tree is the right of the new tree.
                %Also, right argument of orig tree does not have a match in
                %the new tree
                newDeviation.problem = 'BadArgument';
                newDeviation.properties.whichArg = FeedbackTemplates.language.templates.right;
                newDeviation.properties.expectedValue = rso;
                newDeviation.properties.capitalizationFlag = strcmpi(rso,lsn);
                deviations{end+1} = newDeviation;
            else
                %Both args incorrect
                newDeviation.problem = 'BadArgument';
                newDeviation.properties.whichArg = FeedbackTemplates.language.templates.left;
                newDeviation.properties.expectedValue = lso;
                newDeviation.properties.capitalizationFlag = strcmpi(lso,lsn);
                deviations{end+1} = newDeviation;
                
                newDeviation.problem = 'BadArgument';
                newDeviation.properties.whichArg = FeedbackTemplates.language.templates.right;
                newDeviation.properties.expectedValue = rso;
                newDeviation.properties.capitalizationFlag = strcmpi(rso,rsn);
                deviations{end+1} = newDeviation;
            end
        end
    end
end

end


%% Find deviations of nodes that have no descendents
function [deviations,bestMatchingNodeIdx] = findDeviationsOfNodesWithoutDescendents(node,newTree)

deviations = {};
bestMatchingNodeIdx = [];
kindOfNode = node.kind;

newNodes = mtfind(newTree,'Kind',{kindOfNode});
if isnull(newNodes)
    newDeviation.problem = 'NotFound';
    deviations{end+1} = newDeviation;
end

end


%% Find deviations of binary ordered node
function [deviations,bestMatchingNodeIdx] = findDeviationsOfBinaryOrderedNode(node,newTree)

deviations = {};
bestMatchingNodeIdx = [];
kindOfNode = node.kind;

matches = mtfind(newTree,'Kind',kindOfNode);

if isnull(matches)
    newDeviation.problem = 'NotFound';
    deviations{end+1} = newDeviation;
else
    %Find "best matched" node
    tmpDevs = {};
    for j = find(matches.getIX)
        tmpDevs{end+1} = compareBinaryOrderedNodes(node,matches.select(j));
    end
    
    %Find node with minimum deviations
    numDevs = cellfun(@numel,tmpDevs);
    deviations = tmpDevs{numDevs == min(numDevs)};
    idxs = find(matches.getIX);
    bestMatchingNodeIdx = idxs(numDevs == min(numDevs));
end

end


%% Find deviations of binary ordered node
function [deviations,bestMatchingNodeIdx] = findDeviationsOfBinaryUnorderedNode(node,newTree)

deviations = {};
bestMatchingNodeIdx = [];
kindOfNode = node.kind;

matches = mtfind(newTree,'Kind',kindOfNode);

if isnull(matches)
    newDeviation.problem = 'NotFound';
    deviations{end+1} = newDeviation;
else
    %Find "best matched" node
    tmpDevs = {};
    for j = find(matches.getIX)
        tmpDevs{end+1} = compareBinaryUnorderedNodes(node,matches.select(j));
    end
    
    %Find node with minimum deviations
    numDevs = cellfun(@numel,tmpDevs);
    deviations = tmpDevs{numDevs == min(numDevs)};
    idxs = find(matches.getIX);
    bestMatchingNodeIdx = idxs(numDevs == min(numDevs));
end

end



%% Find deviations of unary node
function [deviations,bestMatchingNodeIdx] = findDeviationsOfUnaryNode(node,newTree)

deviations = {};
bestMatchingNodeIdx = [];
kindOfNode = node.kind;

if strcmp(kindOfNode,'ID')
    matches = mtfind(newTree,'Kind',kindOfNode);
    
    %Special case - sometimes, an ID node in a given tree is matched by
    %a CALL node with no Right or Next children.  So, search for those CALL
    %nodes as well and treat them as matches.
    potentialMatches = mtfind(newTree,'Kind','CALL','Left.String',node.string);
    alsoMatchedIdxs = false(1,numel(potentialMatches.getIX));
    for i = find(potentialMatches.getIX)
        potentialMatch = potentialMatches.select(i);
        if isnull(potentialMatch.Right)
            alsoMatchedIdxs(i) = true;
        end
    end
    matches = newTree.select(matches.getIX | alsoMatchedIdxs);
else
    matches = mtfind(newTree,'Kind',kindOfNode);
end

if isnull(matches)
    newDeviation.problem = 'NotFound';
    newDeviation.properties.expectedValue = tree2str(node);
    deviations{end+1} = newDeviation;
else
    %Find "best matched" node
    [bestMatch,minDist] = getBestMatchViaStringDistance(node,matches);
    bestMatchingNodeIdx = find(bestMatch.getIX);
    
    %If min string distance is not 0, then there's a match and so no
    %deviations are added
    if ~isequal(minDist,0)
        newDeviation.problem = 'BadArgument';
        newDeviation.properties.expectedValue = tree2str(node);
        newDeviation.properties.capitalizationFlag = false;
        deviations{end+1} = newDeviation;
    end
end

end



%% Colon node deviations
%  a(:)  -  COLON node has no children
%  1:4   -  COLON has left and right child
%  1:2:8 -  COLON has left and right child, and left child is
%  another COLON
%  General strategy is to handle each COLON node at it's top
%  COLON level, and ensure start/end points are same, and
%  midpoint (if any) is same
function [deviations,bestMatchingNodeIdx] = findDeviationsOfColonNode(node,newTree)
deviations = {};
bestMatchingNodeIdx = [];

%Ignore COLON nodes that are not "top-level" COLON nodes
if strcmp(node.trueparent.kind,'COLON')
    return;
end

matches = mtfind(newTree,'Kind','COLON');

keepers = [];
for i = find(matches.getIX)
    if ~strcmp(matches.select(i).trueparent.kind,'COLON')
        keepers(end+1) = i;
    end
end
matches = matches.select(keepers);

if isnull(matches)
    newDeviation.problem = 'NotFound';
    deviations{end+1} = newDeviation;
else
    %Heuristically determine best match via string distance
    [bestMatch,minDist] = getBestMatchViaStringDistance(node,matches);
    bestMatchingNodeIdx = find(bestMatch.getIX);
    
    %If not an exact match
    if ~isequal(minDist,0)
        
        if isnull(node.Left)
            %If orig node was a single colon
            if ~isnull(bestMatch.Left)
                newDeviation.problem = 'NoLoneColonFound';
                deviations{end+1} = newDeviation;
            end
        else
            abdxOrig = getABdXStringsOfColon(node);
            
            if isnull(bestMatch.Left)
                newDeviation.problem = 'LoneColonNotExpected';
                deviations{end+1} = newDeviation;
            else
                
                abdxSubmission = getABdXStringsOfColon(bestMatch);
                
                if ~strcmp(abdxOrig.a,abdxSubmission.a)
                    newDeviation.problem = 'BadStartValue';
                    newDeviation.properties.expectedValue = abdxOrig.a;
                    deviations{end+1} = newDeviation;
                end
                
                if ~strcmp(abdxOrig.dx,abdxSubmission.dx)
                    newDeviation.problem = 'BadSpacingValue';
                    newDeviation.properties.expectedValue = abdxOrig.dx;
                    deviations{end+1} = newDeviation;
                end
                
                if ~strcmp(abdxOrig.b,abdxSubmission.b)
                    newDeviation.problem = 'BadEndValue';
                    newDeviation.properties.expectedValue = abdxOrig.b;
                    deviations{end+1} = newDeviation;
                end
                
            end
            
        end
        
    end
end

end

%% Helper function for colon nodes
function abdx = getABdXStringsOfColon(node)

if ~strcmp(node.Left.kind,'COLON')
    a = tree2str(node.Left);
    dx = '1';
    b = tree2str(node.Right);
else
    a = tree2str(node.Left.Left);
    dx = tree2str(node.Left.Right);
    b = tree2str(node.Right);
end

abdx.a = a;
abdx.b = b;
abdx.dx = dx;

end


%% Subscript deviations
function [deviations,bestMatchingNodeIdx] = findDeviationsOfSubscriptNode(node,newTree)
deviations = {};
bestMatchingNodeIdx = [];
kindOfNode = node.kind;

matches = mtfind(newTree,'Kind',kindOfNode);

if isnull(matches)
    newDeviation.problem = 'NotFound';
    deviations{end+1} = newDeviation;
else
    %Heuristically determine best match via string distance
    [bestMatch,minDist] = getBestMatchViaStringDistance(node,matches);
    bestMatchingNodeIdx = find(bestMatch.getIX);
    
    %If not an exact match
    if ~isequal(minDist,0)
        if ~strcmp(tree2str(bestMatch.Left),tree2str(node.Left))
            newDeviation.problem = 'WrongVarName';
            newDeviation.properties.capitalizationFlag = strcmpi(tree2str(bestMatch.Left),tree2str(node.Left));
            newDeviation.properties.expectedValue = tree2str(node.Left);
            deviations{end+1} = newDeviation;
        end
        if ~strcmp(bestMatch.Right.string,node.Right.string)
            newDeviation.problem = 'WrongFieldName';
            newDeviation.properties.capitalizationFlag = strcmpi(bestMatch.Right.string,node.Right.string);
            newDeviation.properties.expectedValue = node.Right.string;
            deviations{end+1} = newDeviation;
        end
    end
end

end

%% Left/next deviations
%This is used to find deviations in the 'ANON' nodes
function [deviations,bestMatchingNodeIdx] = findLeftNextDeviations(node,newTree)

deviations = {};
bestMatchingNodeIdx = [];
kindOfNode = node.kind;

matchesKind = mtfind(newTree,'Kind',kindOfNode);
if isnull(matchesKind)
    newDeviation.problem = 'NotFound';
    deviations{end+1} = newDeviation;
else
    [bestMatch,minDist] = getBestMatchViaStringDistance(node,matchesKind);
    bestMatchingNodeIdx = find(bestMatch.getIX);
    
    %If not an exact match
    if ~isequal(minDist,0)

        nOrig = getNumberOfLeftNextArguments(node);
        n = getNumberOfLeftNextArguments(bestMatch);
        if ~isequal(n,nOrig)
            newDeviation.problem = 'WrongNumArguments';
            newDeviation.properties.expectedNumArgs = nOrig;
            deviations{end+1} = newDeviation;
        end
        
    end
end

end

%% Left/right/next deviations
%This is used to find deviations in 'SUBSCR','CALL','DCALL','CELL' nodes, despite its name.
%There is a lot of trickery here, since the language allows things like
%x.b(a), which is a call to the result of x.b
function [deviations,bestMatchingNodeIdx] = findLeftRightNextDeviations(node,newTree)

deviations = {};
bestMatchingNodeIdx = [];
kindOfNode = node.kind;

%The call being made is either to a string (most cases) or the result of a
%cell index / struct field reference
%  (Most cases)   >> fcn(a)        node.Left.string = 'fcn'
%  (Cell index)   >> x{3}(a)       tree2str(node.Left) = 'x{3}'
%  (Struct field) >> x.b(a)        tree2str(node.Left) = 'x.b'
%Determining potential matches is a little bit tricky in the latter two
%cases, since mtfind won't do the heavy lifting for us.
try
    leftString = node.Left.string;
    use_mtfind = true;
catch
    leftString = tree2str(node.Left);
    use_mtfind = false;
end

%Find all nodes with the same Left string. We treat subscr, call, dcall,
%and cell as potential matches.  Then, we treat differences in the kind as
%a deviation of the node.  That lets us avoid a user submission of a{1} not
%being matched to a correct answer of a(1).  In this case, we want to say
%that the deviation is to use parenthesEs instead of curly braces, instead
%of saying that the call to "a" doesn't exist.
if use_mtfind
    matchesString = mtfind(newTree,'Kind',{'SUBSCR','CALL','DCALL','CELL'},'Left.String',leftString);
else
    idxs = false(1,numel(newTree.getIX));
    for i = find(newTree.getIX)
        if strcmp(tree2str(newTree.select(i).Left),leftString) && ...
                ~isempty(strcmp(newTree.select(i).kind,{'SUBSCR','CALL','DCALL','CELL'}))
            idxs(i) = true;
        end
    end
    matchesString = newTree.select(idxs);
end

%Special case - sometimes, if a CALL node in a given tree has no Right
%or Next children, then that can exist in another tree as a simple ID
%node with the same string.  So, if this is one such type of CALL node,
%then we should also search for simple ID nodes to see if any of those
%match.
if strcmp(kindOfNode,'CALL')
    if isnull(node.Right)
        alsoMatches = mtfind(newTree,'Kind','ID','String',leftString);
        matchesString = newTree.select(alsoMatches.getIX | matchesString.getIX);
    end
end


%If none found, add info to the deviation list
if isnull(matchesString)
    newDeviation.problem = 'NotFound';
    deviations{end+1} = newDeviation;
else
    %If any matches with the same Left string do exist
    matchingNodeIdxs1 = [];
    
    %Loop over all nodes that had the same Left string
    for j = find(matchesString.getIX)
        currentKind = matchesString.select(j).kind;
        if any(strcmp(kindOfNode,{'SUBSCR','CALL','DCALL'}))
            if any(strcmp(currentKind,{'SUBSCR','CALL','DCALL','ID'}))
                matchingNodeIdxs1 = [matchingNodeIdxs1, j];
            end
        end
        if strcmp(kindOfNode,'CELL')
            if strcmp(currentKind,'CELL')
                matchingNodeIdxs1 = [matchingNodeIdxs1, j];
            end
        end
    end
    
    %If nothing matches, then someone is using {} where they should be
    %using (), or vice versa.
    if isempty(matchingNodeIdxs1)
        newDeviation.problem = 'WrongIndexOrCallTechnique';
        if strcmp(kindOfNode,'CELL')
            newDeviation.properties.expectedTechnique = '{}';
        else
            newDeviation.properties.expectedTechnique = '()';
        end
        newDeviation.properties.identifierBeingCalled = leftString;
        deviations{end+1} = newDeviation;
    else
        
        %If any matches with the same Left string and comparable Kind do exist
        matchingNodeIdxs2 = [];
        
        %Loop over all nodes that had the same Left string and comparable Kind
        nOrig = getNumberOfRightNextArguments(node);
        for j = find(matchesString.getIX)
            n = getNumberOfRightNextArguments(matchesString.select(j));
            if isequal(n,nOrig)
                %For those nodes with the same number of
                %arguments, remember their index in the tree
                matchingNodeIdxs2 = [matchingNodeIdxs2, j];
            end
        end
        
        %If no nodes have the same number of arguments, add info to
        %the deviation list
        if isempty(matchingNodeIdxs2)
            newDeviation.problem = 'WrongNumArguments';
            newDeviation.properties.expectedNumArgs = nOrig;
            newDeviation.properties.identifierBeingCalled = leftString;
            deviations{end+1} = newDeviation;
        else
            %Heuristically determine best match via string distance
            [bestMatch,minDist] = getBestMatchViaStringDistance(node,matchesString.select(matchingNodeIdxs2));
            bestMatchingNodeIdx = find(bestMatch.getIX);
            
            %If not an exact match
            if ~isequal(minDist,0)
                
                %Add the high-level deviation info
                newDeviation.problem = 'IncorrectArguments';
                newDeviation.properties.identifierBeingCalled = leftString;
                deviations{end+1} = newDeviation;
                
                %Find incorrect or switched arguments for each of
                %the calls that had the same number of arguments
                deviations = [deviations, compareSubtreesFlat(getRightNextArguments(node), ...
                    getRightNextArguments(bestMatch))];
                
            end
            
        end
    end
end

end

%% Deviations from [] and {}
function [deviations,bestMatchingNodeIdx] = findBracketOrCurlyBracesDeviations(node,newTree)

deviations = {};
bestMatchingNodeIdx = [];
kindOfNode = node.kind;

allOpenBrackets = mtfind(newTree,'Kind',kindOfNode);

%See if any open brackets do exist
if isnull(allOpenBrackets)
    newDeviation.problem = 'NotFound';
    deviations{end+1} = newDeviation;
else
    %If any LB/LC nodes do exist, find best match via string
    %distance heuristic
    [bestMatch,minDist] = getBestMatchViaStringDistance(node,allOpenBrackets);
    bestMatchingNodeIdx = find(bestMatch.getIX);
    
    %If not an exact match
    if ~isequal(minDist,0)
        
        %Get number of columns in the rows of original and new
        nColsOrig = getNumberOfColsInEachRow(node);
        nCols = getNumberOfColsInEachRow(bestMatch);
        
        if ~isequal(numel(nCols),numel(nColsOrig))
            %Different number of rows
            newDeviation.problem = 'WrongNumberOfRows';
            newDeviation.properties.expectedNumRows = numel(nColsOrig);
            deviations{end+1} = newDeviation;
        else
            %Same number of rows
            
            for k = 1:numel(nCols)
                if ~isequal(nCols(k),nColsOrig(k))
                    newDeviation.problem = 'WrongNumberOfColumns';
                    newDeviation.properties.expectedNumCols = nColsOrig(k);
                    newDeviation.properties.rowNumber = k;
                    deviations{end+1} = newDeviation;
                end
            end
            
            %Check actual contents of the concatenation
            if isempty(deviations)
                origRowNodes = mtfind(node.Tree,'Kind','ROW');
                origRowIdxs = find(origRowNodes.getIX);
                newRowNodes = mtfind(bestMatch.Tree,'Kind','ROW');
                newRowIdxs = find(newRowNodes.getIX);
                for k = 1:numel(origRowIdxs)
                    newDevs = compareSubtreesFlat(...
                        getArgNextArguments(origRowNodes.select(origRowIdxs(k))),...
                        getArgNextArguments(newRowNodes.select(newRowIdxs(k))));
                    for d = 1:numel(newDevs)
                        newDevs{d}.properties.rowNumber = k;
                    end
                    deviations = [deviations, newDevs];
                end
            end
            
        end
    end
    
end
end

%% Normalize anonymous function input names
function str = normalizeAnonymousFunctionInputs(inpStr)
str = inpStr;
t = mtree(inpStr);

anon = mtfind(t,'Kind','ANON');
for k = find(anon.getIX)    
    anonNode = t.select(k);
    idxs = {};
    
    i = 0;
    anonid = anonNode.Left;
    while ~isnull(anonid)
        i = i + 1;
        newStr = ['anonymousInput' num2str(i)];
        ids = mtfind(anonNode.Tree,'Kind','ANONID','String',anonid.string);
        for j = find(ids.getIX)
            first = ids.select(j).charno;
            last = numel(anonid.string) + first - 1;
            idxs(end+1,:) = {first, last, newStr};
        end
        anonid = anonid.Next;
    end
    
    if (i > 0)
        idxs = sortrows(idxs,-1);
        for i = 1:size(idxs,1)
            str = [str(1:(idxs{i,1}-1)), idxs{i,3}, str((idxs{i,2}+1):end)];
        end
    end
end
end

%% Returns linguistic ordinal (first, second, third, etc.)
function res = getLinguisticOrdinal(number)
import connector.internal.academy.i18n.FeedbackTemplates;
switch number
    case 0
        res = FeedbackTemplates.language.templates.zeroth;
    case 1
        res = FeedbackTemplates.language.templates.first;
    case 2
        res = FeedbackTemplates.language.templates.second;
    case 3
        res = FeedbackTemplates.language.templates.third;
    case 4
        res = FeedbackTemplates.language.templates.fourth;
    case 5
        res = FeedbackTemplates.language.templates.fifth;
    case 6
        res = FeedbackTemplates.language.templates.sixth;
    case 7
        res = FeedbackTemplates.language.templates.seventh;
    case 8
        res = FeedbackTemplates.language.templates.eighth;
    case 9
        res = FeedbackTemplates.language.templates.ninth;
    case 10
        res = FeedbackTemplates.language.templates.tenth;
    otherwise
        res = num2str(number);
end
end

%% Return the best match by using a string distance heuristic
% Note - careful when using this to find best match of commutative
% operators.  'a+b' has a distance of 1 to 'a+c' but a distance of 2 to
% 'b+a', so the min distance would be 'a+c' even though 'b+a' is
% technically a correct match.
function [bestMatch,minDist] = getBestMatchViaStringDistance(origNode,possibleMatches)

%Calculate string distances for each node

j = 0;
idxs = find(possibleMatches.getIX);
strDiffs = NaN(numel(idxs),1);
for i = idxs
    orgStr = tree2str(origNode);
    newStr = tree2str(possibleMatches.select(i));
    j = j+1;
    strDiffs(j) = edit_distance_damerau(orgStr,newStr);
    % The distance algorithm allows things like '.-' to match with '-.' 
    % so here we enforce a minimum distance of 1 for strings that are 
    % not equal
    if (~isequal(orgStr,newStr) && isequal(strDiffs(j),0))
        strDiffs(j) = 1;
    end
end

%Find node with minimum string distance
minDist = min(strDiffs);
minIdx = idxs(strDiffs == minDist);

%Select best match
bestMatch = possibleMatches.select(minIdx(1));

end


%% Edit distance calculator 
% This was pulled from the file exchange. Copyright provided below.
function d=edit_distance_damerau(s,t)
  % EDIT_DISTANCE_DAMERAU calculates the Damerau-Levenshtein edit distance.
  %
  % This code is part of the work described in [1]. In [1], edit distances
  % are applied to match linguistic descriptions that occur when referring
  % to objects (in order to achieve joint attention in spoken human-robot /
  % human-human interaction).
  %
  % [1] B. Schauerte, G. A. Fink, "Focusing Computational Visual Attention
  %     in Multi-Modal Human-Robot Interaction," in Proc. ICMI,  2010.
  %
  % @author: B. Schauerte
  % @date:   2010
  % @url:    http://cvhci.anthropomatik.kit.edu/~bschauer/
  
  % Copyright 2010 B. Schauerte. All rights reserved.
  % 
  % Redistribution and use in source and binary forms, with or without 
  % modification, are permitted provided that the following conditions are 
  % met:
  % 
  %    1. Redistributions of source code must retain the above copyright 
  %       notice, this list of conditions and the following disclaimer.
  % 
  %    2. Redistributions in binary form must reproduce the above copyright 
  %       notice, this list of conditions and the following disclaimer in 
  %       the documentation and/or other materials provided with the 
  %       distribution.
  % 
  % THIS SOFTWARE IS PROVIDED BY B. SCHAUERTE ''AS IS'' AND ANY EXPRESS OR 
  % IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
  % WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
  % DISCLAIMED. IN NO EVENT SHALL B. SCHAUERTE OR CONTRIBUTORS BE LIABLE 
  % FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
  % CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
  % SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
  % BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
  % WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  % OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
  % ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  % 
  % The views and conclusions contained in the software and documentation
  % are those of the authors and should not be interpreted as representing 
  % official policies, either expressed or implied, of B. Schauerte
  
  m=numel(s);
  n=numel(t);
  
  d=zeros(m+1,n+1);
  
  % initialize distance matrix
  for i=0:m % deletion
    d(i+1,1)=i;
  end
  for j=0:n % insertion
    d(1,j+1)=j;
  end
  
  for j=2:n+1
    for i=2:m+1
      if s(i-1) == t(j-1)
        cost = 0;
      else
        cost = 1;
      end
      
      d(i,j)=min([ ...
        d(i-1,j) + 1, ...     % deletion
        d(i,j-1) + 1, ...     % insertion
        d(i-1,j-1) + cost ... % substitution
        ]);
      
      if (i-1)>1 && (j-1)>1 && s((i-1))==t((j-1)-1) && s((i-1)-1) == t(j-1)
        d(i,j) = min([ ... % transposition
          d(i,j), ...
          d(i-2,j-2), ...
          ]);
      end
    end
  end
  
  d=d(m+1,n+1);

end
