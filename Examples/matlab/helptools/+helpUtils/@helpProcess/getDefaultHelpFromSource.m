function getDefaultHelpFromSource(hp)
    if ~hp.noDefault 
        hp.needsHotlinking = true;
        
        if exist(hp.fullTopic, 'file') || ~endsWith(hp.fullTopic, ".m") && exist(regexprep(hp.fullTopic, '\.\w+$', '.m'), 'file')
            name = hp.objectSystemName;
            usage = matlab.internal.language.introspective.getUsageFromSource(hp.fullTopic, name);
            if isempty(name)
                [~, name] = fileparts(hp.topic);
            end
            if hp.wantHyperlinks
                % ensure highlighting by uppering the name
                usage = regexprep(usage, "(^|=)\s*" + name + "\s*(\(|$)", "${upper($0)}");
                name = upper(name);
            end
            if usage == ""
                if hp.isMCOSClass
                    hp.helpStr = getString(message('MATLAB:help:DefaultClassHelp', name));
                elseif hp.isMCOSClassOrConstructor
                    hp.helpStr = getString(message('MATLAB:help:DefaultNoConstructorHelp', name));
                elseif isempty(hp.objectSystemName)
                    hp.helpStr = noUsageHelp(name);
                elseif hp.isDir
                    hp.helpStr = getString(message('MATLAB:help:DefaultPackageHelp', name));
                else
                    switch hp.elementKeyword
                    case 'properties'
                        hp.helpStr = getString(message('MATLAB:help:DefaultPropertyHelp', name));
                    case 'events'
                        hp.helpStr = getString(message('MATLAB:help:DefaultEventHelp', name));
                    case 'enumeration'
                        hp.helpStr = getString(message('MATLAB:help:DefaultEnumerationHelp', name));
                    case 'methods'
                        hp.helpStr = getString(message('MATLAB:help:DefaultNoArgFunctionHelp', name));
                    case 'constructor'
                        hp.helpStr = getString(message('MATLAB:help:DefaultClassHelp', name));
                    case 'packagedItem'
                        hp.helpStr = noUsageHelp(name);
                    end
                end
            else
                if hp.isMCOSClass
                    hp.helpStr = getString(message('MATLAB:help:DefaultConstructorHelp', name, usage));
                elseif hp.isMCOSClassOrConstructor
                    hp.helpStr = getString(message('MATLAB:help:DefaultFullConstructorHelp', name, usage));
                elseif strcmpi(usage, name)
                    hp.helpStr = getString(message('MATLAB:help:DefaultNoArgFunctionHelp', name));
                else
                    hp.helpStr = getString(message('MATLAB:help:DefaultFunctionHelp', name, usage));
                end
            end
        elseif ~isempty(matlab.internal.language.introspective.hashedDirInfo(hp.topic))
            folderName = matlab.internal.language.introspective.minimizePath(hp.topic, true);
            if folderName ~= "private"
                hp.helpStr = getString(message('MATLAB:help:DefaultFolderHelp', folderName));
            end
        end
    end
end

function helpStr = noUsageHelp(name)
    try
        nargin(name);
        % There is no usage because it's P-Coded, not because it's a script
        helpStr = getString(message('MATLAB:help:DefaultNoArgFunctionHelp', name));
    catch
        % Nargin errors because it's a script.
        helpStr = getString(message('MATLAB:help:DefaultScriptHelp', name));
    end
end

