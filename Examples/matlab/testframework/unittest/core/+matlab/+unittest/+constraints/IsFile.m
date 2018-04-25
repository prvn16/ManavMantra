classdef IsFile < matlab.unittest.internal.constraints.IsFileIsFolderConstraint
    % IsFile - Constraint specifying a string or character vector that points to a file
    %
    %   The IsFile constraint produces a qualification failure for any actual
    %   value that is not a string scalar or character vector that points to an
    %   existing file.
    %
    %   IsFile methods:
    %       IsFile - Class constructor
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsFile;
    %       import matlab.unittest.constraints.EveryElementOf;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Check that a file exists
    %       testCase.verifyThat(value, IsFile);
    %
    %       % Check that a file does not exist
    %       testCase.assertThat(value,~IsFile);
    %
    %       % Check that several files exist
    %       fileNames = ["example1.txt","example2.txt"];
    %       testCase.verifyThat(EveryElementOf(fileNames),IsFile);
    %
    %   See also:
    %       matlab.unittest.constraints.IsFolder
    
    % Copyright 2017 The MathWorks, Inc.
    properties(Hidden,Constant,Access=protected)
        CheckFcn = @isfile;
        Catalog = matlab.internal.Catalog('MATLAB:unittest:IsFile');
    end
    
    methods
        function constraint = IsFile()
            % IsFile - Class constructor
            %
            %   IsFile creates a constraint that determines whether a value is a string
            %   scalar or character vector that points to an existing file.
        end
    end
end

% LocalWords:  unittest