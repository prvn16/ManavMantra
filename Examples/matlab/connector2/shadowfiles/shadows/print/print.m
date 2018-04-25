function varargout = print( varargin )
%PRINT Print figure or model. Save to disk as image or MATLAB file.
%   SYNTAX:
%     print
%       PRINT alone sends the current figure to your current printer.
%       The size and position of the printed output depends on the figure's
%       PaperPosition[mode] properties and your default print command
%       as specified in your PRINTOPT.M file.
%
%     print -s
%       Same as above but prints the current Simulink model.
%
%     print -device -options
%       You can optionally specify a print device (i.e., an output format such
%       as tiff or PostScript or a print driver that controls what is sent to
%       your printer) and options that control various characteristics  of the
%       printed file (i.e., the resolution, the figure to print
%       etc.). Available devices and options are described below.
%
%     print -device -options filename
%       If you specify a filename, MATLAB directs output to a file instead of
%       a printer. PRINT adds the appropriate file extension if you do not
%       specify one.
%
%     print( ... )
%       Same as above but this calls PRINT as a MATLAB function instead of
%       a MATLAB command. The difference is only in the parenthesized argument
%       list. It allows the passing of variables for any of the input
%       arguments and is especially useful for passing the handles
%       of figures and/or models to print and filenames.
%
%     Note: PRINT will produce a warning when printing a figure with a
%     ResizeFcn.  To avoid the warning, set the PaperPositionMode to 'auto'
%     or match figure screen size in the PageSetup dialog.
%
%   BATCH PROCESSING:
%       You can use the function form of PRINT, which is useful for batch
%       printing. For example, you can use a for loop to create different
%       graphs and print a series of files whose names are stored in an array:
%
%       for i=1:length(fnames)
%           print('-dpsc','-r200',fnames(i))
%       end
%
%   SPECIFYING THE WINDOW TO PRINT
%       -f<handle>   % Handle Graphics handle of figure to print
%       -s<name>     % Name of an open Simulink model to print
%       h            % Figure or model handle when using function form of PRINT
%
%     Examples:
%       print -f2    % Both commands print Figure 2 using the default driver
%       print( 2 )   % and operating system command specified in PRINTOPT.
%
%       print -svdp  % prints the open Simulink model named vdp
%
%   SPECIFYING THE OUTPUT FILE:
%       <filename>   % String on the command line
%       '<filename>' % String passed in when using function form of PRINT
%
%     Examples:
%       print -dps foo
%       fn = 'foo'; print( gcf, '-dps', fn )
%       Both save the current figure to a file named 'foo.ps' in the current
%       working directory. This file can now be printed to a
%       PostScript-compatible printer.
%
%   COMMON DEVICE DRIVERS
%       Output format is specified by the device driver input argument. This
%       argument always starts with '-d' and falls into one of several
%       categories:
%     Microsoft Windows system device driver options:
%       -dwin      % Send figure to current printer in monochrome
%       -dwinc     % Send figure to current printer in color
%       -dmeta     % Send figure to clipboard (or file) in Metafile format
%       -dbitmap   % Send figure to clipboard (or file) in bitmap format
%       -dsetup    % Bring up Print Setup dialog box, but do not print
%                    (This option/device will be removed in a future version of MATLAB)
%       -v         % Verbose mode, bring up the Print dialog box
%                    which is normally suppressed.
%
%     Built-in MATLAB Drivers:
%       -dps       % PostScript for black and white printers
%       -dpsc      % PostScript for color printers
%       -dps2      % Level 2 PostScript for black and white printers
%       -dpsc2     % Level 2 PostScript for color printers
%
%       -deps      % Encapsulated PostScript
%       -depsc     % Encapsulated Color PostScript
%       -deps2     % Encapsulated Level 2 PostScript
%       -depsc2    % Encapsulated Level 2 Color PostScript
%
%       -dhpgl     % HPGL compatible with Hewlett-Packard 7475A plotter
%       -dill      % Adobe Illustrator 88 compatible illustration file
%                    (This option/device will be removed in a future version of MATLAB)
%       -djpeg<nn> % JPEG image, quality level of nn (figures only)
%                    E.g., -djpeg90 gives a quality level of 90.
%                    Quality level defaults to 75 if nn is omitted.
%       -dtiff     % TIFF with packbits (lossless run-length encoding)
%                    compression (figures only)
%       -dtiffnocompression % TIFF without compression (figures only)
%       -dpng      % Portable Network Graphic 24-bit truecolor image
%                    (figures only)
%
%     Other output formats are possible by using the GhostScript application
%     supplied with MATLAB. For a full listing see the online help
%     for GHOSTSCRIPT, use the command 'help private/ghostscript'.
%     An example of some of the device drivers supported via GhostScript are:
%       -dljet2p   % HP LaserJet IIP
%       -dljet3    % HP LaserJet III
%       -ddeskjet  % HP DeskJet and DeskJet Plus
%       -dcdj550   % HP Deskjet 550C (UNIX only)
%       -dpaintjet % HP PaintJet color printer
%       -dpcx24b   % 24-bit color PCX file format, 3 8-bit planes
%       -dppm      % Portable Pixmap (plain format)
%
%     Examples:
%       print -dwinc  % Prints current Figure to current printer in color
%       print( h, '-djpeg', 'foo') % Prints Figure/model h to foo.jpg
%
%   PRINTING OPTIONS
%     Options only for use with PostScript and GhostScript drivers:
%       -loose     % Use Figure's PaperPosition as PostScript BoundingBox
%       -append    % Append, not overwrite, the graph to PostScript file
%       -tiff      % Add TIFF preview, EPS files only (implies -loose)
%       -cmyk      % Use CMYK colors instead of RGB
%       -adobecset % Use Adobe PostScript standard character set encoding
%                    (This option/device will be removed in a future version of MATLAB)
%
%     Options for PostScript, GhostScript, Tiff, Jpeg, and Metafile:
%       -r<number> % Dots-per-inch resolution. Defaults to 90 for Simulink,
%                    150 for figures in image formats and when
%                    printing in Z-buffer or OpenGL mode,  screen
%                    resolution for Metafiles and 864 otherwise.
%                    Use -r0 to specify screen resolution.
%     Example:
%       print -depsc -tiff -r300 matilda
%       Saves current figure at 300 dpi in color EPS to matilda.eps
%       with a TIFF preview (at 72 dpi for Simulink models and 150 dpi
%       for figures). This TIFF preview will show up on screen if
%       matilda.eps is inserted as a Picture in a Word document, but
%       the EPS will be used if the Word document is printed on a
%       PostScript printer.
%
%     Other options for figure windows:
%       -Pprinter  % Specify the printer. On Windows and Unix.
%       -noui      % Do not print UI control objects
%       -painters  % Rendering for printing to be done in Painters mode
%       -zbuffer   % Rendering for printing to be done in Z-buffer mode
%       -opengl    % Rendering for printing to be done in OpenGL mode
%       A note on renderers: when printing figures, MATLAB does not always
%       use the same renderer as on screen. This is for efficiency reasons.
%       There are cases, however, where the printed output is not exactly
%       like the screen representation because of this. In these instances
%       specifying -zbuffer or -opengl will more likely give you output that
%       emulates the screen.
%
%   See the Using MATLAB Graphics manual for more information on printing.
%
%   See also PRINTOPT, PRINTDLG, ORIENT, IMWRITE, HGSAVE, SAVEAS.

