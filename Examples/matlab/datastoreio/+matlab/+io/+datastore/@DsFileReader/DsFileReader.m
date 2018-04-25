classdef DsFileReader < matlab.io.datastore.internal.HandleUnwantedHideable &...
                        matlab.mixin.Copyable
%DSFILEREADER A file reader object.
%   FR = DsFileReader(FILENAME) returns a DsFileReader created with the
%   filename specified. DsFileReader is used to read data from files
%   represented by a datastore.
%
%   FR = DsFileReader(FILENAME,'TextEncoding',ENCODING) returns a
%   DsFileReader with the filename specified and the TextEncoding
%   specified. By default the TextEncoding for DsFileReader is
%   UTF-8.
%
%   DsFileReader Properties:
%
%       Name         - Name of the file DsFileReader reads from
%       Size         - Size of the file in bytes
%       TextEncoding - Encoding used to interpret bytes from the file as
%                      text
%       Position     - Current byte position in the file
%
%   DsFileReader Methods:
%
%       read         - Reads bytes from the file
%       seek         - Changes position within the file
%       hasdata      - Returns true if there is more data in the file at the
%		       current position
%
%   Example:
%   --------
%       filename = 'airlinesmall.csv';
%       fr = matlab.io.datastore.DsFileReader(filename);
%
%       % seek 299 bytes into the file to get past the variable names line
%       seek(fr,299,'RespectTextEncoding',true);
%
%       if hasdata(fr)
%           % read first 1000 chars
%           d = read(fr,1000,'SizeMethod','OutputSize','OutputType','char');
%       end
%
%   See also matlab.io.Datastore, matlab.io.datastore.Partitionable,
%            matlab.io.datastore.HadoopFileBased,
%            matlab.io.datastore.DsFileSet

