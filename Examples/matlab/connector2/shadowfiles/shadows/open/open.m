function varargout=open(varargin)

% Copyright 2017 The MathWorks, Inc.
% https://www.mathworks.com/help/matlab/ref/open.html

% Make sure we're given exactly 1 argument
narginchk(1,1);
fileToOpen = varargin{1};

% Support the use case where the user may have specified a variable instead of a file 
%
% (these checks are copied from the native open function)
% If we don't do these checks before calling the native open function, the evalin will 
% always treat the argument as a file, even if it is a variable, because it will be using
% the workspace of this shadow function instead of the workspace of this shadow function's caller
%
% In WHICH, files take precedence over variables, but we want
% variables to take precedence in OPEN.  This forces an EXIST
% check on the variable name before we do anything else.
name = fileToOpen;
exist_var = evalin('caller', ['exist(''' strrep(name, '''','''''') ''', ''var'')']);
% If we found a variable that matches, use that; open the variable and get out
if exist_var == 1
    evalin('caller', ['openvar(''' name ''', ' name ');']);
    return;
end

% Disable shadow warnings, store path, add the current directory
warningState = warning('off', 'MATLAB:dispatcher:nameConflict');
originalDir = cd(fullfile(matlabroot, 'toolbox','matlab','general'));

% Save handle to original open function
openHandle = @open;

% Restore directory and shadow warnings
cd(originalDir);
warning(warningState);

% Call native open
try
    if nargout > 0
        [varargout{1}] = openHandle(varargin{:});
    else
        openHandle(varargin{:});
    end
catch exception
    % Handle the case where the file type is not supported & the corresponding open function is private
    % i.e. if the open function is located in toolbox/matlab/general/private, throw the error directly
    identifierKey = 'MATLAB:open:openFailure';
    if strcmp(identifierKey,exception.identifier)
        % We do this here instead of before the call to native open in order to avoid
        % copying the entire contents of native open into this shadow file
        % (i.e. let native open do all the regular error checking for us)
        [fileDir,fileName,ext] = fileparts(fileToOpen);
        origExt = ext;
        if isempty(ext)
            % We need this in order to show the correct error message for private shadow 
            % functions if the user didn't specify an extension
            [~,~,ext] = fileparts(which(fileToOpen));
        end
        % Right now the only way to do this is by checking the file extension because
        % the open functions we are looking for are private and thus they can't be shadowed
        privateShadowFileExtensions = {'.mdl','.slx'};
        if any(strcmp(privateShadowFileExtensions,ext))
            % Append found extension if the original file didn't contain one
            if isempty(origExt)
                fileToOpen = [fileToOpen,ext];
            end
            exception = connector.internal.fileTypeNotSupportedError(fileToOpen);
        end
    end
    
    % Throw the exception here to prevent native open stack trace from appearing in the error msg
    exception.throwAsCaller;
end
