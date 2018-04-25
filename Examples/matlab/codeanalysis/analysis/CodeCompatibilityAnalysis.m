classdef (Sealed) CodeCompatibilityAnalysis
%CodeCompatibilityAnalysis stores the result of code compatibility analysis.
%
%   Properties:
%     Date            - Date of the analysis
%     MATLABVersion   - MATLAB version used for analysis
%     Files           - List of analyzed files
%     ChecksPerformed - Table of checks used for analysis and frequency of
%                       occurrence in code
%     Recommendations - Table of the recommendations to update code
%
%   See also analyzeCodeCompatibility, codeCompatibilityReport

%   Copyright 2017 The MathWorks, Inc.

    properties (SetAccess = private)
        Date              % Date of the Analysis
        MATLABVersion     % MATLAB version used for analysis
        Files             % Analysis was performed on these files

        % Table of checks and frequency used in the analysis
        % The table has the columns:
        % Identifier     - Identifier tag for this check.
        % Description    - A general description of this check.
        % Documentation  - Command to get documentation on this check.
        % Severity       - When this check finds something, how severe is it.
        %                  Error   - Must be performed for the code to run.
        %                  Warning - Suggestions to use a preferred functionality
        %                            or a functionality that will be removed
        %                            in the future.
        % NumOccurrences - The number of occurrences of this Identifier.
        % NumFiles       - The number of files with this Identifier.
        ChecksPerformed

        % Table of the analysis results
        % The table has the columns:
        % Identifier     - Identifier tag for this check.
        % Description    - A specific description of this check.
        % Documentation  - Command to get documentation on this check.
        % Severity       - When this check finds something, how severe is it.
        %                  Error   - Must be performed for the code to run.
        %                  Warning - Suggestions to use a preferred functionality
        %                            or a functionality that will be removed
        %                            in the future.
        % File           - The file with the upgrade issue.
        % LineNumber     - The line number in the file.
        % ColumnRange    - The range of columns (begin and end).
        Recommendations

    end
    properties(Access=private)
        Checks            % Table of checks and their attributes
        Locations         % Table of the locations where issues were found
        Statistics        % Table of statistics from the analysis

    end

    properties(Hidden = true)
        RerunConfiguration
    end

    methods(Hidden)
        function obj = CodeCompatibilityAnalysis(files, checks, locations, rerunConfiguration)
            narginchk(4,4);
            obj.Date = datetime;
            obj.MATLABVersion = string(['R', version('-release')]);
            obj.Files = files;
            obj.Checks = checks;
            obj.Locations = locations;
            obj.RerunConfiguration = rerunConfiguration;
            obj.Statistics = obj.calculateStatistics;
            obj.ChecksPerformed = obj.createChecksPerformed;
            obj.Recommendations = obj.createRecommendations;
        end
    end
    methods(Access=private)
        function checksPerformed = createChecksPerformed(obj)
        % Using check table and statistics table, returns a table with
        % checks and their attributes.

            checksPerformed = outerjoin(obj.Checks, ...
                                        obj.Statistics(:, {'Identifier', 'NumOccurrences', 'NumFiles'}), ...
                                        'MergeKeys', true);
            checksPerformed.NumFiles(isnan(checksPerformed.NumFiles)) = 0;
            checksPerformed.NumOccurrences(isnan(checksPerformed.NumOccurrences)) = 0;
        end

        function recommendations = createRecommendations(obj)
        % Using locations table and check table, returns a table with
        % the recommendations.

            recommendations = innerjoin(obj.Locations, ...
                                        obj.Checks(:, {'Identifier', 'Documentation', 'Severity'}));

            recommendations = recommendations(:, {'Identifier', ...
                                'Description' ...
                                'Documentation' ...
                                'Severity' ...
                                'File' ...
                                'LineNumber' ...
                                'ColumnRange'});
        end

        function statistics = calculateStatistics(obj)
        % Using the locations table, returns a table of statistics from the analysis.
        % The table has the columns:
        % Identifier     - Identifier tag for this check.
        % NumOccurrences - The number of occurrences of this Identifier.
        % NumFiles       - The number of files with this Identifier.

        % For an Identifier, find ALL occurrences.
            [groupNumId, Identifier] = findgroups(obj.Locations.Identifier);
            if isempty(groupNumId)
                % splitapply group numbers must be a vector of positive integers,
                % and cannot be a sparse vector.
                NumOccurrences = zeros(0,1);
            else
                NumOccurrences = splitapply(@sum, ones(size(groupNumId)), groupNumId);
            end

            % For an Identifier AND File, find those occurrences.
            [~, occurrences] = findgroups(obj.Locations.Identifier, obj.Locations.File);

            % For those groups, calculate the number of occurrences in ALL the files.
            groupNumFile = findgroups(occurrences);
            if isempty(groupNumFile)
                % splitapply group numbers must be a vector of positive integers,
                % and cannot be a sparse vector.
                NumFiles = zeros(0,1);
            else
                NumFiles = splitapply(@sum, ones(size(groupNumFile)), groupNumFile);
            end

            if isempty(Identifier)
                Identifier = categorical.empty(0, 1);
            else
                Identifier = categorical(Identifier);
            end
            tableUnsorted = table(Identifier, NumOccurrences, NumFiles);
            statistics = sortrows(tableUnsorted, 'NumFiles', 'descend');
        end
    end
end
