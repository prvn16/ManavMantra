function usage = getUsage(functionName)
    %GETUSAGE Get usage syntax from documentation or source code
    %   USAGE = GETUSAGE(FUNCTIONNAME) returns a struct array of the syntaxes
    %   found for functionName. The struct has two fields; lhs and rhs. lhs
    %   is a string array of the names of the return values for the given 
    %   syntax. rhs is a string array of the names of the input arguments.
    %
    %   GETUSAGE attempts to get the syntax information from the function
    %   reference page. If there is no function reference page, or if the page
    %   does not contain any syntaxes, GETUSAGE will then attempt to get the
    %   syntaxes from the MATLAB file help text.
    %
    %   GETUSAGE will return syntaxes only for the first function that WHICH
    %   finds. To get syntaxes for overloaded methods, provide the full 
    %   classname and methodname to GETUSAGE.
    %
    %   Examples:
    %      usage = matlab.internal.language.introspective.getUsage("magic");
    %
    %         returns a struct with fields:
    %
    %           lhs: "M"
    %           rhs: "n"
    %
    %      usage = matlab.internal.language.introspective.getUsage("LinearModel.Plot");
    %
    %         returns a 1x2 struct array with:
    %
    %         usage(1) =
    %           lhs: [0x0 string]
    %           rhs: "LM"
    %
    %         usage(2) =
    %           lhs: "H"
    %           rhs: "LM"
    %
    %   See also HELP, DOC, GETUSAGEFROMDOC, GETUSAGEFROMHELP, GETUSAGEFROMSOURCE.
    
    %   Copyright 2017 The MathWorks, Inc.
        
    functionName = convertStringsToChars(functionName);
    
    sigs = matlab.internal.language.introspective.getUsageFromDoc(functionName);
    
    if isempty(sigs)
        sigs = matlab.internal.language.introspective.getUsageFromHelp(functionName);
    end
    
    if isempty(sigs)
        nameResolver = matlab.internal.language.introspective.resolveName(functionName, '', false);
        if ~isempty(nameResolver)
            sigs = matlab.internal.language.introspective.getUsageFromSource(nameResolver.whichTopic, nameResolver.resolvedTopic);
            
            if isempty(sigs)
                % script or class with no constructor
                sigs = string(functionName);
            end
        end
    end
    
    usage = sigs2struct(sigs, functionName);
end

function usage = sigs2struct(sigs, functionName)
    usage=struct('lhs',{},'rhs',{});
    functionNamePattern = regexprep(functionName, '.*\W', '($0)?');
    
    for sig = sigs 
        cur.lhs = strings(0);
        cur.rhs = strings(0);

        s = split(sig, '=');
        if ~isscalar(s)
            if (s(1).contains('['))
                argumentList = regexp(s(1), '(?<=\[).*(?=\])', 'match', 'once');
                cur.lhs = splitArgumentList(argumentList);
            else
                cur.lhs = strip(s(1));
            end
            s = join(s(2:end), '=');
        end

        if s.contains('(')
            functionName = extractBefore(s,'(');
            argumentList = regexp(s, '(?<=\().*(?=\))', 'match', 'once');
            cur.rhs = splitArgumentList(argumentList);
        else
            if isempty(cur.lhs)
                s = split(strip(s), ' ');
                if ~isscalar(s)
                    cur.rhs = s(2:end);
                    s = s(1);
                end
            end
            functionName = s;
        end

        if ~isempty(regexp(strip(functionName), ['^', functionNamePattern, '$'], 'once'))
            usage(end+1) = cur; %#ok<AGROW>
        end
    end
end

function list = splitArgumentList(list)
    list = strip(regexp(list, listPattern, 'match'));
end

function g = grouped(s, e)
    s = "\" + s;
    e = "\" + e;
    notE = "[^" + e + "]*";
    g = s + notE + e;
end

function lp = listPattern
    parened = grouped('(', ')');
    bracketed = grouped('[', ']');
    curlied = grouped('{', '}');
    singleQuoted = grouped("'", "'");
    doubleQuoted = grouped('"', '"');    
    id = "[^,\s]+";
    fcnCall = "\s*\w*" + parened;
    argTypes = [fcnCall, bracketed, curlied, singleQuoted, doubleQuoted, id];
    lp = join(argTypes, '|');
end
