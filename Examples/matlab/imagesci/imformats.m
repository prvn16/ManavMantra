function varargout = imformats(varargin)
%IMFORMATS  Manage file format registry.
%   FORMATS = IMFORMATS returns a structure containing all of the values in
%   the file format registry.  The fields in this structure are:
%
%        ext         - A cell array of file extensions for this format
%        isa         - Function to determine if a file "IS A" certain type
%        info        - Function to read information about a file
%        read        - Function to read image data a file
%        write       - Function to write MATLAB data to a file
%        alpha       - 1 if the format has an alpha channel, 0 otherwise
%        description - A text description of the file format
% 
%   The values for the isa, info, read, and write fields must be functions
%   which are on the MATLAB search path or function handles.
%
%   FORMATS = IMFORMATS(FMT) searches the known formats for a format with
%   extension given in the string "FMT."  If found, a structure is returned
%   containing the characteristics and function names.  Otherwise an empty
%   structure is returned.
% 
%   FORMATS = IMFORMATS(FORMAT_STRUCT) sets the format registry to contain
%   the values in the "FORMAT_STRUCT" structure.  The output structure
%   FORMATS contains the new registry settings.  See the "Warning" statement
%   below.
% 
%   FORMATS = IMFORMATS('add', FORMAT_STRUCT) adds the values in the
%   "FORMAT_STRUCT" structure to the format registry.
%
%   FORMATS = IMFORMATS('factory') resets the file format registry to the
%   default format registry values.  This removes any user-specified
%   settings.
%
%   FORMATS = IMFORMATS('remove', FMT) removes the format with extension
%   FMT from the format registry.
%
%   FORMATS = IMFORMATS('update', FMT, FORMAT_STRUCT) change the format
%   registry values for the format with extension FMT to have the values
%   stored in FORMAT_STRUCT.
% 
%   IMFORMATS without any input or output arguments prettyprints a table of
%   file format information for the supported formats.
%
%   Warning:
%
%     Using IMFORMATS to change the format registry is an advanced feature.
%     Incorrect usage may prevent loading of image files.  Use IMFORMATS
%     with the 'factory' setting to return the format registry to a workable
%     state. 
%   
%   Note:
%
%     Changes to the format registry do not persist between MATLAB sessions.
%     To have a format always available when you start MATLAB, add the
%     appropriate IMFORMATS commands to the startup.m file in
%     $MATLAB/toolbox/local. 
%
%   See also IMREAD, IMWRITE, IMFINFO, PATH.

%   Copyright 1984-2013 The MathWorks, Inc.

% Verify correct number of arguments
narginchk(0, 3);
nargoutchk(0, 1);

% Declare format structure as persistent variable
persistent fmts;

% If format structure is empty (first time)
if (isempty(fmts))
  
    % Build default format structure
    fmts = build_registry;
    mlock
    
end

% Determine what to do based on number of input arguments
switch(nargin)
case 0
    % 0 inputs: Informational only
    
    if (nargout == 0)

        % Pretty-print the registry
        pretty_print_registry(fmts)
        
    else
      
        % Return the registry as a struct
        varargout{1} = fmts;
        
    end
    
case 1
    % 1 input: Look for specific format or modify registry
    
    if (isstruct(varargin{1}))
      
        % Change the registry to contain the structure
        fmts = update_registry(varargin{1});
        varargout{1} = fmts;
        
    elseif (isequal(lower(varargin{1}), 'factory'))
      
        % Reset the registry to the default values
        fmts = build_registry;
        varargout{1} = fmts;

    elseif (ischar(varargin{1}))
      
        % Look for a particular format in the registry
        varargout{1} = find_in_registry(fmts, varargin{1});
        
    else
      
        % Error out, wrong input argument type
        error(message('MATLAB:imagesci:imformats:badInputType'))
        
    end

