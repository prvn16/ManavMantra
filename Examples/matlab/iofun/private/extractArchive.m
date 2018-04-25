function files = extractArchive(outputDir, api, fcnName)
    %EXTRACTARCHIVE Extract archive file contents
    %
    %   EXTRACTARCHIVE extracts archive file contents to OUTPUTDIR from an
    %   archive defined by ARCHIVEINSTREAM. The output FILES is a string cell
    %   array of relative path filenames extracted from the archive.
    %
    %   OUTPUTDIR is a string containing the directory for the extracted files.
    %
    %   ARCHIVEINSTREAM is a Java stream object attached to the input archive
    %   file.
    %
    %   FCNNAME is the string name of the calling function.
    
    %   Copyright 2004-2016 The MathWorks, Inc.
    
    % Set flags.
    eof = false;
    files = {};
    verbose = false;
    
    % Define ^M (control-M) character.
    cntrlM = char(13);
    
    % Create a stream copier to copy files.
    streamCopier = ...
        com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier;
    
    % Extract each entry.
    while ~eof
        entry = api.getNextEntry();
        if ~isempty(entry)
            % Obtain the entry's output name,
            % replacing \ with / for Windows
            entryName  = api.getEntryName(entry);
            outputName = fullfile(outputDir,entryName);
            
            % Control characters can be found in some entry names.
            % If found remove and warn if the control character is ^M.
            index = strcmp(outputName(end), {cntrlM, char(0)});
            if any(index)
                outputName(end) = '';
                if index(1)
                    warning(message('MATLAB:extractArchive:removeControlM', outputName));
                end
            end
            
            % If the file is a directory, create it,
            % otherwise copy the entry to the output file.
            iswritten = true;
            if ~entry.isDirectory
                iswritten = extractArchiveEntry( ...
                    outputName, api, entry, streamCopier, verbose, fcnName);
            else
                if ~exist(outputName,'dir')
                    mkdir(outputName);
                end
            end
            if iswritten
                files(end+1) = {regexprep(outputName, '^\.[/\\]', '')}; %#ok<AGROW>
            end
        else
            eof = true;
        end
    end
    
    %--------------------------------------------------------------------------
function iswritten = extractArchiveEntry( ...
        outputName, api, entry, streamCopier, verbose, ~)
    % Extract the archive entry to an output file.
    
    if verbose
        fprintf('inflating: %s\n',outputName);
    end
    
    % Create the Java File output object using the entry's name.
    file = java.io.File(outputName);
    
    % If the parent directory of the entry name does not exist, then create it.
    parentDir = char(file.getParent.toString);
    if ~exist(parentDir,'dir')
        mkdir(parentDir)
    end
    
    % Obtain the entry's last modified timestamp.
    lastModifiedTime = api.getModifiedTime(entry);
    
    % Create an output stream.
    try
        fileOutputStream = java.io.FileOutputStream(file);
    catch exception %#ok<NASGU>
        % File acess or permission error thrown from java.io.FileOutputStream
        % when trying to create the output file.  This can occur because of one
        % of two conditions:
        %
        % 1) If trying to overwrite an existing file without write permissions.
        %    For example, this condition occurs if the file exists with -w file
        %    permissions.
        %
        % 2) The file is trying to be written into a directory with
        %    insufficient privileges. For example, this condition occurs if
        %    the output directory is /usr and the user is not root.
        %
        % Issue a warning and return to get the next entry.
        overwriteExistingFile = file.isFile && ~file.canWrite;
        if overwriteExistingFile
            warning(message('MATLAB:extractArchive:unableToOverwrite',outputName));
        else
            warning(message('MATLAB:extractArchive:unableToCreate',outputName));
        end
        iswritten = false;
        return
    end
    iswritten = true;
    % Create an input stream from the API.
    fileInputStream = api.getInputStream(entry);
    
    % Copy the input stream to the output stream.
    copyStreams(fileInputStream,  fileOutputStream, streamCopier, outputName)
    
    % Set the timestamp of the file to the entry's timestamp.
    % This must be set prior to getting the file's mode,
    % due to Java timing, on Windows.
    file.setLastModified(lastModifiedTime);
    
    % Obtain the entry's file mode.
    mode = api.getFileMode(entry);
    
    % Set the mode of the output file.
    setFileMode(outputName, mode);
    
    %--------------------------------------------------------------------------
