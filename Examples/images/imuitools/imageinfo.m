function hfigure = imageinfo(varargin)
%IMAGEINFO Image Information tool.
%   IMAGEINFO creates an Image Information tool associated with the image
%   in the current figure. The tool displays information about the basic
%   attributes of the target image in a separate figure. The information
%   includes:
%
%      Width (columns)
%      Height (rows)
%      Class
%      Image type
%      Minimum intensity/index (only for 'intensity' or 'indexed' images)
%      Maximum intensity/index (only for 'intensity' or 'indexed' images)
%
%   IMAGEINFO(H) creates an Image Information tool associated with H, where
%   H is a handle to a figure, axes, or image object.
%
%   IMAGEINFO(FILENAME) creates an Image Information tool containing image
%   metadata from the graphics file FILENAME. The image does not have to be
%   displayed in a figure window. FILENAME can be any file type that has
%   been registered with an information function in the file formats
%   registry, IMFORMATS, so its information can be read by IMFINFO.
%   FILENAME can also be a DICOM, NITF, INTERFILE, or ANALYZE file.
%
%   IMAGEINFO(INFO) creates an Image Information tool containing image
%   metadata in the structure INFO. INFO is a structure returned by the
%   functions IMFINFO, DICOMINFO, NITFINFO, INTERFILEINFO, or
%   ANALYZE75INFO.  INFO can also be a user-created structure.
%
%   IMAGEINFO(HIMAGE,FILENAME) creates an Image Information tool containing
%   information about the basic attributes of the image specified by the
%   handle HIMAGE and the image metadata from the graphics file FILENAME.
%
%   IMAGEINFO(HIMAGE,INFO) creates an Image Information tool containing
%   information about the basic attributes of the image specified by the
%   handle HIMAGE and the image metadata in the structure INFO.
%
%   HFIGURE = IMAGEINFO(...) returns a handle to the Image Information
%   tool figure.
%
%   Note
%   ----
%   The Image Information tool gets information about image attributes
%   by querying the image object's CData. The image object converts the
%   CData for a single or int16 images to class double. In these cases,
%   IMAGEINFO(H) returns a 'Class' of 'double', even though the image
%   is of class single or int16. For example,
%
%       h = imshow(ones(10,'int16'));
%       class(get(h,'CData'))
%
%   Examples
%   --------
%
%       imageinfo('peppers.png');
%
%       h = imshow('bag.png');
%       info = imfinfo('bag.png');
%       imageinfo(h,info);
%
%       imshow('canoe.tif');
%       imageinfo;
%
%  See also ANALYZE75INFO, DICOMINFO, IMATTRIBUTES, IMFINFO, IMFORMATS, IMTOOL, INTERFILEINFO, NITFINFO.

%   Copyright 1993-2017 The MathWorks, Inc.

args = matlab.images.internal.stringToChar(varargin);
% parse inputs
[h,metadata,metadataName] = parseInputs(args{:});

% create tool figure
tool_name = getString(message('images:imageinfoUIString:toolName'));
h_fig = figure('IntegerHandle','off',...
    'NumberTitle','off',...
    'Name',tool_name,...
    'Tag','imageinfo',...
    'Toolbar','none',...
    'Menubar','none',...
    'HandleVisibility','callback',...
    'ResizeFcn',@figResizeFcn,...
    'visible','off',...
    'WindowStyle',get(0,'FactoryFigureWindowStyle'));

suppressPlotTools(h_fig);

% declare function scope variables
details_label = [];
details_table = [];
metadata_label = [];
metadata_table = [];
h_image = [];

% Add a blank uitoolbar to get docking arrow on all platforms.  Cannot use a
% blank uimenu due to g222793.
uitoolbar(h_fig);

% special case for R-Set image info we want to save the reference to the
% R-Set overview image object, but only display the provided metadata
rset = [];
if ~isempty(h) && strcmp(get(h,'tag'),'rset overview')
    rset = h;
    h = [];
end

% create and position tables
initializeImageInfo;

