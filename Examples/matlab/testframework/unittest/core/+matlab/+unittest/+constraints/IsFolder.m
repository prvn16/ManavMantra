classdef IsFolder < matlab.unittest.internal.constraints.IsFileIsFolderConstraint
    % IsFolder - Constraint specifying a string or character vector that points to a folder
    %
    %   The IsFolder constraint produces a qualification failure for any actual
    %   value that is not a string scalar or character vector that points to an
    %   existing folder.
    %
    %   IsFolder methods:
    %       IsFolder - Class constructor
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsFolder;
    %       import matlab.unittest.constraints.EveryElementOf;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Check that a folder exists
    %       testCase.verifyThat(value, IsFolder);
    %
    %       % Check that a file does not exist
    %       testCase.assertThat(value,~IsFolder);
    %
    %       % Check that several folders exist
    %       folderNames = ["example1","example2"];
    %       testCase.verifyThat(EveryElementOf(folderNames),IsFolder);
    %
    %   See also:
    %       matlab.unittest.constraints.IsFile
    
    % Copyright 2017 The MathWorks, Inc.
    properties(Hidden,Constant,Access=protected)
        CheckFcn = @isfolder;
        Catalog = matlab.internal.Catalog('MATLAB:unittest:IsFolder');
    end
    
    methods
        function constraint = IsFolder()
            % IsFolder - Class constructor
            %
            %   IsFolder creates a constraint that determines whether a value is a
            %   string scalar or character vector that points to an existing folder.
        end
    end
end

% LocalWords:  unittest