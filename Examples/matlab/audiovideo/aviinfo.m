function fileinfo = aviinfo(filename,outputType)
%AVIINFO Information about AVI file.
%   AVIINFO will be removed in a future release. Use VIDEOREADER instead.
%
%   FILEINFO = AVIINFO(FILENAME) returns a structure whose fields contain
%   information about the AVI file. FILENAME is a string that specifies the
%   name of the AVI file.  If FILENAME does not include an extension, then
%   '.avi' will be used.  The file must be in the current working directory
%   or in a directory on the MATLAB path. 
%
%   The set of fields for FILEINFO are:
%   
%   Filename           - A string containing the name of the file.
%   		      
%   FileSize           - An integer indicating the size of the file in bytes.
%   		      
%   FileModDate        - A string containing the modification date of the file.
%   		      
%   NumFrames          - An integer indicating the total number of frames in
%                     	 the movie.
%   		      
%   FramesPerSecond    - An integer indicating the desired frames per second
%                     	 during playback.
%   		      
%   Width              - An integer indicating the width of AVI movie in
%                        pixels.
%   		      
%   Height             - An integer indicating the height of AVI movie in
%                     	 pixels.
%   		      
%   ImageType          - A string indicating the type of image; either
%                     	 'truecolor' for a truecolor (RGB) image, or
%                     	 'indexed', for an indexed image.
%   		      
%   VideoCompression   - A string containing the compressor used to compress 
%                     	 the AVI file.   If the compressor is not Microsoft
%                     	 Video 1, Run-Length Encoding, Cinepak, or Intel
%                     	 Indeo, the four character code is returned.   
%		      
%   Quality            - A number between 0 and 100 indicating the video
%                     	 quality in the AVI file.  Higher quality numbers
%                     	 indicate higher video quality, where lower
%                     	 quality numbers indicate lower video quality.  This
%                     	 value is not always set in AVI files and therefore
%                     	 may be inaccurate.
%
%   NumColormapEntries - The number of colors in the colormap. For a
%                        truecolor image this value is zero.
%   
%   If the AVI file contains an audio stream, the following fields will be
%   set in FILEINFO:
%   
%   AudioFormat      - A string containing the name of the format used to
%                      store the audio data.
%   
%   AudioRate        - An integer indicating the sample rate in Hertz of
%                      the audio stream.
%   
%   NumAudioChannels - An integer indicating the number of audio channels in
%                      the audio stream.
%   
%   See also VIDEOWRITER, VIDEOREADER.

%   Copyright 1984-2013 The MathWorks, Inc.

warning(message('MATLAB:audiovideo:aviinfo:FunctionToBeRemoved')); 

msg = '';
msgID = '';
narginchk(1,2);

if (~ischar(filename))
  error(message('MATLAB:audiovideo:aviinfo:invalidInputType'));
end

[path,name,ext] = fileparts(filename);
if isempty(ext)
  filename = strcat(filename,'.avi');
end

if nargin == 1
  outputType = [];
end

fid = fopen(filename,'r','l');
if fid == -1
  error(message('MATLAB:audiovideo:aviinfo:unableToOpenFile', filename));
else
  filename = fopen(fid);
end

% Find RIFF chunk.
[chunk, msg, msgID] = findchunk(fid,'RIFF');
errorWithFileClose(msgID,msg,fid);

% Read AVI chunk.
[rifftype,msg,msgID] = readfourcc(fid);
errorWithFileClose(msgID,msg,fid);
if ( strcmpi(rifftype,'AVI ') == 0 )
  error(message('MATLAB:audiovideo:aviinfo:invalidAVIFile'));
end

% Find hdrl LIST chunk.
[hdrlsize, msg, msgID] =  findlist(fid,'hdrl');
errorWithFileClose(msgID,msg,fid);

% Find avih chunk.
[chunk,msg,msgID] = findchunk(fid,'avih');
errorWithFileClose(msgID,msg,fid);

fileinfo.Filename = filename;
d = dir(filename);
fileinfo.FileModDate = d.date;
fileinfo.FileSize = d.bytes;

% Read main AVI header.
fileinfo.MainHeader = readAVIHeader(fid);

