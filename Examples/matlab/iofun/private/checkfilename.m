function varargout = checkfilename(varargin)
%CHECKFILENAME Check validity of a filename.
%
%   FULLFILENAME = CHECKFILENAME(FILENAME, FUNCTION_NAME, ARGUMENT_NAME) 
%   checks the validity of the FILENAME for reading data and issues a
%   formatted error if the FILENAME is invalid. FULLFILENAME is the
%   absolute pathname of the file.  
%
%   FILENAME can be a MATLABPATH relative partial pathname. If the file is
%   not found in the current working directory, CHECKFILENAME searches down
%   MATLAB's search path. The FILENAME must exist with read permission. If
%   FILENAME is a URL address, an error is issued.
%
%   FUNCTION_NAME is a string containing the function name to be used in
%   the formatted error message.
%
%   ARGUMENT_NAME is a string indicating the argument name that is being
%   checked and is used in the formatted error message.
%
%   FULLFILENAME = CHECKFILENAME(FILENAME, EXT, FUNCTION_NAME, ...
%   ARGUMENT_NAME) EXT is a cell array of strings, which may be EMPTY,
%   containing extensions without the '.'  character.  CHECKFILENAME loops,
%   appending each element of EXT in both upper and lower case, until a
%   valid filename is found; otherwise it will issue an error.
%
%   [FULLFILENAME, FID] = CHECKFILENAME(FILENAME, ...) CHECKFILENAME leaves
%   the file, FULLFILENAME, opened and returns the file identifier. 
%
%   [FULLFILENAME, URL] = CHECKFILENAME(FILENAME, ..., ALLOWURL) If
%   ALLOWURL is TRUE, FILENAME may by a URL address. The address must 
%   include the protocol type (e.g., "http://").  In this case,
%   FULLFILENAME is the absolute path to a temporary file copied from the
%   URL location and URL is TRUE; otherwise, URL is false.  If FILENAME is
%   a URL address, remember to delete FULLFILENAME as it is a temporary
%   copy.
%
%   [FULLFILENAME, URL] = CHECKFILENAME(FILENAME, ..., ALLOWURL, URLDIR) If
%   ALLOWURL is TRUE, FILENAME may by a URL address. In this case,
%   FULLFILENAME is the absolute path to the file copied from the URL
%   location to the directory specified by URLDIR and URL is TRUE;
%   otherwise, URL is false.  

%   Copyright 2004 The MathWorks, Inc.

[filename, ext, function_name, ~, allowURL, urlDir] =  ...
   parseInputs(varargin{:});


[fullfilename, fid] = validateFilename( ...
      filename, ext, function_name, allowURL, urlDir);

switch nargout
   case {0,1}
      % CHECKFILENAME(...)
      % FULLFILENAME = CHECKFILENAME(...)
      if ~isempty(fid)
         fclose(fid);
      end
      varargout{1} = fullfilename;
      if allowURL
         delete(fullfilename); % delete temporary download         
         error(message('MATLAB:checkfilename:tooFewOutputs'));
      end

   case 2
      % [FULLFILENAME, FID] = CHECKFILENAME(...)
      % [FULLFILENAME, URL] = CHECKFILENAME(..., ALLOWURL)
      varargout{1} = fullfilename;
      if (nargin > 3)
         if islogical(varargin{4})  ||  (nargin >= 5)
            varargout{2} = isempty(fid);
            if ~isempty(fid)
               fclose(fid);
            end
         else
            varargout{2} = fid;
         end
      else
         varargout{2} = fid;
      end

   otherwise
      if ~isempty(fid)
         fclose(fid);
      end
      error(message('MATLAB:checkfilename:tooManyOutputs'));
end

%--------------------------------------------------------------------------
function [fullfilename, fid] = validateFilename(filename, ext, ...
   function_name, allowURL, urlDir)

fid = [];

% If the filename contains a URL string,
%  then download the remote file
%  and test access by writing to a tempname
protocol = filename(1:strfind(filename,'://'));
if ~isempty(protocol)

   if ~usejava('jvm')
      error(message('MATLAB:checkfilename:invalidJVM',upper(function_name)));
   end

   if ~allowURL
      error(message('MATLAB:checkfilename:invalidFilenameURL',filename));
   end

   [~, name, ext] = fileparts(filename);
   if isempty(urlDir) || isequal(urlDir,tempdir) 
      urltempname = [tempname ext];
   else
      urltempname = fullfile(urlDir,[name ext]);
   end
   try
      fullfilename = urlwrite(filename, urltempname);
      return;
   catch e
      if exist(urltempname,'file')
         delete(urltempname);
      end
      error(message('MATLAB:checkfilename:urlwriteError',upper(function_name), filename));
   end

