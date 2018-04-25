function resolveExplicitPath(obj, topic)

    atOccurances = sum(topic == '@');
        
    if atOccurances == 2
        UDDParts = regexp(topic, '^(?<path>.*?[\\/])?(?<package>@\w+)[\\/](?<class>@\w+)(?<methodSep>[\\/])?(?<method>(?(methodSep)\w+))?(?(method)\.\w+)?$', 'names', obj.regexpCaseOption);
        if ~isempty(UDDParts)
            % Explicitly two @ directories
            obj.UDDClassInformation(UDDParts);
            obj.malformed = isempty(obj.classInfo);        
        end
    else      
        MCOSParts = regexp(topic, '^(?<path>[\\/]?([^@+][^\\/]*[\\/])*)?(?<packages>\+\w+([\\/]\+\w+)*)?(?<classSep>(?(packages)[\\/]|(?(path)|^[\\/]?))@)?(?<class>(?(classSep)\w+))(?<methodSep>[\\/])?(?<method>(?(methodSep)\w+))?(?<ext>(?(method)\.\w+))?$', 'names', obj.regexpCaseOption);
        if ~isempty(MCOSParts)
            % Explicitly zero or more + directories and/or one @ directory
            obj.MCOSClassInformation(topic, MCOSParts);
            obj.malformed = isempty(obj.classInfo);
        end
    end
end

%   Copyright 2013 The MathWorks, Inc
