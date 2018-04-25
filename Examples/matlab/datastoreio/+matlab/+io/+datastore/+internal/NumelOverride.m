classdef NumelOverride
%NUMELOVERRIDE A helper object to override the numel behavior.
%   See also - matlab.io.datastore.splitter.WholeFileCustomReadFileSetSplitter,
%              matlab.io.datastore.DsFileSet, matlab.io.datastore.ImageDatastore.

%   Copyright 2017 The MathWorks, Inc.

    properties
        NumelValue;
    end

    methods
        function n = numel(obj)
            n = obj.NumelValue;
        end
    end
end
