function resolveImplicitPath(obj, topic)

    imports = builtin('_toolboxCallerImports');
    firstName = regexp(topic, '\w+', 'match', 'once');

    for i = 1:length(imports)
        thisImport = imports{i};
        if thisImport(end) == '*'
            innerResolveImplicitPath(obj, [thisImport(1:end-1) topic]);
        else
            names = regexp(thisImport, '^(?<qualifiers>.*\.)?(?<lastItem>.*)$', 'names');
            if matlab.internal.language.introspective.casedStrCmp(obj.isCaseSensitive, firstName, names.lastItem)
                innerResolveImplicitPath(obj, [names.qualifiers topic]);
            end
        end

        if ~isempty(obj.classInfo)
            obj.classInfo.unaryName = topic;
            return;
        end
    end

    innerResolveImplicitPath(obj, topic);
end

%% ------------------------------------------------------------------------
function innerResolveImplicitPath(obj, topic)

    objectParts = regexp(topic, '^(?<pathAndPackage>.+?)(?<s1>[.\\/])?(?<class>(?(s1)\w+))(?<s2>[.\\/])?(?<method>(?(s2)\w+))$', 'names');
    
    if ~isempty(objectParts)
        
        objectParts.pathAndPackage = regexprep(objectParts.pathAndPackage, '\\', '/');
        
        if isempty(objectParts.method)
            allPackageInfo = [];
        else
            allPackageInfo = ternaryResolve(obj, objectParts);
            if isempty(obj.classInfo)
                [objectParts, allPackageInfo] = convertClassToPackage(obj, objectParts, allPackageInfo);
            end
        end

        if isempty(obj.classInfo) && ~isempty(objectParts.class)
            binaryResolve(obj, objectParts, allPackageInfo);
            if isempty(obj.classInfo)
                [objectParts, allPackageInfo] = convertClassToPackage(obj, objectParts, allPackageInfo);
            end
        end

        if isempty(obj.classInfo)
            unaryResolve(obj, objectParts, allPackageInfo);
        end

        if ~isempty(obj.classInfo)
            obj.classInfo.isMinimal = isempty(regexp(objectParts.pathAndPackage, '[\\/.]', 'once'));
        end
    end
end

%% ------------------------------------------------------------------------
function allPackageInfo = ternaryResolve(obj, objectParts)

    allPackageInfo = getPackageInfo(obj, objectParts.pathAndPackage);
    
    for i = 1:length(allPackageInfo)
        
        packageInfo = allPackageInfo(i);
        packagePath = packageInfo.path;
        packageName = matlab.internal.language.introspective.getPackageName(packagePath);
        
        [isDocumented, packageID] = obj.isDocumentedPackage(packageInfo, packageName);
        
        if isDocumented
            
            classIndex      = matlab.internal.language.introspective.casedStrCmp(obj.isCaseSensitive, packageInfo.classes, objectParts.class);
            className       = '';
            fileType        = '';
            classHasNoAtDir = false;
            
            if any(classIndex)
                className = packageInfo.classes{classIndex};
            elseif ischar(packageID)
                [className, foundTarget, fileType] = matlab.internal.language.introspective.extractFile(packageInfo, objectParts.class, obj.isCaseSensitive);
                if foundTarget
                    classHasNoAtDir = true;
                end
            end
            
            if ~isempty(className)
                
                if ischar(packageID)
                    classHandle = matlab.internal.language.introspective.classWrapper.rawMCOS(className, fileType, packagePath, packageID, classHasNoAtDir, false, obj.isCaseSensitive);
                else
                    classHandle = matlab.internal.language.introspective.classWrapper.rawUDD(className, packagePath, packageID, false);
                end
                
                obj.classInfo = classHandle.getClassInformation(objectParts.method, obj.justChecking);
                                
                if ~isempty(obj.classInfo)
                    return;
                end
            end
        end
    end
end

%% ------------------------------------------------------------------------
function [allPackageInfo] = binaryResolve(obj, objectParts, allPackageInfo)

    if ~isstruct(allPackageInfo)
        allPackageInfo = getPackageInfo(obj, objectParts.pathAndPackage);
    end
    
    binaryResolveThroughPackages(obj, objectParts, allPackageInfo);
    
    if ~isempty(obj.classInfo)
       return; 
    end
    
    classMFile = matlab.internal.language.introspective.safeWhich(objectParts.pathAndPackage, obj.isCaseSensitive);

    if ~matlab.internal.language.introspective.isObjectDirectorySpecified(classMFile)

        [packagePath, className, classExt] = fileparts(classMFile);

        classHandle = matlab.internal.language.introspective.classWrapper.rawMCOS(className, classExt(2:end), packagePath, '', true, false, obj.isCaseSensitive);
        obj.classInfo = classHandle.getClassInformation(objectParts.class, obj.justChecking);
    end
end

