classdef PathFixture < matlab.unittest.fixtures.Fixture
    % PathFixture - Fixture for adding a folder to the MATLAB path.
    %
    %   PathFixture(FOLDER) constructs a fixture for adding FOLDER to the
    %   MATLAB path. When the fixture is set up, FOLDER is added to the path.
    %   When the fixture is torn down, the MATLAB path is restored to its
    %   previous state.
    %
    %   PathFixture methods:
    %       PathFixture - Class constructor.
    %
    %   PathFixture properties:
    %       Folder - Character vector containing the folder to be added to the path.
    %       IncludeSubfolders - Boolean that specifies whether the subfolders are added to path.
    %       Position - Character vector that specifies whether the folder is added at the beginning or end of the path.
    %
    %   Name/Value Options:
    %       Name                  Value
    %       ----                  -----
    %       IncludingSubfolders   False or true (logical 0 or 1) that specifies
    %                             whether subfolders are added to the
    %                             path. Default value is false.
    %       Position              Character vector ('begin' or 'end') that
    %                             specifies whether the folder is added at
    %                             the beginning or end of the path.
    %                             Default value is 'begin'.
    %
    %   Example:
    %       % Use PathFixture as a shared test fixture
    %       classdef (SharedTestFixtures={matlab.unittest.fixtures.PathFixture('helperFiles')}) ...
    %               testFoo < matlab.unittest.TestCase
    %           methods(Test)
    %               function test1(testCase)
    %                   % Test for Foo
    %               end
    %           end
    %       end
    %
    %   See also: CurrentFolderFixture
    
    %  Copyright 2012-2016 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        % Folder - Character vector containing the folder to be added to the path.
        %
        %   The Folder property is a character vector representing the absolute
        %   path to the folder that is added to the MATLAB path when the fixture is
        %   set up.
        Folder
        
        % IncludeSubfolders - Boolean that specifies whether the subfolders are added to path.
        %
        %   The IncludeSubfolders property is a boolean (true or false)
        %   that specifies whether the subfolders of the given folder
        %   are added to the path. This property is read only and can be
        %   set only through the constructor.
        IncludeSubfolders = false;
        
        % Position - Character vector that specifies whether the folder is added at the beginning or end of the path.
        %
        %   The Position property is a character vector specified as 'begin' or
        %   'end' that indicates whether the folder is added to the beginning or
        %   the end of the path.
        Position = 'begin';
    end
    
    properties(Access=private)
        StartPath
    end
    
    methods
        function fixture = PathFixture(folder, varargin)
            % PathFixture - Class constructor.
            %
            %   FIXTURE = PathFixture(FOLDER) constructs a fixture for adding FOLDER to
            %   the MATLAB path. FOLDER may refer to a relative or absolute path.
            %
            %   FIXTURE = PathFixture(FOLDER, 'IncludingSubfolders', true) constructs
            %   a fixture for adding FOLDER and its subfolders to the MATLAB path.
            %
            %   FIXTURE = PathFixture(FOLDER, 'Position', POSITION) constructs
            %   a fixture for adding FOLDER to the specified POSITION in
            %   the path. The value of POSITION can be either 'begin' or
            %   'end'. 'begin' adds FOLDER to the top of the path 
            %   and 'end' adds it to the bottom of the path. If this option 
            %   is used with 'IncludingSubfolders', FOLDER and its subfolders 
            %   are added to the top or bottom of the path as a single 
            %   block with FOLDER on top.
            
            import matlab.unittest.internal.folderResolver;
            fixture.Folder            = folderResolver(folder);
                        
            parser = matlab.unittest.internal.strictInputParser;
            parser.addParameter('IncludingSubfolders', false, @(x)validateIncludeSub(x,'IncludingSubfolders'));
            parser.addParameter('IncludeSubfolders', false, @(x)validateIncludeSub(x,'IncludeSubfolders')); % supported alias
            parser.addParameter('Position', 'begin', @validatePosition);
            parser.parse(varargin{:});
            
            checkForOverdeterminedParameters(parser,'IncludingSubfolders','IncludeSubfolders');
            
            fixture.IncludeSubfolders = parser.Results.IncludingSubfolders || parser.Results.IncludeSubfolders;
            fixture.Position          = char(parser.Results.Position);
        end
        
        function setup(fixture)
            
            if fixture.IncludeSubfolders
                pathToBeAdded = genpath(fixture.Folder);
                fixture.SetupDescription = getString(message('MATLAB:unittest:PathFixture:SetupDescriptionSubfolders', ...
                                                    fixture.Folder));
            else
                pathToBeAdded = fixture.Folder;
                fixture.SetupDescription = getString(message('MATLAB:unittest:PathFixture:SetupDescription', ...
                                                    fixture.Folder));
            end
            
            fixture.StartPath = addpath(pathToBeAdded, ['-' fixture.Position]);
            
        end
        
        function teardown(fixture)
            path(fixture.StartPath);
            
            fixture.TeardownDescription = getString(message('MATLAB:unittest:PathFixture:TeardownDescription'));
        end
    end
    
    methods (Hidden, Access=protected)
        function bool = isCompatible(fixture, other)
            bool = strcmp(fixture.Folder, other.Folder) && isequal(fixture.IncludeSubfolders, other.IncludeSubfolders) ...
                                                        && strcmp(fixture.Position, other.Position);
        end
    end
end

function validateIncludeSub(value,varname)
validateattributes(value, {'logical'}, {'scalar'}, '' ,varname)
end

function validatePosition(position)
validateattributes(position, {'char','string'}, {'scalartext'}, '', 'Position');
if ~any(strcmp(position, {'begin', 'end'}))
    error(message('MATLAB:unittest:PathFixture:InvalidPosition'));
end
end

function checkForOverdeterminedParameters(parser,p1,p2)
if ~any(ismember({p1,p2},parser.UsingDefaults))
    error(message('MATLAB:unittest:NameValue:OverdeterminedParameters',p1,p2));
end
end