%   Copyright 2017 The MathWorks, Inc.

    properties (Dependent, SetAccess = private)
        %NAME Name of the file.
        Name

        %SIZE Size of the file in bytes.
        Size

        %TEXTENCODING Encoding used to decode bytes into text.
        %   TextEncoding is used to decode bytes from the file into text.
        %   The default value is UTF-8.
        TextEncoding

        %POSITION Position in the file in bytes.
        %   Position is initially 0 and will advance with every call to
        %   read. Position can also be modified by calls to seek.
        Position
    end

    properties (Access = private)
        % Internal TextStream object
        Stream
    end

    % Class constants
    properties (Constant, Access = private)
        % Constructor NV Pairs
        TEXT_ENCODING_NV_NAME = 'TextEncoding';
        FILENAME_NAME = 'filename';
        DEFAULT_TEXT_ENCODING = 'UTF-8';
        % Read NV Pairs
        READ_METHOD_NAME = 'read';
        SIZE_NAME = 'size';
        SIZE_MODE_NV_NAME = 'SizeMethod';
        SIZE_MODE_SIZE_IN = 'NumBytes';
        SIZE_MODE_SIZE_OUT = 'OutputSize';
        DEFAULT_SIZE_MODE = matlab.io.datastore.DsFileReader.SIZE_MODE_SIZE_IN;
        OUTPUT_TYPE_NV_NAME = 'OutputType';
        DEFAULT_OUTPUT_TYPE = 'uint8';
        % Seek NV Pairs
        SEEK_METHOD_NAME = 'seek';
        BYTES_NAME = 'bytes';
        RESPECT_TEXT_ENCODING_NV_NAME = 'RespectTextEncoding';
        DEFAULT_RESPECT_TEXT_ENCODING = false;
        ORIGIN_NV_NAME = 'Origin';
        ORIGIN_CURRENT_POSITION = 'currentposition';
        ORIGIN_START_OF_FILE = 'start-of-file';
        ORIGIN_END_OF_FILE = 'end-of-file';
        DEFAULT_ORIGIN = matlab.io.datastore.DsFileReader.ORIGIN_CURRENT_POSITION;
        M_FILENAME = mfilename;
    end

    % Constructor
    methods
        function fr = DsFileReader(varargin)
            inputs = iParseConstructorInputs(varargin{:});
            
            % for string support
            filename = char(inputs.filename);
            encoding = char(inputs.TextEncoding);

            % validate TextEncoding
            try
                encoding = iValidateTextEncoding(encoding);
                % Create a text stream
                fr.Stream = iCreateStream(filename, encoding);
            catch ME
                throw(ME);
            end
        end
    end

    % Getters and Setters
    methods
        % Name
        function filename = get.Name(fr)
            filename = fr.Stream.Filename;
        end

        % Size
        function size = get.Size(fr)
            % The FileSize property of TextStream is a uint64. Converting
            % to double for convenience in MATLAB.
            size = double(fr.Stream.FileSize);
        end

        % TextEncoding
        function encoding = get.TextEncoding(fr)
            encoding = fr.Stream.Encoding;
        end

        % Position
        function position = get.Position(fr)
            try
                position = tell(fr.Stream);
            catch exc
                handleStreamException(fr, exc);
                position = tell(fr.Stream);
            end
        end
    end

    % Public Methods
    methods
        function [A, count] = read(fr, size, varargin)
            %READ Read bytes from the file.
            %   [A,COUNT] = READ(FR,SIZE) read bytes from the file into
            %   A. Size specifies the number of bytes to read from the file
            %   and COUNT is the number of bytes actually read.
            %
            %   [A,COUNT] = READ(__,'OutputType',TYPE) specifying
            %   OutputType determines the type of A. By default, OutputType
            %   is uint8.
            %
            %   [A,COUNT] = READ(__,'SizeMethod',MODE) specifying SizeMethod
            %   changes the meaning of the SIZE input and COUNT output. By
            %   default, SizeMethod is 'NumBytes'. This means SIZE refers to
            %   the number of bytes to read in and COUNT refers to the
            %   number of bytes read in. Specifying 'OutputSize' means that
            %   SIZE is the requested number of elements in A and COUNT is
            %   the actual number of elements in A.
            %
            %   Example:
            %       % read SIZE bytes from the file and interpret them as
            %       % characters
            %       [A,count] = read(fr,SIZE,'OutputType','char');
            %
            %       % read as many bytes from the file as required to fill
            %       % SIZE number of characters
            %       [A,count] = read(fr,SIZE,'SizeMethod','OutputSize','OutputType','char');
            %
            %   See also matlab.io.Datastore, hasdata, matlab.io.datastore.DsFileReader

            try
                inputs = iParseReadInputs(size, varargin{:});
            catch ME
                throw(ME);
            end

            try
                [A, count] = readWithParsedInputs(fr, inputs);
            catch exc
                handleStreamException(fr, exc);
                % Try it one more time, if stream is created or opened successfully.
                [A, count] = readWithParsedInputs(fr, inputs);
            end
        end

        function numbytes = seek(fr, varargin)
            %SEEK Seek to a position in the file.
            %   NUMBYTES = SEEK(FR,BYTES) seeks a number of bytes past the
            %   current position in the file. If BYTES is negative, seek
            %   will move backwards in the file.
            %
            %   NUMBYTES = SEEK(__,'RespectTextEncoding',TF) specifies the
            %   logical true or false to indicate whether seek uses the
            %   TextEncoding property to respect the character boundaries
            %   of multibyte characters. The default value is false.
            %
            %   NUMBYTES = SEEK(__,'Origin',POS) specifies the starting
            %   point of the seek operation. POS can be 'currentposition'
            %   which starts the seek at the current position in the file,
            %   'start-of-file' which starts the seek at position 0 in the
            %   file, or 'end-of-file' which starts the seek at the end of
            %   the file. The default value for 'StartPosition' is
            %   'currentposition'.
            %
            %   See also matlab.io.Datastore, read, matlab.io.datastore.DsFileReader

            try
                inputs = iParseSeekInputs(varargin{:});
            catch ME
                throw(ME);
            end

            try
                numbytes = seekWithParsedInputs(fr, inputs);
            catch exc
                handleStreamException(fr, exc);
                % Try it one more time, if stream is created or opened successfully.
                numbytes = seekWithParsedInputs(fr, inputs);
            end
        end

        function status = hasdata(fr)
            %HASDATA Returns true if more data is available.
            %   Returns a logical scalar indicating the availability of
            %   data. This method should be called before calling read.
            %
            %   See also datastore, read, matlab.io.datastore.DsFileReader

            try
                status = ~eof(fr.Stream);
            catch exc
                handleStreamException(fr, exc);
                % Try it one more time, if stream is created or opened successfully.
                status = ~eof(fr.Stream);
            end
        end
    end

    methods (Access = private)
        function numbytes = seekWithParsedInputs(fr, inputs)
            %SEEKWITHPARSEDINPUTS Seek using the parsed inputs from InputParser

            import matlab.io.datastore.DsFileReader
            origin = inputs.Origin;
            bytes = double(inputs.bytes);
            if bytes < 0 && abs(bytes) > fr.Position
                numbytes = -(fr.Position);
                seek(fr.Stream,0);
            elseif inputs.RespectTextEncoding
                % skipBytes uses the current position as the origin so seek
                % to the appropriate location
                switch origin
                    case DsFileReader.ORIGIN_CURRENT_POSITION
                        startPos = fr.Position;
                    case DsFileReader.ORIGIN_START_OF_FILE
                        fr.Stream.seek(0, -1);
                        startPos = 0;
                    case DsFileReader.ORIGIN_END_OF_FILE
                        fr.Stream.seek(0, 1);
                        startPos = fr.Size;
                end
                % skipBytes is mindful of TextEncoding and may skip more
                % bytes than requested to ensure it ends up at the
                % beginning of a character when possible. If at the end of
                % a file, the method may skip fewer bytes than requested.
                fr.Stream.skipBytes(bytes);
                numbytes = abs(fr.Position - startPos);
            else
                switch origin
                    case DsFileReader.ORIGIN_CURRENT_POSITION
                        originNum = 0;
                        startPos = fr.Position;
                    case DsFileReader.ORIGIN_START_OF_FILE
                        originNum = -1;
                        startPos = 0;
                    case DsFileReader.ORIGIN_END_OF_FILE
                        originNum = 1;
                        startPos = fr.Size;
                end
                % Seek doesn't tell us how many bytes were read so
                % calculate it.
                fr.Stream.seek(bytes, originNum);
                numbytes = abs(fr.Position - startPos);
            end
        end

        function [A, count] = readWithParsedInputs(fr, inputs)
            %READWITHPARSEDINPUTS Read using the parsed inputs from InputParser

            import matlab.io.datastore.DsFileReader
            size = double(inputs.size);
            outputType = inputs.OutputType;

            % Choose a read method based on output type and the size mode
            if strcmp(outputType, 'char')
                switch inputs.SizeMethod
                    case DsFileReader.SIZE_MODE_SIZE_IN
                        % readTextBytes reads a 'size' number of bytes into
                        % char
                        [A, count] = fr.Stream.readTextBytes(size);
                    case DsFileReader.SIZE_MODE_SIZE_OUT
                        % readText reads the number of bytes required to get
                        % 'size' number of char
                        [A, count] = fr.Stream.readText(size);
                end
            else % read bytes into the specified type
                switch inputs.SizeMethod
                    case DsFileReader.SIZE_MODE_SIZE_IN
                        % Read the specified number of bytes and then cast
                        % to the output type
                        [A, count] = fr.Stream.read(size, 'uint8');
                        try
                            A = typecast(A, outputType);
                        catch ME
                            % Back up to our previous position
                            seek(fr, -count);
                            if strcmp(ME.identifier,'MATLAB:typecastc:unsupportedClass')
                                error(message('MATLAB:datastoreio:dsfilereader:invalidOutputType'));
                            elseif strcmp(ME.identifier, 'MATLAB:typecastc:notEnoughInputElements') && ...
                                   count ~= size
                                % We hit the end of the file before we
                                % could get enough bytes to typecast
                                error(message('MATLAB:datastoreio:dsfilereader:ranOutOfBytes',size,outputType));
                            end
                            throwAsCaller(ME);
                        end
                    case DsFileReader.SIZE_MODE_SIZE_OUT
                        % Read however many bytes are required to a size
                        % number of outputType units.
                        [A, count] = fr.Stream.read(size, outputType);
                end
            end
        end

        function handleStreamException(fr, exc)
            %HANDLESTREAMEXCEPTION Handle a stream exception
            % If the exception is about opening the stream, try to create the stream,
            % or open it. If unsuccessful throw the input exception.

            if strcmp(exc.identifier, 'MATLAB:datastoreio:stream:streamOpenError')
                % Try to create the stream, if open has failed before.
                fr.Stream = iCreateStream(fr.Name, fr.TextEncoding);
            elseif strcmp(exc.identifier, 'MATLAB:datastoreio:stream:streamNotOpen')
                % Try to open the stream.
                try
                    fr.Stream.open();
                catch me
                    % Opening a stream does not throw a streamNotOpen exception
                    % so this will not go into infinite recursion
                    handleStreamException(fr, me);
                end
            else
                throw(exc);
            end
        end
    end

    methods (Access = protected)
        function copiedFr = copyElement(fr)
            %COPYELEMENT Implement DsFileReader specific deep copy.
            %   Returns a copied DsFileReader with a deep copy of the
            %   the internal stream object and seeking to the original
            %   DsFileReader's position.

            copiedFr = copyElement@matlab.mixin.Copyable(fr);
            % Copy the internal stream object.
            copiedFr.Stream = copy(fr.Stream);
            % Seek to the original DsFileReader's position.
            copiedFr.Stream.seek(fr.Position);
        end
    end

    methods (Hidden)
        function s = saveobj(fr)
            % Store empty filereader, stream and position
            % in the save struct.
            s.FileReader = fr;
            s.Stream = fr.Stream;
            % Position is not stored in the stream, because it's
            % not a property
            s.Position = fr.Position;
        end
    end

    methods (Static, Hidden)
        function fr = loadobj(s)
            if isstruct(s)
                % objects saved after 17b
                fr = s.FileReader;
                fr.Stream = s.Stream;
                pos = s.Position;
            else
                % objects loaded from 17b.
                fr = s;
                pos = 0;
            end

            if ~isOpen(fr.Stream)
                try
                    fr.Stream.open();
                catch exc
                    % Try to create the stream, if open fails.
                    % Any error, like file not found, will be thrown
                    % as a warning.
                    handleStreamException(fr, exc);
                end
            end
            fr.Stream.seek(pos);
        end
    end