% make figure tight around table if we have only one table
if isempty(metadata)
    fig_pos = get(h_fig,'Position');
    details_label_pos = get(details_label,'Position');
    details_table_pos = get(details_table,'Position');
    fig_width = max(details_label_pos(3),details_table_pos(3));
    fig_height = details_label_pos(4) + details_table_pos(4);
    fig_origin_y = fig_pos(2) + details_label_pos(2) + ...
        details_label_pos(4) - fig_height;
    set(h_fig,'Position',[fig_pos(1) fig_origin_y fig_width fig_height]);
    set(h_fig,'Resize','off');
elseif isempty(h)
    fig_pos = get(h_fig,'Position');
    metadata_label_pos = get(metadata_label,'Position');
    metadata_table_pos = get(metadata_table,'Position');
    fig_width = max(metadata_label_pos(3),metadata_table_pos(3));
    fig_height = metadata_label_pos(4) + metadata_table_pos(4);
    fig_origin_y = fig_pos(2) + metadata_label_pos(2) + ...
        metadata_label_pos(4) - fig_height;
    set(h_fig,'Position',[fig_pos(1) fig_origin_y fig_width fig_height]);
end

% if we have an R-Set reset our h_image variable for figure alignment and
% reactToImageChanges
if ~isempty(rset)
    h_image = rset;
    target_fig = ancestor(h_image,'figure');
end

% if we have a target image, align the tool and listen for image changes
if ishghandle(h_image,'image')

    iptwindowalign(target_fig,'left',h_fig,'left');
    iptwindowalign(target_fig,'bottom',h_fig,'top');
    
    reactToImageChangesInFig(h_image,h_fig,@reactDeleteFcn,...
        @reactRefreshFcn);
    registerModularToolWithManager(h_fig,h_image);
    
end

% turn on figure visibility and return output args
set(h_fig,'Visible','on');
if nargout > 0
    hfigure = h_fig;
