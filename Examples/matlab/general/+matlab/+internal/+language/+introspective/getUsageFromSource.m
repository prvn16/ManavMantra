function usage = getUsageFromSource(fullPath, name)    
    %GETUSAGEFROMSOURCE Get usage syntax from source code.
    %   USAGE = GETUSAGEFROMSOURCE(FULLPATH, NAME) returns a string 
    %   containing the function line for the local function NAME found in 
    %   the source file FULLPATH.
    %
    %   See also HELP, GETUSAGE, GETUSAGEFROMDOC, GETUSAGEFROMHELP.
    
    %   Copyright 2017 The MathWorks, Inc.
    
    fullPath = convertStringsToChars(fullPath);
    name = convertStringsToChars(name);

    usage = "";
    whichTopic = regexprep(fullPath, '\.p$', '.m');
    if exist(whichTopic, 'file') && ~exist(whichTopic, 'dir')
        functionText = fileread(whichTopic);
        functionName = regexp(name, '\w+$', 'match', 'once');
        [functionLine, pretext] = regexp(functionText, functionPattern(functionName), 'names', 'split', 'lineanchors', 'dotexceptnewline', 'once');
        if ~isempty(functionLine) && (functionName ~= "" || isempty(regexp(pretext{1}, '\S', 'once')))
            usage = regexprep(string(strip(functionLine.sig)), '\.{3}.*\n', ' ', 'dotexceptnewline');
            % insert optional missing commas between outputs
            usage = regexprep(usage, '(\w)\s+(?=\w)', '$1,');
            % remove all whitespace
            usage = regexprep(usage, '\s+', '');
            % insert whitespace back after commas and around equals
            usage = regexprep(usage, [",", "="], [", ", " = "]);
        end
    end
end

function i = id
    i = "[a-zA-Z]\w*";
end

function o = optional(p)
    o = "(" + p + ")?";
end

function k = kleene(p)
    k = "(" + p + ")*";    
end

function w = white
    w = kleene(kleene("\s") + optional("\.{3}.*\n"));
end

function idl = idList(id, separator)
    idl = white + optional(id + white + kleene(separator + white + id + white));
end

function e = either(varargin)
    e = "(" + join([varargin{:}], "|") + ")";
end

function c = capture(name, p)
    c = "(?<" + name + ">" + p + ")";
end

function fp = functionPattern(functionName)
    bracketed = "\[" + idList(id, "[,\s]") + "\]";
    parenthesized = "\(" + idList(either(id, "~"), ",") + "\)";
    lhs = optional(either(bracketed, id) + white + "=" + white);
    rhs = optional(parenthesized + white);
    if functionName == ""
        functionName = id;
    end
    fp = "^\s*function\s" + white + capture("sig", lhs + functionName + white + rhs) + either("[,;%]", "\.{3}", "$");
end
