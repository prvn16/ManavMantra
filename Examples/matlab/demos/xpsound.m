function xpsound(action)
%XPSOUND Demonstrate MATLAB's sound capability.
%   MATLAB is useful for exploring audio data. Sounds can be thought of as
%   one-dimensional arrays, or vectors.
%
%   This window allows you to choose a sound and view its audio data
%   graphically. If your computer has sound capability, you can play the
%   sound and choose the volume.
%
%   You may view the audio graphically in three ways:
%
%   The time sequence is a two-dimensional plot of the data as a function
%   of time.
%
%   The power spectral density (PSD) is a distribution of the signal's
%   frequency content for the duration of the sound. The integral of the
%   PSD over a given frequency band computes the average power in the
%   signal over such frequency band.
%
%   The spectrogram is a view of the frequency content of the signal as a
%   function of time. Time increases from left to right, and frequency
%   increases from bottom to top.
%
%   (Note that the power spectral density and spectrogram options require
%   the Signal Processing Toolbox.)

%   Denise L. Chen, 7-27-93
%   Copyright 1984-2014 The MathWorks, Inc.

persistent SD_VOLUME SD_NAMES SD_DISP SD_PLOTCMD
persistent funcs func_titles

if nargin < 1
   % See if the figure already exists
   fig = findobj(0,'Type','figure','Name',getString(message('MATLAB:demos:xpsound:LabelSound')));
   if isempty(fig)
      action = 'initialize';
   else
      % If this figure is already on screen, make it current and
      % return early
      figure(fig)
      return
   end
end

