classdef WholeFileCustomReadSplitReader < matlab.io.datastore.splitreader.SplitReader
%WHOLEFILECUSTOMREADSPLITREADER SplitReader that reads files with a custom read function.
%
% See also - matlab.io.datastore.WholeFileCustomReadDatastore

%   Copyright 2015-2016 The MathWorks, Inc.

    properties (Hidden)
        % Split to read
        Split;
        % Read function
        ReadFcn;
        % Boolean to indicate if reading is complete
        ReadingDone = false;
    end

    properties (Access = protected, Transient)
        % Info struct for this Split.
        Info;
        % Local filename.
        LocalFilename;
        % Is local temporary copy for remote file created.
        LocalCopyCreated = false;
    end

    methods (Access = protected)
        function copyFileToLocal(rdr)
            if rdr.LocalCopyCreated
                return;
            end
            basePath = tempname;
            while (true)
                [status, message, messageID] = mkdir(basePath);
                if ~status
                    error(messageID, message);
                elseif isempty(messageID)
                    break;
                end
                basePath = tempname;
            end
            [~, name, ext] = fileparts(rdr.Split.Filename);
            rdr.LocalFilename = fullfile(basePath, [name ext]);
            % Self open, Self closing stream!
            stream = matlab.io.datastore.internal.filesys.createStream(rdr.Split.Filename, 'r');
            fileID = fopen(rdr.LocalFilename, 'w');
            c = onCleanup(@()fclose(fileID));
            uint8Values = read(stream, rdr.Split.FileSize, 'uint8');
            fwrite(fileID, uint8Values);
            rdr.LocalCopyCreated = true;
        end

        function deleteIfLocalCopy(rdr)
            if ~rdr.LocalCopyCreated
                return;
            end
            localTempDir = fileparts(rdr.LocalFilename);
            if exist(localTempDir, 'dir')
                rmdir(localTempDir, 's');
            end
            rdr.LocalCopyCreated = false;
        end

        function createLocalCopy(rdr)
            deleteIfLocalCopy(rdr);
            if matlab.io.datastore.internal.isIRI(rdr.Split.Filename)
                copyFileToLocal(rdr);
            else
                rdr.LocalFilename = rdr.Split.Filename;
            end
        end
        function copiedObj = copyElement(obj)
            % Shallow copy
            copiedObj = copyElement@matlab.mixin.Copyable(obj);
            % Need a different copy to be created and deleted.
            copiedObj.LocalCopyCreated = false;
            copiedObj.ReadingDone = false;
        end
    end
    methods (Hidden)

        function pctg = progress(rdr)
            % Percentage of read completion between 0.0 and 1.0 for the split.
            pctg = double(rdr.ReadingDone);
        end

        function tf = hasNext(rdr)
            % Return logical scalar indicating availability of data
            tf = ~rdr.ReadingDone;
        end

        function [data, info] = getNext(rdr)
            % Return data and info as appropriate for the datastore
            createLocalCopy(rdr);
            try
                data = rdr.ReadFcn(rdr.LocalFilename);
            catch e
                iErrorOnReadFcn(e, rdr.ReadFcn, rdr.Split.Filename);
            end
            info = rdr.Info;
            rdr.ReadingDone = true;
            deleteIfLocalCopy(rdr);
        end

        function reset(rdr)
            % Reset the reader to the beginning of the split
            if isempty(rdr.Split)
                return;
            end
            % The checks for file existence is not needed (In case,
            % the file is deleted just before reading). We let the read
            % error for full file datastores.

            % initialize the info struct to be returned by readSplitData
            rdr.Info = struct('Filename', rdr.Split.Filename, ...
                'FileSize', rdr.Split.FileSize);
            rdr.ReadingDone = false;
        end

        function delete(rdr)
            % Delete if there's a local copy, probably while erroring at
            % getNext(rdr).
            deleteIfLocalCopy(rdr);
        end
    end
end

function iErrorOnReadFcn(e, readFcn, filename)
    funcStr = func2str(readFcn);
    if ~isempty(funcStr) && ~isequal(funcStr(1), '@')
        funcStr = ['@', funcStr];
    end
    % if the first element in the error stack is getNext(), this means
    % the nargout of readFcn is not at least 1.
    if strcmp( e.identifier, 'MATLAB:TooManyOutputs' ) && ~isempty(e.stack)
        stckName = e.stack(1).name;
        if isempty(e.stack(1).file) && numel(e.stack) > 1
            % Grab the second element name, if the first element's file
            % is empty; this is the case for anonymous functions.
            stckName = e.stack(2).name;
        end
        if strcmp(stckName, [mfilename, '.getNext'])
            msg = message('MATLAB:datastoreio:customreaddatastore:noOutputReadFcn', funcStr);
            err = matlab.io.datastore.exceptions.CustomReadException(e, 'MATLAB:datastoreio:customreaddatastore:noOutputReadFcn', '%s', msg.getString());
            throw(err);
        end
    end
    % Get the error message with the whole stack
    s = getReport(e);
    % Find the start of the stack for getNext()
    idx = strfind(s, mfilename);
    % Take the first match
    idx = idx(1);
    idx = regexp(s(1:idx), '\n');
    % Take the last new line index
    idx = idx(end);
    % Remove all stack beneath getNext()
    s = strtrim(s(1:idx));
    if ~isempty(s)
        msg = message('MATLAB:datastoreio:customreaddatastore:readFcnError', funcStr, filename, s);
        err = matlab.io.datastore.exceptions.CustomReadException(e, 'MATLAB:datastoreio:customreaddatastore:readFcnError', '%s', msg.getString());
        throw(err);
    end
    throw(e);
end
