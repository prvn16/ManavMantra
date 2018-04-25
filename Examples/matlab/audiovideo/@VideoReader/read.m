function varargout = read(obj, varargin)
%READ Read a video file. 
%   READ will be removed in a future release. Use READFRAME instead.
%
%   VIDEO = READ(OBJ) reads in all video frames from the file associated 
%   with OBJ.  VIDEO is an H x W x B x F matrix where:
%         H is the image frame height
%         W is the image frame width
%         B is the number of bands in the image (e.g. 3 for RGB),
%         F is the number of frames read
%   The class of VIDEO depends on the data in the file. 
%   For example, given a file that contains 8-bit unsigned values 
%   corresponding to three color bands (RGB24), video is an array of 
%   uint8 values.
%
%   VIDEO = READ(OBJ,INDEX) reads only the specified frames. INDEX can be 
%   a single number or a two-element array representing an INDEX range 
%   of the video stream.  Use Inf to represent the last frame of the file.
%
%   For example:
%
%      VIDEO = READ(OBJ, 1);        % first frame only
%      VIDEO = READ(OBJ, [1 10]);   % first 10 frames
%      VIDEO = READ(OBJ, Inf);      % last frame only
%      VIDEO = READ(OBJ, [50 Inf]); % frame 50 thru end
%
%   If an invalid INDEX is specified, MATLAB throws an error.
%
%   VIDEO = READ(___,'native') always returns data in the format specified 
%   by the VideoFormat property, and can include any of the input arguments
%   in previous syntaxes.  See 'Output Formats' section below.
%
%   Output Formats
%   VIDEO is returned in different formats depending upon the usage of the
%   'native' parameter, and the value of the obj.VideoFormat property:
%
%     VIDEO Output Formats (default behavior):
%                             
%       obj.VideoFormat   Data Type   VIDEO Dimensions  Description
%       ---------------   ---------   ----------------  ------------------
%        'RGB24'            uint8         MxNx3xF       RGB24 image
%        'Grayscale'        uint8         MxNx1xF       Grayscale image
%        'Indexed'          uint8         MxNx3xF       RGB24 image
%
%     VIDEO Output Formats (using 'native'):
%
%       obj.VideoFormat   Data Type   VIDEO Dimensions  Description
%       ---------------   ---------   ----------------  ------------------
%        'RGB24'            uint8         MxNx3xF       RGB24 image
%        'Grayscale'        struct        1xF           MATLAB movie*
%        'Indexed'          struct        1xF           MATLAB movie*
%
%     Motion JPEG 2000 VIDEO Output Formats (using default or 'native'):
%                             
%       obj.VideoFormat   Data Type   VIDEO Dimensions  Description
%       ---------------   ---------   ----------------  ------------------
%        'Mono8'            uint8         MxNx1xF       Mono image
%        'Mono8 Signed'     int8          MxNx1xF       Mono signed image
%        'Mono16'           uint16        MxNx1xF       Mono image
%        'Mono16 Signed'    int16         MxNx1xF       Mono signed image
%        'RGB24'            uint8         MxNx3xF       RGB24 image
%        'RGB24 Signed'     int8          MxNx3xF       RGB24 signed image
%        'RGB48'            uint16        MxNx3xF       RGB48 image
%        'RGB48 Signed'     int16         MxNx3xF       RGB48 signed image
%
%     *A MATLAB movie is an array of FRAME structures, each of
%      which contains fields cdata and colormap.
%
%   Example:
%      % Construct a multimedia reader object associated with file 
%      % 'xylophone.mp4'.
%      readerobj = VideoReader('xylophone.mp4');
%
%      % Read in all video frames.
%      vidFrames = read(readerobj);
%
%      % Get the number of frames.
%      numFrames = get(readerobj, 'numberOfFrames');
%
%      % Create a MATLAB movie struct from the video frames.
%      for k = 1 : numFrames
%            mov(k).cdata = vidFrames(:,:,:,k);
%            mov(k).colormap = [];
%      end
%
%      % Create a figure
%      hf = figure; 
%      
%      % Resize figure based on the video's width and height
%      set(hf, 'position', [150 150 readerobj.Width readerobj.Height])
%
%      % Playback movie once at the video's frame rate
%      movie(hf, mov, 1, readerobj.FrameRate);
%
%   See also AUDIOVIDEO, MOVIE, VIDEOREADER, VIDEOREADER/READFRAME, VIDEOREADER/HASFRAME, MMFILEINFO.

%    NCH DTL
%    Copyright 2005-2018 The MathWorks, Inc.

if length(obj) > 1
    error(message('MATLAB:audiovideo:VideoReader:nonscalar'));
end

% ensure that we pass in 1, 2 or 3 arguments only
narginchk(1, 3);

% ensure that we pass out only 1 output argument
nargoutchk(0, 1);

validateattributes(obj, {'VideoReader'}, {}, 'VideoReader.read');

if ~hasVideo(obj)
    varargout{1} = [];
    return;
end

