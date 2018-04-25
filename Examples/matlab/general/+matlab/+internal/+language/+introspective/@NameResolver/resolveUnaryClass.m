function resolveUnaryClass(obj, className)
    obj.whichTopic = matlab.internal.language.introspective.safeWhich(className, obj.isCaseSensitive);

    if ~isempty(obj.whichTopic)
        hasFilesep = ~isempty(regexp(className, '[\\/]', 'once'));
        [isClassMFile, className, whichComment] = matlab.internal.language.introspective.isClassMFile(obj.whichTopic);
        if isClassMFile
            obj.classInfo = matlab.internal.language.introspective.classInformation.simpleMCOSConstructor(className, obj.whichTopic, obj.justChecking);
        elseif ~hasFilesep && ~isempty(whichComment)
            obj.whichTopic = '';
        end
    end
end