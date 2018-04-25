%TempFolder
% A helper class that maintains a local temporary folder. If this object is
% sent to a worker, the worker will not hold lifetime ownership over the
% temporary folder.

%   Copyright 2015 The MathWorks, Inc.

classdef (Sealed, Hidden) TempFolder < handle
    properties (SetAccess = immutable)
        % The path to the temporary local folder.
        Path;
    end
    
    properties (GetAccess = private, SetAccess = immutable, Transient)
        % A flag that indicates if this instance is responsible for cleanup of the folder.
        ShouldCleanup = false;
    end
    
    methods
        % Create a temporary local folder.
        function obj = TempFolder
            obj.Path = iCreateTempFolder();
            obj.ShouldCleanup = true;
        end
        
        function delete(obj)
            if obj.ShouldCleanup && exist(obj.Path, 'dir')
                rmdir(obj.Path, 's');
            end
        end
    end
end

function path = iCreateTempFolder()
while (true)
    path = tempname;
    
    % We use this syntax as the only way to atomically detect
    % whether a folder already exists is to catch the warning
    % that is generated.
    [status, message, messageID] = mkdir(path);
    if ~status
        error(messageID, message);
    elseif isempty(messageID)
        return;
    end
end
end
