function underqualifiedResolve(obj, topic)
    if ~isempty(regexp(topic, '^\w+(?:\.\w+)?$', 'once')) && ~hasFolderHelp(topic)
        [~, whichDescriptors] = which(topic, '-all');
        for i = 1:length(whichDescriptors)
            whichDescriptor = whichDescriptors{i};
            methodDescriptor = regexp(whichDescriptor, '\<(?<className>\S*) method$', 'names');
            if ~isempty(methodDescriptor)
                methodName = regexp(topic, '\w+(?=(\.\w+)?$)', 'match', 'once');
                qualifiedTopic = [methodDescriptor.className, '/', methodName];
                obj.isUnderqualified = true;
                obj.doResolve(qualifiedTopic, false);
                if obj.isResolved
                    if isempty(obj.classInfo) || ~obj.classInfo.isAccessible
                        obj.classInfo  = [];
                        obj.whichTopic = '';
                        obj.isInaccessible = true;
                    else
                        break;
                    end
                end
            end
        end
    end
end

function b = hasFolderHelp(topic)
    folders = what(topic)';
    for folder = folders
        if ~isempty(folder.m) || ~isempty(folder.classes)
            % for a folder to have help it must have a Contents.m file, or
            % some other .m file or a class folder
            b = true;
            return;
        end
    end
    b = false;
end