end

% Try to open the filename with read permission
fid = fopen(filename, 'r');
if (fid == -1)

   % The file cannot be opened with read permission
   %  Try to append various extensions and try again
   found = 0;
   extension = [lower(ext) upper(ext)];

   for p = 1:numel(extension)

      extname = [filename '.' extension{p}];
      fid = fopen(extname, 'r');
      if (fid ~= -1)
         % File was found.
         %  Break "for" loop with updated extname
         found = 1;
         break;
      end

   end

   % Check that some filename+extension combination was found.
   if (~found)

      % Filename could not be opened with 'r' permission
      %  but could exist with write mode or as a MATLAB file
      if isequal(exist(filename,'file'),2)

         % Check to verify NOT a MATLAB file
         if ~(isequal(exist([filename '.m'],'file'),2) || ...
               isequal(exist([filename '.M'],'file'),2))
            % File exists without read mode
            error(message('MATLAB:checkfilename:invalidFileMode',upper(function_name), filename));
         end

      end
      % File does not exist
      error(message('MATLAB:checkfilename:invalidFilename', upper(function_name), filename));

   else
      % extname was opened with 'r' permission
      filename = extname;
   end
end

% Return the full pathname if not in pwd.
fullfilename = fopen(fid);
if isequal(exist(fullfile(pwd,fullfilename),'file'),2)
   fullfilename = fullfile(pwd, fullfilename);
end

%--------------------------------------------------------------------------
function [filename, ext, function_name, arg_name, allowURL, urlDir] =  ...
   parseInputs(varargin)

allowURL= false;
urlDir = '';
switch nargin
   case {0,1,2}
      % CHECKFILENAME
      % CHECKFILENAME(FILENAME)
      % CHECKFILENAME(FILENAME, FUNCTION_NAME)
      error(message('MATLAB:checkfilename:tooFewInputs'));

   case 3
      % CHECKFILENAME(FILENAME, FUNCTION_NAME, ARGUMENT_NAME)
      filename = varargin{1};
      function_name = varargin{2};
      arg_name = varargin{3};
      ext = {''};

   case 4
      filename = varargin{1};
      if islogical(varargin{4})
         % CHECKFILENAME(FILENAME, FUNCTION_NAME, ...
         %               ARGUMENT_NAME, ALLOWURL)
         function_name = varargin{2};
         arg_name = varargin{3};
         allowURL = varargin{4};
         ext = {''};
      else
         % CHECKFILENAME(FILENAME, EXT, FUNCTION_NAME, ...)
         %               ARGUMENT_NAME)
         ext = varargin{2};
         function_name = varargin{3};
         arg_name = varargin{4};
      end

   case {5,6}
      filename = varargin{1};
      if islogical(varargin{4}) &&  nargin == 5
         % CHECKFILENAME(FILENAME, FUNCTION_NAME, ,...
         %               ARGUMENT_NAME, ALLOWURL, URLDIR)
         ext = {''};
         function_name = varargin{2};
         arg_name = varargin{3};
         allowURL = varargin{4};
         urlDir = varargin{5};
      elseif islogical(varargin{5}) && nargin == 5
         % CHECKFILENAME(FILENAME, EXT, FUNCTION_NAME, ,...
         %               ARGUMENT_NAME, ALLOWURL)
         ext = varargin{2};
         function_name = varargin{3};
         arg_name = varargin{4};
         allowURL = varargin{5};
      elseif islogical(varargin{5}) && nargin == 6
         % CHECKFILENAME(FILENAME, EXT, FUNCTION_NAME, ,...
         %               ARGUMENT_NAME, ALLOWURL, URLDIR)
         ext = varargin{2};
         function_name = varargin{3};
         arg_name = varargin{4};
         allowURL = varargin{5};
         urlDir = varargin{6};
      else
         error(message('MATLAB:checkfilename:invalidInputs'));
      end

   otherwise
      error(message('MATLAB:checkfilename:tooManyInputs'));
end

% Verify the inputs
if ~ischar(function_name)
   error(message('MATLAB:checkfilename:invalidFunctionName'));
end

if ~iscell(ext)
   error(message('MATLAB:checkfilename:invalidExt'));
end

if ~ischar(arg_name)
   error(message('MATLAB:checkfilename:invalidArgName'));
end

if isempty(filename)
   error(message('MATLAB:checkfilename:expectedNonEmpty',upper(function_name), arg_name));
elseif ~ischar(filename) 
   error(message('MATLAB:checkfilename:invalidType',upper(function_name), arg_name));
end
