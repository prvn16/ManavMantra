function cdirs = catdirs(caller, varargin)
%CATDIRS Concatenate separate strings of directories into one string. 
%   CATDIRS  CALLER DIRNAME checks that DIRNAME is a string, removes any
%   leading or tailing whitespace, and appends a path separator. CALLER is
%   the name of the calling function, used only when displaying warnings.
%
%   CATDIRS  CALLER DIR1 DIR2 DIR3 ... for each input, checks it is a
%    string, removes any leading or tailing whitespace, and appends a path
%    separator; and then concatenates all these strings. CALLER is the
%    name of the calling function, used only when displaying warnings.
%
%   Example:
%       dirlist = catdirs('addpath', '/home/user/matlab','/home/user/matlab/test');

%   Copyright 1984-2015 The MathWorks, Inc.

n= nargin-1;
narginchk(2,Inf);

cdirs = '';

for i=1:n
    next = varargin{i};
    if ~ischar(next)
        error(message('MATLAB:catdirs:ArgNotString'));
    end
    % Remove leading and trailing whitespace
	trimmedNext = strtrim(next);
    if ~isempty(trimmedNext)
        if ~strcmp(trimmedNext, next)
            [~,caller]=fileparts(caller);
            switch caller
                case 'addpath'
                    warning(message('MATLAB:catdirs:AddLeadingTrailingWhitespace', ...
                        trimmedNext, next));
                case 'rmpath'
                    warning(message('MATLAB:catdirs:RemoveLeadingTrailingWhitespace', ...
                        trimmedNext, next));
            end
        end
        cdirs = [cdirs trimmedNext pathsep]; %#ok<AGROW>
    end
end
