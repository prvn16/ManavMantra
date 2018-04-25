classdef TextFileSplitReader < matlab.io.datastore.splitreader.SplitReader
%TextFileSplitReader   SplitReader for reading text file splits.
%   Allows the user to ensure the reader returns data ending at logical 
%   record boundaries as defined by the end of record (EOR) character 
%   sequence. Once can customize the size of the chunk that is returned by
%   this reader and the EOR sequence. This reader is assigned a split and
%   iterates through the split using the hasNext and getNext
%   paradigm. It keeps doing this until it runs out of data.

%   Copyright 2015 The MathWorks, Inc.

    properties
        Split; 
    end
    
    properties (Transient, Access = 'private')
        SizeRead = 0;       % size currently read from the split
        Stream;             % the stream to use for reading
    end
    
    properties (Transient)
        FileEncoding;       % encoding to use
        EOR;                % end of record to use
    end

    properties (Constant, Access = private)
        MAXIMUM_SIZE_TO_READ = 32*1024*1024; % 32MB
    end

    methods 
        function set.EOR(rdr, eor)
            rdr.EOR = sprintf(eor);
        end
    end
    
    methods        
        function rdr = TextFileSplitReader()
            % split property must be initialized before use
            rdr.Split = [];
            rdr.Stream = [];
        end
        
        function tf = hasNext(rdr)
            % Return logical scalar indicating availability of data
            tf = ~isempty(rdr.Split) && rdr.SizeRead < rdr.Split.Size;
        end
        
        function [data, info] = getNext(rdr)
            % Return "data" and "info" read while iterating over the split
            
            % local vars
            split = rdr.Split;
            if rdr.SizeRead < split.Size
                import matlab.io.datastore.splitreader.TextFileSplitReader;
                % Read the minimum of MAXIMUM_SIZE_TO_READ or the remaining
                % amount of bytes left in the split.
                bytesToRead = min(TextFileSplitReader.MAXIMUM_SIZE_TO_READ,...
                                    split.Size-rdr.SizeRead);
                [charBody, numBytes] = readTextBytes(rdr.Stream, bytesToRead);
                [charEnd, numEndBytes] = readUpto(rdr.Stream, rdr.EOR);
                data = [charBody, charEnd];
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
            try
                % any errors in initializing the stream must restore
                % SizeRead as that determines if a split has data.
                initStream(rdr);
                
                rdr.SizeRead = 0;
                
                if ~isempty(rdr.Split) && (rdr.Split.Offset ~= 0)
                    % if the split does not start at 0, we must skip up to
                    % its start point, as channels by default are at
                    % position 0
                    rdr.SizeRead = skipBytes(rdr.Stream, rdr.Split.Offset) - ...
                                                          rdr.Split.Offset;
                    % we then skip the first record we see
                    [~,numBytes] = readUpto(rdr.Stream, rdr.EOR);
                    rdr.SizeRead = rdr.SizeRead + numBytes;
                end
            catch ME                
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
           if ~isempty(rdrCopy.Split)
               rdrCopy.initStream();
               rdrCopy.Stream.seek(rdrCopy.Split.Offset + rdrCopy.SizeRead);
           end
        end 
    end
    
    methods (Access = 'private')

        function initStream(rdr)
            import matlab.io.datastore.internal.filesys.createStream;
            
            split = rdr.Split;
            if isempty(split)
                return;
            end

            rdr.Stream = createStream(split.Filename,'rt', rdr.FileEncoding);
        end
        
    end
end