end


    %-------------------------------
    function reactDeleteFcn(obj,evt) %#ok<INUSD>
        
        if ishghandle(h_fig)
            delete(h_fig)
        end
        
    end


    %--------------------------------
    function reactRefreshFcn(obj,evt) %#ok<INUSD>

        % close tool if the target image cdata is empty
        if isempty(get(h_image,'CData'))
            reactDeleteFcn();
            return;
        end
        
        % delete old labels and tables
        if ishghandle(details_table)
            delete(details_label);
            delete(details_table);
        end
        if ishghandle(metadata_table)
            delete(metadata_label);
            delete(metadata_table);
        end
        
        % wipe any old metadata if we have it
        metadata = [];

        % recreate new details table
        initializeImageInfo;

    end


    %---------------------------
    function initializeImageInfo

        % initialize image handle
        h_image = [];

        % initialize tool name
        tool_name = getString(message('images:imageinfoUIString:toolName'));
        h_fig_name = tool_name;
        set(h_fig,'Name',h_fig_name);
        
        % create tables based on function input
        if isempty(h)
            % create metadata table only
            createMetadataTable;
            % use metadata name in figure name
            if ~isempty(metadataName)
                h_fig_name = sprintf('%s %s', tool_name, metadataName);
                set(h_fig,'Name',h_fig_name);
            end

        elseif isempty(metadata)
            % create details table only
            [h_image,target_fig] = checkhandle(h);
            createDetailsTable;

        else
            % create both details and metadata tables
            [h_image,target_fig] = checkhandle(h);
            % creation order matters
            createDetailsTable;
            createMetadataTable;

        end
       
    end


    %-----------------------------
    function figResizeFcn(~,~)
        if ishghandle(details_table)
            positionDetailsTable
        end
        if ishghandle(metadata_table)
            positionMetadataTable
        end

    end

    %--------------------------
    function createDetailsTable

        % set name on image info tool figure
        target_fig_name = createFigureName('',target_fig);
        set(h_fig,'Name',sprintf('%s%s',tool_name,target_fig_name));
        fig_color = get(h_fig,'Color');

        % create label for details table
        details_label_text = getString(message('images:imageinfoUIString:imageDetails',target_fig_name));
        details_label = uicontrol('Parent',h_fig,...
            'Style','text',...
            'BackgroundColor',fig_color,...
            'HorizontalAlignment','left',...
            'Units','pixels',...
            'Tag','details label',...
            'FontSize',10,...
            'String', details_label_text);

        % create details table
        attributes = imattributes(h_image);
        details_table_data = createTableDataFromCellArray(attributes);
        % 'RowName',[] removes the first "row number" column
        details_table = uitable('Parent',h_fig,...
            'ColumnName',{getString(message('images:imageinfoUIString:attribute')),getString(message('images:imageinfoUIString:value'))},...
            'RowName',[],...
            'FontUnits','pixels',...
            'FontSize',10,...
            'Data',details_table_data,...
            'Tag','detailsTable');
        
        % position details label and table
        positionDetailsTable;

    end % createDetailsTable


    %----------------------------
    function positionDetailsTable

        % get figure and label sizes
        h_fig_pos = get(h_fig,'Position');
        fig_height = h_fig_pos(4);
        details_label_extent = get(details_label,'Extent');
        label_width = details_label_extent(3);
        label_height = details_label_extent(4);
        
        % put label at the top of the figure. Add 5 pixels space on top and
        % bottom to evenly space out the vertical placement.
        set(details_label,'Position',...
            [1 ...
            fig_height - label_height - 5 ...
            label_width ...
            label_height+5]);

        % get table extent and add some extra width for aesthetics
        [details_table_extent,max_col_one,max_col_two] = getTableExtent(details_table);
        table_width = details_table_extent(3) * 1.8;
        table_height = details_table_extent(4);
        
        % Add a fudge factor to the height to avoid displaying scrollbars
        % Use different fudge factors depending on locale
        if strncmpi(get(0,'lang'),'en',2)
            table_height = table_height + 1.0;
        else
            table_height = table_height + 22.0;
        end
                    
        % position table below label
        details_label_pos = get(details_label,'Position');
        set(details_table,'Position',...
            [1 ...
            details_label_pos(2) - table_height ...
            table_width ...
            table_height]);
        
        % compute the usable width that we can allocate to columns in the 
        % table.  account for beveled table edge decorations.
        usable_width = table_width - 4;

        % adjust columns widths to fit usable space
        adjustTableColumns(details_table,usable_width,max_col_one,...
            max_col_two);
        
    end % positionDetailsTable


    %--------------------------
    function createMetadataTable

        fig_color = get(h_fig,'Color');

        % create label for metadata table
        metadata_label = uicontrol('Parent',h_fig,...
            'Style','text',...
            'BackgroundColor',fig_color,...
            'HorizontalAlignment','left',...
            'Units','pixels',...
            'Tag','metadata label',...
            'FontSize',10,...
            'String', getString(message('images:imageinfoUIString:metadataLabel',metadataName)));

        % create metadata table
        metadata_table_data = createTableDataFromStruct(metadata);
        metadata_table = uitable('Parent',h_fig,...
            'ColumnName',{getString(message('images:imageinfoUIString:attribute')),getString(message('images:imageinfoUIString:value'))},...
            'RowName',[],...
            'FontUnits','pixels',...
            'FontSize',10,...
            'Data',metadata_table_data,...
            'Tag','metadataTable');
        
        % position metadata label and table
        positionMetadataTable;

    end % createMetadataTable


    %----------------------------
    function positionMetadataTable

        % get figure and label sizes
        h_fig_pos = get(h_fig,'Position');
        fig_width = h_fig_pos(3);
        fig_height = h_fig_pos(4);
        metadata_label_extent = get(metadata_label,'Extent');
        label_width = metadata_label_extent(3);
        label_height = metadata_label_extent(4);

        % find upper bound of available real estate
        if ishghandle(details_table)
            details_table_pos = get(details_table,'Position');
            upper_bound = details_table_pos(2) - 1;
        else
            upper_bound = fig_height;
        end

        % place label as high as possible. Add 5 pixels vertical space
        % above the label.
        set(metadata_label,'Position',...
            [1 ...
            upper_bound - label_height - 5 ...
            label_width ...
            label_height]);

        % get table extent and ensure it has positive size since it will
        % resize according to figure size
        metadata_label_pos = get(metadata_label,'Position');
        [metadata_table_extent,max_col_one,max_col_two] = getTableExtent(metadata_table);
        table_width = max(1,fig_width);
        % how much space is remaining below the label
        vertical_space = max(1,metadata_label_pos(2) - 1);
        % table height should not exceed the remaining vertical space
        table_height = min(vertical_space,metadata_table_extent(4));
        
        % adjust the table base to keep it flush with the bottom of the
        % label
        table_base = max(1,vertical_space - table_height + 1);
        
        % position table below label extending to figure edges
        set(metadata_table,'Position',...
            [1 ...
            table_base ...
            table_width ...
            table_height]);
        
        % compute usable area to divide between table columns.  Its ok for
        % this to be greater than the figure width because we will get
        % scrollbars.
        usable_width = max(fig_width,metadata_table_extent(3));
        
        % subtract the border decorations (2 pixels on each side)
        usable_width = usable_width - 4;
        
        % account for vertical scrollbar width
        vertical_sb_width = 16;
        usable_width = usable_width - vertical_sb_width;

        % adjust columns widths to fit usable space
        adjustTableColumns(metadata_table,usable_width,max_col_one,...
            max_col_two);

    end % positionMetadataTable


    %-----------------------------------
    function [him,hFig] = checkhandle(h)
        
        him = imhandles(h);
        
        if isempty(him)
            close(h_fig);
            error(message('images:common:noImageInFigure'))
        elseif ~isscalar(him)
            him = him(1);
            warning(message('images:imageinfo:ignoreMultipleImageHandles'))
        end
        
        hFig = ancestor(him,'figure');
        
    end % checkhandle

