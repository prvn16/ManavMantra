function files = existing(files)
% Allow case-insensitive file-extension match on Windows; require
% case-exact match on other platforms.
%
% For example, there are two files, foo.FIG and foo.m.
% When foo.m is passed to REQUIREMENTS. foo.fig is found via matlab.rdl 
% or mcr.rdl and then passed into existing(). 
%
% exist('foo.fig') returns 2 on windows and mac;
%                  returns 0 on linux.
% which('foo.fig') returns 'foo.FIG' on windows;
%                  returns '' on linux and mac.
% With the following code, 
% existing('foo.fig') returns 'foo.FIG' on windows;
%                     returns {} on linux and mac.

% WHICH lies about UNC files (those specified by full path beginning with a
% double slash) -- it always says they don't exist. So skip the WHICH test
% for those files.

e = false(1,numel(files));
for k=1:numel(files)
    file = files{k};
    % DeMorgan's law: ~(A & B) => (~A || ~B)
    % If the path's too short to be a UNC path (length less than three), or
    % the path doesn't start with  \\, we can safely call WHICH. (Test for
    % length required to avoid hard error on indexing conditions.)
    if numel(file) < 3 || ...
            (file(1) ~= '\' && file(1) ~= '/') || ...
            (file(2) ~= '\' && file(2) ~= '/')
        files{k} = matlab.depfun.internal.cacheWhich(files{k});
    end
    e(k) = matlab.depfun.internal.cacheExist(files{k},'file')==2;
end
files = files(e);
