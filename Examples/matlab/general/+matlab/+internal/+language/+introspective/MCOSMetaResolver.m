classdef MCOSMetaResolver < handle
    
    properties
        resolvedMeta;
        resolvedName;
        
        fullTopicElements = {''};
        isCaseSensitive;
    end
    
    methods
        function obj = MCOSMetaResolver(topic)
            if ~isempty(regexp(topic, '^\w+([.\\/]\w+)*$', 'once'))
                obj.fullTopicElements = strsplit(topic,{'.','/','\'});
            end
        end
        
        function [resolvedMeta, resolvedName] = executeResolve(obj)
            
            resolvedMeta = [];
            resolvedName = '';

            if ~any(cellfun('isempty', obj.fullTopicElements))

                obj.isCaseSensitive = false;
                obj.doResolve();

                resolvedMeta = obj.resolvedMeta;
                resolvedName = obj.resolvedName;

                if ~isempty(obj.resolvedMeta)
                    obj.isCaseSensitive = true;
                    obj.doResolve(); 

                    if ~isempty(obj.resolvedMeta)
                        resolvedMeta = obj.resolvedMeta;
                        resolvedName = obj.resolvedName;
                    end
                end
            end
        end
    end
    
    methods(Access=private)
        function doResolve(obj)
            
            obj.resolvedMeta = [];
            obj.resolvedName = '';
            
            classes = meta.class.getAllClasses();
            classes = [classes{:}];

            obj.resolveMCOSClass(classes, obj.fullTopicElements);

            if isempty(obj.resolvedMeta)
                packages = meta.package.getAllPackages(); 
                packages = [packages{:}];

                obj.resolveMCOSPackage(packages, obj.fullTopicElements);
            end
        end

        function resolveMCOSPackage(obj, packages, topicElements)
            if ~isempty(packages) && ~isempty(topicElements)

                packageMatches = obj.getMetaInfoByName(packages, topicElements{1});

                for package = packageMatches
                    obj.resolveMCOSPackagedFunction(package, topicElements(2:end));

                    if isempty(obj.resolvedMeta)
                        obj.resolveMCOSClass(package.ClassList, topicElements(2:end));
                    end

                    if isempty(obj.resolvedMeta)
                        if numel(topicElements) > 1
                            obj.resolveMCOSPackage(package.PackageList, topicElements(2:end));
                        else
                            obj.resolvedMeta = package;
                            obj.resolvedName = package.Name;
                        end
                    end

                    if ~isempty(obj.resolvedMeta)
                       break; 
                    end
                end
            end
        end

        function resolveMCOSClass(obj, classes, topicElements)
            if ~isempty(classes) && ~isempty(topicElements) && numel(topicElements) < 3
                
                classMatches = obj.getMetaInfoByName(classes, topicElements{1});

                if ~isempty(classMatches) && numel(topicElements) == 1
                    obj.resolvedMeta = classMatches(1);
                    obj.resolvedName = classMatches(1).Name;
                else
                    for classMatch = classMatches
                        obj.resolveMCOSClassElement(classMatch, topicElements(2));
                        if ~isempty(obj.resolvedMeta)
                            break;
                        end
                    end
                end
            end
        end

        function resolveMCOSPackagedFunction(obj, package, topicElements)
            if ~isempty(package) && numel(topicElements) == 1
                obj.resolveElementMetaInfo(topicElements{1}, package.FunctionList);
                
                if ~isempty(obj.resolvedMeta)
                    obj.resolvedName = [package.Name '.' obj.resolvedMeta.Name];
                end
            end
        end

        function resolveMCOSClassElement(obj, class, topicElements)
            if ~isempty(class) && numel(topicElements) == 1
                elementName = topicElements{1};
                
                obj.resolveElementMetaInfo(elementName, class.MethodList);
                obj.resolveElementMetaInfo(elementName, class.PropertyList);
                obj.resolveElementMetaInfo(elementName, class.EventList);
                obj.resolveElementMetaInfo(elementName, class.EnumerationMemberList);
                
                if ~isempty(obj.resolvedMeta)
                    if isprop(obj.resolvedMeta, 'Static') && obj.resolvedMeta.Static
                        separator = '.';
                    else
                        separator = '/';
                    end
                    obj.resolvedName = [class.Name, separator, obj.resolvedMeta.Name];
                end
            end
        end

        function matchedMetaInfo = getMetaInfoByName(obj, metaInfoList, name)

            if obj.isCaseSensitive
                regexpCase = 'matchcase';
            else
                regexpCase = 'ignorecase';
            end 
            
            isMatch = regexp({metaInfoList.Name},['\<' name '$'],'once', regexpCase);
            isMatch = ~cellfun('isempty', isMatch);

            if any(isMatch)
                matchedMetaInfo = metaInfoList(isMatch);
                matchedMetaInfo = matchedMetaInfo(:)';
            else
                matchedMetaInfo = [];
            end
        end

        function resolveElementMetaInfo(obj, elementName, elementList)
            if isempty(obj.resolvedMeta)
                match = matlab.internal.language.introspective.casedStrCmp(obj.isCaseSensitive,{elementList.Name},elementName);
                match = find(match,1);

                if match ~= 0
                    obj.resolvedMeta = elementList(match);
                end
            end
        end
    end
end