% Find the video and audio streams.
found = 0; audiofound = 0;
for i = 1:fileinfo.MainHeader.NumStreams
  % Find strl LIST chunk.
  [strlsize,msg,msgID] = findlist(fid,'strl');
  errorWithFileClose(msgID,msg,fid);
  % Read strh chunk.
  [strhchunk,msg,msgID] = findchunk(fid,'strh');
  errorWithFileClose(msgID,msg,fid);
  % Determine stream type.
  streamtype = readfourcc(fid);
  % If it is a video or audio stream, read it.
  if(strcmpi(streamtype,'vids') && (found==0))
    found = 1;
    if ( strhchunk.cksize == 64 )
      strh = read64ByteHeader(fid);
      fileinfo.VideoStreamHeader = strh;
    elseif ( strhchunk.cksize == 56 )
       strh = read56ByteHeader(fid);
       fileinfo.VideoStreamHeader = strh;
    elseif ( strhchunk.cksize == 48 )
      strh = read48ByteHeader(fid);
      fileinfo.VideoStreamHeader = strh;
    else 
      error(message('MATLAB:audiovideo:aviinfo:unknownHeaderSize'));
    end
    
    % Some files have a mismatched number of frames in the MainHeader and
    % VideoStreamHeader.  We should always trust the
    % VideoStreamHeaders number of frames over the MainHeader.TotalFrmes.  
    % However, it is possible that there are files whose
    % MainHeader.TotalFrames is greater than VideoStreamHeader's frames. 
    % So, to support such AVI files, only update the main headers total
    % frames if it is less than the video stream headers frame count.
    if fileinfo.MainHeader.TotalFrames < fileinfo.VideoStreamHeader.Length
        fileinfo.MainHeader.TotalFrames = fileinfo.VideoStreamHeader.Length;
    end
    
    % Read strf chunk.
    [strfvchunk, msg, msgID] = findchunk(fid,'strf');
    errorWithFileClose(msgID,msg,fid);
    
    % Read the data header.
    strfv = readBitmapHeader(fid, strfvchunk.cksize);
    
    % AVIINFO returns info only about the first video stream because
    % VIDEOREADER will only read the first video stream.
  elseif ( strcmpi(streamtype,'auds') && (audiofound == 0))
    audiofound = 1;
    if ( strhchunk.cksize == 64 )
      strh = read64ByteHeader(fid);
    elseif ( strhchunk.cksize == 56 )
      strh = read56ByteHeader(fid);
    else 
      msgID = 'MATLAB:audiovideo:aviinfo:unknownAudioStreamHeader';
      msg = getString(message(msgID));
    end
        
    if isempty(msg)
      % Read strf chunk.
      [strfachunk, msg, msgID] = findchunk(fid,'strf');
      errorWithFileClose(msgID,msg,fid);
      
      % Read the data header.
      strfa = readAudioFormat(fid, strfachunk.cksize);
      fileinfo.AudioStreamHeader = strfa;
    else
      warning(msgID, msg)
      if fseek(fid,strhchunk.cksize-4,0) == -1
        errorWithFileClose('MATLAB:audiovideo:aviinfo:invalidFileChunkSize',getString(message('MATLAB:audiovideo:aviinfo:invalidFileChunkSize')),fid);
      end
    end
  else
    % Seek to end of strl list minus the amount we read.
    if ( fseek(fid,strlsize - 16,0) == -1 )  
        error(message('MATLAB:audiovideo:aviinfo:invalidFileChunkSize'));
    end
  end
end
  
if (found == 0)
  errorWithFileClose('MATLAB:audiovideo:aviinfo:noVideoStreamFound',getString(message('MATLAB:audiovideo:aviinfo:noVideoStreamFound')),fid);
end

strfv.NumColormapEntries = (strfvchunk.cksize - strfv.BitmapHeaderSize)/4;

% 8-bit grayscale
% 24-bit truecolor
% 8-bit indexed
if strfv.NumColorsUsed > 0
  strfv.ImageType = 'indexed';
else
  if strfv.BitDepth > 8
    strfv.ImageType = 'truecolor';
    strfv.ImageType = 'truecolor';
  else
    strfv.ImageType = 'grayscale';
  end
end

fileinfo.VideoFrameHeader = strfv;

fileinfo = formulateOutput(fileinfo,outputType);
fclose(fid);
return;

% ------------------------------------------------------------------------
function outinfo = formulateOutput(info,outputType)
if isempty(outputType)
  outputType = 'Normal';
end

