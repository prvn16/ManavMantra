function filename = validateCertificateFile(filename)
% Check that filename is a valid certificate file and return the fullpath.
% This function tries to optimize by not re-validating a file that hasn't
% changed.  Only remembers the last file checked.

% Copyright 2016-2017 The MathWorks, Inc.
    persistent validatedFile modified
    filename = char(filename);
    if ~isempty(filename)
        if exist(filename,'file')
            fid = fopen(filename,'r');
            if fid > 0
                clean = onCleanup(@()fclose(fid));
                filename = fopen(fid); % get the full path of the file
                info = dir(filename);
                date = info.date;
                if isequal(validatedFile,filename) && strcmp(date,modified)
                    % We validated this file before.  If it hasn't changed, just return.
                    return
                end
                % see if contains at least one valid certificate header/trailer
                c = fread(fid,inf,'*char').';
                if isempty(regexp(c,'-----BEGIN[a-zA-Z_0-9 ]*CERTIFICATE-----\r*\n.*?-----END[a-zA-Z_0-9 ]*CERTIFICATE-----\r*\n','once'))
                    validatedFile = [];
                    error(message('MATLAB:webservices:BadCertificateFile',filename));
                end
                % file is good, save it
                validatedFile = filename;
                modified = date;
                clear clean
            else
                % out of file descriptors?
                error(message('MATLAB:webservices:CertificateFileNotFound',filename));
            end
        else 
            error(message('MATLAB:webservices:CertificateFileNotFound',filename));
        end
    end
end