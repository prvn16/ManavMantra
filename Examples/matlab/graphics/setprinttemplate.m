function setprinttemplate( h, pt )
%SETPRINTTEMPLATE Sets a figure's PrintTemplate

%   Copyright 1984-2006 The MathWorks, Inc. 

if isfield(pt, 'PaperType')
    set(h, 'PaperType', pt.PaperType);
    pt = rmfield(pt, 'PaperType');
end    
if isfield(pt, 'PaperOrientation')
    set(h, 'PaperOrientation', pt.PaperOrientation);
    pt = rmfield(pt, 'PaperOrientation');
end
% Set PaperUnits before papersize or paperposition, otherwise it'll convert
% twice over
if isfield(pt, 'PaperUnits')
    set(h, 'PaperUnits', pt.PaperUnits);
    pt = rmfield(pt, 'PaperUnits');
end
if isfield(pt, 'PaperSize')
    set(h, 'PaperSize', pt.PaperSize);
    pt = rmfield(pt, 'PaperSize');
end
% Be sure to set the PaperPosition BEFORE the PaperPositionMode.
% If we do it in the reverse order, the act of setting the PaperPosition
% will reset a PaperPositionMode of 'manual' to 'auto'.
if isfield(pt, 'PaperPosition')
    paperPosition = pt.PaperPosition;
    paperSize = get(h, 'PaperSize');
    adjustedPaperPosition = [paperPosition(1), ...
        paperSize(2) - (paperPosition(2) + paperPosition(4)), ...
        paperPosition(3), ...
        paperPosition(4)];
    set(h, 'PaperPosition', adjustedPaperPosition);
    pt = rmfield(pt, 'PaperPosition');
end
if isfield(pt, 'PaperPositionMode')
    set(h, 'PaperPositionMode', pt.PaperPositionMode);
    pt = rmfield(pt, 'PaperPositionMode');
end
if isfield(pt, 'InvertHardCopy')
    set(h, 'InvertHardCopy', pt.InvertHardCopy);
    pt = rmfield(pt, 'InvertHardCopy');
end

% Separate the headerinfo
hs = struct('dateformat','none',...
            'string','',...
            'fontname',get(0,'DefaultTextFontName'),...
            'fontsize',12,...   % in points
            'fontweight','normal',...
            'fontangle','normal',...
            'margin',72);
foundheader = false;        
if isfield(pt, 'HeaderText')
    hs.string = pt.HeaderText;
    pt = rmfield(pt, 'HeaderText');
    foundheader = true;
end
if isfield(pt, 'HeaderDateFormat')
    hs.dateformat = pt.HeaderDateFormat;
    pt = rmfield(pt, 'HeaderDateFormat');
    foundheader = true;
end
if isfield(pt, 'HeaderFontName')
    hs.fontname = pt.HeaderFontName;
    pt = rmfield(pt, 'HeaderFontName');
    foundheader = true;
end
if isfield(pt, 'HeaderFontSize')
    hs.fontsize = pt.HeaderFontSize;
    pt = rmfield(pt, 'HeaderFontSize');
    foundheader = true;
end
if isfield(pt, 'HeaderFontAngle')
    hs.fontangle = pt.HeaderFontAngle;
    pt = rmfield(pt, 'HeaderFontAngle');
    foundheader = true;
end
if isfield(pt, 'HeaderFontWeight')
    hs.fontweight = pt.HeaderFontWeight;
    pt = rmfield(pt, 'HeaderFontWeight');
    foundheader = true;
end
if isfield(pt, 'HeaderMargin')
    hs.margin = pt.HeaderMargin;
    pt = rmfield(pt, 'HeaderMargin');
    foundheader = true;
end
if foundheader
  setappdata(double(h), 'PrintHeaderHeaderSpec', hs);
end

% Set the printtemplate structure as a property of the figure
set(h, 'PrintTemplate', pt);
    

