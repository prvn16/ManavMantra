% Internal function for creating and packaging a toolbox from the MATLAB command line

% Copyright 2014 The MathWorks, Inc.
function create(file, varargin)
   % narginchk(1,2);
   
    p = inputParser;
    p.addOptional('dependencyOption',[]);
    
    p.parse(varargin{:});
    
    dependencyOption = p.Results.dependencyOption; 
    
    % g1143308 ssegench
    % optional switch to control how much of the dependency analys is
    % included in the prj / toolbox. options are:
    % "fullanalysis" (default) - dependency anaysis is run and all results are stored
    %       in the toolbox
    % "productanalysis" - dependency anaysis is run and only the product 
    %       dependencioes are stored in the toolbox
    % "noanalysis" - dependency anaysis is not run. The prj will by default
    %       include MATLAB as a product dependency but that is all
    options = {'fullanalysis' 'productanalysis' 'noanalysis'};
    if(~isempty(dependencyOption))
        if  ~any(strcmp(dependencyOption, options))
            disp('dependencyOption must be one of: fullanalysis, productanalysis or noanalysis');
            return; 
        end
    else 
        dependencyOption = 'fullanalysis';
    end
        
    
    % g1100786
    % need to pause matlab for java to be able to see the
    % current MATLAB path
    pause(1);
    
    if isdir(file)
        [~, b] = fileattrib(file);

           
        rootPath = b.Name;
        projectFileString = [rootPath '.prj'];
        service = com.mathworks.toolbox_packaging.services.ToolboxPackagingService;
        configKey = service.createConfiguration(java.lang.String(projectFileString));
        
        % Add the root folder and update the fileset
        service.setToolboxRoot(configKey, rootPath);
        
        % Examples, apps, and doc
        toolboxDependencies = matlab.depfun.internal.DependencyFormatter.toolboxPackagingDependencies(rootPath, []);
        
        service.updateExamplesAppsAndDoc( ...
            configKey, toolboxDependencies.CategorizedExamples, toolboxDependencies.AppsList, ...
            toolboxDependencies.DocFile, toolboxDependencies.DemosFile);
        
        % Requirements analysis
        % g1143308 ssegench
        if ~strcmp(dependencyOption, 'noanalysis')
            [ externalDependencies, productName, productVersion, productNumber, ~] = ...
                matlab.depfun.internal.DependencyFormatter.findExternalDependenciesTopOnly( ...
                rootPath,false,rootPath);
            if ~strcmp(dependencyOption, 'fullanalysis')
                externalDependencies = [];
            end
            
            service.updateRequiredFilesAndProducts( ...
                configKey, externalDependencies, productName, productVersion, productNumber);
        end        
        
        
        % Package
        service.packageProject(configKey);
        
        % Clean up
        service.closeProject(configKey);
        
    else
        disp('Input must be a root folder for the toolbox');
    end
    
end

