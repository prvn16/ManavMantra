function success = validateFile(filename)
%VALIDATEFILE Validates that the specified file is indeed a HDF file.
%   This function should be used prior to opening an HDF file.
%
%   Function arguments
%   ------------------
%   FILENAME: the name of the file to validate.

%   Copyright 2005-2013 The MathWorks, Inc.

    % Find and open the file
    fid = fopen(filename,'r');
    if (fid == -1)
        error(message('MATLAB:imagesci:hdftool:fileOpen', filename));
    else
        filename = fopen(fid);
        fclose(fid);
    end

    % Determine if the file is HDF.
    success = hdfh('ishdf',filename);

end