if strcmpi(outputType,'Normal');
  outinfo.Filename = info.Filename;
  outinfo.FileSize = info.FileSize;
  outinfo.FileModDate = info.FileModDate;
  outinfo.NumFrames = info.MainHeader.TotalFrames;
  outinfo.FramesPerSecond = info.VideoStreamHeader.Rate/info.VideoStreamHeader.Scale;
  outinfo.Width = info.VideoFrameHeader.Width;
  outinfo.Height = abs(info.VideoFrameHeader.Height);
  outinfo.ImageType = info.VideoFrameHeader.ImageType;
  outinfo.VideoCompression = info.VideoFrameHeader.CompressionType;
  outinfo.Quality = info.VideoStreamHeader.Quality/100;
  outinfo.NumColormapEntries = info.VideoFrameHeader.NumColormapEntries;
  if isfield(info,'AudioStreamHeader')
    outinfo.AudioFormat = info.AudioStreamHeader.Format;
    outinfo.AudioRate = info.AudioStreamHeader.SampleRate;
    outinfo.NumAudioChannels = info.AudioStreamHeader.NumChannels;
  end
elseif strcmpi(outputType,'robust')
  outinfo = info;  
end
return;

% ------------------------------------------------------------------------
function avih = readAVIHeader(fid)
	
msg = getString(message('MATLAB:audiovideo:aviinfo:unableToReadAVIHeader'));

% Read the micro-seconds per frame field and convert to fps.
[MicroSecPerFrame, count] = freadWithCheck(fid,1,'uint32',msg);
avih.FramesPerSecond = 1/(MicroSecPerFrame*10^-6);

% Read MaxBytePerSec.
avih.MaxBytePerSec =  freadWithCheck(fid,1,'uint32',msg);

% Read Reserved.
reserved =  freadWithCheck(fid,1,'uint32',msg);

% Read Flags.
flags =  freadWithCheck(fid,1,'uint32',msg);
flagbits = find(bitget(flags,1:32));
for i = 1:length(flagbits)
  switch flagbits(i)
   case 5
    avih.HasIndex = 'True';
   case 6
    avih.MustUseIndex = 'True';
   case 9
    avih.IsInterleaved = 'True';
   case 12
    avi.TrustCKType = 'True';
   case 17
    avih.WasCaptureFile = 'True';
   case 18
    avih.Copywrited = 'True';
  end
end

% Read TotalFrames.
avih.TotalFrames = freadWithCheck(fid,1,'uint32',msg);

% Read InitialFrames.
InitialFrames =  freadWithCheck(fid,1,'uint32',msg);

% Read NumStreams.
avih.NumStreams = freadWithCheck(fid,1,'uint32',msg);

% Read SuggestedBufferSize.
SuggestedBufferSize =  freadWithCheck(fid,1,'uint32',msg);

% Read Width.
avih.Width = freadWithCheck(fid,1,'uint32',msg);

% Read Height.
height = freadWithCheck(fid,1,'int32',msg);
% Handle the case of an AVI that's written top down
if height < 0
    height = -height;
end
avih.Height = height;

% Read Scale.
avih.Scale = freadWithCheck(fid,1,'uint32',msg);

% Read Rate.
avih.Rate = freadWithCheck(fid,1,'uint32',msg);

% Read Start.
start =  freadWithCheck(fid,1,'uint32',msg);

% Read Length, (value is typically not set properly).
len =  freadWithCheck(fid,1,'uint32',msg);
return;

% ------------------------------------------------------------------------
function strh = read64ByteHeader(fid)
% Purpose:  To read a stream header.
% Inputs:   A file identifier at the position 
%           of the stream header.
%
% Outputs:  A structure with fields corresponding 
%           pertinent information in the header.

msg = getString(message('MATLAB:audiovideo:aviinfo:unableToReadStreamHeader'));

% Read Compression handler.
[handler, count] = freadWithCheck(fid,4,'uchar',msg);
strh.Compression = char(handler)';

% Read Flags.
flags =  freadWithCheck(fid,1,'uint32',msg);
flagbits = find(bitget(flags,1:32));
for i = 1:length(flagbits)
  switch flagbits(i)
   case 17
    strh.PaletteChanges = 'True';
   case 1
    strh.DataRendering = 'Manual';
  end
end

% Read Reserved.
Reserved =  freadWithCheck(fid,1,'uint32',msg);

% Read InitialFrames.
strh.InitialFrames =  freadWithCheck(fid,1,'uint32',msg);

% Read Scale.
strh.Scale = freadWithCheck(fid,1,'uint32',msg);

% Read Rate.
strh.Rate  = freadWithCheck(fid,1,'uint32',msg);

