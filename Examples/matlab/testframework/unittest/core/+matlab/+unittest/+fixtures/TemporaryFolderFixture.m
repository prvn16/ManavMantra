classdef TemporaryFolderFixture < matlab.unittest.fixtures.Fixture & ...
        matlab.unittest.internal.mixin.PreservingOnFailureMixin & ...
        matlab.unittest.internal.mixin.WithSuffixMixin
    % TemporaryFolderFixture - Create a temporary folder.
    %
    %   The TemporaryFolderFixture test fixture is used to create a temporary
    %   folder. When the fixture is set up, it creates a folder. Typically, the
    %   fixture deletes the folder and all its contents when torn down. Before
    %   deleting the folder, the fixture clears from memory the definitions of
    %   any MATLAB-files, P-files, and MEX-files that are defined in the
    %   temporary folder.
    %
    %   When 'PreservingOnFailure' is specified as true and a failure
    %   (verification, assertion, or fatal assertion qualification failure or
    %   uncaught error) occurs in the test using the fixture, then a message is
    %   printed to the Command Window and the folder is not deleted. Preserving
    %   the folder and its contents may aid in investigation of the cause of
    %   the test failure.
    %
    %   The name of the folder can be customized by specifying the 'WithSuffix'
    %   parameter along with a character vector. The specified character vector
    %   is appended to the end of the name of the folder that is created.
    %
    %
    %   TemporaryFolderFixture methods:
    %       TemporaryFolderFixture - Class constructor.
    %
    %   TemporaryFolderFixture properties:
    %       Folder            - Created folder.
    %       PreserveOnFailure - Boolean that specifies whether the folder is deleted after a failure.
    %       Suffix            - Character vector appended to the name of the folder.
    %
    %   Example:
    %       classdef testFoo < matlab.unittest.TestCase
    %           methods(Test)
    %               function test1(testCase)
    %                   import matlab.unittest.fixtures.TemporaryFolderFixture;
    %                   import matlab.unittest.fixtures.CurrentFolderFixture;
    %
    %                   % Create a temporary folder and make it the current working folder.
    %                   tempFolder = testCase.applyFixture(TemporaryFolderFixture);
    %                   testCase.applyFixture(CurrentFolderFixture(tempFolder.Folder));
    %
    %                   % The test can now write files to the current working folder.
    %               end
    %           end
    %       end
    %
    %   See also: PathFixture, CurrentFolderFixture
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    
    properties (SetAccess = private)
        % Folder - Created folder.
        %
        %   The Folder property is a character vector that specifies the absolute
        %   path of the folder created by the fixture.
        Folder = '';
    end
    
    properties (Access=private)
        ShouldPreserveFolder = false;
    end
    
    methods
        function fixture = TemporaryFolderFixture(varargin)
            % TemporaryFolderFixture - Class constructor.
            %
            %   FIXTURE = TemporaryFolderFixture creates a temporary folder
            %   fixture instance and returns it as FIXTURE.
            
            fixture = fixture.parse(varargin{:});
            validateSuffixInTempname(fixture.Suffix);
        end
        
        function setup(fixture)
            fixture.Folder = [tempname, fixture.Suffix];
            mkdir(fixture.Folder);
            
            if fixture.PreserveOnFailure
                fixture.onFailure(@fixture.setShouldPreserveFolder);
            end
            fixture.SetupDescription = getString(message( ...
                'MATLAB:unittest:TemporaryFolderFixture:SetupDescription', fixture.Folder));
        end
        
        function teardown(fixture)
            import matlab.unittest.Verbosity;
            import matlab.unittest.internal.fixtures.TemporaryFolderFixturePreservedDiagnostic;
            import matlab.unittest.constraints.Eventually;
            import matlab.unittest.constraints.IsTrue;
            
            if fixture.ShouldPreserveFolder
                fixture.log(Verbosity.Terse, TemporaryFolderFixturePreservedDiagnostic(fixture.Folder));
                return;
            end
            
            % Clear the items in the temporary folder that are in memory.
            [mpInMem, mexInMem] = inmem('-completenames');
            inMemInFolder = [mpInMem; mexInMem];
            folder = [fixture.Folder, filesep];
            
            if ispc
                inMemInFolder = inMemInFolder(strncmpi(inMemInFolder, folder, numel(folder)));
            else
                inMemInFolder = inMemInFolder(strncmp(inMemInFolder, folder, numel(folder)));
            end
            
            cellfun(@clear, inMemInFolder);
            
            % Remove the folder along with its contents.
            eventuallyIsTrue = Eventually(IsTrue, 'WithTimeoutOf',5);
            msg = '';
            function result = removeDir
                result = true;
                if exist(fixture.Folder,'dir')
                    [result, msg] = rmdir(fixture.Folder, 's');
                end
            end
            
            if ~eventuallyIsTrue.satisfiedBy(@removeDir)
                warning(message('MATLAB:unittest:TemporaryFolderFixture:DeletionFailed', ...
                    fixture.Folder, msg));
            end
            
            fixture.TeardownDescription = getString(message( ...
                'MATLAB:unittest:TemporaryFolderFixture:TeardownDescription', fixture.Folder));
        end
    end
    
    methods (Hidden, Access=protected)
        function bool = isCompatible(fixture, other)
            bool = strcmp(fixture.Suffix, other.Suffix) && ...
                isequal(fixture.PreserveOnFailure, other.PreserveOnFailure);
        end
    end
    
    methods (Access=private)
        function setShouldPreserveFolder(fixture)
            fixture.ShouldPreserveFolder = true;
            fprintf('%s',getString(message('MATLAB:unittest:TemporaryFolderFixture:FolderPreservedAdditionalDiagnostic',fixture.Folder)));
        end
    end
end


function validateSuffixInTempname(suffix)
import matlab.unittest.internal.validateGeneratedPathname;
validateGeneratedPathname([tempname, suffix],'Suffix');
end

% LocalWords:  completenames