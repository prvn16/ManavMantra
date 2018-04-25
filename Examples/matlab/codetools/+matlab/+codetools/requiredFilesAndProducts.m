function [fList, pList] = requiredFilesAndProducts(files, varargin)
% [fList, pList] = requiredFilesAndProducts(files[, 'toponly'])
%
% matlab.codetools.requiredFilesAndProducts is a function that provides 
% a list of user MATLAB program files and a list of MathWorks products 
% which one or more MATLAB program files require to run. 
% 
% Inputs:
%
%   files - A list of files needs to be analyzed. It can be a character
%           vector that contains the name of one MATLAB program file, a 
%           cell array of character vectors that contain the names of
%           MATLAB program files, or a string array that contains the names
%           of MATLAB program files.
%
%   'toponly' - When this case insensitive string option is specified, 
%           the function returns only those files and products used 
%           directly by "files".
%
% Outputs:
%
%   fList - Full paths of user MATLAB program files required by "files". 
%           Note that MathWorks MATLAB program files are not required,
%           because they are installed with MATLAB or other MathWorks 
%           products.
%
%   pList - A list of MathWorks products required by "files". Each required 
%           product is described by name, version, and product number.            
%
%   Copyright 2013-2016 The MathWorks, Inc.

% Validation of the number of input arguments
narginchk(1,2)

% Validation of the required input argument
validateattributes(files,{'char','cell','string'},{}, ...
    'matlab.codetools.requiredFilesAndProducts','files',1)
if ischar(files)
    files = {files};
end

% "files" is now either a string or cell
if isstring(files)
    files = cellstr(files);
else
    % "files" is a cell
    fcn = @(fn)ischar(fn) && (isrow(fn) || isempty(fn));
    invalidInput = ~cellfun(fcn,files(:));
    if any(invalidInput)
        error(message('MATLAB:requiredFilesAndProducts:NameMustBeChar', ...
            num2str(find(invalidInput(:).'),'#%d ')))
    end
end

% Case insensitive validation of the optional input argument
toponly = nargin == 2;
if toponly && ~strcmpi(varargin{1},'toponly')
    validateattributes(varargin{1},{'char','string'},{'scalartext'}, ...
        'matlab.codetools.requiredFilesAndProducts','toponly',2)
    error(message('MATLAB:requiredFilesAndProducts:BadStringFlag', ...
        char(varargin{1})))
end

% Only analyze non-MathWorks MATLAB program files
tgt = matlab.depfun.internal.Target.parse('MATLAB');

% The following warnings are not necessary to find file and product
% dependencies. Find their original states before reaching this point, and
% restore them after the dependency analysis.
warnID = { 'MATLAB:depfun:req:CorrespondingMCodeIsEmpty' };
orgState = cellfun(@(w)warning('off', w), warnID);
restoreWarn = onCleanup(@()arrayfun(@(s)warning(s), orgState));

% Initialize output argument(s)
fList = {};

try    
    % Dependency Analysis
    c = matlab.depfun.internal.Completion(files, tgt, toponly);

    % Outputs
    parts = c.parts;
    if ~isempty(parts)
        fList = {parts.path};
    end

    if nargout > 1
        pList = c.products;
    end
catch e
    throw(e)
end

end % The end of requiredFilesAndProducts