% Verify that the index argument is of numeric type
% Corresponds to the syntax: read(obj)
if nargin == 1 
    videoFrames = readFramesUntilEnd(obj);
    outputFormat = 'default';
    
% Corresponds to the syntax: read(obj, 'native')
elseif nargin == 2 && ischar(varargin{1})
    try
        VideoReader.validateOutputFormat(varargin{1}, 'VideoReader.read');
    catch ME
        throwAsCaller(ME);
    end
    
    videoFrames = readFramesUntilEnd(obj);
    outputFormat = varargin{1};
    
% Corresponds to the syntax: read(obj, index)
elseif nargin == 2 && ~ischar(varargin{1})
    validateattributes( varargin{1}, {'numeric'}, ...
                        {'vector', 'nonnan', 'positive'},...
                        'VideoReader.read', 'index' );
                    
    videoFrames = readFramesInIndex(obj, varargin{1});
    outputFormat = 'default';
    
% Corresponds to the syntax: read(obj, index, 'native')
elseif nargin == 3
    validateattributes( varargin{1}, {'numeric'}, ...
                        {'vector', 'nonnan', 'positive'},...
                        'VideoReader.read', 'index' );
    try
        VideoReader.validateOutputFormat(varargin{2}, 'VideoReader.read');
    catch ME
        throwAsCaller(ME);
    end
    
    videoFrames = readFramesInIndex(obj, varargin{1});
    outputFormat = varargin{2};
end

videoFrames = VideoReader.convertToOutputFormat( videoFrames, ...
                                                 get(obj, 'VideoFormat'), ...
                                                 outputFormat, ...
                                                 get(getImpl(obj), 'Colormap'));

% Video is the output argument.
varargout{1} = videoFrames;

obj.IsFrameBased = true;

end

function videoFrames = readFramesUntilEnd(obj, startIndex)

if obj.IsStreamingBased
    error( message('MATLAB:audiovideo:VideoReader:ReadNotAllowed') );
end

if nargin == 1
    startIndex = 1;
end

% This value is required only to pre-allocate the output matrix and so an
% approximate value is sufficient as the array can be grown or shrunk as
% needed.
numFrames = floor(obj.Duration*obj.FrameRate);
if numFrames == 0
    numFrames = 1;
end

vidHeight = get(obj,'Height');
vidWidth = get(obj, 'Width');
numChannels = obj.getImplValue('NumColorChannels');
outputType = getTypeFromVideoFormat(get(obj, 'VideoFormat'));

numFramesRequested = numFrames - startIndex + 1;
videoFrames = zeros([vidHeight vidWidth numChannels numFramesRequested], outputType);

try 
    % Track the actual number of frames that were read from the file.
    actNumFramesRead = 0;
    if obj.NextFrameIndexToRead == startIndex
        vid = obj.StoredFrame;
    else
        obj.StoredFrame = [];
        try
            vid = readFrameAtPosition(getImpl(obj), startIndex);
        catch ME
            % First reset the object so that next "read" call does not
            % error out
            reset(obj);
            % This check is deferred in order to avoid the penalty of frame
            % counting              
            checkIfIndexOutOfRange(obj, startIndex);
            throwAsCaller(ME);
        end
    end
    actNumFramesRead = actNumFramesRead + 1;

    videoFrames(:,:,:, 1) = vid.Data;

    while hasFrame( getImpl(obj) )
        vid = readNextFrame(getImpl(obj));
        actNumFramesRead = actNumFramesRead + 1;
        obj.NextFrameIndexToRead = obj.NextFrameIndexToRead + 1;
        videoFrames(:,:,:, actNumFramesRead) = vid.Data;
    end
catch ME
    % First reset the object so that next "read" call does not
    % error out
    reset(obj);
    VideoReader.handleImplException(ME);
end

% There is a good chance that the number of frames have been computed by
% the time all the frames have been read from the file.
numFrames = get(obj, 'NumberOfFrames');

if numFrames ~= actNumFramesRead
    videoFrames = videoFrames(:,:,:,1:actNumFramesRead);
end

% Generate a warning if the actual number of frames read is fewer than the
% expected total number of frames.
checkIncompleteRead(obj.VideoReaderImpl, actNumFramesRead, [startIndex numFrames]);
reset(obj);
end

function reset(obj)
% Reset the object to its initial state
obj.StoredFrame = [];
obj.NextFrameIndexToRead = 0;
obj.ReadAheadException = [];
end

function videoFrames = readFramesInIndex(obj, index)

if obj.IsStreamingBased
    error( message('MATLAB:audiovideo:VideoReader:ReadNotAllowed') );
end
% Basic index validation
checkIndex(index); 

try 
    if isscalar(index)
        videoFrames = readSingleFrame(obj, index);
    else
        try
         videoFrames = readFrameSequence(obj, index);
        catch ME
            % This check is deferred in order to avoid the penalty of frame
            % counting
            checkIfIndexOutOfRange(obj, index);
            rethrow(ME);
        end
    end
catch ME
    VideoReader.handleImplException(ME);
end

end

