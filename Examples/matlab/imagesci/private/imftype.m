function [format,fmt_s] = imftype(filename)
%IMFTYPE Determine image file format.
%   [FORMAT,REGISTRY] = IMFTYPE(FILENAME) attempts to determine the image
%   file format for the file FILENAME.  If IMFTYPE is successful,
%   FORMAT will be returned as the first string in the ext field
%   of the format registry (e.g., 'jpg', 'png', etc.)
%
%   FORMAT will be an empty string if IMFTYPE cannot determine
%   the file format.
%   
%   REGISTRY is a structure containing all of the values in
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
%   See also IMREAD, IMWRITE, IMFINFO, IMFORMATS.

%   Copyright 1984-2013 The MathWorks, Inc.

narginchk(1, 1);

% Optimization:  look for a filename extension as a clue for the
% first format to try.

idx = find(filename == '.');
if (~isempty(idx))
    extension = lower(filename(idx(end)+1:end));
else
    extension = '';
end

% Try to get useful imformation from the extension.

if (~isempty(extension))
    
    % Look up the extension in the file format registry.
    fmt_s = imformats(extension);
    
    if (~isempty(fmt_s))
    
        if (~isempty(fmt_s.isa))

            % Call the ISA function for this format.
            tf = feval(fmt_s.isa, filename);
            
            if (tf)
              
                % The file is of that format.  Return the ext field.
                format = fmt_s.ext{1};
                return;
                
            end
        end
    end
end

% No useful information was found from the extension. 

% Get all formats from the registry.
fmt_s = imformats;

% Look through each of the possible formats.
for p = 1:length(fmt_s)
  
    % Call each ISA function until the format is found.
    if (~isempty(fmt_s(p).isa))

        tf = feval(fmt_s(p).isa, filename);
        
        if (tf)
          
            % The file is of that format.  Return the ext field.
            format = fmt_s(p).ext{1};
            fmt_s = fmt_s(p);
            return
            
        end
        
    else
      
        warning(message('MATLAB:imagesci:imftype:missingIsaFunction')); 
        
    end
end

% The file was not of a recognized type.


% Return empty value
format = '';
fmt_s = '';
