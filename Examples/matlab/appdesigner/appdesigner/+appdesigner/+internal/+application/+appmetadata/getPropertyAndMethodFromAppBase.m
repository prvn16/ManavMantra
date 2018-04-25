function appBaseClassAttributes = getPropertyAndMethodFromAppBase()
    % GETPROPERTYANDMETHODFROMAPPBASE Get all the properties and methods declared in AppBase

    % If the class name is changed, it will throw error

    %   Copyright 2015-2016 The MathWorks, Inc.

    % get app base properties & methods
    baseClassMeta = ?matlab.apps.AppBase;
    appBaseProperties = {baseClassMeta.PropertyList.Name};
    propertyDefiningClass =  cellfun(@(x) x.Name, {baseClassMeta.PropertyList.DefiningClass},'UniformOutput', false);
    appBaseMethods = {baseClassMeta.MethodList.Name};
    methodsDefiningClass =  cellfun(@(x) x.Name, {baseClassMeta.MethodList.DefiningClass},'UniformOutput', false);

    % filter out handle code items
    appBaseProperties(~strcmp(baseClassMeta.Name, propertyDefiningClass)) = [];
    appBaseMethods(~strcmp(baseClassMeta.Name, methodsDefiningClass)) = [];

    
    appBaseClassAttributes.BaseClassData.Name = [ ...
        appBaseProperties, ...
        appBaseMethods, ...
        ];
    
    appBaseClassAttributes.BaseClassData.Type = [ ...
        repmat({'AppBaseProperty'},1,length(appBaseProperties)), ...
        repmat({'AppBaseMethod'},1,length(appBaseMethods)), ...
        ];
end
