function fullName = getFullyQualifiedName( fileName )
%GETFULLYQUALIFIEDNAME takes an input file name and resolves it into fully
%   qualified names.

%   Copyright 2014-2017 The MathWorks, Inc.

% Algorithm:
% 1) Try dir and get the name that is a MATLAB Code File in the current directory.
% 2) Try dir by appending a valid code file extension.
% 1) Try which and get the name that is a MATLAB Code File.
% 2) Try which by appending a valid code file extension.
%

try
    fullName = resolveNameUsingDir( fileName );

    if( ~isempty( fullName ) )
        return;
    end

    fullName = resolveNameUsingWhich( fileName );

    if( isempty( fullName ) )
        error( message( 'MATLAB:mlint:FileNotFound', fileName ) );
    end
catch
    error( message( 'MATLAB:mlint:FileNotFound', fileName ) );
end
end

%==========================================================================

function fullName = resolveNameUsingWhich( fileName )

fullName = which( '-all', fileName );
if( ~isempty( fullName ) )
    % Get the first code file and strip additional text like Constructor
    % method etc.
    fullName = getFirstCodeFileInList( fullName );
    if( ~isempty( fullName ) )
        return;
        % else Try this function by appending valid extensions
    end
    % else Try this function by appending valid extensions
end

[~, ~, fileExt] = fileparts( fileName );
if( ~isempty( fileExt ) )
    % File was supplied with an extension, do not try adding extensions and
    % resolving
    return;
end

exts = getValidMatlabCodefileExtensions();

for i = 1:numel( exts )
    fileNameWithExt = [fileName exts{i}];
    fullName = resolveNameUsingWhich( fileNameWithExt );
    if( ~isempty( fullName ) )
        return;
    end
end

end

%==========================================================================

function fullName = getFirstCodeFileInList( ipName )

if(~iscell( ipName ) )
    fullName = ipName;
    return;
end

fullName = '';

for i = 1:numel( ipName )
   if( isValidMatlabCodefile( ipName{i} ) )
        fullName = ipName{i};
        return;
    end
end

end

%==========================================================================

function fullName = resolveNameUsingDir( fileName )

% Algorithm:
% Use dir to find the absolute path to the file (fully qualified name).
% If there is no extension, we try with all valid extension.

[~, ~, ext] = fileparts( fileName );
if( isempty( ext ) )
    exts = getValidMatlabCodefileExtensions();
    for i = 1:numel( exts )
        fileNameWithExt = [fileName exts{i}];
        fullName = resolveNameUsingDir( fileNameWithExt );
        if( ~isempty( fullName ) )
            return;
        end
    end
    return;
end

fullName = '';
dir_result = dir(fileName);
if ~isempty(dir_result)
    if isscalar(dir_result) && ~dir_result.isdir
        fullName = fullfile(dir_result.folder, dir_result.name);  
    end
end

end

%==========================================================================

function tf = isValidMatlabCodefile( fileName )
% Ensure that file name is a valid matlab code file by ensuring that its
% not a built-in or a java method and that it has a valid file extension.

invalidTypes = { 'built-in', 'java method' };
noMatchesFound = cellfun( @(x)isempty( regexpi( fileName, x, 'once' ) ), invalidTypes );
tf = all( noMatchesFound );

[~, ~, ext] = fileparts( fileName );
tf = tf && any( strcmp( getValidMatlabCodefileExtensions(), ext ) );

end

%==========================================================================