end

% Parser Functions
function inputs = iParseConstructorInputs(varargin)
    % Parse the constructor Name-Value pairs using inputParser
    import matlab.io.datastore.DsFileReader
    persistent inpP;
    if isempty(inpP)
        inpP = inputParser;
        addRequired(inpP, DsFileReader.FILENAME_NAME);
        addParameter(inpP, DsFileReader.TEXT_ENCODING_NV_NAME, DsFileReader.DEFAULT_TEXT_ENCODING);
        inpP.FunctionName = DsFileReader.M_FILENAME;
    end
    parse(inpP, varargin{:});
    inputs = inpP.Results;
end

function inputs = iParseReadInputs(size, varargin)
    % Parse the read Name-Value pairs using inputParser
    import matlab.io.datastore.DsFileReader
    persistent inpP;
    if isempty(inpP)
        inpP = inputParser;
        addParameter(inpP, DsFileReader.SIZE_MODE_NV_NAME, DsFileReader.DEFAULT_SIZE_MODE);
        addParameter(inpP, DsFileReader.OUTPUT_TYPE_NV_NAME, DsFileReader.DEFAULT_OUTPUT_TYPE);
        inpP.FunctionName = DsFileReader.M_FILENAME;
    end
    parse(inpP, varargin{:});
    inputs = inpP.Results;
    inputs.size = iValidateReadSize(size);
    inputs.SizeMethod = iValidateSizeMethod(inputs.SizeMethod);
    inputs.OutputType = iValidateOutputType(inputs.OutputType);
