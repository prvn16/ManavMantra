function info = audioinfo(filename)
%audioinfo Information about an audio file.
%   INFO = AUDIOINFO(FILENAME) returns a structure whose fields contain
%   information about an audio file. FILENAME is a string that specifies
%   the name of the audio file. FILENAME must be in the current directory,
%   in a directory on the MATLAB path, or a full path to a file. 
%
%   The set of fields in INFO depends on the individual file and
%   its format.  However, the first nine fields are always the
%   same. These common fields are:
%
%   'Filename'          A string containing the name of the file
%   'CompressionMethod' Method of audio compression in the file
%   'NumChannels'       Number of audio channels in the file.
%   'SampleRate'        The sample rate (in Hertz) of the data in the file.
%   'TotalSamples'      Total number of audio samples in the file.
%   'Duration'          Total duration of the audio in the file, in seconds.
%   'Title'             String representing the value of the Title tag
%                       present in the file. Value is empty if tag is not
%                       present.
%   'Comment'           String representing the value of the Comment tag
%                       present in the file. Value is empty if tag is not
%                       present. 
%   'Artist'            String representing the value of the Artist or
%                       Author tag present in the file. Value is empty if
%                       tag not present.
%
%   Format specific fields areas follows:
%
%   'BitsPerSample'     Number of bits per sample in the audio file.  
%                       Only supported for WAVE (.wav) and FLAC (.flac)
%                       files. Valid values are 8, 16, 24, 32 or 64.
%
%   'BitRate'           Number of kilobits per second (kbps) used for
%                       compressed audio files. In general, the larger the
%                       BitRate, the higher the compressed audio quality.
%                       Only supported for MP3 (.mp3) and MPEG-4 Audio
%                       (.m4a, .mp4) files. 
%
%   See also AUDIOREAD, AUDIOWRITE

%   Copyright 2012-2016 The MathWorks, Inc.

% Parse input arguments:
narginchk(1,1);

% Expand the path, using the matlab path
filename = multimedia.internal.io.absolutePathForReading(...
    filename, ...
    'MATLAB:audiovideo:audioinfo:fileNotFound', ...
    'MATLAB:audiovideo:audioinfo:filePermissionDenied');

errorIfTextFormat(filename);

import multimedia.internal.audio.file.PluginManager;

try
    readPlugin = PluginManager.getInstance.getPluginForRead(filename);
catch exception
    % The exception has been fully formed. Only the prefix has to be
    % replaced.
    exception = PluginManager.replacePluginExceptionPrefix(exception, 'MATLAB:audiovideo:audioinfo');
    
    throw(exception);
end

try
    options.Filename = filename;
    
    % Create Channel object and give it
    channel = asyncio.Channel( ...
        readPlugin,...
        PluginManager.getInstance.MLConverter,...
        options, [0, 0]);
    
    info.Filename = filename;
    info.CompressionMethod = channel.CompressionMethod;
    info.NumChannels = channel.NumberOfChannels;
    info.SampleRate = channel.SampleRate;
    info.TotalSamples = channel.TotalSamples;
    info.Duration = channel.Duration;
    
    info.Title = [];
    if ~isempty(channel.Title)
        info.Title = channel.Title;
    end
    
    info.Comment = [];
    if ~isempty(channel.Comment)
        info.Comment = channel.Comment;
    end
    
    info.Artist = [];
    if ~isempty(channel.Artist)
        info.Artist = channel.Artist;
    end
    
    if any(ismember(properties(channel),'BitsPerSample'))
        info.BitsPerSample = channel.BitsPerSample;
    end
    
    if any(ismember(properties(channel),'BitRate'))
        info.BitRate = channel.BitRate / 1000; % convert to kbps
    end
catch exception
    exception = PluginManager.convertPluginException(exception, ...
        'MATLAB:audiovideo:audioinfo');
    
    throw(exception);
end

end

function errorIfTextFormat(fileName)
    %Don't try to open text files with known text extensions.
    [~,~,ext] = fileparts(fileName);
    textExts = {'txt','text','csv','html','xml','m'};
    if ~isempty(ext) && any(strcmpi(ext(2:end),textExts))
        error(message('MATLAB:audiovideo:audioinfo:unsupportedText'));
    end
end