% Read Start.
strh.StartTime = freadWithCheck(fid,1,'uint32',msg);

% Read Length (stream length units are in frames or seconds).
strh.Length = freadWithCheck(fid,1,'uint32',msg);

% Read SuggestedBufferSize.
strh.SuggestedBufferSize = freadWithCheck(fid,1,'uint32',msg);

% Read Quality.
strh.Quality = freadWithCheck(fid,1,'uint32',msg);

% Read SampleSize.
strh.SampleSize =  freadWithCheck(fid,1,'uint32',msg);

% Read Rect.
rect = freadWithCheck(fid,4,'uint32',msg);
return;

% ------------------------------------------------------------------------
function strh = read56ByteHeader(fid)

msg = getString(message('MATLAB:audiovideo:aviinfo:unableToReadStreamHeader'));
compression = freadWithCheck(fid,4,'char',msg);
strh.CompressionHandler = char(compression)';

flags = freadWithCheck(fid,1,'uint32',msg);
flagbits = find(bitget(flags,1:32));
for i = 1:length(flagbits)
  switch flagbits(i)
   case 17
    strh.PaletteChanges = 'True';
   case 1
    strh.DataRendering = 'Manual';
  end
end

strh.Reserved = freadWithCheck(fid,1,'uint32',msg);  
strh.InitialFrames = freadWithCheck(fid,1,'uint32',msg);
strh.Scale = freadWithCheck(fid,1,'uint32',msg);    
strh.Rate = freadWithCheck(fid,1,'uint32',msg);     
strh.Start = freadWithCheck(fid,1,'uint32',msg);     
strh.Length = freadWithCheck(fid,1,'uint32',msg);   
strh.SuggestedBufferSize = freadWithCheck(fid,1,'uint32',msg);
strh.Quality = freadWithCheck(fid,1,'uint32',msg);   
strh.SampleSize = freadWithCheck(fid,1,'uint32',msg);

% Read Rect.
Rect = freadWithCheck(fid,4,'uint16',msg);
return;

% ------------------------------------------------------------------------
function strh = read48ByteHeader(fid)
msg = getString(message('MATLAB:audiovideo:aviinfo:unableToReadStreamHeader'));
% Read fccHandler.
compression = freadWithCheck(fid,4,'char',msg);
strh.CompressionHandler = char(compression)';

flags = freadWithCheck(fid,1,'uint32',msg);
flagbits = find(bitget(flags,1:32));
for i = 1:length(flagbits)
  switch flagbits(i)
   case 17
    strh.PaletteChanges = 'True';
   case 1
    strh.DataRendering = 'Manual';
  end
end

strh.Reserved = freadWithCheck(fid,1,'uint32',msg);  
strh.InitialFrames = freadWithCheck(fid,1,'uint32',msg);
strh.Scale = freadWithCheck(fid,1,'uint32',msg);    
strh.Rate = freadWithCheck(fid,1,'uint32',msg);     
strh.Start = freadWithCheck(fid,1,'uint32',msg);     
strh.Length = freadWithCheck(fid,1,'uint32',msg);   
strh.SuggestedBufferSize = freadWithCheck(fid,1,'uint32',msg);
strh.Quality = freadWithCheck(fid,1,'uint32',msg);   
strh.SampleSize = freadWithCheck(fid,1,'uint32',msg);
return;

% ------------------------------------------------------------------------
function strf = readBitmapHeader(fid, chunksize)
% Purpose: To read the BITMAPINFO header information.

Compression = '';
msg = getString(message('MATLAB:audiovideo:aviinfo:unableToReadBITMAPINFOHEADER'));

% Get the starting file position for this header.
fPosHeaderStart = ftell(fid);
if (fPosHeaderStart == -1)
  error(message('MATLAB:audiovideo:aviinfo:invalidFileChunkSize'));
end

% Read header size.
strf.BitmapHeaderSize = freadWithCheck(fid,1,'uint32',msg);

% Read Width.
strf.Width = freadWithCheck(fid,1,'int32',msg);

% Read Height.
strf.Height = freadWithCheck(fid,1,'int32',msg);

% Read Planes.
strf.Planes = freadWithCheck(fid,1,'uint16',msg);

% Read BitCount.
strf.BitDepth = freadWithCheck(fid,1,'uint16',msg);

% Read Compression.
compress = freadWithCheck(fid,1,'uint32',msg);
switch compress
 case 0
  Compression = 'none';
 case 1
  Compression = '8-bit RLE';
 case 2
  Compression = '4-bit RLE';
 case 3
  Compression = 'bitfields';
