function send( pj )
%SEND Send output file to hardcopy device.
%   The output file is in the format specified by the device argument to 
%   the PRINT command. The command used to send the file to the output device 
%   is operating system specific. The command is stored in the PrintJob object.
%
%   Ex:
%      SEND( pj );
%
%   See also PRINT, PRINTOPT.

%   Copyright 1984-2017 The MathWorks, Inc.

lprcmd = pj.PrintCmd;

% set up a filename for use
theFileName = pj.FileName;

if isfield(pj, 'GhostName') && ~isempty(pj.GhostName)
    theFileName = pj.GhostName;
end

% Does something exist to send to the printer?
if ~exist( theFileName, 'file' )
    error(message('MATLAB:print:NoFile'))
end

if ispc

    % replace the default printer name with one specified 
    % in print command, if any
    filenamePlaceholderStarts = strfind(lprcmd, '%s');
    if ~isempty(filenamePlaceholderStarts) && ~isempty(pj.PrinterName)
        % take everything in lprcmd up to and including the '%s' filename
        % placeholder (filenamePlaceholderStarts + 1), and append the specified printer to it
        lprcmd = sprintf('%s %s', lprcmd(1:filenamePlaceholderStarts+1), pj.PrinterName);
    end
    % double the slashes, and insert file name
    cmd = sprintf(strrep(lprcmd,'\','\\'), theFileName);
    
    % insert a port name
    if contains(cmd,'$portname$')
        
        % find out which port it goes to
        portName = system_dependent('getspecifiedprinterport', pj.PrinterName);
        
        % check for empty (unknown) port or FILE: device, use default if
        % found
        if isempty(portName) 
            
	    % error, no default printer setup
	    if isempty(pj.PrinterName) 		
		error(message('MATLAB:print:NoDefaultPrinter'));
	    end
	    
            error(message('MATLAB:print:invalidPrinter', pj.PrinterName));
        end
        
        if strcmp(portName,'FILE:')
	    error(message('MATLAB:print:UnsupportedPort', portName, pj.PrinterName));
        end
        
        % substitute $portname$ for a real port
        cmd = strrep(cmd,'$portname$','%s');
        % replace slashes by double slashes (sprintf converts then to
        % escapes)
        cmd = strrep(cmd,'\','\\');
        % substitute portname into string, once only
        cmd = sprintf(cmd, portName);
    end

    % insert a file name
    if contains(cmd,'$filename$')
        
        % substitute $portname$ for a real port
        cmd = strrep(cmd,'$filename$','%s');
        % replace slashes by double slashes (sprintf converts then to
        % escapes)
        cmd = strrep(cmd,'\','\\');
        % substitute portname into string, once only
        cmd = sprintf(cmd, theFileName);
    end

    if pj.DebugMode
        disp( ['PRINT debugging: print command = ''' cmd '''.'] )
    end
    
    
    [s, r] = privdos(pj,cmd);

    if ~pj.DebugMode
        delete(theFileName);
    end
    
else
    if strncmp( lprcmd, 'lp ', min(length(lprcmd),3) ) 
        notBSD = 1;
    else
        notBSD = 0;
    end
    if ~isempty( pj.PrinterName )
        %If user specified a printer, add it to the printing command
        if notBSD
          cmdOption = '-d';
        else
          cmdOption = '-P';
        end
        lprcmd = [ lprcmd ' "' cmdOption pj.PrinterName '"' ];
    end
    
    if pj.DebugMode
        disp( ['PRINT debugging: print command = ''' lprcmd ' "' theFileName '"''.'] )
    end
    try
      [s, r] = unix([lprcmd ' "' theFileName '"' ] );
    catch
      % Try unix with one argument if last call fails
      s = unix([lprcmd ' "' theFileName '"' ]);
      r = '';
    end
      
    if notBSD
        % SGI and SOL2 without Berkley printing extensions do not
        % have a 'delete when done' option, so used copy option and
        % now delete the temporary file we made.

        if ~pj.DebugMode
            delete(theFileName)
        end

    end
end

% general error code and output testing
if s && ~isempty(r)
    error(message('MATLAB:print:ProblemSendingFile', r))
end

% mac "Print" never has non-zero return code - check stdout
if strncmp(computer,'MA',2) && ~isempty(r)  && strncmp(lprcmd,'Print',5) && contains(r,'ERROR:')
    error(message('MATLAB:print:ProblemSendingFile', r))
end
