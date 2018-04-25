classdef WorkingFolderFixture < matlab.unittest.fixtures.Fixture & ...
                                matlab.unittest.internal.mixin.WithSuffixMixin & ...
                                matlab.unittest.internal.mixin.PreservingOnFailureMixin
    % WorkingFolderFixture - Move to a temporary, working folder.
    %
    %   The WorkingFolderFixture test fixture is used to create a temporary
    %   folder and set that folder as the current working folder. This allows
    %   the test or the product under test to create files or otherwise modify
    %   the folder's contents without impacting the source or test folder
    %   structure. When the fixture is set up, it adds the current folder to
    %   the path, creates a temporary folder, and changes the current working
    %   folder to the temporary folder.
    %
    %   Typically, the fixture deletes the temporary folder and all its
    %   contents when torn down. However, when 'PreservingOnFailure' is
    %   specified as true and a failure (verification, assertion, or fatal
    %   assertion qualification failure or uncaught error) occurs in the test
    %   using the fixture, then a message is printed to the Command Window and
    %   the folder is not deleted. Preserving the folder and its contents may
    %   aid in investigation of the cause of the test failure.
    %
    %   The name of the temporary folder can be customized by specifying the
    %   'WithSuffix' parameter along with a character vector. The specified
    %   character vector is appended to the end of the name of the folder that
    %   is created.
    %
    %   WorkingFolderFixture methods:
    %       WorkingFolderFixture - Class constructor.
    %
    %   TemporaryFolderFixture properties:
    %       Folder            - Created temporary folder.
    %       PreserveOnFailure - Boolean that specifies whether the temporary folder is deleted after a failure.
    %       Suffix            - Character vector appended to the name of the temporary folder.
    %
    %   Example:
    %       classdef testFoo < matlab.unittest.TestCase
    %           methods(Test)
    %               function test1(testCase)
    %                   import matlab.unittest.fixtures.WorkingFolderFixture;
    %
    %                   testCase.applyFixture(WorkingFolderFixture);
    %                   x = 1:10;
    %
    %                   % Save a file in the temporary folder
    %                   save('data.mat','x');
    %               end
    %           end
    %       end
    %
    %   See also: matlab.unittest.fixtures.PathFixture,
    %             matlab.unittest.fixtures.CurrentFolderFixture,
    %             matlab.unittest.fixtures.TemporaryFolderFixture
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    properties (SetAccess=private)
        % Folder - Created temporary folder.
        %
        %   The Folder property is a character vector that specifies the absolute
        %   path of the temporary folder that the fixture creates. When set up, the
        %   fixture also sets this folder as the current folder.
        %
        Folder = '';
    end
    
    methods
        function fixture = WorkingFolderFixture(varargin)
            % WorkingFolderFixture - Class constructor.
            %
            %   FIXTURE = WorkingFolderFixture creates a working folder fixture
            %   instance and returns it as FIXTURE.
            
            import matlab.unittest.internal.fixtures.FolderScope;
            
            fixture.parse(varargin{:});
            fixture.FolderScope = FolderScope.Within;
            validateSuffixInTempname(fixture.Suffix);
        end
        
        function setup(fixture)
            import matlab.unittest.fixtures.PathFixture;
            import matlab.unittest.fixtures.TemporaryFolderFixture;
            import matlab.unittest.fixtures.CurrentFolderFixture;
            
            fixture.apply(PathFixture(pwd));
            temporaryFolderFixture = fixture.apply(TemporaryFolderFixture( ...
                'PreservingOnFailure',fixture.PreserveOnFailure, 'WithSuffix',fixture.Suffix));
            fixture.Folder = temporaryFolderFixture.Folder;
            fixture.apply(CurrentFolderFixture(temporaryFolderFixture.Folder));
        end
    end
    
    methods (Hidden, Access=protected)
        function bool = isCompatible(fixture, otherFixture)
            bool = isequal(fixture.PreserveOnFailure, otherFixture.PreserveOnFailure) && ...
                strcmp(fixture.Suffix, otherFixture.Suffix);
        end
    end
    
    methods (Access=private)
        function otherFixture = apply(fixture, otherFixture)
            fixture.addTeardown(@fixture.appendTeardownDescriptionFrom, otherFixture);
            fixture.applyFixture(otherFixture);
            fixture.appendSetupDescriptionFrom(otherFixture);
        end
        
        function appendSetupDescriptionFrom(fixture, otherFixture)
            fixture.SetupDescription = mergeDescriptions(fixture.SetupDescription, ...
                otherFixture.SetupDescription);
        end
        
        function appendTeardownDescriptionFrom(fixture, otherFixture)
            fixture.TeardownDescription = mergeDescriptions(fixture.TeardownDescription, ...
                otherFixture.TeardownDescription);
        end
    end
end


function combined = mergeDescriptions(first, second)
import matlab.unittest.internal.diagnostics.indent;

indention = '   ';
combined = sprintf('%s\n%s', first, indent(second, indention));
combined = sprintf('\n%s%s', indention, strtrim(combined));
end


function validateSuffixInTempname(suffix)
import matlab.unittest.internal.validateGeneratedPathname;
validateGeneratedPathname([tempname, suffix],'Suffix');
end