otherwise
    % n inputs: Modify the registry using a command.

    command = validatestring(varargin{1},{'add','update','remove'});
    
    switch (lower(command))
        case 'add'
            fmts = add_entry(fmts, varargin{2:end});
        case 'update'
            fmts = update_entry(fmts, varargin{2:end});
        case 'remove'
            fmts = remove_entry(fmts, varargin{2:end});
    end
    varargout{1} = fmts;
end

% Protect current file's persistent variables from CLEAR
mlock;


%--------------------------------------------------------------------------
function fmts = build_registry
%BUILD_REGISTRY  Create the file format registry with default values

% Assemble the registry from hard-coded values
fmts(1).ext = {'bmp'};
fmts(1).isa = @isbmp;
fmts(1).info = @imbmpinfo;
fmts(1).read = @readbmp;
fmts(1).write = @writebmp;
fmts(1).alpha = 0;
fmts(1).description = 'Windows Bitmap';

fmts(end + 1).ext = {'cur'};
fmts(end).isa = @iscur;
fmts(end).info = @imcurinfo;
fmts(end).read = @readcur;
fmts(end).write = '';
fmts(end).alpha = 1;
fmts(end).description = 'Windows Cursor resources';

fmts(end + 1).ext = {'fts', 'fits'};
fmts(end).isa = @isfits;
fmts(end).info = @imfitsinfo;
fmts(end).read = @readfits;
fmts(end).write = '';
fmts(end).alpha = 0;
fmts(end).description = 'Flexible Image Transport System';

fmts(end + 1).ext = {'gif'};
fmts(end).isa = @isgif;
fmts(end).info = @imgifinfo;
fmts(end).read = @readgif;
fmts(end).write = @writegif;
fmts(end).alpha = 0;
fmts(end).description = 'Graphics Interchange Format';

fmts(end + 1).ext = {'hdf'};
fmts(end).isa = @ishdf;
fmts(end).info = @imhdfinfo;
fmts(end).read = @readhdf;
fmts(end).write = @writehdf;
fmts(end).alpha = 0;
fmts(end).description = 'Hierarchical Data Format';

fmts(end + 1).ext = {'ico'};
fmts(end).isa = @isico;
fmts(end).info = @imicoinfo;
fmts(end).read = @readico;
fmts(end).write = '';
fmts(end).alpha = 1;
fmts(end).description = 'Windows Icon resources';

fmts(end + 1).ext = {'j2c', 'j2k'};
fmts(end).isa = @isjp2;
fmts(end).info = @imjp2info;
fmts(end).read = @readjp2;
fmts(end).write = @writej2c;
fmts(end).alpha = 0;
fmts(end).description = 'JPEG 2000 (raw codestream)';

fmts(end + 1).ext = {'jp2'};
fmts(end).isa = @isjp2;
fmts(end).info = @imjp2info;
fmts(end).read = @readjp2;
fmts(end).write = @writejp2;
fmts(end).alpha = 0;
fmts(end).description = 'JPEG 2000 (Part 1)';

fmts(end + 1).ext = {'jpf', 'jpx'};
fmts(end).isa = @isjp2;
fmts(end).info = @imjp2info;
fmts(end).read = @readjp2;
fmts(end).write = '';
fmts(end).alpha = 0;
fmts(end).description = 'JPEG 2000 (Part 2)';

fmts(end + 1).ext = {'jpg', 'jpeg'};
fmts(end).isa = @isjpg;
fmts(end).info = @imjpginfo;
fmts(end).read = @readjpg;
fmts(end).write = @writejpg;
fmts(end).alpha = 0;
fmts(end).description = 'Joint Photographic Experts Group';

fmts(end + 1).ext = {'pbm'};
fmts(end).isa = @ispbm;
fmts(end).info = @impnminfo;
fmts(end).read = @readpnm;
fmts(end).write = @writepnm;
fmts(end).alpha = 0;
fmts(end).description = 'Portable Bitmap';

fmts(end + 1).ext = {'pcx'};
fmts(end).isa = @ispcx;
fmts(end).info = @impcxinfo;
fmts(end).read = @readpcx;
fmts(end).write = @writepcx;
fmts(end).alpha = 0;
fmts(end).description = 'Windows Paintbrush';