function binaryResolveThroughPackages(obj, objectParts, allPackageInfo)

    for i = 1:length(allPackageInfo)

        classHandle = [];
        packageInfo = allPackageInfo(i);
        packagePath = packageInfo.path;
        packageName = matlab.internal.language.introspective.getPackageName(packagePath);

        [isDocumented, packageID] = obj.isDocumentedPackage(packageInfo, packageName);

        if isDocumented
            classIndex = matlab.internal.language.introspective.casedStrCmp(obj.isCaseSensitive, packageInfo.classes, objectParts.class);

            if any(classIndex)
                objectParts.class = packageInfo.classes{classIndex};
                if ischar(packageID)
                    classHandle = matlab.internal.language.introspective.classWrapper.rawMCOS(objectParts.class, '', packagePath, packageID, false, true, obj.isCaseSensitive);
                else
                    classHandle = matlab.internal.language.introspective.classWrapper.rawUDD(objectParts.class, packagePath, packageID, true);
                end
            else
                [className, foundTarget, fileType] = matlab.internal.language.introspective.extractFile(packageInfo, objectParts.class, obj.isCaseSensitive);
                if foundTarget
                    if ischar(packageID) && matlab.internal.language.introspective.isClassMFile(fullfile(packagePath, className))
                        % MCOS Class
                        obj.classInfo = matlab.internal.language.introspective.classInformation.fullConstructor([], packageName, className, packagePath, true, true, obj.justChecking);
                    else
                        obj.classInfo = matlab.internal.language.introspective.classInformation.packagedFunction(packageName, packagePath, className, fileType);
                    end
                    return;
                else
                    packageList = dir(packagePath);

                    if obj.isCaseSensitive
                        regexCase = 'matchcase';
                    else
                        regexCase = 'ignorecase';
                    end

                    items = regexp({packageList.name}, ['^(?<name>' objectParts.class ')(?<ext>\.\w+)$'], 'names', regexCase);
                    items = [items{:}];
                    
                    for item = items
                        helpFunction = matlab.internal.language.introspective.getHelpFunction(item.ext);
                        if ~isempty(helpFunction)
                            % unknown packaged item with help extension
                            itemFullName = [item.name item.ext];
                            obj.classInfo = matlab.internal.language.introspective.classInformation.packagedUnknown(packageName, packagePath, item.name, itemFullName, helpFunction);
                            return;
                        end
                    end
                end
            end
        end

        if isempty(classHandle) && ischar(packageID)
            [packagePath, classDir] = fileparts(packagePath);
            if ~isempty(classDir) && classDir(1) == '@'      
                packageSplit = regexp(packageName, '(?<package>.*(?=\.))?\.?(?<class>.*)', 'names');
                packageName  = packageSplit.package;
                classHandle  = matlab.internal.language.introspective.classWrapper.rawMCOS(packageSplit.class, '', packagePath, packageName, false, false, obj.isCaseSensitive);
            end
        end

        if ~isempty(classHandle)
            obj.classInfo = classHandle.getClassInformation(objectParts.class, obj.justChecking);
            if ~isempty(obj.classInfo)
                return;
            end
        end
    end
end

%% ------------------------------------------------------------------------
function unaryResolve(obj, objectParts, allPackageInfo)
    className = objectParts.pathAndPackage;

    obj.resolveUnaryClass(className);

    if isempty(obj.whichTopic) && ~isempty(regexp(className, '.*\w$', 'once'))
        if ~isstruct(allPackageInfo)
            allPackageInfo = getPackageInfo(obj, className);
        end

        obj.resolvePackageInfo(allPackageInfo, false);

        if isempty(obj.classInfo) && (isequal(objectParts.s2, '.') || (isempty(objectParts.s2) && isequal(objectParts.s1, '.')))
            % which may have used an extension as a target
            obj.whichTopic = '';
        end
    end

    if ~isempty(obj.classInfo)
        obj.classInfo.unaryName = className;
    end
end

%% ------------------------------------------------------------------------
function [objectParts, newPackageInfo] = convertClassToPackage(obj, objectParts, oldPackageInfo)

    uddPackageInfo  = matlab.internal.language.introspective.hashedDirInfo([objectParts.pathAndPackage '/@' objectParts.class], obj.isCaseSensitive);
    mcosPackageInfo = matlab.internal.language.introspective.hashedDirInfo([objectParts.pathAndPackage '/+' objectParts.class], obj.isCaseSensitive);

    newPackageInfo  = [mcosPackageInfo; uddPackageInfo];

    for i = 1:numel(oldPackageInfo)
        packageIndex = matlab.internal.language.introspective.casedStrCmp(obj.isCaseSensitive, oldPackageInfo(i).packages, objectParts.class);
        if any(packageIndex)
            newPackageInfo = [newPackageInfo; matlab.internal.language.introspective.hashedDirInfo(fullfile(oldPackageInfo(i).path, ['+' oldPackageInfo(i).packages{packageIndex}]), obj.isCaseSensitive)]; %#ok<AGROW>
        end
    end

    objectParts.pathAndPackage = [objectParts.pathAndPackage, '/', objectParts.class];
    objectParts.class          = objectParts.method;
    objectParts.method         = '';
end

%% ------------------------------------------------------------------------
function allPackageInfo = getPackageInfo(obj, packagePath)

    packagePath    = regexprep(packagePath, '\.(\w*)$', '/$1');
    allPackageInfo = matlab.internal.language.introspective.hashedDirInfo(regexprep(packagePath, '(^|/)(\w*)$', '$1@$2'), obj.isCaseSensitive);
    pathSeps       = regexp(packagePath, '[/.]');

    if isempty(pathSeps)
        allPackageInfo = [matlab.internal.language.introspective.hashedDirInfo(['+' packagePath], obj.isCaseSensitive); allPackageInfo];
    else
        for pathSep = fliplr(pathSeps)
            packagePath    = [packagePath(1:pathSep-1), '/+', packagePath(pathSep+1:end)];
            allPackageInfo = [matlab.internal.language.introspective.hashedDirInfo(packagePath, obj.isCaseSensitive); allPackageInfo]; %#ok<AGROW>
        end
    end
end