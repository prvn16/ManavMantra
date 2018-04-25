function pj = validate( pj )
%VALIDATE Method to check state of PrintJob object.
%   Values of PrintJob object class variables are checked for consistency.
%   Errors out if it finds bad combinations. Fills in missing data with
%   defaults.
%
%   Ex:
%      pj = VALIDATE( pj );
%
%   See also PRINT, PRINTOPT, INPUTCHECK.

%   Copyright 1984-2016 The MathWorks, Inc.

pj.Validated = 1;

%If no window requested, and none to act as default, error out.
pj = validateHandleToPrint(pj); 

if ~pj.UseOriginalHGPrinting
   % for future use
   if pj.RGBImage 
       if ~isempty(pj.Driver)
           error(message('MATLAB:print:IncompatibleRGBImageOptionNoDriver', pj.Driver));
       end
       
       if ~isempty(pj.FileName)
           error(message('MATLAB:print:IncompatibleRGBImageOptionFilename'));
       end
       
       if ~isempty(pj.PrinterName)
           error(message('MATLAB:print:IncompatibleRGBImageOptionPrinter'));
       end
   end
   
   if pj.ClipboardOption 
       if ~isempty(pj.FileName)
           error(message('MATLAB:print:IncompatibleClipboardOptionFilename'));
       end
       
       if ~isempty(pj.PrinterName)
           error(message('MATLAB:print:IncompatibleClipboardOptionPrinter'));
       end
       
       if isempty(pj.Driver) 
           error(message('MATLAB:print:IncompatibleClipboardOptionNoDriver'));
       end
       
       if ~pj.DriverClipboard %driver doesn't support clipboard
           error(message('MATLAB:print:IncompatibleClipboardOptionDriver', pj.Driver));
       end
       
   end
end

if pj.PostScriptPreview && ~strcmp(pj.DriverClass,'EP')
    error(message('MATLAB:print:ValidateTiffPreviewOnlyWithEPS'))
end

%If no device given, use default from PRINTOPT
if ~pj.RGBImage && isempty( pj.Driver )
    %Use method to validate default and set related class variables
    wasError = 0;
    try
        pj = inputcheck( pj, pj.DefaultDevice );
        pj.DriverColorSet = 0;
    catch ex  %#ok<NASGU>
        wasError = 1;
    end
    if wasError || isempty( pj.Driver )
      error(message('MATLAB:print:ValidateUnknownDeviceType', pj.DefaultDevice));
    end
end

if strcmp(pj.DriverClass, 'MW' ) 
    if isunix
      error(message('MATLAB:print:ValidateUseWindowsDriver', pj.Driver));
    end
    
    % If user specifies a filename while device is -dwin
    % or -dwinc, either because the user gave that device or, more
    % likely, it's the default, and since the filename is useless
    % with Windows driver anyway, we'll assume the user really wants
    % a PostScript file. This is because 'print foo' is easier
    % to type then 'print -dps foo' and probably more commonly
    % meant if a filename is given. Unless of course the user asked
    % for the Print Dialog with the -v flag, then s/he really meant it.
    if (~isempty(pj.FileName) && ~pj.Verbose ) ...
            && ( strcmp(pj.Driver, 'win') || strcmp(pj.Driver, 'winc') )
        if pj.DriverColor
            pj.Driver = 'psc';
        else
            pj.Driver = 'ps';
        end
        pj.DriverExt = 'ps';
        pj.DriverClass = 'PS';
    end
end

%TIFF previews imply -loose, historically because ZBuffer TIFF was always "loose".
if pj.PostScriptPreview == pj.TiffPreview
    pj.PostScriptTightBBox = 0;    
end

h = pj.Handles{1}(1);

% Validate use of fillpage/bestfit options
%    can't do -fillpage and -bestfit at same time
%    must be with a page format (PS, PDF, or Printer)
%    must be with a figure (not SL or SF) 
isfig = isfigure(h); 
isPage = locIsPageFormatOrPrinter(pj);
isAuto = strcmp(get(h, 'PaperPositionMode'), 'auto'); 
if pj.FillPage || pj.BestFit
  if pj.FillPage
      option = 'fillpage';
  else
      option = 'bestfit';
  end
  % must be with figure (not SL/SF) 
  % can't do -fillpage and -bestfit at same time
  % must be with a page format (PS, PDF, or Printer)
  if ~isfig
      error(message('MATLAB:print:OptionOnlyValidForFigures', option));
  end

  if pj.FillPage && pj.BestFit 
      error(message('MATLAB:print:FillPageBestFitExclusive'));
  end

  if ~isPage
      error(message('MATLAB:print:OptionOnlyValidForPageFormats', option));
  end
 
end
if isfig
  % if printing to page format in 'auto' mode (and user hasn't specified either 
  % -bestfit or -fillpage), warn the user and offer suggestions if the output will get 
  % cropped (because figure is too large to fit on the page)
  if isPage && isAuto && ~(pj.FillPage || pj.BestFit)
     paperPos = get(h, 'PaperPosition'); 
     if any(paperPos(1:2) < 0)
        warning(message('MATLAB:print:FigureTooLargeForPage'));
     end
  end
  %Fill renderer and -noui from the printtemplate (if it exists) if
  %the user didn't specify these options on the command line
  pt = getprinttemplate(h);
  if ~isempty(pt)
	if ~pj.nouiOption
	  pj.PrintUI = pt.PrintUI;
	end
	if ~pj.rendererOption && ~strcmp( pt.Renderer, 'auto' )
	  pj.Renderer = pt.Renderer;
      pj.rendererOption = 1; % overriding figure renderer
	end
  end 
    
  if ~pj.UseOriginalHGPrinting && (isfield(pj.temp, 'isFigureShowEnabled') && ...
          ~pj.temp.isFigureShowEnabled)
      %If user did not specify -noui and there are visible uicontrols, error now
      if ~pj.nouiOption && ~isempty(validateFindControls(h))
           error(message('MATLAB:prepareui:UnsupportedPlatform'));
      end
  end
end

% end validate

function ispage = locIsPageFormatOrPrinter(pj)
    ispage = (isempty(pj.DriverClass) || ... % caller didn't specify a -d device
            strncmpi(pj.Driver, 'win', 3) || ... % or we're going directly to printer on windows
            strcmp(pj.DriverClass, 'PR')  || ... % or we're going directly to printer on any platform
            (strcmp(pj.DriverClass, 'MW') && ~pj.DriverExport) || ...  % printer on windows
            any(strncmpi(pj.Driver, {'pdf', 'ps', 'psc'}, 2)));
% end locMakeSafeForDmfile