function copyStreams(fileInputStream, fileOutputStream, streamCopier, outputName)
    % Copy the input stream to the output stream using the streamCopier.
    
    try
        % Extract the entry via the output stream.
        streamCopier.copyStream(fileInputStream, fileOutputStream);
        
        % Close the output stream.
        % Closing the output stream will update the
        % modification time of the newly created file.
        fileOutputStream.close;
        
    catch exception
        % The most likely reason to arrive here is the entry was not able to be
        % copied by the output stream. This error is thrown by the stream
        % copier. The most likely cause is that the entry is password-protected
        % or encrypted. If the output file has been created, it needs to be
        % closed and deleted. The fileOutputStream needs to be closed if an
        % unknown error exists when creating the output file.
        msg = exception.message;
        
        if strfind(msg, 'not enough space on the disk')
            error(message('MATLAB:extractArchive:outputDiskFull'));
        end
        
        try
            fileOutputStream.close;
            delete(outputName);
        catch exception2 %#ok
            % Nothing to do.
        end
        
        % If fileNotFound is true, then the output error message contains the
        % Java exception FileNotFoundException printed as a Java classname and
        % it is not part of the internationalized error message. In general,
        % this condition will not be true, unless the entry name is invalid
        % (containing for example control characters).
        fileNotFound = ~isempty(strfind('filenotfound', lower(msg)));
        if ~fileNotFound
            entryInfo = getString(message('MATLAB:extractArchive:protectedEntry'));
        else
            entryInfo = getString(message('MATLAB:extractArchive:invalidEntry'));
        end
        error(message('MATLAB:extractArchive:unableToWrite',outputName,entryInfo));
    end
    
    %--------------------------------------------------------------------------
function setFileMode(outputName, mode)
    % Set the file's mode.
    
    if ispc
        % Set Windows file attribute with attribute mode.
        % (Unix mode shifted left by 16 bits)
        setFileAttrib(outputName, mode);
    else
        % Set Unix file mode.
        setUnixFileMode(outputName, mode);
    end
    
    %--------------------------------------------------------------------------
function octalMode = convertModeToOctal(mode)
    % Covert the decimal mode value to octal char class.
    
    defaultFileMode = 644; %rw-r-r
    try
        base8StringMode = dec2base(mode,8);
        if numel(base8StringMode) >= 3
            octalMode = str2double(base8StringMode(end-2:end));
        else
            octalMode = defaultFileMode;
        end
    catch exception %#ok
        octalMode = defaultFileMode;
    end
    
    %--------------------------------------------------------------------------
