function tf = isFolder(paths)
    %ISFOLDER Check each string element is a folder or not.
    %
    %   TF = isFolder(PATHS) returns a logical array of size equal to PATHS
    %   indicating whether each of the string element is a folder or not.
    %   PATHS must be a string vector.
    tf = false(numel(paths), 1);
    for ii = 1:numel(paths)
        idx = matlab.io.datastore.internal.indexOfFirstFolderOrWildCard(char(paths(ii)));
        tf(ii) = idx ~= -1;
    end
end
