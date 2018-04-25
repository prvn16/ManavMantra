classdef (Hidden) ReduceTextKVSerializer < matlab.mapreduce.internal.AbstractKVSerializer
%REDUCETEXTKVSERIALIZER A text serializer for reducer's keys and values.
%   ReduceTextKVSerializer Methods:
%   serialize - Serialize given key-value pairs to a text file on disk.
%
%   See also datastore, mapreduce.

%   Copyright 2014 The MathWorks, Inc.

    properties (Access = private)
        % Pathname to a writable text file.
        OutputTextFile;
        % Either '\r\n' in pc or '\n' in unix.
        Crlf;
        % To check if the output file is written
        WrittenToText;
    end

    methods (Access = private) 
        function writeToTextfile(rkvsr, keys, values)
            [fh, errmsg] = fopen(rkvsr.OutputTextFile, 'a', 'n', 'UTF-8');
            if fh < 3 || ~isempty(errmsg)
                matlab.mapreduce.internal.checkFolderExistence(fileparts(rkvsr.OutputTextFile));
                error(message(...
                    'MATLAB:mapreduceio:reducetextkvserializer:nonOpenableTextFile', ...
                    rkvsr.OutputTextFile, errmsg));
            end
            c = onCleanup(@() fclose(fh));
            % If both keys and values are numeric, bruteforce write and
            % return.
            if isnumeric(keys) && isnumeric(values)
                fprintf(fh, ['%d\t%d',rkvsr.Crlf], [keys'; values']);                
                rkvsr.WrittenToText = true;
                return;
            end
            % At this point, keys and values are either numeric vectors or
            % cell array of strings.
            numK = isnumeric(keys);
            numV = isnumeric(values);
            for i = 1:numel(keys)
                if numK
                    fprintf(fh, '%d', keys(i));
                else
                    fprintf(fh, '%s', keys{i});
                end
                fprintf(fh, '\t');
                if numV
                    fprintf(fh, '%d', values(i));
                else
                    fprintf(fh, '%s', values{i});
                end
                fprintf(fh, rkvsr.Crlf);
            end
            rkvsr.WrittenToText = true;
        end
    end

    properties (Constant = true, Access = private)
        DEFAULT_FLUSH_LIMIT = 10 * 1024 * 1024; % 10 MB
        FILE_EXTENSION = '.txt';
        LF_CHAR = '\n';
        CR_LF_CHAR = '\r\n';
        FILEPREFIX_SEPARATOR = '_';
    end
    
    methods (Hidden = true)
        function rkvsr = ReduceTextKVSerializer(prefix, folder, suffix)
            import matlab.mapreduce.internal.ReduceTextKVSerializer;
            rkvsr.OutputTextFile = fullfile(folder, [prefix, ...
                ReduceTextKVSerializer.FILEPREFIX_SEPARATOR,...
                '1',...
                ReduceTextKVSerializer.FILEPREFIX_SEPARATOR,...
                suffix, ...
                ReduceTextKVSerializer.FILE_EXTENSION]);
            rkvsr.Crlf = ReduceTextKVSerializer.LF_CHAR;
            if ispc
                rkvsr.Crlf = ReduceTextKVSerializer.CR_LF_CHAR;
            end
            rkvsr.WrittenToText = false;
        end

        function tf = serialize(rkvsr, keys, values, bytesUsed, varargin)
        %serialize(kvsr, keys, values, varargin)
        %   Serialize given key-value pairs to a text file on disk.
            tf = false;
            if bytesUsed > matlab.mapreduce.internal.ReduceTextKVSerializer.DEFAULT_FLUSH_LIMIT
                if nargin > 4
                    sizeToSerialize = varargin{1};
                    keys = keys(1:sizeToSerialize);
                    values = values(1:sizeToSerialize);
                end
                rkvsr.writeToTextfile(keys, values);
                tf = true;
            end
        end

        function outputds = constructDatastore(rkvsr)
            outFile = rkvsr.OutputTextFile;
            if ~rkvsr.WrittenToText
                outFile = {};
            end
            outputds = matlab.mapreduce.internal.createTextDSWithKeyValueVarNames(outFile);
        end
    end
end % classdef end
