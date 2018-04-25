function usage = getUsageFromHelp(functionName)
    %GETUSAGEFROMHELP Get usage syntax from help text.
    %   USAGE = GETUSAGEFROMHELP(FUNCTIONNAME) returns a string array of the
    %   syntaxes found for functionName. 
    %
    %   GETUSAGEFROMHELP attempts to get the syntax information from the 
    %   help text for functionName.
    %
    %   GETUSAGEFROMHELP will return syntaxes only for the first function 
    %   that WHICH finds. To get syntaxes for overloaded methods, provide 
    %   the full classname and methodname to GETUSAGEFROMHELP.
    %
    %   Examples:
    %      usage = matlab.internal.language.introspective.getUsageFromHelp("magic");
    %
    %         returns a string:
    %
    %           "magic(N)"
    %
    %      usage = matlab.internal.language.introspective.getUsageFromHelp("LinearModel.Plot");
    %
    %         returns a 1×2 string array with:
    %
    %         usage(1) =
    %           "plot(LM)"
    %
    %         usage(2) =
    %           "H = plot(LM)"
    %
    %   See also HELP, GETUSAGE, GETUSAGEFROMDOC, GETUSAGEFROMSOURCE.
    
    %   Copyright 2017 The MathWorks, Inc.
    
    functionName = convertStringsToChars(functionName);
    
    helpStr = help(functionName, '-help');
    isBoth = getString(message('MATLAB:help:IsBothBanner', functionName));
    helpStr = split(helpStr, isBoth);
    helpStr = helpStr{end};
    helpStr = removeHelpForBanner(helpStr);
    helpParts = matlab.internal.language.introspective.helpParts(helpStr, functionName);
    rawPart = helpParts.getPart('raw');
    helpStr = string(rawPart(1).helpStr).extractAfter(newline);
    
    % convert paragraphs into lines
    helpStr = regexprep(helpStr, '(\S) *\n *(\S)', '$1 $2');
    
    usage = regexp(helpStr, functionPattern, 'lineanchors', 'match');
    usage = strip(regexprep(usage, '</?strong>', ''));
    
    % do not return usages with no inputs and no outputs
    scriptUsages = ~usage.contains(["=", " ", "("]);
    usage(scriptUsages) = [];
end

function o = optional(p)
    o = "(" + p + ")?";
end

function k = kleene(p)
    k = "(" + p + ")*";    
end

function w = white
    w = kleene("\s");
end

function e = either(p1, p2)
    e = "(" + p1 + "|" + p2 + ")";
end

function c = capture(name, p)
    c = "(?<" + name + ">" + p + ")";
end

function ite = ifThenElse(name, pt, pf)
    ite = "(?(" + name + ")" + pt + "|" + pf + ")";
end

function fp = functionPattern
    lazy = ".*?";
    bracketed = "\[" + lazy + "\]";
    nested = "\(" + lazy + "\)";
    parenthesized = "\((" + nested + "|.)*?\)";    
    lhs = capture("lhs", optional(either("\S+", bracketed) + white + "=" + white));
    fcnName = "<strong>\S*?</strong>";
    cmdArgs = kleene("\s+-?[A-Z.]+\>");
    rhs = ifThenElse("lhs", optional(parenthesized), either(parenthesized, cmdArgs));
    fp = "^" + white + lhs + fcnName + rhs;
end

function helpStr = removeHelpForBanner(helpStr)
    bannerPlaceholder = 'HELP_FOR_BANNER_PLACEHOLDER';
    bannerPattern = getString(message('MATLAB:help:HelpForBanner', bannerPlaceholder));
    bannerPattern = regexptranslate('escape', bannerPattern);
    bannerPattern = regexprep(bannerPattern, bannerPlaceholder, '\\S*');
    helpStr = regexprep(helpStr, bannerPattern, '');
end