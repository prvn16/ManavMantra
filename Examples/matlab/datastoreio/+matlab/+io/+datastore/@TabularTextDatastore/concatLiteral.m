function [outCellStr, outSkipVec] = concatLiteral(inFormatCell, strOrCellStrFlag)
%concatLiteral preserves/concatenates literal with/to primitive formats to
%return data
%   This function is responsible for either combining literals with
%   primitive formats to make them format specifiers which return data or
%   preserve the customer specified format without modifying the ordering
%   of literals based on strOrCellStrFlag. When the flag is false every
%   literal is concatenated to the primitive format on its right. If the
%   literal does not find a primitive format on the right, it appends the
%   literal to the format found on the left. When the flag is true we do
%   not modify the ordering of literals. The function also returns a
%   logical vector indicating the skipped formats

%   Copyright 2014 The MathWorks, Inc.

% imports
import matlab.io.datastore.TabularTextDatastore;

% input format string
inStr = strjoin(inFormatCell);

% using the builtin textscan interface to validate the given format
builtin('_textscan_interface', TabularTextDatastore.DEFAULT_TEXTSCAN_STRING, ...
                                                                    inStr);

% preserve the literal ordering in the formats
if strOrCellStrFlag
    numElements = numel(inFormatCell);
    outSkipVec = zeros(1,numElements);
    
    for i = 1:numElements
        outSkipVec = setSkippedVecWhenCombinedWithPrev(inFormatCell{i}, ...
                                                            i, outSkipVec);
    end    
    outCellStr = inFormatCell;
    return
end

% we order the literal formats here based on the rules described above.
% construct a format parser struct
inStruct = matlab.iofun.internal.formatParser(inStr);

% check if all the format specifiers are literals.
litVec = inStruct.IsLiteral;
if all(litVec)
    error(message('MATLAB:datastoreio:tabulartextdatastore:invalidLiteralFormat'));
end

% when inCellStr is a cell of one string, it cannot be a skipped format
inCellStr = inStruct.Format;
inSkipVec = inStruct.IsSkipped;
startIdx = 1;
curr = startIdx;
outCurr = startIdx;
endIdx = numel(inCellStr);
outSkipVec = zeros(1,endIdx);

% a single literal is accounted for above.
if startIdx == endIdx
    outSkipVec = inSkipVec;
    outCellStr = inCellStr;
    return
end

% loop over individual formats 
while(curr <= endIdx)
    next = curr + 1;
    prev = outCurr - 1;
    
    combinedWithNext = 0;
    combinedWithPrev = 0;
    
    if (litVec(curr))        
        if curr == startIdx
            % processing the first element
            if litVec(next)
                % combine literals until we find a non-literal format
                nonLiteralPos = find(~litVec,1);
                outCellStr{outCurr} = ...
                         strjoin(inCellStr(curr:nonLiteralPos));%#ok<AGROW>
                combinedWithNext = nonLiteralPos - 1;
                outSkipVec = setSkippedVec(inSkipVec,nonLiteralPos, ...
                                                       outCurr,outSkipVec);
            else
                outCellStr{outCurr} = ...
                                  strjoin(inCellStr(curr:next));%#ok<AGROW>
                combinedWithNext = 1;
                outSkipVec = setSkippedVec(inSkipVec,next,outCurr, ...
                                                               outSkipVec);
            end
        elseif curr == endIdx
            % processing the last element.
            outCellStr = combineWithPrev(prev, inCellStr{curr}, outCellStr);            
            combinedWithPrev = 1;
            outSkipVec = ...
                setSkippedVecWhenCombinedWithPrev(outCellStr{prev}, ...
                                                         prev, outSkipVec);
        else
            % processing for the in between elements
            if litVec(next)
                outCellStr = combineWithPrev(prev, inCellStr{curr}, ...
                                                               outCellStr);
                combinedWithPrev = 1;
                outSkipVec = ...
                    setSkippedVecWhenCombinedWithPrev(outCellStr{prev}, ...
                                                         prev, outSkipVec);
            else
                outCellStr{outCurr} = strjoin(inCellStr(curr:next), ...
                                                           ''); %#ok<AGROW> 
                combinedWithNext = 1;                
                outSkipVec = setSkippedVec(inSkipVec, next, outCurr, ...
                                                               outSkipVec);
            end
        end
    else
        % handling formats without literals
        outCellStr{outCurr} = inCellStr{curr}; %#ok<AGROW>
        outSkipVec = setSkippedVec(inSkipVec, curr, outCurr, outSkipVec);        
    end
    
    % post processing
    curr = curr + combinedWithNext + 1;
    outCurr= outCurr + 1 - combinedWithPrev;
end

% resizing to size the outputLogical
outSkipVec(numel(outCellStr) + 1: end) = [];
end

function skippedVec = setSkippedVecWhenCombinedWithPrev(str, prev, skippedVec)
%SETSKIPPEDVECWHENCOMBINEDWITHPREV sets the skipped vector
%   This function is used to find a skipped non-literal format from a
%   format specifier and set the skipped vector accordingly. The format
%   that is passed into this function is a result of a combination of the
%   current format with the previous format. This is needed to create a
%   logical vector of the formats which are skipped and non-literal. This
%   function guards against formats with %'s and *'s in them and
%   differntiates them from traditional skipped formats like (%*s etc)

%   Copyright 2014 The MathWorks, Inc.

% create a formatParser struct
tempStruct = matlab.iofun.internal.formatParser(str);

% a single literal format is invalid
if (1 == numel(tempStruct.Format)) && (tempStruct.IsLiteral)
    error(message('MATLAB:datastoreio:tabulartextdatastore:invalidLiteralFormat'))
end

numPrimitiveFormats = nnz(~tempStruct.IsSkipped);
numSkipOnlyFormats = nnz(tempStruct.IsSkipped & ~tempStruct.IsLiteral);

% number of skipped only formats (non-literal) for a given string should be
% 1, or the number of unskipped formats should be 1, and both should not be
% same
if (numPrimitiveFormats > 1)  || (numSkipOnlyFormats > 1) || ...
                                (numPrimitiveFormats == numSkipOnlyFormats)
    error(message('MATLAB:datastoreio:tabulartextdatastore:tooManyFormats'));   
end

% set the output logical vector only if there is a skipped non-literal
if any(xor(tempStruct.IsSkipped, tempStruct.IsLiteral))
    skippedVec(prev) = 1; 
end
end

function skippedVec = setSkippedVec(skipLog, inputIdx, outputIdx, skippedVec)
%SETSKIPPEDVEC sets the skipped vector
%   This function sets the skipped vector based on the whether a particular
%   input format is skipped or not. This function is called whenever a
%   concatenation with the next format happens or when there is no
%   concatenation.

%   Copyright 2014 The MathWorks, Inc.

if skipLog(inputIdx)
    skippedVec(outputIdx) = 1;
end
end

function outCellStr = combineWithPrev(prev, inStr, outCellStr)
%COMBINEWITHPREV combines 2 formats with a space
%   This function combines the input format string and the current output
%   format with a space.

%   Copyright 2014 The MathWorks, Inc.

outCellStr{prev} = [outCellStr{prev}, ' ', inStr];
end