function y = implay(varargin) 
%IMPLAY Play movies, videos, or image sequences.
%   IMPLAY opens a movie player for showing MATLAB movies, videos, or image
%   sequences (also called image stacks). Use the IMPLAY File menu to
%   select the movie or image sequence that you want to play. You can use
%   IMPLAY controls to play the movie, jump to a specific frame in the
%   sequence, change the frame rate of the display, or perform other
%   exploration activities.  You can open multiple IMPLAY movie players to
%   view different movies simultaneously.
% 
%   IMPLAY('filename') opens the IMPLAY movie player, displaying the
%   content of the file specified by 'filename'. The file can be an AVI
%   file. IMPLAY reads one frame at a time, conserving memory during
%   playback. IMPLAY does not play audio tracks. 
%
%   IMPLAY(I) opens the IMPLAY movie player, displaying the first frame in
%   the multiframe image array specified by I. I can be a MATLAB movie 
%   structure, or a sequence of binary, grayscale, or truecolor images. A 
%   binary or grayscale image sequence can be an M-by-N-by-1-K array or an
%   M-by-N-by-K array. A truecolor image sequence must be an
%   M-by-N-by-3-by-K array.
%
%   IMPLAY(..., FPS) specifies the rate at which you want to view the movie 
%   or image sequence. The frame rate is specified as frames-per-second. If
%   omitted, IMPLAY uses the frame rate specified in the file or the
%   default value 20.
%
%   Class Support
%   -------------
%   I can be numeric but uint8 is preferred.  The actual data type used to
%   display pixels may differ from the source data type.
%
%   Examples
%   --------
%       % Animate a sequence of images
%       load cellsequence
%       implay(cellsequence,10);
%
%       % Visually explore a stack of MRI.
%       load mristack
%       implay(mristack);
%
%       % Play an AVI file.
%       implay('rhinos.avi');
%
%   See also MOVIE, IMTOOL, MONTAGE, VIDEOREADER.

%   Copyright 2007-2017 The MathWorks, Inc.

args = matlab.images.internal.stringToChar(varargin);
nargs = nargin;
names = cell(1, nargs);
for indx = 1:nargs
    names{indx} = inputname(indx);
end

hScopeCfg = iptscopes.IMPlayScopeCfg(args, ...
    uiservices.cacheFcnArgNames(names));

% Create new scope instance.
obj = uiscopes.new(hScopeCfg);

if nargout > 0
    y = obj;
end

