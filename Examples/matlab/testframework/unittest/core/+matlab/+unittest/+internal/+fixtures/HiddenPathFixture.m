classdef (Hidden) HiddenPathFixture < matlab.unittest.fixtures.PathFixture
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods
        function fixture = HiddenPathFixture(folder)
            import matlab.unittest.internal.fixtures.FolderScope;
            
            fixture = fixture@matlab.unittest.fixtures.PathFixture(folder);
            fixture.FolderScope = FolderScope.Boundary;
        end
    end
end

