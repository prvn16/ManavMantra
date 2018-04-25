function [data, info] = readData(ds)
%READDATA Read subset of data from a datastore.
%   T = READDATA(TDS) reads some data from TDS.
%   T is a table with variables governed by TDS.SelectedVariableNames.
%   Number of rows in T is governed by TDS.ReadSize.
%   read(TDS) errors if there is no more data in TDS, and should be used
%   with hasdata(TDS).
%
%   [T,info] = READDATA(TDS) also returns a structure with additional
%   information about TDS. The fields of info are:
%       Filename - Name of the file from which data was read.
%       FileSize - Size of the file in bytes.
%       Offset - Starting position of the read operation, in bytes.
%       NumCharactersRead - Number of characters read from the file.
%
%   Example:
%   --------
%      % Create a TabularTextDatastore
%      tabds = tabularTextDatastore('airlinesmall.csv')
%      % Handle erroneous data
%      tabds.TreatAsMissing = 'NA'
%      tabds.MissingValue = 0;
%      % We are only interested in the Arrival Delay data
%      tabds.SelectedVariableNames = 'ArrDelay'
%      % Preview the first 8 rows of the data as a table
%      tab8 = preview(tabds)
%      % Sum the Arrival Delays
%      sumAD = 0;
%      while hasdata(tabds)
%         tab = read(tabds);
%         sumAD = sumAD + sum(tab.ArrDelay);
%      end
%      sumAD
%
%   See also - matlab.io.datastore.TabularTextDatastore, hasdata, readall, preview, reset.

%   Copyright 2016 The MathWorks, Inc.

import matlab.io.datastore.TabularTextDatastore;

% error early if no data available
if ~hasdata(ds)
    error(message('MATLAB:datastoreio:splittabledatastore:noMoreData'));
end

% if here, then we are at a split which has data or the buffer has data

if isnumeric(ds.ReadSize)
    readSize = ds.ReadSize;
    fullFile = false;
else
    readSize = Inf;
    fullFile = true;
end

scanFormats = strjoin(ds.TextscanFormats, ' ');

% error occured, pick up where we left off
% or readsize was smaller than split size
if isempty(ds.CurrBuffer)
    [ds.CurrBuffer, ds.CurrSplitInfo] = getNext(ds.SplitReader);
end

% aggregate textscan arguments.
txtScanArgs = ds.getTextscanArgs;

% turn off textscan warning in case TextscanFormats contains %D
% and if ambiguity exists between datetime formats
onState = warning('off', 'MATLAB:textscan:UnableToGuessFormat');
c = onCleanup(@() warning(onState));

bufferOnError = ds.CurrBuffer;
infoOnError = ds.CurrSplitInfo;
try
    [data,info] = iReadUntilSize(ds, readSize, scanFormats, txtScanArgs, fullFile);
catch me
    % Some exception happened, revert back to the old Buffer and
    % Split Info.
    ds.CurrBuffer = bufferOnError;
    ds.CurrSplitInfo = infoOnError;
    throw(me);
end

% Set the offset to the original offset when read was called,
% since the info's offset could've been updated during read.
info.Offset = infoOnError.Offset;

end

function nCharsBeforeData = iGetNCharsBeforeData(ds, txtScanArgs)
%IGETNCHARSBEFOREDATA Get num chars before data that includes headerlines, etc.
%   Skips header lines and then apply the format to the variable line
%   based on ReadVariableNames (this for free takes care of empty lines
%   between header line and variable name line). The empty lines before
%   the data are taken care of by the textscan call which deals with the
%   data later. this does not take care of empty lines before the header
%   lines, that needs to specified as part of the header lines. This
%   also takes care of lines with custom whitespace, comment lines before
%   the variable line.
    if (0 == ds.CurrSplitInfo.Offset)
        % handle beginning of files
        [~,nCharsBeforeData] = textscan(ds.CurrBuffer, ['%*[^',ds.RowDelimiter,']'], ...
            double(ds.ReadVariableNames), ...
            'HeaderLines', ds.NumHeaderLines, ...
            txtScanArgs{:});
    else
        nCharsBeforeData = 0;
    end
end

function [data,info] = iReadUntilSize(ds, readSize, scanFormats, txtScanArgs, fullFile)
    data = [];
    % Number of characters read for this read method call
    numCharactersForInfo = 0;
    while size(data, 1) < readSize
        % for beginning of files, this is still 0 as no characters have been
        % read/converted. This always holds the characters between succesive read
        % calls to maintain info
        nCharsRead = ds.NumCharactersReadInChunk;

        % nCharsBeforeData variable holds the number of characters before the data line
        % which basically in the number of characters in the header lines + any empty
        % lines + the variable name line.
        nCharsBeforeData = iGetNCharsBeforeData(ds, txtScanArgs);

        currReadSize = readSize - size(data, 1);
        [currData, info, nbytes] = convertReaderData(ds, ...
                                       ds.CurrBuffer, ds.CurrSplitInfo, currReadSize, scanFormats, ...
                                       txtScanArgs, nCharsRead, nCharsBeforeData, ~fullFile);
        data = vertcat(data, currData);

        numCharactersForInfo = numCharactersForInfo + info.NumCharactersRead;

        if ~fullFile && (nCharsRead + info.NumCharactersRead < numel(ds.CurrBuffer))
            % If there are still characters not consumed in CurrBuffer, we will read
            % either next time or in the while loop
            ds.NumCharactersReadInChunk = nCharsRead + info.NumCharactersRead;
            ds.CurrSplitInfo.Offset = ds.CurrSplitInfo.Offset + nbytes;
        else
            ds.NumCharactersReadInChunk = 0;
            if hasNext(ds.SplitReader)
                % If there's more data in the split, read them in for fullfilling
                % the ReadSize
                [ds.CurrBuffer, ds.CurrSplitInfo] = getNext(ds.SplitReader);
            else
                % no more data break and read from the next split in the next read
                ds.CurrSplitInfo = [];
                ds.CurrBuffer = '';
                break;
            end
        end
    end
    info.NumCharactersRead = numCharactersForInfo;
end