end

function inputs = iParseSeekInputs(varargin)
    % Parse the seek Name-Value pairs using inputParser
    import matlab.io.datastore.DsFileReader
    persistent inpP;
    if isempty(inpP)
        inpP = inputParser;
        addRequired(inpP, DsFileReader.BYTES_NAME);
        addParameter(inpP, DsFileReader.RESPECT_TEXT_ENCODING_NV_NAME, ...
            DsFileReader.DEFAULT_RESPECT_TEXT_ENCODING);
        addParameter(inpP, DsFileReader.ORIGIN_NV_NAME, ...
            DsFileReader.DEFAULT_ORIGIN);
        inpP.FunctionName = DsFileReader.M_FILENAME;
    end
    parse(inpP, varargin{:});
    inputs = inpP.Results;
    inputs.bytes = iValidateBytes(inputs.bytes);
    inputs.RespectTextEncoding = iValidateRespectEncoding(inputs.RespectTextEncoding);
    inputs.Origin = iValidateOrigin(inputs.Origin);
end

% Validation functions
function inputs = iValidateReadSize(readSize)
    % Validate the size NV-pair
    classes = {'numeric'};
    attrs = {'scalar','positive','integer'};
    import matlab.io.datastore.DsFileReader
    try
        validateattributes(readSize, classes, attrs);
        inputs = readSize;
    catch ME
        error(message('MATLAB:datastoreio:dsfilereader:invalidReadSize'));
    end
