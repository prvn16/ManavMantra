function varargout = pagesetupdlg(Fig, varargin)
%PAGESETUPDLG is not recommended.  Use printpreview instead.

%PAGESETUPDLG  Page setup dialog
%
%  DLG = PAGESETUPDLG(FIG) creates a dialog box from which a set of page
%  layout properties for the figure window, FIG, can be set.
%
%  PAGESETUPDLG implements the "Page Setup..." option in the
%  Figure File Menu.
%
%  PAGESETUPDLG currently only supports setting the layout for a single
%  figure.  FIG must be a single figure handle, not a vector of figures or
%  a Simulink diagram.
%
%  See also PRINTDLG, PRINTOPT, PRINTPREVIEW .

%  Additional notes:
%  PAGESETUPDLG sets the Figure
%     PaperPosition, PaperOrientation, PaperPositionMode,
%     and PrintTemplate properties.

%   Copyright 1984-2017 The MathWorks, Inc.
%     

if nargin > 1
    % TODO: The old HG (non-Java) implementation of the printdlg calls this
    % function with two arguments, but this function for a long time has
    % done nothing but return when called with two arguments.  So we're
    % explicitly returning here so as not to break any old functionality.
    % When the printdlg is cleaned up, this, too, can be simplified and
    % should probably throw some harder error when called with the wrong
    % number of arguments.
    return;
else
    if nargin == 0
        Fig = gcbf;
    end
    if isempty(Fig)
        Fig = gcf;
    end
end

callPrintPreview = pagesetupdlg_helper(Fig);
if callPrintPreview
    % Call printpreview
    printpreview(Fig)
    return;
end

Dlg = LocalInitFig(Fig);

if nargout==1
    varargout{1} = Dlg;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInitFig %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function Dlg=LocalInitFig(Fig)

try
    LocalJavaSetupDlg(Fig, sprintf('Page Setup - %s', dlgfigname(Fig)));
    Dlg = [];
catch
    Dlg = old_pagesetupdlg(Fig);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalJavaSetupDlg( Fig, name )
error(javachk('swing'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Try using the Java page setup dialog. If fails return 0.
% The dialog will have been dismissed by the time this routine returns.
import com.mathworks.page.export.pagesetup.PageSetupDialog;

[optKeys, optVals] = LocalGetSetupData( Fig );

jPanel = PageSetupDialog.create(name, ...
    optKeys, ...
    optVals);

% compute the position for the page dialog
dlgPos = getpixelposition(Fig);
dlgPos(1) = dlgPos(1) + 10;  % offset a little
dlgPos(3) = 500;
dlgPos(4) = 400;

% Wire a callback to the panel and stuff it into a figure

%callback = handle(jPanel.getCallback());
%l = handle.listener(callback, 'delayed', @cbfcn);

callback = jPanel.getCallback();
l = addlistener(callback, 'delayed', @cbfcn);

hDialog = dialog('Name', name, 'Position', dlgPos);
[~, hc] = javacomponent(jPanel, [], hDialog);
set(hc,'Units','normalized','Position',[0 0 1 1])

% Store this for testing
% It can be used by automated tests to grab the panel and force it to close
setappdata(0,'PageSetupDialog',jPanel);

waitfor(hDialog);
delete(l);

rmappdata(0,'PageSetupDialog');


if ~jPanel.isCanceled
    % get options from dialog
    LocalSetSetupData( Fig, optKeys, jPanel.getSetupData );
end

    function cbfcn(o,e) %#ok
        delete(hDialog)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [keys,options] = LocalGetSetupData( Fig )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returns cell array of options from the figure's printing
% properties and any PrintTemplate it has. Also computes
% lists and values needed by the pagesetup dialog

if isunix
    defPrinter = findprinters;
    if defaultprtcolor
        printerinfo = {defPrinter, 1};
    else
        printerinfo = {defPrinter, 0};
    end
else
    printerinfo = system_dependent('getprinterinfo');
    names = printerinfo{3};
    if ~isempty(names)
        toolong = find(cellfun('length',names) > 28);
        for k=toolong
            names{k} = [names{k}(1:25) '...'];
        end
        printerinfo{3} = names;
    end
end

pt = getprinttemplate(Fig);
if isempty(pt)
    pt = printtemplate;
    if ~isempty(printerinfo{2})
        pt.DriverColor = printerinfo{2};
    end
end

pt.PaperType = get(Fig, 'PaperType');
pt.PaperSize = get(Fig, 'PaperSize');
pt.PaperOrientation = get(Fig, 'PaperOrientation');
pt.PaperUnits = get(Fig, 'PaperUnits');
pt.PaperPositionMode = get(Fig, 'PaperPositionMode');
pt.PaperPosition = get(Fig, 'PaperPosition');
pt.FigSize = hgconvertunits(Fig, get(Fig, 'Position'), ...
    get(Fig, 'units'), pt.PaperUnits, Fig);

% Add to the printtemplate
pt.InvertHardCopy = get(Fig, 'InvertHardCopy');

% construct list of keys and values
keys = fieldnames( pt );
options = struct2cell( pt );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetSetupData( Fig, keys, options )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% saves the given printing options in the given figure's
% properties and PrintTemplate.

nfields = length(keys);
t = cell(2,nfields);
t(1,:) = keys(1:nfields);
t(2,:) = options(1:nfields);
t = reshape(t,1,2*nfields);
st = struct(t{:});

% set the figure properties
set(Fig, 'PrintTemplate', st);
set(Fig, 'PaperUnits', st.PaperUnits);
set(Fig, 'PaperPosition', st.PaperPosition);
set(Fig, 'PaperOrientation', st.PaperOrientation);
set(Fig, 'PaperSize', st.PaperSize);
set(Fig, 'InvertHardCopy', st.InvertHardCopy);
set(Fig, 'PaperPositionMode', st.PaperPositionMode);

end

% LocalWords:  cbfcn pagesetup getprinterinfo
