classdef (Abstract) SupportPackageInfoBase < matlab.mixin.Heterogeneous
   
    properties (Access = public) 
        
        % Mandatory properties
        
        % baseProduct: String (MANDATORY)
        % Full Name of the base product for the support package 
        % e.g. Data Acquisition Toolbox
        baseProduct = '';
        
        % name: String (MANDATORY)
        % The externalProductIdentifier from config/products xml
        % for the given support package
        name = '';
        
        % displayName: String (MANDATORY)
        % name to display in deploytool. 
        displayName = '';
        
        % Optional properties  
        % thirdPartyName & thirdPartyURL are optional properties
        % These provide support packages the ability to include notes about
        % third party software dependencies.  
        % Both of these are cell arrays. If there are multiple third party dependencies 
        % each should have its own name and URL.
        thirdPartyName = {};
        thirdPartyURL = {};
        
        % okToCopyFiles is primarily for the Aero use case.
        % This allows deploytool to copy the files from the support package
        % to a temporary directory and then -a the single directory.
        % Otherwise including every file individually with a -a could 
        % result in the lenght of the mcc command exceeding the windows limit.
        okToCopyFiles = false;
        
    end
    
    % mandatoryIncludeList and conditionalIncludeMap are for the default implementations
    % of the class methods. Limit access to protect their usage from outside of the class
    properties (Access = protected) 
        % Cell array of the files and folders that should always be included for deployment
        % All files and folders should be specified using a full path
        % Listing folders is preferred to individual files
        % Take care listing platform specific files and folders. Either use wildcards
        % or commands like computer('arch') or mexext to ensure the paths are correct. 
        % Listing a file or folder that does not exist will cause mcc to fail.
        mandatoryIncludeList = {};
        
        % container.Map 
        % Keys: Fullpath to a matlab file. Use of this file indicates the support package 
        % should be included in deployment. The file can be in the support package or part 
        % part of MATLAB
        % Values: Cell array of the files and folders that should be included for deployment
        % if the matlab file specified by the Key is used. This can be left empty. 
        conditionalIncludeMap = {};        
        
    end
    
    methods
        
        % test for determining whether or not a support package should be included 
        % for deployment
        function bool = filesOrProductsUseSupportPackage(obj, fileList, productList) 
            % check to see if there is a conditional include map
            % if so, use it
            if(~isempty(obj.conditionalIncludeMap) && obj.conditionalIncludeMap.Count > 0 )
                keys = obj.conditionalIncludeMap.keys;
                list = fileList;
            else
                % if not use the product info
                keys = obj.baseProduct;
                list = productList;
            end
            % make sure the list is a cellarray
            if(ischar(list))
                list = {list};
            end
            % see if any of the keys are in the list
            [~,idx] = intersect(keys, list);
            bool = any(idx);
        end
        
        % function to get the list of files and folders that should be included for deployment
        function filesAndFolders = getIncludeList(obj, fileList)
            % always include the mandatory list
            filesAndFolders = obj.mandatoryIncludeList;
            
            % if there are conditional includes check them as well
            if(hasConditionalIncludes(obj) && ~isempty(fileList))
                if(ischar(fileList))
                    fileList = {fileList};
                end
                keys = obj.conditionalIncludeMap.keys;
                [~,idx] = intersect(keys, fileList);
                v = obj.conditionalIncludeMap.values;
                 if(~isempty(idx))
                    incFiles = {};
                    for i = 1:length(idx)
                        incFiles = union(incFiles, v{idx(i)});
                    end
                    
                    filesAndFolders = union(filesAndFolders, incFiles);
                 end
            end
            if(~isrow(filesAndFolders))
                filesAndFolders = filesAndFolders';
            end
        end
        
        % Optimization to let deployment now if it needs to 
        % call requiements before calling the includeList method
        function bool = hasConditionalIncludes(obj)
            v = {};
            % A support package to use the conditional include map
            % strictly for use in the "includeInPackage" method
            % and have a mandatory include list.
            % If the conditionalIncludeMap is not empty 
            % check the list of values.
            % If that is empty there are no conditional includes
            if(~isempty(obj.conditionalIncludeMap))
                v = obj.conditionalIncludeMap.values;
            end
            bool = any(~cellfun('isempty', v));
        end
        
        
    end
    
end