function [tf, nitf_version] = isnitf(filename)
%ISNITF   Check if file is NITF.
%    [TF, NITF_VERSION] = ISNITF(FILENAME) checks whether a file contains
%    NITF data, returning TRUE in TF if it does and FALSE otherwise.  If
%    the file does contain NITF data, NITF_VERSION contains the format
%    version.
%
%    See also NITFINFO, NITFREAD.

%   Copyright 2007-2014 The MathWorks, Inc.

% Open the file.
[fid, msg] = fopen(filename, 'r');
if (fid < 0)
    
  error('images:isnitf:fileOpen','%s',getString(message('MATLAB:images:isnitf:fileOpen', filename, msg)));
end

% Get first conditional NITF header fields and inspect the first for the NITF version.
fhdr = fread(fid, 324, 'uint8=>char');
fclose(fid);

%Check the NITF version
if (numel(fhdr) == 324 && isequal(char(fhdr(1:9))', 'NITF02.10'))

  % It's an NITF2.1 file.
  nitf_version = '2.1';
  tf = true;
  
elseif (numel(fhdr) == 324 && isequal(char(fhdr(1:9))', 'NITF02.00')) 
   
  % It's an NITF2.0 file.
  nitf_version = '2.0';
  tf = true;

elseif (numel(fhdr) == 324 && isequal(char(fhdr(1:9))', 'NITF01.10')) 
   
  % It's an NITF1.1 file.
  nitf_version = '1.1';
  tf = true;
  
elseif (numel(fhdr) == 324 && isequal(char(fhdr(1:9))', 'NSIF01.00'))
    
    % It's an NSIF 1.0 file which translates to an NITF2.1 file;
    nitf_version = '2.1';
    tf = true;
        
else
  
  % If we can't determine the NITF version the file is invalid
    nitf_version = 'UNK';
    tf = false;
end

end
