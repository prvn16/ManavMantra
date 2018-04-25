function hfig = soundview(soundData,soundFreq,name)
%SOUNDVIEW View and play sound with replay button
% SOUNDVIEW(FILENAME) Shows figure with sound data while playing sound,
% filename is title.
% SOUNDVIEW(Y,FS) Shows figure with sound data while playing sound.
% SOUNDVIEW(Y,FS,NAME) Same as above using NAME in title.
%
% See also UILOAD, OPEN, MOVIEVIEW, IMAGEVIEW

% Copyright 1984-2017 The MathWorks, Inc.

narginchk(1,3)

figname = getString(message('MATLAB:soundview:TitleSoundViewer'));

if ischar(soundData)
    s = importdata(soundData);
    if isstruct(s)
        figname = [figname ' - ' soundData];
        soundData = s.data;
        if isfield(s,'fs')
            soundFreq = s.fs;
        else
            soundFreq = 8192;
        end
    else
        errordlg(getString(message('MATLAB:soundview:DialogUnableToPreviewSoundInFile',soundData)));
    end
end

p = audioplayer(soundData, soundFreq);

if nargin == 3
    figname = [figname ' - ' name];
end

h = figure('menubar','none', ...
           'toolbar','none', ...
           'name',figname, ...
           'numbertitle','off', ...
           'visible','off', ...
           'resize','off', ...
           'color',get(0,'DefaultUicontrolBackgroundColor'), ...
           'CloseRequestFcn', @closeIt);
if nargout
    hfig = h;
end
set(h,'units','pixels');
ss = get(0,'screensize');
fs = get(h,'position');
b1 = uicontrol('style','pushbutton',...
              'string',getString(message('MATLAB:soundview:ButtonPlayAgain')),...
              'HandleVisibility','callback', ...
              'units','pixels',...
              'position',[5 5 100 30],...
              'callback', @playIt);

b2 = uicontrol('style','pushbutton',...
              'string',getString(message('MATLAB:soundview:ButtonDone')),...
              'HandleVisibility','callback', ...
              'units','pixels',...
              'position',[110 5 100 30],...
              'callback',@closeIt);
a = gca;
set(a,'visible','off');

btop = 30 + 5;

% resize figure to fit buttons and movie
width = 410 + 80;
height = btop + 5 + 150 + 5 + 40 + 5 + 30;
set(h,'position',[fs(1) fs(2) width height])
fs = get(h,'position');

% recenter figure on screen
set(h,'position',[(ss(3) - fs(3))/2 (ss(4) - fs(4))/2 fs(3) fs(4)])

% recenter buttons on figure
if width ~= 215
    leftGap = 5 + (width - 215) / 2;
    p1 = get(b1,'position');
    set(b1,'position',[leftGap p1(2:end)]);
    p2 = get(b2,'position');
    set(b2,'position',[leftGap + 110 p2(2:end)]);
end

% plot signal
plot(soundData,'r');

% place axis
get(a,'pos');
axis('tight')
set(get(gca,'title'),'color','k','interpreter','none')
set(a,'units','pixels','color','white','xcolor','k','ycolor','k',...
      'position',[5 + 40 btop + 40 400 150]);
if nargin == 3
    title(getString(message('MATLAB:soundview:LabelSamplesFs',name,num2str(length(soundData)), num2str(soundFreq))))
else
    title(getString(message('MATLAB:soundview:LabelSoundDataSamplesFs',num2str(length(soundData)), num2str(soundFreq))))
end

set(h,'visible','on')

if nargout == 0
    set(h,'HandleVisibility','callback');
end
drawnow;
playIt;

function playIt(varargin)
    stopIt();
    play(p);
end

function stopIt()
    if ~isempty(p)
        stop(p);
    end
end

function closeIt(varargin)
    stopIt();
    p = [];
    try
        delete(ancestor(varargin{1}, 'figure'));
    catch
    end
end

end

