classdef TextFileSplitReader < matlab.io.datastore.internal.SplitReader
%TextFileSplitReader   SplitReader for reading text file splits.
%   Allows the user to ensure the reader returns data ending at logical 
%   record boundaries as defined by the end of record (EOR) character 
%   sequence. Once can customize the size of the chunk that is returned by
%   this reader and the EOR sequence. This reader is assigned a split and
%   iterates through the split using the hasSplitData readSplitData
%   paradigm. It keeps doing this until it runs out of data.

%   Copyright 2014-2016 The MathWorks, Inc.

    properties (Access = 'public')
        Split;
        Eor = [];           % the end of record for this reader
        FileEncoding = 'UTF-8';
    end

    properties (Access = 'private', Transient = true)
        SizeRead = 0;       % size currently read from the split
        Stream;             % the stream to use for reading
    end

    properties (Constant = true, Access = 'private')
        DFLT_EOR = '\r\n';  % default end of record
        DEFAULT_FILE_ENCODING = 'UTF-8';
    end
    
    methods
        function set.Split(rdr, split)
            rdr.Split = split;
        end
        
        function set.Eor(rdr, eor)
            import matlab.io.internal.validators.isString;
            import matlab.io.datastore.internal.TextFileSplitReader;
            if ~isString(eor) || (~strcmp(eor, TextFileSplitReader.DFLT_EOR) && numel(sprintf(eor)) ~= 1)
                error(message('MATLAB:datastoreio:textfilesplitreader:invalidStr', ...
                    'RowDelimiter'));
            end
            rdr.Eor = eor;
        end
        
        function set.FileEncoding(rdr, fileEncoding)
            encStats = ... % throws errors for invalid encoding
                  matlab.io.datastore.internal.encodingStats(fileEncoding);
            rdr.FileEncoding = encStats.CanonicalName;
        end
    end
    
    methods (Access = 'public')
        
        function rdr = TextFileSplitReader(eor, fileEncoding)
            % Create a TextFileSplitReader. % default end of record is \r\n
            import matlab.io.datastore.internal.TextFileSplitReader;
            
            if nargin < 2
                fileEncoding = TextFileSplitReader.DEFAULT_FILE_ENCODING;
            end
            
            if nargin < 1
                eor = TextFileSplitReader.DFLT_EOR;
            end
            
            % reader properties must be initialized before use
            rdr.FileEncoding = fileEncoding;
            rdr.Eor = eor;
            rdr.Split = [];
            rdr.Stream = [];
        end
        
        function tf = hasSplitData(rdr)
            % Return logical scalar indicating availability of data
            tf = ~isempty(rdr.Split) && rdr.SizeRead < rdr.Split.Size;
        end
        
        function [data, info] = readSplitData(rdr)
            % Return "data" and "info" read while iterating over the split
            
            % local vars
            split = rdr.Split;
            eorStr = sprintf(rdr.Eor);
            if rdr.SizeRead < split.Size
                remainingSize = split.Size-rdr.SizeRead;
                [splitBody, numBytes] = readTextBytes(rdr.Stream, remainingSize);
                [splitEnd, numEndBytes] = readUpto(rdr.Stream, eorStr);
                data = [splitBody, splitEnd];
            else
                data = '';
                numBytes = 0;
                numEndBytes = 0;
            end

            % populate the info struct
            info = struct('Filename', split.Filename, ...
                          'FileSize', split.FileSize, ...
                          'Offset', split.Offset + rdr.SizeRead, ...
                          'NumCharactersRead', numel(data));

            % update the size read, add numel in splitEnd as we read
            % that many chars, and therefore at least that many bytes
            rdr.SizeRead = rdr.SizeRead + numBytes + numEndBytes;
        end

        function reset(rdr)
            % store the previous SizeRead
            prevSizeRead = rdr.SizeRead;
            
            % Reset the reader to the beginning of the split
            rdr.SizeRead = 0;
            
            try
                % any errors in initializing the stream must restore
                % SizeRead as that determines if a split has data.
                initStream(rdr);
                
                if ~isempty(rdr.Split) && (rdr.Split.Offset ~= 0)
                    % if the split does not start at 0, we must skip up to
                    % its start point, as channels by default are at
                    % position 0
                    rdr.SizeRead = skipBytes(rdr.Stream, rdr.Split.Offset) - ...
                                                          rdr.Split.Offset;
                    % we then skip the first record we see
                    eorStr = sprintf(rdr.Eor);
                    [~,numBytes] = readUpto(rdr.Stream, eorStr);
                    rdr.SizeRead = rdr.SizeRead + numBytes;
                end
            catch ME
                % restore the sizeRead as we do not want to change the
                % sizeRead on a failed reset
                rdr.SizeRead = prevSizeRead;
                
                % throw the pathlookup ID as stream ID has IRI information
                if strcmp(ME.identifier, ...
                    'MATLAB:datastoreio:stream:fileNotFound')
                    error(message('MATLAB:datastoreio:pathlookup:fileNotFound', ...
                                                      rdr.Split.Filename));
                end
                
                throw(ME);
            end
        end
        
        function frac = progress(rdr)
        % Percentage of read completion between 0.0 and 1.0 for the split.
            frac = min(rdr.SizeRead/rdr.Split.Size, 1.0);
        end
        
        function delete(rdr)
        % Delete the reader
            rdr.Stream = [];
        end

    end
    
    methods (Access = 'protected')
        function rdrCopy = copyElement(rdr)
           % make a shallow copy of all properties
           rdrCopy = copyElement@matlab.mixin.Copyable(rdr);
           % unshare the shallow copy to the handle of the stream
           rdrCopy.Stream = [];
        end 
    end
    
    methods (Access = 'private')

        function initStream(rdr)
            import matlab.io.datastore.internal.filesys.createStream;
            
            split = rdr.Split;
            if isempty(split)
                return;
            end

            stream = createStream(split.Filename,'rt', rdr.FileEncoding);

            % get rid of the old ref (self destructing Stream)
            % and take the new ref
            rdr.Stream = stream;
        end
        
    end
end
