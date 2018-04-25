function copyFigureHelper (hFigure)
% This undocumented helper function is for internal use only.

% Calls the printing code that copies the figure to the clipboard
% This does the branching for different platforms.

% Copyright 2013-2016 The MathWorks, Inc.

narginchk(1,1)

if ~ishghandle(hFigure, 'figure')
        return;
end

% Save off the old figure properties.
initialState.InvertHardcopy_I = get(hFigure, 'InvertHardcopy_I');
initialState.PaperPosition = get(hFigure, 'PaperPosition');
initialState.PaperPositionMode = get(hFigure, 'PaperPositionMode');
initialState.Pointer_I = get(hFigure, 'Pointer_I');
if ispc % These properties are only changed for Windows Copy Figure.
    initialState.Renderer = get(hFigure, 'Renderer');
    initialState.RendererMode = get(hFigure, 'RendererMode');
end
if ismac
    initialState.PaperSize = get(hFigure, 'PaperSize');
    initialState.PaperSizeMode = get(hFigure, 'PaperSizeMode');
    initialState.SizeChangedFcn = get(hFigure, 'SizeChangedFcn'); 
    initialState.SizeChangedFcnMode = get(hFigure, 'SizeChangedFcnMode'); 
end
c = onCleanup(@() restoreInitialState(hFigure, initialState));

% Set figure to watch pointer until the copy action is completed
set(hFigure, 'Pointer_I', 'watch');

% Set Preference flag, so that preparehg.m will know we came from the copy options menu pick
% as opposed to command line print ... or other print
javaMethod('setIntegerPref', 'com.mathworks.services.Prefs', 'CopyOptions.HonorCOPrefs', 1);

% get Background Color preference: 0 = transparent, 1 = white, 2 = preserve color
defaultBkColorPref = 0; % Mac does not show the Copy options dialog so pick 0.
if ispc
    defaultBkColorPref = 2; % For Windows this is what we have been doing for a while.
end
bkColorPref = javaMethod('getIntegerPref', 'com.mathworks.services.Prefs', 'CopyOptions.FigureBackground', defaultBkColorPref);

% Set the figure's invert hardcopy property to the preference in the copy options
hardcopyValue  = 'off';
if (bkColorPref == 1) % if White
    hardcopyValue = 'on';
end
set(hFigure, 'InvertHardcopy_I', hardcopyValue );

argsToPrint = {hFigure, '-clipboard'};

if ismac
    % On the Mac we always put up a PDF file onto the clipboard which is a 
    % vector output. See g961646
    % We can generate a PDF file and allow the print pipeline to decide 
    % whether to use opengl or painters.
    argsToPrint{end + 1} = '-dpdf';
    
    % PDF  is a Paper Type output format. So sending that to the clipboard
    % will have a lot of whitspace. 
    % So we make the PaperSize tight with the PaperPosition. This will make
    % the PDF output look similar to Image format outputs (eps, jpeg etc). 
    hFigure.PaperPositionMode = 'auto';
    paperPos = hFigure.PaperPosition;
    hFigure.PaperSize =  paperPos(3:4); 
    % force the offsets to be 0 ...
    % ... Yes, this will reset mode to manual
    hFigure.PaperPosition(1:2) = [0 0];  
    
    % disable the resizeFcn - we should be generating output at the same
    % size as the onscreen figure. Not disabling the resizeFcn can lead to
    % warnings when PaperPositionMode is manual
    hFigure.SizeChangedFcn = [];
end

if ispc 
    % Apply renderer and output format preferences for Windows.
    % These are read from the Copy Options GUI. 
    % Ideally if this GUI is enabled for Mac this branching would not be needed.
    
    % get figure format preference : 0 = bitmap, 1 = metafile, 2 = preserve
    formatPref = javaMethod('getIntegerPref', 'com.mathworks.services.Prefs', 'CopyOptions.FigureFormat', 2);
        
    % get "Match Figure Screen Size" preference - 0 means no (use print settings), 1 means yes (paperpositionmode 'auto')
    matchSize = javaMethod('getBooleanPref', 'com.mathworks.services.Prefs', 'CopyOptions.MatchFigureScreen', true);
    if matchSize
        set(hFigure, 'PaperPositionMode', 'auto');
    end
        
    switch (formatPref)
        case 0
            % If the preference says bitmap, force it to bitmap, it
            % doesn't matter what the renderer is.
            argsToPrint{end + 1} = '-dbitmap';
            argsToPrint{end + 1} = '-r0';
            
        case 1
            % If the preference says metafile, force it to metafile,
            % AND force the renderer to be painters.  Otherwise, you
            % have a metafile with a bitmap in it which is relatively useless.
            set(hFigure, 'RendererMode', 'manual');
            set(hFigure, 'Renderer', 'painters');
            argsToPrint{end + 1} = '-dmeta';
            
        case 2
            % Switch the output format based what we think we can do 
            % use metafile 
            %    if set renderer explicitly to painters, or we 
            %    think we can do painters w/o too much trouble
            %  use bitmap 
            %    if user set renderer explicitly to opengl or 
            %    we don't think we can do painters 
            isPainters = strcmpi(get(hFigure, 'Renderer'), 'painters');
            if strcmpi(initialState.RendererMode, 'manual')
                if isPainters
                    usePainters = true;
                else
                    usePainters = false;
                end
            else 
                % user didn't set renderer ... let's ask print what to use
                % we'll pretend we want vector output and see if print
                % would switch to painters for it 
                pj.Handles{1} = hFigure;
                pj.Driver = 'meta';
                pj.rendererOption = 0;
                usePainters = matlab.graphics.internal.autoSwitchToPaintersForPrint(pj); 
            end
            if usePainters
               argsToPrint{end + 1} = '-dmeta';
               % since we figured out above that we want to use painters
               % we might as well specify it and avoid some processing in
               % the print pipeline
               argsToPrint{end + 1} = '-painters'; 
            else
               argsToPrint{end + 1} = '-dbitmap';
               argsToPrint{end + 1} = '-r0';
               % since we figured out above that we won't use painters
               % we might as well specify opengl and avoid some processing 
               % in he print pipeline
               argsToPrint{end + 1} = '-opengl'; 
            end
    end
end

% get print uicontrols preference
printUIPref = javaMethod('getBooleanPref', 'com.mathworks.services.Prefs', 'CopyOptions.ShowUiControls', true);

if (printUIPref == false)
    % If the noui preference is set, use it.
    argsToPrint{end + 1} = '-noui';
end

% Print to clipboard
print(argsToPrint{:});


    function restoreInitialState(hFigure, initialState)
        % Restore the CopyOptions setting
        javaMethod('setIntegerPref', 'com.mathworks.services.Prefs', 'CopyOptions.HonorCOPrefs', 0);
        % Restore the figure properties.
        if ~ishghandle(hFigure, 'figure')
            return;
        end
        set(hFigure, initialState);
    end
end