end % imageinfo





%----------------------------------------------------------
function [h,metadata,metadataLabel] = parseInputs(varargin)

% assign defaults
h = [];
metadata = [];
metadataLabel = [];
metadataOrFile = [];

narginchk(0,2);

switch nargin
    case 0
        h = get(0,'CurrentFigure');
        if isempty(h)
            error(message('images:common:notAFigureHandle', upper( mfilename )))
        end

    case 1
        if isstruct(varargin{1}) || ischar(varargin{1}) 
            metadataOrFile = varargin{1};
        elseif ishghandle(varargin{1})
            h = varargin{1};
            iptcheckhandle(h,{'image','axes','figure'},mfilename,'H',1);
        else
            error(message('images:imageinfo:invalidInputArgument'))
        end

    case 2
        h = varargin{1};
        metadataOrFile = varargin{2};

        iptcheckhandle(h,{'image'},mfilename,'HIMAGE',1);

        if ~isstruct(metadataOrFile) && ~ischar(metadataOrFile)
            error(message('images:imageinfo:invalidStructureOrFilename'))
        end
end

if ~isempty(metadataOrFile)
    [metadata,metadataLabel] = getMetadata(metadataOrFile);
end

end % parseInputs


%-------------------------------------------------------
function [metadata,label] = getMetadata(structureOrFile)

if isstruct(structureOrFile)
    % struct containing metadata
    
    metadata = structureOrFile;
    % Take metadata of first first frame if coming from multiframe file.
    metadata = metadata(1);

    % construct the label from the filename (if we can find in struct)
    fnames = fieldnames(metadata);
    idx = strncmpi('Filename',fnames,length('Filename'));
    if any(idx,1)
        field = fnames(idx == 1);
        label = metadata.(field{1});
        [~,n,ext] = fileparts(label);
        label = sprintf('(%s)',[n ext]);
    else
        label = '';
    end