fmts(end + 1).ext = {'pgm'};
fmts(end).isa = @ispgm;
fmts(end).info = @impnminfo;
fmts(end).read = @readpnm;
fmts(end).write = @writepnm;
fmts(end).alpha = 0;
fmts(end).description = 'Portable Graymap';

fmts(end + 1).ext = {'png'};
fmts(end).isa = @ispng;
fmts(end).info = @impnginfo;
fmts(end).read = @readpng;
fmts(end).write = @writepng;
fmts(end).alpha = 1;
fmts(end).description = 'Portable Network Graphics';

fmts(end + 1).ext = {'pnm'};
fmts(end).isa = @ispnm;
fmts(end).info = @impnminfo;
fmts(end).read = @readpnm;
fmts(end).write = @writepnm;
fmts(end).alpha = 0;
fmts(end).description = 'Portable Any Map';

fmts(end + 1).ext = {'ppm'};
fmts(end).isa = @isppm;
fmts(end).info = @impnminfo;
fmts(end).read = @readpnm;
fmts(end).write = @writepnm;
fmts(end).alpha = 0;
fmts(end).description = 'Portable Pixmap';

fmts(end + 1).ext = {'ras'};
fmts(end).isa = @isras;
fmts(end).info = @imrasinfo;
fmts(end).read = @readras;
fmts(end).write = @writeras;
fmts(end).alpha = 1;
fmts(end).description = 'Sun Raster';

fmts(end + 1).ext = {'tif', 'tiff'};
fmts(end).isa = @istif;
fmts(end).info = @imtifinfo;
fmts(end).read = @readtif;
fmts(end).write = @writetif;
fmts(end).alpha = 0;
fmts(end).description = 'Tagged Image File Format';

fmts(end + 1).ext = {'xwd'};
fmts(end).isa = @isxwd;
fmts(end).info = @imxwdinfo;
fmts(end).read = @readxwd;
fmts(end).write = @writexwd;
fmts(end).alpha = 0;
fmts(end).description = 'X Window Dump';


%--------------------------------------------------------------------------
function pretty_print_registry(fmts)
%PRETTY_PRINT_REGISTRY  Display a table showing the values in the registry

% Initialize variables to hold maximum sizes encountered.  The initial values
% are the minimum values needed for alignment with the header.
s.ext = 3;
s.isa = 3;
s.info = 4;
s.read = 4;
s.write = 5;
s.description = 11;

% Find the maximum lengths of each column
for p = 1:length(fmts)
    % Special case for multiple format extensions
    len = length([fmts(p).ext{:}]) + length(fmts(p).ext) - 1;
    s.ext = max(len, s.ext);
    
    % Remainder are single valued only
    s.isa = max(length(whoami(fmts(p).isa)), s.isa);
    s.info = max(length(whoami(fmts(p).info)), s.info);
    s.read = max(length(whoami(fmts(p).read)), s.read);
    s.write = max(length(whoami(fmts(p).write)), s.write);
    s.description = max(length(fmts(p).description), s.description);
end

% Assemble header for the table
hdr = ['EXT'   repmat(' ', 1, (s.ext - 3 + 2)), ...
       'ISA'   repmat(' ', 1, (s.isa - 3 + 2)), ...
       'INFO'  repmat(' ', 1, (s.info - 4 + 2)), ...
       'READ'  repmat(' ', 1, (s.read - 4 + 2)), ...
       'WRITE' repmat(' ', 1, (s.write - 5 + 2)), ...
       'ALPHA  ', ...
       'DESCRIPTION' repmat(' ', 1, max(0, (s.description - 11)))];

table = cell(1,numel(fmts)+2);
table{1} = hdr;
table{2} = repmat('-', 1, length(hdr));

