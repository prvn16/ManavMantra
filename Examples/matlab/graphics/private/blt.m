function bool = blt( pj, h )
%BLT Returns FALSE if Lines and Text objects in Figure should be printed in black.

%   Copyright 1984-2014 The MathWorks, Inc.

%DriverColorSet was turned to TRUE iff there was a device cmd line argument
%If there was a cmd line device argument we use the DriverColor resulting from it
%
%Otherwise we look for a PrintTemplate object in the Figure
%If there is one we return its DriverColor boolean value.
%
%Otherwise, on windows, 
% 1. if we're printing from the dialog (pj.Verbose) we
%    return true (and let the print code determine later if we need to change
%    to b&w)
% 2. if we're not printing from the dialog we base decision on whether or
%    not the printer supports color 
%
% Otherwise we just look at the driver and whether it says it supports color 
% (pj.DriverColor)

%depviewer should always be printed in color mode to avoid
%the going through NODITHER
if( length(pj.Handles) == 1 && ...
    strcmpi(get(pj.Handles{1},'Tag'),'DAStudio.DepViewer') )
    bool = true;
    return;
end

if pj.DriverColorSet
    bool = pj.DriverColor;
else
    pt = getprinttemplate(h);
    if isempty( pt ) 
        %default to using setting based on default driver from PRINTOPT.
        bool = pj.DriverColor;
        if ispc && strncmp( pj.Driver, 'win', 3 )
        % using Windows print dialog - determine later if conversion needed
            if pj.Verbose
                bool = true;
            else
                % command line - ask if printer supports color
                bool = queryPrintServices('supportscolor', pj.PrinterName);
            end
        end
    else
        bool = pt.DriverColor;
    end
end

bool = logical(bool);
end