else
    % filename to get metadata from

    % label is filename
    label = structureOrFile;
    try
        metadata = imfinfo(structureOrFile);
    catch %#ok<CTCH>
        try
            metadata = dicominfo(structureOrFile);
        catch %#ok<CTCH>
            try
                metadata = nitfinfo(structureOrFile);
            catch %#ok<CTCH>
                try
                    metadata = analyze75info(structureOrFile);
                catch %#ok<CTCH>
                    try
                        metadata = interfileinfo(structureOrFile);
                    catch %#ok<CTCH>
                        error(message('images:imageinfo:couldNotReadFile', label))
                    end
                end
            end
        end
    end
    label = sprintf('(%s)',label);
    
    % Take metadata of first first frame if coming from multiframe file.
    metadata = metadata(1);

end

end % getMetadata


%---------------------------------------------------
function tableData = createTableDataFromCellArray(c)

fieldNames = c(:,1);
values = c(:,2);
charArray = evalc('disp(values)');
C = textscan(charArray,'%s','delimiter','\n');
dispOfValues = C{1};

numFields = length(fieldNames);
tableData = cell(numFields,2);

% First column of tableData contain fieldNames. Second column of tableData
% contains the string representation of values. We use the values or
% dispOfValues depending on whether each element of values is a vector of
% characters.
tableData(:,1) = fieldNames;
for idx = 1: numFields
    val = values{idx};
    if ischar(val) && size(val,1) == 1
        tableData{idx,2} = val;
    else
        val = dispOfValues{idx};
        spaces = isspace(val);  % Remove extra whitespace,e.g, [    8].
        val(spaces)= '';
        tableData{idx,2} = val;
    end
end

end % createTableDataFromCellArray


%------------------------------------------------
function tableData = createTableDataFromStruct(s)

fieldNames = fieldnames(s);
values = struct2cell(s);

charArray = evalc('disp(s)');
C = textscan(charArray,'%s','delimiter','\n');
fieldnameAndValue = C{1};
numLines = length(fieldnameAndValue);
dispOfValues = cell(numLines);
for k = 1 : numLines
  idx = find(fieldnameAndValue{k}==':');
  if ~isempty(idx) % to avoid blank lines
    dispOfValues{k} = fieldnameAndValue{k}((idx(1)+2):end);
  end
end

numFields = length(fieldNames);
tableData = cell(numFields,2);

% First column of tableData contain fieldNames. Second column of tableData
% contains the string representation of values. We use the values or
% dispOfValues depending on whether each element of values is a vector of
% characters.
tableData(:,1) = fieldNames;
for idx = 1: numFields
    val = values{idx};
    if ischar(val) && size(val,1) == 1
        tableData{idx,2} = val;
    else
        tableData{idx,2} = dispOfValues{idx};
    end
end

end % createTableDataFromStructure


function [table_extent,max_col_one,max_col_two] = getTableExtent(h_table)

% find max row width in the table data
table_data = get(h_table,'Data');
size_of_data = cellfun('prodofsize',table_data);
max_col_one = max(size_of_data(:,1));
max_col_two = max(size_of_data(:,2));
max_width_of_data = max_col_one + max_col_two;%max(sum(size_of_data,2));

% if the table data is empty assign value of 1 to width
if isempty(max_width_of_data)
    max_width_of_data = 1;
end

% find row width of the column header row
column_names = get(h_table,'columnName');
size_of_column_headers = cellfun('prodofsize',column_names);
width_of_column_headers = sum(size_of_column_headers);

% max_width is the longest row (in characters) of the table
max_width = max(max_width_of_data,width_of_column_headers);

% find table height (include header row)
num_rows = size(table_data, 1);
max_height = num_rows + 1;

% compute width and height based on font size.  note: default font is not
% monospaced so this is a (conservative) approximation.
font_size = get(h_table,'FontSize');
table_width = 0.75 * max_width * font_size;
table_height = 1.85 * max_height * font_size;
table_extent = [0 0 table_width table_height];

end % getTableExtent


function adjustTableColumns(h_table,usable_width,max_col_one,max_col_two)

col_one_percent = max_col_one / (max_col_one + max_col_two);
col_one_width = floor(usable_width * col_one_percent);
col_two_width = usable_width - col_one_width;
set(h_table,'ColumnWidth',{col_one_width col_two_width});

end % adjustTableColumns
