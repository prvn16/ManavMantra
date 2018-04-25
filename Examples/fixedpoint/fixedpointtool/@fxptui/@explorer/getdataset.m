function [dataset, runName] = getdataset(h)
    %GETDATASET Get the dataset.
    
    %   Copyright 2007-2016 The MathWorks, Inc.
    
    modelName = h.getFPTRoot.getDAObject.getFullName();
    appData = SimulinkFixedPoint.getApplicationData(modelName);
    dataset = appData.dataset;
    runName = appData.ScaleUsing;
end