function ext = extension(file)
% EXTENSION Return file extension. 
%
% Not using fileparts for performance reasons -- we only want the
% extension, and fileparts spends a lot of time messing around to find the
% path and filename parts.

% Note: Code more or less copied from the last bit of fileparts (with
% better comments).

% Extension not known
ext = '';

% Find the location of the last '.' in the name.
dotIdx = find(file == '.', 1, 'last');

% Find the location of the last filesep in the name.
sepIdx = find(file == filesep, 1, 'last');

% ssegench
% brute force to make extension deal with normalized paths
if isempty(sepIdx)
    sepIdx = find(file == '/', 1, 'last');
end

% If we found a '.' after the last '/' (or '\' on Windows), the extension 
% consists of the dot and everything that follows it.
% ssegench adding "|| isempty(sepIdx))" to account for a file with no path
if ~isempty(dotIdx) && ((~isempty(sepIdx) && dotIdx > sepIdx) || isempty(sepIdx))
    ext = file(dotIdx:end);
end
