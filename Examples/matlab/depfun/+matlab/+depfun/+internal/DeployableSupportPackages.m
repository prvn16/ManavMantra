classdef DeployableSupportPackages < handle
    
    % Class for getting the list of Support Packages that support
    % matlab.addons.internal.SupportPackageInfoBase interface
    
    properties (Access = private) 
       supportPackageList; 
    end

    methods
        function obj=DeployableSupportPackages()
        
            % store the instances in a map facilitate lookup by name
            obj.supportPackageList = containers.Map;
        
            packages = meta.package.fromName( 'matlab.addons.internal' );
            classes = packages.ClassList;
            for i = 1:length(classes)
                if(~classes(i).Abstract) % skip the abstract class
                    % need to check that is has matlab.addons.internal.SupportPackageInfoBase
                    % as a superclass
                    if(length(classes(i).SuperclassList) == 1 ...
                            &&  strcmp(classes(i).SuperclassList.Name, 'matlab.addons.internal.SupportPackageInfoBase'))
                        tmpClass = feval(classes(i).Name);
                        % Although we should never hit this, the posibility exists that 
                        % two classes could have the same "name"
                        % Check to see if the name is already a key in the map
                        if(obj.supportPackageList.isKey(tmpClass.name))
                            % If it is, warn there are two class implemenations that have the same name
                            error(message( ...
                                'MATLAB:depfun:DeployableSupportPackages:DuplicateNames', ...
                                class(obj.supportPackageList(tmpClass.name)), classes(i).Name))
                        else
                            % Otherwise, add it to the map
                            obj.supportPackageList(tmpClass.name) = tmpClass;
                        end
                        
                    end
                end
            end
        end
        
        function supportPkgList = getSupportPackageList(obj)
            supportPkgList = obj.supportPackageList.values;
        end
        
        function supportPkg = getSupportPackage(obj, name)
            supportPkg = [];
            
            if(obj.supportPackageList.isKey(name))
                supportPkg = obj.supportPackageList(name);
            end
            
        end
    end
    
    
end