classdef MLCategoricalDataModel < ...
        internal.matlab.variableeditor.MLArrayDataModel & ...
        internal.matlab.variableeditor.CategoricalDataModel
    % MLCategoricalDataModel
    % Matlab Categorical variable Data Model
    
    % Copyright 2013-2014 The Mathworks, Inc.
    
    methods(Access='public')
        % Constructor
        function this = MLCategoricalDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLArrayDataModel(...
                name, workspace);
        end
    end
    
    methods(Access='protected')
        % Compares new data to the current data and returns Rows(I) and
        % Columns(J) of Unmatched Values.  Assumes this.Data and newData
        % are the same size.
        %
        % For example, the following inputs returns [1, 2]:
        % this.Data = categorical({'r' 'b'; 'g' 'r'}, {'r' 'g' 'b'}, ...
        %     {'red' 'green' 'blue'})
        % newData = categorical({'r' 'g'; 'g' 'r'}, {'r' 'g' 'b'}, ...
        %     {'red' 'green' 'blue'})
        function [I, J] = doCompare(this, newData)           
            % Compare categories first
            aCat = categories(this.Data);
            bCat = categories(newData);
            if length(aCat) == length(bCat)
                categoriesDiffer = any(cellfun(@(a,b) ~isequal(a,b), ...
                    aCat, bCat));
            else
                categoriesDiffer = true;
            end
            
            if categoriesDiffer
                % Return multiple values to entire table is redisplayed
                I = [1,1];
                J = [1,1];
            else
                % Compare by string value so '<undefined>' can match
                % '<undefined>'  (most categorical compare functions
                % treate <undefined> like nan... it is not equal to
                % itself.
                [I,J] = find(cellfun(@(a,b) ~isequal(a,b), ...
                    cellstr(this.Data), cellstr(newData)));
            end
        end
        
        % Get LHS for eval.  Categorical variables are indexed like numeric
        % arrays.
        function lhs = getLHS(~, idx)
            lhs = sprintf('(%s)', idx);
        end
    end
end