if strcmp(action,'initialize')
   oldFigNumber = watchon;
   
   % ================================================================
   % Set all the global variables
   SD_NAMES = [ 'chirp   '
      'gong    '
      'handel  '
      'splat   '
      'train   '
      'laughter'];
   
   SD_PLOTCMD = str2mat('plot(t,y);xlabel(''Time in seconds'');',...
      'p = periodogram(y,[],[],Fs);plot(p);',...
      'spectrogram(y,hanning(256),128,256,Fs,''yaxis'')');
  
   SD_DISP = 1;
   
   S =  brighten([[zeros(8,2) (3:10)'/10]; prism(56)],1/3);
   if (get(0,'ScreenDepth') == 1)
      S = gray(64);
   end
   
   % specify functions
   funcs = str2mat( ...
      'Fs = 8192;t = 0:1/Fs:2;y = (sin(300*2*pi*t)+sin(330*2*pi*t))/2;',...
      'Fs = 8192;t = 0:1/Fs:2;y = sin(2*pi*440*erf(t));');
   func_titles = str2mat('(sin(a*t)+sin(b*t))/2',...
      'sin(c*erf(t))');
   
   % ================================================================
   figure( ...
      'Colormap',S, ...
      'Visible','on', ...
      'NumberTitle','off', ...
      'Toolbar', 'none', ...
      'Name',getString(message('MATLAB:demos:xpsound:LabelSound')), ...
      'Pointer','watch');
   
   wids = 0.26;
   axes( ...
      'Position', [0.1 .22 .9*(.9-wids) .68], ...
      'Visible','off');
   
   % ================================================================
   % Information for all buttons
   labelColor = 192/255*[1 1 1];
   top = 0.92;
   bottom = 0.06;
   left = 0.73;
   labelWid = 0.23;
   labelHt = 0.053;
   btnWid = 0.23;
   btnHt = 0.0535;
   % Spacing between the label and the button for the same command
   btnOffset = 0.003;
   % Spacing between the button and the next command's label
   spacing = 0.055;
   
   % =================================================================
   % The CONSOLE frame
   frmBorder = 0.02;
   yPos = 0.05-frmBorder;
   frmPos = [left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
   uicontrol( ...
      'Style','frame', ...
      'Units','normalized', ...
      'Position',frmPos, ...
      'BackgroundColor',[0.5 0.5 0.5]);
   
   % =======================================================================
   % The SOUND command popup menu
   
   % Menu label info
   btnNumber = 1;
   yLabelPos = top-(btnNumber-1)*(btnHt+labelHt+spacing);
   labelPos = [left yLabelPos-labelHt labelWid labelHt];
   uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',labelPos, ...
      'BackgroundColor',labelColor, ...
      'HorizontalAlignment','left', ...
      'String',getString(message('MATLAB:demos:xpsound:LabelSound')));
   
   % Pop-up menu info
   btnPos = [left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
   
   popupStr = str2mat(getString(message('MATLAB:demos:xpsound:PopupBirdChirps')),...
      getString(message('MATLAB:demos:xpsound:PopupChineseGong')),getString(message('MATLAB:demos:xpsound:PopupHallelujah')), ...
      getString(message('MATLAB:demos:xpsound:PopupDroppingEgg')),getString(message('MATLAB:demos:xpsound:PopupTrainWhistle')),...
      getString(message('MATLAB:demos:xpsound:PopupLaughter')),getString(message('MATLAB:demos:xpsound:PopupBeats')),...
      getString(message('MATLAB:demos:xpsound:PopupFM')));
   
   uicontrol('Style','popup',...
      'Units','normalized', ...
      'Position', btnPos, ...
      'String',popupStr, ...
      'Callback','xpsound(''sound'')');
   
   % =======================================================================
   % The DISPLAY command popup menu
   
   % Menu label info
   btnNumber = 2;
   yLabelPos = top-(btnNumber-1)*(btnHt+labelHt+spacing);
   labelPos = [left yLabelPos-labelHt labelWid labelHt];
   uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',labelPos, ...
      'BackgroundColor',labelColor, ...
      'HorizontalAlignment','left', ...
      'String',getString(message('MATLAB:demos:xpsound:LabelDisplay')));
   
   % Pop-up menu info
   btnPos = [left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
   
   % Signal Processing Toolbox is on the path
   if exist('spectrogram', 'file')
      uicontrol('Style','popup',...
         'Units','normalized', ...
         'Position', btnPos, ...
         'String',str2mat(getString(message('MATLAB:demos:xpsound:PopupTimeSequence')),...
         getString(message('MATLAB:demos:xpsound:PopupPowerSpectralDensity')),...
         getString(message('MATLAB:demos:xpsound:PopupSpectrogram'))),...
         'Callback','xpsound(''display'')');
      % Signal Processing Toolbox is not on the path
   else
      uicontrol('Style','text',...
         'Units','normalized', ...
         'Position', btnPos, ...
         'String',str2mat(getString(message('MATLAB:demos:xpsound:PopupTimeSequence'))));
   end;
   
   
   % =======================================================================
   % The PLAY button
   btnNumber = 3;
   yLabelPos = top-(btnNumber-1)*(btnHt+labelHt+spacing);
   btnPos = [left yLabelPos-labelHt-btnHt-btnOffset btnWid 2*btnHt];
   btnHndl = uicontrol( ...
      'Style','pushbutton', ...
      'Units','normalized', ...
      'Position', btnPos, ...
      'String',getString(message('MATLAB:demos:xpsound:ButtonPlaySound')), ...
      'Callback','xpsound(''play'')');
   % use try-catch to hide the PLAY button if sound is unavailable
   soundFlag = 'on';
   eval('sound(0)','soundFlag = ''off'';');
   set(btnHndl,'Visible',soundFlag);
   
   % =======================================================================
   % The INFO button
   uicontrol( ...
      'Style','pushbutton', ...
      'Units','normalized', ...
      'Position',[left bottom+2*btnHt+spacing btnWid 2*btnHt], ...
      'String',getString(message('MATLAB:demos:shared:LabelInfo')), ...
      'Callback','xpsound(''info'')');
   
   % =======================================================================
   % The CLOSE button
   uicontrol( ...
      'Style','pushbutton', ...
      'Units','normalized', ...
      'Position',[left bottom btnWid 2*btnHt], ...
      'String',getString(message('MATLAB:demos:shared:LabelClose')), ...
      'Callback','xpsound(''close'')');
   
   % =======================================================================
   % The VOLUME slider
   
   SD_VOLUME = uicontrol( ...
      'Units','normal',...
      'Position',[0.125 .09 .8*(.9-wids) .04], ...
      'Style','slider', ...
      'Visible',soundFlag, ...
      'Min',0.01, 'max',1, ...
      'Value',1);
   
   % label volume control
   pos = [0.55 0.04 0.15 0.04];
   uicontrol('style','text', ...
      'Units','normal', ...
      'Position',pos,...
      'String',getString(message('MATLAB:demos:xpsound:SliderVolume')), ...
      'BackgroundColor',get(gcf,'color'),...
      'Visible',soundFlag, ...
      'ForegroundColor', get(gca,'xcolor'),...
      'Horizontal','left');
   
   % =======================================================================
   % Initialize the demo to Bird Chirps with Time Sequence
   
   %    set(gcf,'pointer','watch');drawnow;
   
   load chirp Fs y;
   y = y/max(abs(y));
   t = (0:length(y)-1)/Fs;
   set(gcf,'UserData',[t(:) y(:)]);
   n = SD_DISP;
   eval(SD_PLOTCMD(n,:));
   title(getString(message('MATLAB:demos:xpsound:TitleSamples',int2str(length(y)))));
   drawnow;
   
   set(gcf,'pointer','arrow');
   
   % =======================================================================
   watchoff(oldFigNumber);
   
   % END of INITIALIZE section
   
   % =======================================================================
   % Sound callback.
   
elseif strcmp(action,'sound')
   hndl = gco;
   popStr = get(hndl,'String');
   value = get(hndl,'Value');
   selectStr = deblank(popStr(value,:));
   
   nfiles = size(SD_NAMES,1);
   set(gcf,'pointer','watch');
   drawnow;
   
   % Load file, if available. Otherwise, use FUNCS to do a fnct evaluation
   if value <= nfiles
      file = SD_NAMES(value,:);
      file(file == ' ') = []; % get rid of extra blanks in filename
      load(file,'Fs','y');
      y = y/max(abs(y));
      t = (0:length(y)-1)/Fs;
   else
      eval(deblank(funcs(value-nfiles,:)));
   end
   
   set(gcf,'UserData',[t(:) y(:)]);
   n = SD_DISP;
   eval(SD_PLOTCMD(n,:));
   
   if value <= nfiles
      title(getString(message('MATLAB:demos:xpsound:TitleSamples',int2str(length(y)))));
   else
      title(deblank(func_titles(value-nfiles,:)));
   end
   drawnow;
   
   set(gcf,'pointer','arrow');
   
   % ========================================================================
   % Display callback.
   
elseif strcmp(action,'display')
   hndl = gco;
   popStr = get(hndl,'String');
   value = get(hndl,'Value');
   selectStr = deblank(popStr(value,:));
   
   Fs = 8192;          % Sampling rate is the same for all files!
   SD_DISP = value;
   y = get(gcf,'UserData');
   if ~isempty(y),t = y(:,1);
      y = y(:,2);
      set(gcf,'pointer','watch');
      drawnow;
      titl = get(get(gca,'title'),'String');
      eval(SD_PLOTCMD(value,:));
      set(gcf,'pointer','arrow');
      title(titl)
      drawnow
   end;
   
   % ========================================================================
   % Play callback.
   
elseif strcmp(action,'play')
   
   set(gcf,'pointer','watch');
   try
      Fs = 8192;          % Sampling rate is the same for all files!
      
      dat = get(gcf,'UserData');
      y = dat(:,2);
      sound(y*get(SD_VOLUME,'value'),Fs);
   catch
   end
   set(gcf,'pointer','arrow');
   
   % ========================================================================
elseif strcmp(action,'info'),
   helpwin(mfilename)
   
elseif strcmp(action,'close'),
   close(gcf);
   clear global SD_VOLUME SD_NAMES SD_DISP SD_PLOTCMD;
   clear global funcs func_titles;
   
end;    % if strcmp(action, ...
