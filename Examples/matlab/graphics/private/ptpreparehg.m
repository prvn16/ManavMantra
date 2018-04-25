function pt = ptpreparehg( pt, h )
%PREPAREHG Method of PrintTemplate object that formats a Figure for output.
%   Input of PrintTemplate object and a Figure to modify on.
%   Figure has numerous properties modified to account for template settings.

%   Copyright 1984-2017 The MathWorks, Inc.

if pt.DebugMode
    fprintf(getString(message('MATLAB:uistring:ptpreparehg:PreparingFigure', num2str(double(h)))));
    disp(pt); 
end

% Initialize structure which used to store objects, property and
% corresponding original values throughout the process
oldTickLimit.objs = {};
oldTickLimit.prop = {};
oldTickLimit.values = {};

v1hgdata = [];

newStyle = printingConvertToExportStyle(pt);

% Update Axes/Ruler Tick/Limit mode values, and store original values
oldTickLimit = printingAxesTickLabelUpdate(h, newStyle, oldTickLimit);
v1hgdata.oldTickLimit = oldTickLimit;

pt.v1hgdata = v1hgdata;

% try
if pt.VersionNumber > 1
    
    % Get all necessary objects to process
    objCollections = printingObjectCollection(h);
    
    try
        err = 0;
        
        % Initialize structure which used to store objects, property and
        % corresponding original values throughout the process
        old.objs = {};
        old.prop = {};
        old.values = {};
        
        % Process Font
        old = printingFontUpdate(objCollections.allFont, newStyle, old);
        
        % Process Line
        old = printingLineUpdate(objCollections.line, newStyle, old);
        
        if isfield(pt,'DriverColor')
            if pt.DriverColor == 1 && isfield(pt, 'GrayScale') && pt.GrayScale==1
                old = printingGrayscaleUpdate(objCollections, old);
            end
        end
        
        if strcmp('off', get(h,'InvertHardcopy')) && isfield(pt, 'BkColor') && ~isempty(pt.BkColor)
            hgdata.bkcolor = get(h, 'Color');
            if any(pt.BkColor == '[')
                % use str2num to convert the string array of values into a
                % double array
                pt.BkColor = str2num(pt.BkColor); %#ok<ST2NM>
            end
            hgdata.bkcolormode = get(h, 'ColorMode');
            set(h, 'Color', pt.BkColor');
        end
    catch ex
        err = 1;
    end
    hgdata.old = old;
    pt.v2hgdata = hgdata;
    
    % If there's a failure, still propagate the error up. But roll back all
    % changes made to the figure FIRST.
    if err
        ptrestorehg( pt, h );
        rethrow( ex );
    end
end
end

% LocalWords:  PREPAREHG YTick ZTick grayscale XColor YColor ZColor
