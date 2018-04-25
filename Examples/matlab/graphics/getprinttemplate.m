function pt = getprinttemplate( h )
%GETPRINTTEMPLATE Get a figure's PrintTemplate

%   Copyright 1984-2008 The MathWorks, Inc.

pt = get(h, 'PrintTemplate');
if ~isempty(pt)
  if isfield(pt,'VersionNumber')
    ver = pt.VersionNumber;
  else
    ver = nan;
  end
  if isnan(ver)
    ptnew = printtemplate;
    ptnew.Name = pt.Name;
    ptnew.FrameName = pt.FrameName;
    if pt.DriverColor
      ptnew.DriverColor = 1;
    else
      ptnew.DriverColor = 0;
    end
    ptnew.AxesFreezeTicks = pt.AxesFreezeTicks;
    ptnew.AxesFreezeLimits = pt.AxesFreezeLimits;
    pt = ptnew;
  end
  % Append the figure paper properties and header info without changing
  % the VersionNumber since ptpreparehg and ptrestorehg perform a check
  % that the VersionNumber is 2 (or more) for the new page layout 
  % PrintTemplate.
  pt = appendPropsFromFigToPrintTemplate(pt,h);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pt = appendPropsFromFigToPrintTemplate(pt,h)
% get the papertype,size, orientation, etc. from the figure
pt.PaperType = get(h, 'PaperType');
pt.PaperSize = get(h, 'PaperSize');
pt.PaperOrientation = get(h, 'PaperOrientation');
pt.PaperUnits = get(h, 'PaperUnits');
paperPosition = get(h, 'PaperPosition');
pt.PaperPosition = [paperPosition(1), ...
        pt.PaperSize(2) - (paperPosition(2) + paperPosition(4)), ...
        paperPosition(3), ...
        paperPosition(4)];
pt.PaperPositionMode = get(h, 'PaperPositionMode');
pt.FigSize = hgconvertunits(handle(h), get(h, 'Position'), ...
                               get(h, 'units'), pt.PaperUnits, get(h, 'Parent'));
pt.FigSize = pt.FigSize(3:4);
pt.InvertHardCopy = get(h, 'InvertHardCopy');

% get the figure header info...
headerinfo = getappdata(double(h), 'PrintHeaderHeaderSpec');
if ~isempty(headerinfo)
    pt.HeaderText = headerinfo.string;
    pt.HeaderDateFormat = headerinfo.dateformat;
    pt.HeaderFontName = headerinfo.fontname;
    pt.HeaderFontSize = headerinfo.fontsize;
    pt.HeaderFontAngle = headerinfo.fontangle;
    pt.HeaderFontWeight = headerinfo.fontweight;
    pt.HeaderMargin = headerinfo.margin;
end
