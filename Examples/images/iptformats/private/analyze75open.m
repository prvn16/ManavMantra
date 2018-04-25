function fid = analyze75open(filename, ext, mode, defaultByteOrder)
% Open an Analyze 7.5 file.

%   Copyright 2006-2011 The MathWorks, Inc.



% Ensure that filename has a .hdr extension
[pname, fname, passedExt] = fileparts(filename);

if ~isempty(passedExt)
    switch lower(passedExt)
    case {'.hdr','.img'}
        % The file has the correct extension.
            
    otherwise
        error(message('images:analyze75info:invalidFileFormat', passedExt));
        
    end  % switch
end  % if

filename = fullfile(pname, [fname '.' ext]);

if (nargin < 4)
    defaultByteOrder = 'ieee-be';
end

% Open the file with the default ByteOrder.
fid = fopen(filename, mode, defaultByteOrder);

if (fid == -1)
    if ~isempty(dir(filename))
        error(message('images:isanalyze75:hdrFileOpen', filename))
    else
        error(message('images:isanalyze75:hdrFileExist', filename))
    end  % if

end