% Add each format to the table line-by-line
for p = 1:length(fmts)
  
    % Extensions.
    exts = '';
    
    for q = 1:length(fmts(p).ext)
        exts = cat(2, exts, fmts(p).ext{q});
        exts = cat(2, exts, ' ');
    end
    
    exts(end) = '';
    
    table{p + 2} = sprintf('%s%s%s%s%s%s%s%s%s%s%d      %s', ...
             exts, ...
             repmat(' ', 1, (s.ext - length(exts) + 2)), ...
             whoami(fmts(p).isa), ...
             repmat(' ', 1, (s.isa - length(whoami(fmts(p).isa)) + 2)), ...
             whoami(fmts(p).info), ...
             repmat(' ', 1, (s.info - length(whoami(fmts(p).info)) + 2)), ...
             whoami(fmts(p).read), ...
             repmat(' ', 1, (s.read - length(whoami(fmts(p).read)) + 2)), ...
             whoami(fmts(p).write), ...
             repmat(' ', 1, (s.write - length(whoami(fmts(p).write)) + 2)), ...
             fmts(p).alpha, ...
             fmts(p).description);
    
end

% Print the table
disp(' ')
fprintf('%s\n', table{:});


%--------------------------------------------------------------------------
function out = update_registry(in)
%UPDATE_REGISTRY  Change the format registry to the input value

out = in;

% Verify all required fields are in the input structure
if (~isfield(out, 'ext'))
    error(message('MATLAB:imagesci:imformats:extFieldRequired'))
end

if (~isfield(out, 'isa'))
    out(1).isa = '';
end

if (~isfield(out, 'info'))
    out(1).info = '';
end

if (~isfield(out, 'read'))
    out(1).read = '';
end

if (~isfield(out, 'write'))
    out(1).write = '';
end

if (~isfield(out, 'alpha'))
    out(1).alpha = [];
end

if (~isfield(out, 'description'))
    out(1).description = '';
end

% Verify individual fields
for p = 1:length(out)
    s = out(p);
    
    % Check that extensions are nonempty cell arrays of 1-D char arrays
    if (isempty(s.ext))
        error(message('MATLAB:imagesci:imformats:extValueRequired'))
    end
    
    % Convert extensions to lowercase and to cell array if necessary
    if (~iscell(s.ext))
        if (ischar(s.ext) && (size(s.ext, 1) == 1))
            out(p).ext = {lower(s.ext)};
        else
            error(message('MATLAB:imagesci:imformats:extNotCell'))
        end
    else
        % Check each element of a cell array passed in
        for q = 1:length(s.ext)
            if (~ischar(s.ext{q}) || (size(s.ext{q}, 1) ~= 1))
                error(message('MATLAB:imagesci:imformats:extNotCell'))
            end
            
            out(p).ext{q} = lower(s.ext{q});
        end
    end
    
    % Ensure all empty fields are char arrays, except alpha.
    if (isempty(s.isa))
        out(p).isa = '';
    end
    
    if (isempty(s.info))
        out(p).info = '';
    end
    
    if (isempty(s.read))
        out(p).read = '';
    end
    
    if (isempty(s.write))
        out(p).write = '';
    end
    
    if (isempty(s.description))
        out(p).description = '';
    end
    
    if (isempty(s.alpha))
        out(p).alpha = 0;
    end
    
   % Function fields (ISA, INFO, READ, WRITE) must be 1-D char arrays,
   % function handles, or empty.
    tf = [((ischar(s.isa)) || (isa(s.isa, 'function_handle')) || (isempty(s.isa))) ...
          ((ischar(s.info)) || (isa(s.info, 'function_handle')) || (isempty(s.info))) ...
          ((ischar(s.read)) || (isa(s.read, 'function_handle')) || (isempty(s.read))) ...
          ((ischar(s.write)) || (isa(s.write, 'function_handle')) || (isempty(s.write))) ...
          (size(s.isa, 2) == numel(s.isa)) ...
          (size(s.info, 2) == numel(s.info)) ...
          (size(s.read, 2) == numel(s.read)) ...
          (size(s.write, 2) == numel(s.write))];
    
    if (~all(tf))
        error(message('MATLAB:imagesci:imformats:badFunctionName', out( p ).ext{ 1 }));
    end
    
    if (~(ischar(s.description)) && ~(isempty(s.description)))
        error(message('MATLAB:imagesci:imformats:badDescription', out( p ).ext{ 1 }))
    end