%   Copyright 1984-2013 The MathWorks, Inc.

    persistent origPrint;

    if isempty(origPrint)
        % First, disable shadow warnings
        warningState = warning('off', 'MATLAB:dispatcher:nameConflict');
        originalDir = cd(fullfile(matlabroot, 'toolbox', 'matlab', 'graphics'));
        origPrint = @print;
        cd(originalDir);
        warning(warningState);
    end

    if ~hasFilenameArgument(varargin)
       if hasDriverOrOption(varargin)
            if hasRGBImageOption(varargin)
                % run the regular print command
                if nargout > 0
                    varargout = {origPrint(varargin{:})};
                    return;
                else
                    origPrint(varargin{:});
                    return;
                end
            else
                warning('The print command with no output file name only supports PDF. For more control over printing, please specify an output file name.');
            end
        end

        import com.mathworks.matlabserver.workercommon.client.*;
        clientServiceRegistryFacade = ClientServiceRegistryFactory.getClientServiceRegistryFacade();
        userManager = clientServiceRegistryFacade.getUserManager();

        userRoot = char(userManager.getUserHomeDir());
        printDir = fullfile(userRoot, '.tmp');
        printName = 'printOutput.pdf';
        fullName = fullfile(printDir, printName);

        if ~exist(printDir, 'dir')
            try
                mkdir(userRoot, '.tmp');
            catch
                warning('Unable to create temp directory');
                fullName = fullfile(originalDir, printName);
            end
        end

        origPrint(getFigureHandle(varargin), '-dpdf', fullName);

        import com.mathworks.matlabserver.workercommon.client.*;
        clientServiceRegistryFacade = ClientServiceRegistryFactory.getClientServiceRegistryFacade();
        clientBrowserService = clientServiceRegistryFacade.getBrowserService();
        clientBrowserService.openWithBrowser(fullName);

    else
        args = convertArguments(originalDir, varargin);

        % run the regular print command
        if nargout > 0
            varargout = {origPrint(args{:})};
        else
            origPrint(args{:});
        end
    end

end


%% Convert arguments - mainly for making the filename absolute
function args = convertArguments(originalDir, args)
    for i = 1:numel(args)
        if isFilenameArgument(args{i})
            filename = args{i};
            if isRelativeFilename(filename)
                filename = fullfile(originalDir, char(filename));
            end
            args{i} = filename;
        end
    end
end


%% Filename arguments are defined as string args which don't start with '-'
function result = hasFilenameArgument(args)
    result = false;
    for i = 1:numel(args)
        if isFilenameArgument(args{i})
            result = true;
            break;
        end
    end
end


%% Determine if an arg
function result = isFilenameArgument(arg)
    result = (ischar(arg) || isstring(arg)) && arg(1) ~= '-';
end


%% Determine if an arg
function result = isRelativeFilename(filename)
    [fpath, ~, ~] = fileparts(filename);
    result = numel(fpath) == 0 || fpath(1) ~= filesep;
end


%% Filename arguments are defined as string args which don't start with '-'
function result = hasDriverOrOption(args)
    result = false;
    for i = 1:numel(args)
        arg = args{i};
        if (ischar(arg) || isstring(arg)) && arg(1) == '-' && ~strcmp(arg(1:2), '-f')
            result = true;
            break;
        end
    end
end


%% Check for '-RGBImage' option in the string args
function result = hasRGBImageOption(args)
    result = false;
    for i = 1:numel(args)
        arg = args{i};
        if (ischar(arg) || isstring(arg)) && strcmp(arg, '-RGBImage')
            result = true;
            break;
        end
    end
end


%% Figure handle
function h = getFigureHandle(args)
    if numel(args) > 0
        for i = 1:numel(args)
            arg = args{i};
            if (ischar(arg) || isstring(arg)) && numel(arg) > 2 && strcmp(arg(1:2), '-f')
                h = str2double(arg(3:end));
                return;
            elseif isscalar(arg) && (isnumeric(arg) || ishghandle(arg))
                h = arg;
                return;
            end
        end
    end
    % default is gcf
    h = gcf;
end
