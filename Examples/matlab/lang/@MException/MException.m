%MException  Capture error information.
%   ME = MException(MSGID, ERRMSG, V1, V2, ..., VN) captures information
%   about a specific error and stores it in MException object ME.
%
%   MSGID is a character vector or string scalar that uniquely identifies
%   the source of the error, and is composed of at least two substrings
%   separated by a colon (such as COMPONENT:MNEMONIC).  For more
%   information, type HELP ERROR and see MESSAGE IDENTIFIERS.
%
%   ERRMSG is a character vector or string scalar that informs the user
%   about the cause of the error and can suggest how to correct the faulty
%   condition. The ERRMSG can include escape sequences such as \t or
%   \n, as well as any of the format conversion specifiers supported by the
%   SPRINTF function, such as %s or %d.  For more information, type HELP
%   SPRINTF.
%
%   Inputs V1, V2, ..., VN provide values that replace any conversion
%   specifiers in the ERRMSG.
%
%   Examples:
%
%       % Example 1 - Check the identifier of a MATLAB exception.
%       try
%         fid = fopen('noSuchFile.dat');
%         mydata = fread(fid);
%         fclose(fid);
%       catch ME
%         if strcmp(ME.identifier, 'MATLAB:FileIO:InvalidFid')
%            disp('Could not find the specified file.');
%            rethrow(ME);
%         end
%       end
%       
%       % Example 2 - Create your own exception.
%       inputstr = input('Type a variable name:', 's');
%       if ~exist(inputstr, 'var')
%          ME = MException('MyComponent:noSuchVariable', ...
%                          'Variable %s not found', inputstr);
%          throw(ME);
%       end
%
%   MException methods:
%       throw         - Issue exception and terminate function
%       rethrow       - Reissue existing exception and terminate function
%       throwAsCaller - Issue exception as if from calling function
%       addCause      - Record additional causes of exception
%       getReport     - Get error message for exception
%       last          - Return last uncaught exception
%
%   MException public fields:
%       identifier - Character vector that uniquely identifies the error	
%       message	   - Formatted error message that is displayed	
%       stack	   - Structure containing stack trace information
%       cause      - Cell array of MExceptions that caused this exception
%
%   See also ERROR, ASSERT, TRY, CATCH, DBSTACK.

%   Copyright 2007-2017 The MathWorks, Inc.
%   Built-in function.

%{
properties
    %IDENTIFIER Character vector that uniquely identifies the error.
    %    If nonempty, the IDENTIFIER tag contains at least two substrings
    %    separated by a colon, where the first substring is the component
    %    (such as MATLAB).
    %
    %    Example: View the identifier for the most recent exception.
    %
    %       last_exception = MException.last;
    %       last_ID = last_exception.identifier
    %
    %    See also MException, MESSAGE.
    identifier;
    
    %MESSAGE Formatted error message that is displayed.
    %    Describes the error in a readable text format.
    %    
    %    Example: View the most recently encountered error message.
    %
    %       last_exception = MException.last;
    %       last_msg = last_exception.message
    %
    %    See also MException, IDENTIFIER, getReport.
    message;

    %STACK Structure containing stack trace information.
    %    The structure is N-by-1, where N is the depth of the call stack,
    %    that is, the number of functions called from the point of the 
    %    exception to the top-level function.
    %
    %    Fields in the structure:
    %       file - File name
    %       name - Function name
    %       line - Line number within function where exception was thrown
    %
    %    Example:
    %
    %    Consider hypothetical functions A1, B1, and B2, where:
    %        A1, in file C:\temp\A1.m, calls B1 at line 43.
    %        B1, in file C:\temp\B1.m, calls B2 at line 9.
    %        B2, in file C:\temp\B1.m, throws an exception at line 31.
    %    The code
    %
    %       last_exception = MException.last;
    %       last_stack = last_exception.stack(:)
    %
    %    returns
    %
    %       ans = 
    %       file: 'C:\temp\B1.m'
    %       name: 'B2'
    %       line: 31
    %       ans = 
    %       file: 'C:\temp\B1.m'
    %       name: 'B1'
    %       line: 9
    %       ans = 
    %       file: 'C:\temp\A1.m'
    %       name: 'A1'
    %       line: 43 
    %
    %    See also MException, THROW, throwAsCaller, RETHROW.
    stack;

    %CAUSE Cell array of MExceptions that caused this exception.
    %
    %   Example:
    %
    %      try
    %         x = D(1:25);
    %      catch cause1_ME
    %         try
    %            filename = 'test204';
    %            testdata = load(filename);
    %            x = testdata.D(1:25)
    %         catch cause2_ME
    %            base_ME = MException('MATLAB:LoadErr', ...
    %                'Unable to load from file %s', filename);
    %            new_ME = addCause(base_ME, cause1_ME);
    %            new_ME = addCause(new_ME, cause2_ME);
    %            throw(new_ME);
    %         end
    %      end
    %
    %      % View the cause property of the exception new_ME:
    %      new_ME.cause{:}      
    %      
    %
    %   See also MException, addCause.
    cause;
end
%}