end

% Verify the alpha channel data is a scalar integer in [0,1]
try
    alphas = [out(:).alpha];
catch me
    error(message('MATLAB:imagesci:imformats:alphaScalarInt'))
end

if ((~isnumeric(alphas)) || ...
    (~all((alphas == 0) | (alphas == 1))) || ...
    (~(length(alphas) == length(out))))
  
    error(message('MATLAB:imagesci:imformats:alphaValue'))
    
end


%--------------------------------------------------------------------------
function [out, match] = find_in_registry(in, key)
%FIND_IN_REGISTRY  Find a particular format given

validateattributes(key,{'char'},{'nonempty','row'},'','KEY');


% Look for the input format in the formats registry
match = false(1,length(in));
for p = 1:length(in)
    match(p) = any(strcmpi(key, in(p).ext));
end

% Check whether the format was found
switch (sum(match))
case 0
    % Not found.
    out = struct([]);
case 1
    % One match found.
    out = in(match);
end


%--------------------------------------------------------------------------
function out = whoami(in)
%WHOAMI  Take a function handle or string and return the name as a string.

if (ischar(in))
    out = in;
elseif (isa(in, 'function_handle'))
    out = func2str(in);
else
    error(message('MATLAB:imagesci:imformats:badInputFunctionName'))
end



%--------------------------------------------------------------------------
function fmts = add_entry(fmts, format_values)
%ADD_ENTRY  Add a format to the formats registry.

validateattributes(format_values,{'struct'},{'nonempty'},'','FORMAT_VALUES');


% Extensions must appear only once.  Check it.
if (~isfield(format_values, 'ext'))   
    error(message('MATLAB:imagesci:imformats:extFieldRequired'))   
end

if (ischar(format_values.ext))
    if (extAlreadyExists(format_values.ext))       
        error(message('MATLAB:imagesci:imformats:duplicateExtension', format_values.ext))     
    end  
elseif (iscellstr(format_values.ext))  
    for p = 1:numel(format_values.ext)      
        if (extAlreadyExists(format_values.ext{p}))           
            error(message('MATLAB:imagesci:imformats:duplicateExtension', format_values.ext{ p }))          
        end      
    end  
end
    

% Verify new format, but don't actually add it to the registry yet.
format_values = update_registry(format_values);

% Add to the registry.
fmts(end + 1) = format_values;



%--------------------------------------------------------------------------
function fmts = update_entry(fmts, ext, new_values)
%UPDATE_ENTRY  Update a particular format in the registry.

validateattributes(ext,{'char'},{'nonempty'},'','EXT');
validateattributes(new_values,{'struct'},{'nonempty'},'','NEW_VALUES');

[old_values, indices] = find_in_registry(fmts, ext);

if (isempty(old_values))
    
    % If the format doesn't exist in the registry, just add it.
    fmts = add_entry(fmts, new_values);
    
else
    
    % Verify the new format and replace the old format.
    new_values = update_registry(new_values);
    fmts(indices) = new_values;
    
end



%--------------------------------------------------------------------------
function fmts = remove_entry(fmts, ext)
%REMOVE_ENTRY  Remove a format from the registry.

validateattributes(ext,{'char'},{'nonempty'},'','EXT');

% Find format's location in the registry and remove it.
[old_values, indices] = find_in_registry(fmts, ext);

if (isempty(old_values))   
    error(message('MATLAB:imagesci:imformats:formatNotFound', ext)) 
else   
    fmts(indices) = [];  
end



%--------------------------------------------------------------------------
function alreadyExists = extAlreadyExists(extension)

try

    results = imformats(extension);
    alreadyExists = ~isempty(results);
    
catch me %#ok<NASGU>
  
    alreadyExists = false;
    
end
