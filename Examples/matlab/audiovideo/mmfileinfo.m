function fileInfo = mmfileinfo(filename)
%MMFILEINFO Information about a multimedia file.
%
%   INFO = MMFILEINFO(FILENAME) returns a structure whose fields contain
%   information about FILENAME's audio and/or video data.  FILENAME
%   is a string that specifies the name of the multimedia file.  
%
%   The set of fields for the INFO structure are:
%
%      Filename - A string, indicating the name of the file.
%
%      Path     - A string, indicating the absolute path to the file.
%
%      Duration - The length of the file in seconds.
%
%      Audio    - A structure whose fields contain information about the
%                 audio component of the file.
%      
%      Video    - A structure whose fields contain information about the
%                 video component of the file.
%
%   The set of fields for the Audio structure are:
%
%      Format           - A string, indicating the audio format.
%      
%      NumberOfChannels - The number of audio channels.
%      
%   The set of fields for the Video structure are:
%    
%      Format          - A string, indicating the video format.
%           
%      Height          - The height of the video frame.
%           
%      Width           - The width of the video frame.
%
%   See also AUDIOVIDEO.

% JCS
% Copyright 1984-2017 The MathWorks, Inc.

% Check number of input arguments.
narginchk(1,1);

% Currently, this function supports every platform but Solaris
if (strcmp(computer(),'SOL64'))
    error(message('MATLAB:audiovideo:mmfileinfo:invalidPlatform'));
end

% Make sure that only characters are being passed in.
if ( isempty(filename) || ~ischar(filename))
    error(message('MATLAB:audiovideo:mmfileinfo:FileMustBeString'));
end

try
    filename = multimedia.internal.io.absolutePathForReading( ...
        filename, ...
        'MATLAB:audiovideo:VideoReader:FileNotFound', ...
        'MATLAB:audiovideo:VideoReader:FilePermissionDenied');

    if ispc
        % Call the MEX-function which gets all of the information about the
        % file.
        [filepath, filename, fileext] = fileparts(filename);
        fileInfo = WinMMFileInfo(filepath, [filename fileext]);
    else 
        fileInfo = VideoReaderMMFileInfo(filename);
    end

catch exception
    throw(exception);
end

end

function fileInfo = VideoReaderMMFileInfo(filename)

% open this file using VideoReader
try
    obj = VideoReader( filename );
catch ME
    % Check if exception was generated because no video was found. If so,
    % use the audioinfo function to get the information about the audio
    % stream.
    if strcmp(ME.identifier, 'MATLAB:audiovideo:VideoReader:NoVideo')
        fileInfo = getAudioInfo(filename);
        return;
    else
        throw(ME);
    end
end


fileInfo.Filename = obj.Name;
fileInfo.Path = obj.Path;
fileInfo.Duration = obj.Duration;

if hasAudio(obj)
    fileInfo.Audio.Format = obj.AudioCompression; % unsupported by VideoReader on Windows (for use in mmfileinfo only)
    fileInfo.Audio.NumberOfChannels = obj.NumberOfAudioChannels;    % unsupported by VideoReader on Windows (for use in mmfileinfo only)
else
    fileInfo.Audio.Format = '';
    fileInfo.Audio.NumberOfChannels = [];
end

if hasVideo(obj)
    fileInfo.Video.Format = obj.VideoCompression; % unsupported by VideoReader on Windows (for use in mmfileinfo only)
    fileInfo.Video.Height = obj.Height;
    fileInfo.Video.Width = obj.Width;
else
    fileInfo.Video.Format = '';
    fileInfo.Video.Height = [];
    fileInfo.Video.Width = [];
end

end

function fileInfo = getAudioInfo(filename)
% Helper that uses audioinfo to query information about the audio stream in
% the file

[fpath, fname, fext] = fileparts(filename);
fileInfo.Filename = [fname fext];
fileInfo.Path = fpath;

try
    info = audioinfo(filename);
    fileInfo.Duration = info.Duration;
    fileInfo.Audio.Format = info.CompressionMethod;
    fileInfo.Audio.NumberOfChannels = info.NumChannels;
catch ME      
    fileInfo.Audio.Format = '';
    fileInfo.Audio.NumberOfChannels = [];
end

fileInfo.Video.Format = '';
fileInfo.Video.Height = [];
fileInfo.Video.Width = [];

end