function setFileAttrib(filename, mode)
    % Set the file's attributes on a Windows system.
    
    % Ideally, a method would exist to determine the entry's attributes, but
    % unfortunately, that is not the case. The following table was generated
    % empirically.
    %
    % The table below lists the common bit patterns found in many applications.
    % The Unix    file mode      is in the upper two-bytes of the mode.
    % The Windows file attribute is in the lower two-bytes of the mode.
    %
    % Attribute  Bit Pattern
    % ---------  -----------
    %       r    10000001001001000000000000000001
    %       w    10000001101101100000000000000000
    %       s    10000001101101100000000000000100
    %
    %       w    10000001101101100000000000000000
    %       wa   10000001101101100000000000100000
    %
    %       w    10000001101101100000000000000000
    %       wh   10000001101101100000000000000010
    %
    %       wh   10000001101101100000000000000010
    %       wha  10000001101101100000000000100010
    %
    %       r    10000001001001000000000000000001
    %       ra   10000001001001000000000000100001
    %
    %       r    10000001001001000000000000000001
    %       rh   10000001001001000000000000000011
    %
    %       rh   10000001001001000000000000000011
    %       rha  10000001001001000000000000100011
    %
    % The table below lists the bit patterns from the WinZip application.
    %       r    00000000000000000000000000000001
    %       w    00000000000000000000000000000000
    %
    %       w    00000000000000000000000000000000
    %       wa   00000000000000000000000000100000
    %
    %       wh   00000000000000000000000000000010
    %       wha  00000000000000000000000000100010
    %
    %       r    00000000000000000000000000000001
    %       ra   00000000000000000000000000100001
    %
    %       r    00000000000000000000000000000001
    %       rh   00000000000000000000000000000011
    %
    %       r    00000000000000000000000000000001
    %       rha  00000000000000000000000000100011
    %
    % Common Bit Patterns
    %
    %       r    1 (1) (Windows)
    %       w    1 (0) (Windows)
    %       r   24 (0) (UNIX)
    %       w   24 (1) (UNIX)
    %       h    2
    %       s    3
    %       a    6
    
    attrib = uint32(mode);
    
    % Determine the write attribute value.
    % The write attribute is determined by either bit 1 or bit 24, depending on
    % the pattern of the higher order bits. (When the higher order bits are
    % set, bit 32 is always set to 1, as can be seen in the above table.)
    %
    % Some Windows applications, such as WinZip, do not set any higher order
    % bits, as can be seen by the second table above. Other Windows
    % applications and MATLAB functions, such as TAR, do not set any lower
    % order bits.
    %
    % For the case where there are no higher order bits set, use bit 1 for
    % determining if the write attribute is set. (Note that in this case, bit 1
    % is true if the file is read-only.) Otherwise, if the highest order bit is
    % set, use bit 24 (the high-order write bit), which is required for TAR.
    % (Note that in this case, bit 24 is false if the file is read-only.)
    
    useHighOrderWriteBit = logical(bitget(attrib, 32));
    if useHighOrderWriteBit
        % If the file is read-only, bit 24 is false.
        writeBit = 24;
        hasWriteAttrib = logical(bitget(attrib, writeBit));
    else
        % If the file is read-only, bit 1 is true.
        writeBit = 1;
        hasWriteAttrib = ~logical(bitget(attrib, writeBit));
    end
    
    % The Windows-only attributes are always determined by the lower bit
    % values.
    hiddenBit  = 2;
    systemBit  = 3;
    archiveBit = 6;
    
    hasHiddenAttrib  = logical(bitget(attrib, hiddenBit));
    hasArchiveAttrib = logical(bitget(attrib, archiveBit));
    hasSystemAttrib  = logical(bitget(attrib, systemBit));
    
    plusMinus = { '+' '-'};
    writeMode   = [plusMinus{[hasWriteAttrib   ~hasWriteAttrib]}   'w'];
    archiveMode = [plusMinus{[hasArchiveAttrib ~hasArchiveAttrib]} 'a'];
    hiddenMode  = [plusMinus{[hasHiddenAttrib  ~hasHiddenAttrib]}  'h'];
    systemMode  = [plusMinus{[hasSystemAttrib  ~hasSystemAttrib]}  's'];
    
    attrib = [writeMode ' ' archiveMode ' ' hiddenMode ' ' systemMode];
    [status, msg]=fileattrib(filename, attrib);
    if status ~= 1
        warning(message('MATLAB:extractArchive:fileattrib',msg));
    end
    
    %--------------------------------------------------------------------------
function setUnixFileMode(filename, mode)
    % Set the file mode on Unix using chmod via the MEX-function unixchmod.
    
    mode = convertModeToOctal(mode);
    if isunix && ~isempty(mode)
        status = matlab.iofun.internal.unixchmod(filename, uint16(mode));
        if status ~= 0
            error(message('MATLAB:extractArchive:chmodError',mode,filename));
        end
    end
