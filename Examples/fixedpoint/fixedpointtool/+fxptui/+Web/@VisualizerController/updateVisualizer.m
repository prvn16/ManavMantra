
function updateVisualizer(this, lastUpdatedRun, simulatedResults,  ~)
%% UPDATEVISUALIZER function updates visualizer with histograms from latest run

%   Copyright 2016 The MathWorks, Inc.

    % If Visualizer is featured on
    if slfeature('Visualizer') 
        % resultRenderingOrder 
        %if ~isempty(spreadsheetResultHierarchy) && ~isempty(spreadsheetResultHierarchy.results)
            %resultRenderingOrder =  spreadsheetResultHierarchy.results;
            %resultRenderingOrder = [resultRenderingOrder{:}];

            % Send data that matches the visualization order of
            % FPT Model Hierarchy tree
            this.sendVisualizationData(lastUpdatedRun, simulatedResults, {});
        %end
    end
end