function videoFrame = readSingleFrame(obj, index)

% The last frame is being read
if isinf(index)
    index = obj.NumberOfFrames;
else
    % Basic index validation
    checkIndex(index);
end

try
    videoFrame = readFrameAtIndex(obj, index);
catch ME
     % This check is deferred in order to avoid the penalty of frame
     % counting
    checkIfIndexOutOfRange(obj, index);
    throwAsCaller(ME);
end

end


function videoFrames = readFrameSequence(obj, index)

% Indicates that only one frame is requested
if index(1) == index(2)
    videoFrames = readSingleFrame(obj, index(1));
    return;
end

% Indicates that the entire video is requested
if isequal(index, [1 Inf])
    videoFrames = readFramesUntilEnd(obj);
    return;
end

vidHeight = get(obj,'Height');
vidWidth = get(obj, 'Width');
numChannels = obj.getImplValue('NumColorChannels');
outputType = getTypeFromVideoFormat(get(obj, 'VideoFormat'));

if isinf(index(2))
    videoFrames = readFramesUntilEnd(obj, index(1));
    return;    
end

numFramesRequested = index(2) - index(1) + 1;
videoFrames = zeros([vidHeight vidWidth numChannels numFramesRequested], outputType);

try
    for cnt = index(1):1:index(2)
        videoFrames(:, :, :, cnt - index(1)+1) = readFrameAtIndex(obj, cnt);
    end
catch ME
    if ~strcmp(ME.identifier, 'MATLAB:audiovideo:VideoReader:EndOfFile')
        throwAsCaller(ME);
    end
end
    
actNumFramesRead = cnt - index(1) + 1;
checkIncompleteRead(obj.VideoReaderImpl, actNumFramesRead, index);


end

function videoFrame = readFrameAtIndex(obj, index)

   % If an error was generated when reading ahead, then throw that
   % exception. 
   throwNonEofException(obj);
    
    try
        % If the read index is the next frame, that frame has already been
        % stored and so there is no reason to seek.
        if obj.NextFrameIndexToRead == index 
            videoFrame = obj.StoredFrame.Data;
        else
            videoFrame = readFrameAtPosition(obj.VideoReaderImpl, index);
            videoFrame = videoFrame.Data;
        end
    catch ME
        throwAsCaller(ME);        
    end
    
    try
        % Update the index of the next frame to read
        obj.NextFrameIndexToRead = index + 1;

        % Read ahead one frame
        obj.StoredFrame = readNextFrame(obj.VideoReaderImpl);
    catch ME
        obj.StoredFrame = [];
        obj.NextFrameIndexToRead = 0;
        obj.ReadAheadException = ME;
        % This indicates that all frames have been read and EOF has been
        % reached. The NextFrameIndexToRead tracks the index of the frame
        % that has been cached. However, as no frames have been cached,
        % setting this value to 0.
        if isEofException(obj)
            obj.NextFrameIndexToRead = 0;
        end
    end
end


function checkIndex(index)
% This function does some basic checking on the indices provided - ensures
% first value is less than the second value, and the number of elements in
% index is less than 3. If any value in index is Inf, then we validate it
% later.

    if isscalar(index)
        index = [index index];
    end
    
    if numel(index) > 2 || ( index(1) > index(2) )
        msg = message('MATLAB:audiovideo:VideoReader:invalidFrameRange');
        throw( MException(msg.Identifier, msg.getString()) );
    end

    % If an index is specified as Inf, then the validation will be performed
    % later
    if any( isinf(index) )
        return;
    end
end

function checkIfIndexOutOfRange(obj, index)
% This function checks if the index provided exceeds the total number of
% frames in the video. This is a deferred test since getting the total
% number of frames imposes performance penalty.

    numFrames = obj.NumberOfFrames;
    index(isinf(index)) = numFrames;

    if any(index > numFrames)
        msg = message('MATLAB:audiovideo:VideoReader:invalidFrameIndex');
            
        throw(MException(msg.Identifier, msg.getString()));
    end
end


function type = getTypeFromVideoFormat(videoFormat)
    switch videoFormat
        case {'Mono8 Signed', 'RGB24 Signed'}
            type = 'int8';
        case {'Mono16', 'RGB48'}
            type = 'uint16';
        case {'Mono16 Signed', 'RGB48 Signed'}
            type = 'int16';
        otherwise
            type = 'uint8';
    end
end

function checkIncompleteRead(videoReaderImpl, actNum, index)
    expNum = index(2) - index(1) + 1;
    if actNum < expNum
        % Wait for a brief period to ensure that any errors that might have
        % occurred when reading the frames to be processed. 
        % While not ideal, this code path is utilized for an edge case
        % condition i.e. reading a sequence of frames from a file that
        % encounters an error when decoding frames.
        pause(0.2);
        try
            readNextFrame(videoReaderImpl);
            warning(message('MATLAB:audiovideo:VideoReader:incompleteRead', ...
                index(1), index(1)+actNum-1));
        catch ME
            VideoReader.handleImplException(ME);
        end
    end
end

