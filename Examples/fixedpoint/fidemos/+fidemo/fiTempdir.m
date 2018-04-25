%    Copyright 2010-2015 The MathWorks, Inc.

classdef fiTempdir

    properties (SetAccess = private, GetAccess = public)
        currentDir; %current working dir needed to be cached when working in tempDir
        tempDir;
    end

    methods

        function obj = fiTempdir(mDemofilename)
            obj.currentDir = pwd;
            obj.tempDir = [tempname '_' mDemofilename];
            if ~exist(obj.tempDir,'dir')
                mkdir(obj.tempDir)
            end
            cd(obj.tempDir)

        end

        function status = cleanUp(obj)
            cd(obj.currentDir);
            status = rmdir(obj.tempDir, 's');
            obj.currentDir = [];
            obj.tempDir = [];
        end

    end

end
