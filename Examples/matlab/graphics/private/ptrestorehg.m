function ptrestorehg( pt, h )
%FORMAT Method that restores a Figure after formatting it for output.
%   Input of PrintTemplate object and a Figure to modify.
%   Figure has numerous properties restore to previous values modified
%   to account for template settings.

%   Copyright 1984-2017 The MathWorks, Inc.

if pt.DebugMode
    fprintf(getString(message('MATLAB:uistring:ptrestorehg:RestoringFigure', num2str(double(h)))));
    disp(pt); 
end

if pt.VersionNumber > 1
    hgdata = pt.v2hgdata;
    
    % Restore to all original values
    if isfield(hgdata, 'old') && ~isempty(hgdata.old)
        restoreExport(hgdata.old);
    end
    
    % Restore bkColor
    if isfield(hgdata, 'bkcolor')
        set(h, 'Color', hgdata.bkcolor);
    end
    
    % Restore bkcolormode
    if isfield(hgdata, 'bkcolormode')
        set(h, 'ColorMode', hgdata.bkcolormode);
    end
end

% Restore Axes/Ruler Tick/Limit values
hg1data = pt.v1hgdata;

if isfield(hg1data, 'oldTickLimit')
    restoreExport(hg1data.oldTickLimit);
end

end
