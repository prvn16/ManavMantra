classdef (Hidden) HiddenCurrentFolderFixture < matlab.unittest.fixtures.CurrentFolderFixture
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods
        function fixture = HiddenCurrentFolderFixture(folder)
            import matlab.unittest.internal.fixtures.FolderScope;
            
            fixture = fixture@matlab.unittest.fixtures.CurrentFolderFixture(folder);
            fixture.FolderScope = FolderScope.Boundary;
        end
    end
end

