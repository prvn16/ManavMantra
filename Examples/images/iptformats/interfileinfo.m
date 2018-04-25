function info = interfileinfo(filename)
%INTERFILEINFO Read metadata from Interfile 3.3 files.
%   INFO = INTERFILEINFO(FILENAME) returns a structure whose fields contain
%   information about images in an Interfile file.  FILENAME is a string or
%   character vector that specifies the name of the graphics file.  The
%   file must be in the current directory or in a directory on the MATLAB
%   path.
%   
%   Examples
%   --------
%
%       info = interfileinfo('MyFile.hdr');
%
%   For more information on the Interfile format, go to this website:
%
%   http://www.medphys.ucl.ac.uk/interfile/
%
%   See also INTERFILEREAD.

%   Copyright 2005-2017 The MathWorks, Inc.

filename = matlab.images.internal.stringToChar(filename);

info = [];
% check header file extension
if (isempty(filename) || ~ischar(filename))
    error(message('images:interfileinfo:filenameNotChar'))
end
[~, ~, ext] = fileparts(filename);
if isempty(ext)
    filename = [filename '.hdr'];
end

% open file for parsing
fid = fopen(filename);
if fid == -1
    error(message('images:interfileinfo:invalidFilename', filename));
end

% initialize variables
bad_chars = '!()[]/-_';
dates = ['DateOfKeys' 'ProgramDate' 'PatientDob' 'StudyDate'];
times = ['StudyTime' 'ImageStartTime'];
found_header = 0;
found_end = 0;
line_num = 0;

% parse through the file
while (true)
    line_txt = fgetl(fid);
    % stop if no more lines
    if (line_txt == -1)
        break;
    end
    
    % Strip out comments.  Interfile v3.3 spec, paragraph I.4.H: "Key-value
    % pairs may have comments appended to them by preceding the comment with
    % a semicolon <;>.  Conversion programs can ignore all characters
    % including and following a semicolon  <;> to the end of line code.
    % Where no key is stated, for example when an ASCII line starts with a
    % semicolon, the whole line is treated as comment.
    line_txt = regexprep(line_txt, ';.*$', '');
        
    if (sum(isspace(line_txt)) == length(line_txt))
        % Line is empty, skip to the next.
        continue;

    else
        line_num = line_num+1;
        % find index of separator and issue warning if not found
        sep_ind = strfind(line_txt, ':=');
        if (isempty(sep_ind))
            fclose(fid);
            % if no separator on first non-empty line, then not in INTERFILE format
            if isempty(info)
                error(message('images:interfileinfo:invalidFile', filename));
                
            % if not on first non-empty line, then invalid expression
            else
                error(message('images:interfileinfo:noSeparator', num2str( line_num ), filename));
            end
        
        else
            field_str_ind = 1;
            value_str_ind = sep_ind+2;
            field = '';
            
            % parse string to extract field
            while (true)
                [str, count, ~, nextindex] = sscanf(line_txt(field_str_ind:sep_ind-1), '%s', 1);
                % check for duplicate header
                if (strcmp(str, '!INTERFILE'))
                    if (found_header == 1)
                        fclose(fid);
                        error(message('images:interfileinfo:duplicateHeader', line_num, filename));
                        
                    else
                        found_header = 1;
                    end
                end
                
                % break if no field in rest of string
                if (count == 0)
                    break;
                end
                
                % concatenate strings to form field
                if (strcmp(str, 'ID'))
                    field = [field str]; %#ok<AGROW>
                    
                else
                    str = lower(str);
                    i = 1;
                    
                    % remove illegal characters
                    while (i <= length(str))
                        k = strfind(bad_chars, str(i));
                        if (~isempty(k))
                            if (k >= 6)
                                str = [str(1:i-1) upper(str(i+1)) str(i+2:length(str))];

                            else
                                str = [str(1:i-1) str(i+1:length(str))];
                            end
                        end

                        i = i+1;
                    end
                    
                    field = [field upper(str(1)) str(2:length(str))]; %#ok<AGROW>
                end
                
                field_str_ind = field_str_ind+nextindex-1;
            end
            
            % remove extra spaces from beginning of value string
            for i = value_str_ind:length(line_txt)
                if (~isspace(line_txt(i)))
                    break;
                end
            end
            
            value = strcat(line_txt(i:length(line_txt)), '');
            if (strcmp(field, 'VersionOfKeys'))
                if (~strcmp(value, '3.3'))
                    fclose(fid);
                    error(message('images:interfileinfo:unsupportedVersion'))
                end
            end
            
            if isempty(value)
                value = '';
            end
                
            [x, ok] = str2num(value);
            if ((ok ~= 0) && (isempty(strfind(dates, field))) && (isempty(strfind(times, field))))
                value = x;
            end
            
            % close file if end-of-file marker encountered
            if (strcmp(field, 'EndOfInterfile'))
                found_end = 1;
                break;
                
            else
                % check for header
                if (found_header == 0)
                    fclose(fid);
                    error(message('images:interfileinfo:noHeader'))

                % store field and value
                elseif (~strcmp(field, 'Interfile'))
                    if (isfield(info, field))
                        if (ischar(info.(field)))
                            info.(field) = {info.(field) value};
                            
                        elseif (iscell(info.(field)))
                            info.(field){length(info.(field))+1} = value;
                            
                        else
                            info.(field) = [info.(field) value];
                        end
                        
                    else
                        info.(field) = value;
                    end
                end
            end
        end
    end
end

% check for end of file marker
if (found_end == 0)
    fclose(fid);
    error(message('images:interfileinfo:unexpectedEOF'))
end

% close file
fclose(fid);