end

function encoding = iValidateTextEncoding(encoding)
    % Validate the TextEncoding nv-pair to the DsFileReader constructor
    try
        encStats = matlab.io.datastore.internal.encodingStats(encoding);
    catch ME
        error(message('MATLAB:datastoreio:dsfilereader:invalidTextEncoding',encoding));
    end
    encoding = encStats.CanonicalName;
end

function outType = iValidateOutputType(outType)
    % Validate the OutputType nv-pair of read
    import matlab.io.datastore.DsFileReader
    try
        validatestring(outType, {...
            'uint8',...
            'uint16',...
            'uint32',...
            'uint64',...
            'int8',...
            'int16',...
            'int32',...
            'int64',...
            'single',...
            'double',...
            'char'
            },...
            DsFileReader.READ_METHOD_NAME,...
            DsFileReader.OUTPUT_TYPE_NV_NAME);
    catch ME
        error(message('MATLAB:datastoreio:dsfilereader:invalidOutputType'));
    end
end

function mode = iValidateSizeMethod(mode)
    % Validate the SizeMethod nv-pair of read
    import matlab.io.datastore.DsFileReader
    try
        validatestring(mode, {DsFileReader.SIZE_MODE_SIZE_IN,...
            DsFileReader.SIZE_MODE_SIZE_OUT},...
            DsFileReader.READ_METHOD_NAME,...
            DsFileReader.SIZE_MODE_NV_NAME);
    catch ME
        error(message('MATLAB:datastoreio:dsfilereader:invalidSizeMethod'));
    end
end

function bytes = iValidateBytes(bytes)
    classes = {'numeric'};
    attrs = {'scalar','integer'};
    try
        validateattributes(bytes, classes, attrs);
    catch ME
        error(message('MATLAB:datastoreio:dsfilereader:invalidReadSize'));
    end
end

function respectEncoding = iValidateRespectEncoding(respectEncoding)
    errorMsg = 'MATLAB:datastoreio:dsfilereader:invalidRespectEncoding';
    matlab.io.datastore.internal.validators.validateLogicalOption(...
        respectEncoding,errorMsg);
end

function origin = iValidateOrigin(origin)
    % Validate the Origin nv-pair of seek
    import matlab.io.datastore.DsFileReader
    try
        validatestring(origin, {DsFileReader.ORIGIN_CURRENT_POSITION,...
            DsFileReader.ORIGIN_START_OF_FILE,...
            DsFileReader.ORIGIN_END_OF_FILE},...
            DsFileReader.SEEK_METHOD_NAME,...
            DsFileReader.ORIGIN_NV_NAME);
    catch ME
        error(message('MATLAB:datastoreio:dsfilereader:invalidOrigin'));
    end
end

function stream = iCreateStream(fileName, encoding)
    import matlab.io.datastore.internal.filesys.createStream;
    try
        stream = createStream(fileName, 'rt', encoding);
    catch e
        throwAsCaller(e);
    end
end
