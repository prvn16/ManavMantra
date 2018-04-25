function varargout=ls(varargin)
%LS List folder contents.
%   LS displays the results of the 'ls' command on UNIX. On UNIX, 
%   LS returns a character row vector of filenames separated 
%   by tab and space characters. On Windows, LS returns an m-by-n 
%   character array of filenames, where m is the number of filenames 
%   and n is the number of characters in the longest filename found. 
%   Filenames shorter than n characters are padded with space characters.
%
%   You can pass any flags to LS as well that your operating system supports.
%
%   See also DIR, MKDIR, RMDIR, FILEATTRIB, COPYFILE, MOVEFILE, DELETE.

%   Copyright 1984-2017 The MathWorks, Inc.
%=============================================================================
% validate input parameters
if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if ~iscellstr(varargin)
    error(message('MATLAB:ls:InputsMustBeStrings'));
end

% check output arguments
if nargout > 1
    error(message('MATLAB:ls:TooManyOutputArguments'));
end

% perform platform specific directory listing
if isunix
    pd = pwd;
    if exist(pd,'dir')
        [s,listing] = unix(['cd "' pd '" && ls' quoteUnixCmdArg(varargin)]);
    else
        [s,listing] = unix(['ls' quoteUnixCmdArg(varargin)]);
    end
    if s~=0
        error(message('MATLAB:ls:OSError',listing));
    end
else
    if nargin == 0
        % Display output of dir in wide format.  
        % dir; prints out info.  
        % d = dir; does not.
        if nargout == 0
            dir;
        else
            d = dir;
            listing = char(d.name);
        end
    elseif nargin == 1
        if nargout == 0
            dir(varargin{1});
        else
            d = dir(varargin{1});
            listing = char(d.name);
        end
    else
        error(message('MATLAB:ls:TooManyInputArguments'));
    end
end

% determine output mode, depending on presence of output arguments
if nargout == 0 && isunix
    disp(listing)
elseif nargout > 0
    varargout{1} = listing;
end

%---------------------------------------------------------------------------
function quotedArgs = quoteUnixCmdArg(tildeArgs)
% Algorithm: Start and end each argument with a single quote (squote).
%            Within each argument:
%            1. squote -> squote '\' squote squote
%            2. '!'    -> squote '\' '!' squote
%            3. '*'    -> squote '*' squote	(MATLAB globbing character)
%
if isempty(tildeArgs)
    quotedArgs = '';
    return
end
% Do any tilde expansion first 
ix = find(strncmp(tildeArgs,'~',1)); 
if ~isempty(ix) 
  tildeArgs(ix) = unix_tilde_expansion(tildeArgs(ix)); 
end 

% Special cases to maintain as literal: single quote or ! with '\thing_I_found'
quotedArgs= regexprep(tildeArgs,'[''!]','''\\$&''');

% Special cases to maintain as NOT literal: Replace * with 'thing_I_found'
quotedArgs= regexprep(quotedArgs,'[*]','''$&''');

quotedArgs = strcat(' ''', quotedArgs, '''');
quotedArgs = [quotedArgs{:}];
