function [tData, tInfo, nbytes] = convertReaderData(ds, readerData, readerInfo, readSize, fmts, txtScanArgs, prevNumCharsRead, nCharsBeforeData, calcbytes)
%convertReaderData function responsible for conversion
%   This function is responsible for converting a given char array into
%   tables worth of data based on the input arguments.

%   Copyright 2014-2015 The MathWorks, Inc.

% imports
import matlab.io.datastore.TabularTextDatastore;

tInfo = readerInfo;

try
    % nCharsBeforeData is added to account for headerlines+ any empty lines
    % + the variable name line
    [cellArr, numCharsReadInChunk] = textscan(readerData, fmts, ...
                                              readSize, txtScanArgs{:}, ...
                                              'NumCharactersToSkip', prevNumCharsRead + nCharsBeforeData);
catch baseME
    if strcmp(baseME.identifier, 'MATLAB:textscan:handleErrorAndShowInfo')
        % find the faulty varibale name and format
        [varName, format] = findFaultyVarFormat(ds.VariableNames, ...
                                       ds.TextscanFormats, baseME.message);
        % the offset is converted to a string as offsets can go beyond
        % intmax and there is no support for floating point holes.
        m = message('MATLAB:datastoreio:tabulartextdatastore:failedConversion', ...
                       varName, format, tInfo.Filename, num2str(tInfo.Offset));
        throw(addCause(baseME, MException(m.Identifier,'%s',getString(m))));
    else
        throw(baseME);
    end
end

% skip trailing EoRs
% ------------------
% we should do this in accordance to how textscan would do it
% because the hasdata() method only checks if all the data is
% consumed or not. This specifically also has to account for
% trailing new lines at the end of a file.
if numCharsReadInChunk + 1 <= numel(readerData)
    [~,numCharsReadInChunk] = textscan(readerData, ...
                                       ['%*[',sprintf(ds.RowDelimiter),']'], 1, ...
                                       txtScanArgs{:}, ...
                                       'ReturnOnError', true, ...
                                       'NumCharactersToSkip', numCharsReadInChunk);
end
           
% table conversion
sVarNamesIdx = ds.SelectedVariableNamesIdx;
sVariableNames = ds.SelectedVariableNames;
tData = table.empty(0,0);

% Make the dimension names unique with respect to the var names, silently
tData.Properties.DimensionNames = matlab.lang.makeUniqueStrings(tData.Properties.DimensionNames,sVariableNames,namelengthmax);

% populating the table, taking ordering into account
for iter = 1:length(sVariableNames)
    varName = sVariableNames{iter};
    dataIdx = sVarNamesIdx(iter) == sort(sVarNamesIdx);
    val = cellArr{dataIdx};
    
    try
        tData.(varName) = val;
    catch 
        error(message('MATLAB:datastoreio:tabulartextdatastore:UnequalVarLengths', tInfo.Filename));
    end
end

% for the info struct, the actual characters read is from the beginning of
% this invocation, until now. numCharsReadInChunk is always from the
% beginning of the readerData, therefore nCharsBeforeData does not need to
% be added as it is already accounted for.
tInfo.NumCharactersRead = numCharsReadInChunk - prevNumCharsRead;

if calcbytes
    % offset is in bytes, nCharsBeforeData does not need to
    % be added as it is already accounted for in numCharsReadInChunk
    nbytes = numel(unicode2native(...
                                readerData(prevNumCharsRead+1:numCharsReadInChunk), ...
                                ds.FileEncoding));
else
    nbytes = -1;
end
end

function [varName, format] = findFaultyVarFormat(varNames, formats, msgStr)
% FINDFAULTYVARFORMAT finds the faulty variable name and format

% Copyright 2014 The MathWorks, Inc.

% read in the field index
matchNums = regexp(msgStr,'[0-9]+','match');
fieldIdx = str2double(matchNums{2});
numFormats = 0;

% find the faulty variable name and format
for i = 1:numel(varNames)
    fStruct = matlab.iofun.internal.formatParser(formats{i});
    numFormats = numFormats + numel(fStruct.Format);
    if numFormats >= fieldIdx
        varName = varNames{i};
        format = formats{i};
        return
    end
end
end