classdef PathNormalizer

	methods (Static)

        function tf = isfullpath(file)
            % Ugly, but faster than regexp.
            % File is a full path already if:
            %   * It starts with / on any platform.
            %   * On the PC, it starts with / or \
            %   * On the PC, it starts with X:\ or X:/ (where X is any drive)
            import matlab.depfun.internal.requirementsConstants
            tf = (~isempty(file) && ...
                 (file(1) == requirementsConstants.FileSep || file(1) == '/' || ...
                 (requirementsConstants.isPC && numel(file) >= 3 && file(2) == ':' && ...
                 (file(3) == requirementsConstants.FileSep || file(3) == '/'))));
        end
        
        function absolute_path = denormalizeFiles(file)
            import matlab.depfun.internal.requirementsConstants
            if iscell(file)
                absolute_path = cell(1,numel(file));
                for k=1:numel(file)
                    if ~matlab.depfun.internal.PathNormalizer.isfullpath(file)
                        absolute_path{k} = [requirementsConstants.MatlabRoot ...
                             requirementsConstants.FileSep file];
                    else
                        absolute_path{k} = file;
                    end
                end
            else
                if ~matlab.depfun.internal.PathNormalizer.isfullpath(file)
                    absolute_path = ...
                        [requirementsConstants.MatlabRoot requirementsConstants.FileSep file];
                else
                    absolute_path = file;
                end
            end
            if requirementsConstants.isPC
                absolute_path = strrep(absolute_path, '/', requirementsConstants.FileSep);
            end
        end

        function relative_path = normalizeFiles(files, processPathsForSql)
        % Normalize path and make it relative to matlabroot. If escapeApostrophesForSql
        % is true, double any apostrophes so that they won't kill an SQL query.
            import matlab.depfun.internal.requirementsConstants
            sprintf('type: %s', class(files));
            if (nargin < 3)
                processPathsForSql = true;
            end
            if ~iscell(files)
                files = { files };
            end
            
            % matlabroot patterns
            pat = [requirementsConstants.MatlabRoot requirementsConstants.FileSep];
            pat1 = regexptranslate('escape', pat);
            pat2 = regexptranslate('escape', strrep(pat, requirementsConstants.FileSep, '/'));
            expr = ['(' pat1 '|' pat2 ')'];

            % remove matlabroot
            relative_path = regexprep(files, expr, '');
            % canonical path
            relative_path = strrep(relative_path, requirementsConstants.FileSep,'/');
            % Convert apostrophes to double apostrophes so they won't
            % break an SQL query.
            if (processPathsForSql)
                relative_path = matlab.depfun.internal.PathNormalizer.processPathsForSql(...
                    relative_path);
            end
        end
        
        function relative_path = normalizeFile(file, processPathsForSql)
        % Normalize path and make it relative to matlabroot. If escapeApostrophesForSql
        % is true, double any apostrophes so that they won't kill an SQL query.
            relative_path = matlab.depfun.internal.PathNormalizer.normalizeFiles(...
                file, processPathsForSql);
            relative_path = relative_path{1};
        end

        function escaped_path = processPathsForSql(files)
            escaped_path = strrep(files, '''', '''''');
        end
        
    end
end