end

if isempty(Compression)
  code = getfourcc(compress);
  switch lower(code)
   case 'none'
    Compression = 'None';
   case 'rgb '
    Compression = 'None';
   case 'raw '
    Compression = 'None';  
   case '    '
    Compression = 'None';
   case 'rle '
    Compression = 'RLE';
   case 'cvid'
    Compression = 'Cinepak';
   case 'iv32'
    Compression = 'Indeo3';
   case 'iv50'
    Compression = 'Indeo5';
   case 'msvc'
    Compression = 'MSVC';
   case 'cram'
    Compression = 'MSVC';
   otherwise
    Compression = code;
  end
end

strf.CompressionType = Compression;

strf.Bitmapsize = freadWithCheck(fid,1,'uint32',msg);

strf.HorzResoltion = freadWithCheck(fid,1,'uint32',msg);

strf.VertResolution = freadWithCheck(fid,1,'uint32',msg);

strf.NumColorsUsed = freadWithCheck(fid,1,'uint32',msg);

strf.NumImportantColors = freadWithCheck(fid,1,'uint32',msg);

% Get the current file position.
fPosHeader = ftell(fid);
if (fPosHeader == -1)
  error(message('MATLAB:audiovideo:aviinfo:invalidFileChunkSize'));
end

% Calculate the remaining bytes in this header.
headerBytesRead = fPosHeader - fPosHeaderStart;
headerBytesRemaining = chunksize - headerBytesRead;

% Skip over the remainder of the header.
if headerBytesRemaining > 0
    if (fseek(fid, headerBytesRemaining, 0) == -1 )  
	  error(message('MATLAB:audiovideo:aviinfo:invalidFileChunkSize'));
    end
end
return

% ------------------------------------------------------------------------
function strf = readAudioFormat(fid, chunksize)
% Read WAV format chunk information.

msg = getString(message('MATLAB:audiovideo:aviinfo:unableToReadAudioStreamHeader'));
% Read format tag.
formatTag = freadWithCheck(fid,1,'uint16',msg);

% Complete list of formats can be found in Microsoft Platform SDK header
% file "MMReg.h" or in MSDN Library (search for "registered wave formats").
switch formatTag
 case  1
  strf.Format = 'PCM';
 case 2
  strf.Format = 'Microsoft ADPCM';
 case 6
  strf.Format = 'CCITT a-law';
 case 7
  strf.Format = 'CCITT mu-law';
 case 17
  strf.Format = 'IMA ADPCM';   
 case 34
  strf.Format = 'DSP Group TrueSpeech TM';
 case 49
  strf.Format = 'GSM 6.10';
 case 50
  strf.Format = 'MSN Audio';
 otherwise
  strf.Format = ['Format # 0x' dec2hex(formatTag)];
end

% Read number of channels.
strf.NumChannels = freadWithCheck(fid,1,'uint16',msg);

% Read samples per second.
strf.SampleRate = freadWithCheck(fid,1,'uint32',msg);

% Read buffer estimation.
avgBytesPerSec = freadWithCheck(fid,1,'uint32',msg);

% Read block size of data.
blockAlign = freadWithCheck(fid,1,'uint16',msg);

% If this strf chunk is larger than 14 bytes, then
% it uses the newer extended wave format.  Read in
% the extra information.
if chunksize > 14
  % Read bits per sample.
  bitsPerSample = freadWithCheck(fid,1,'uint16',msg);
  % Non-PCM formats have additional header information.
  if chunksize > 16
   % Read the size (in bytes) of the additional information.
   size = freadWithCheck(fid,1,'uint16',msg);
    if size > 0
     % Skip over extra unneeded bytes based on the above size.
     if (fseek(fid, size, 0) == -1 )
      error(message('MATLAB:audiovideo:aviinfo:invalidFileChunkSize'));
     end
    end
  end
end
return

% ------------------------------------------------------------------------
function errorWithFileClose(msgID,msg,fid)
% Close open file the error.
if ~isempty(msgID)
  fclose(fid);
  error(msgID,msg);
end
return;

% ------------------------------------------------------------------------
function [value,count] = freadWithCheck(fid,size,precision,msgID,msg)
% A wrapper around FREAD to make sure the correct amount of data was read.
[value, count] = fread(fid,size,precision);
if count ~= size
  errorWithFileClose(msgID,msg,fid);
end
return;
