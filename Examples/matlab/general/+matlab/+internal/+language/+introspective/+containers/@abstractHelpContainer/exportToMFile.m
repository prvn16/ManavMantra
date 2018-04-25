function outputMFilePath = exportToMFile(this, outputDir)
    % EXPORTTOMFILE - takes a HelpContainer object as input and generates
    % a MATLAB file containing all the help comments stored in this object.
    %
    % Example:
    % filePath = which('addpath');
    % helpContainer = helpUtils.XMLUtils.HelpContainer.create(filePath);
    % outputDir = pwd;
    % outputMFilePath = helpContainer.exportToMFile(outputDir);
    
    % Copyright 2009-2015 The MathWorks, Inc.

    narginchk(2,2);
    
    if ~ischar(outputDir) || ~isdir(outputDir)
        error(message('MATLAB:introspective:exportToMFile:InvalidOutputDirectory'));
    end
    
    % Need to extract method name from package and/or class qualified name
    fileName = regexp(this.mFileName, '\w*$', 'match', 'once');
    
    outputMFilePath = fullfile(outputDir, [fileName '.m']);
    
    outputFileHandle = fopen(outputMFilePath, 'w');
    
    if outputFileHandle < 0
        error(message('MATLAB:introspective:exportToMFile:MFileCreationFailed', outputDir));
    end
    
    closeFile = onCleanup(@()fclose(outputFileHandle));
    
    if this.isClassHelpContainer
        writeClassHelpMFile(this, outputFileHandle, fileName);
    else
        if writeFunctionHelpMFile(this, outputFileHandle)
            writeCopyrightText(this, outputFileHandle);
        else
            error(message('MATLAB:introspective:exportToMFile:NoHelpComments'));
        end
    end
    
end

%% ------------------------------
function hasMainHelp = writeFunctionHelpMFile(helpContainer, outputFileHandle)
    % writeFunctionHelpMFile - outputs the main help string stored in
    % HelpContainer to the output file as a comment.
    mainHelpStr = helpContainer.getHelp;
    
    hasMainHelp = ~isempty(mainHelpStr);
    if hasMainHelp
        mainHelpStr = regexprep(mainHelpStr, '^.', '%', 'lineanchors');
        if mainHelpStr(end) ~= 10
            mainHelpStr = [mainHelpStr 10];
        end
        fprintf(outputFileHandle, '%s', mainHelpStr);
    end
end

%% ------------------------------
function writeCopyrightText(helpContainer, outputFileHandle)
    copyrightText = helpContainer.getCopyrightText;
    if ~isempty(copyrightText)
        fprintf(outputFileHandle, '\n %s\n\n', copyrightText);
    end
end


%% ------------------------------
function writeClassHelpMFile(helpContainer, outputFileHandle, className)
    
    fprintf(outputFileHandle, 'classdef %s', className);
    if ~isempty(helpContainer.superClassList)
        fprintf(outputFileHandle, '< %s', helpContainer.superClassList);        
    end
    fprintf(outputFileHandle, '\n');
    
    if writeFunctionHelpMFile(helpContainer, outputFileHandle)
        % if class has main help then append newline followed by copyright
        writeCopyrightText(helpContainer, outputFileHandle);
        writeClassMembers(helpContainer, outputFileHandle);
    else
        % otherwise write the copyright at the bottom of the class file
        writeClassMembers(helpContainer, outputFileHandle);
        writeCopyrightText(helpContainer, outputFileHandle);
    end
    
end

%% ------------------------------
function writeClassMembers(helpContainer, outputFileHandle)
    % writeClassMembers - prints the help content of a ClassHelpContainer
    % related to methods (including constructor) and properties into the
    % output file.

    % Write 'methods' block
    strIndent = getIndent(1);
    fprintf(outputFileHandle, [strIndent 'methods\n']);

    % Print the constructor
    printConstructorFcnHandle = @(constructorHelpContainer) printMethodHelp(outputFileHandle, ...
            constructorHelpContainer, 'out=%s');

    printAllMembersHelp(helpContainer.getConstructorIterator, printConstructorFcnHandle);

    % Print all the methods
    printMethodsFcnHandle = @(methodHelpContainer) printMethodHelp(outputFileHandle, ...
            methodHelpContainer, '%s(in) %%#ok<MANU>');

    printAllMembersHelp(helpContainer.getConcreteMethodIterator, printMethodsFcnHandle);
    
    fprintf(outputFileHandle, [strIndent 'end\n']);
    
    % Write abstract methods block
    fprintf(outputFileHandle, [strIndent 'methods (Abstract)\n']);
    
    % Print all the abstract methods as if they are properties
    printAbstractFcnHandle = @(abstractHelpContainer) printPrefixHelp(outputFileHandle, abstractHelpContainer, ' %#ok<NOIN>');
    
    printAllMembersHelp(helpContainer.getAbstractMethodIterator, printAbstractFcnHandle);
    
    fprintf(outputFileHandle, [strIndent 'end\n']);

    for elementType = matlab.internal.language.introspective.getSimpleElementTypes            
        printSimpleElementHelp(outputFileHandle, strIndent, elementType.keyword, helpContainer);
    end
    
    fprintf(outputFileHandle, 'end\n');
end

%% ------------------------------
function printSimpleElementHelp(outputFileHandle, strIndent, elementKeyword, helpContainer)
    elementIterator = helpContainer.getSimpleElementIterator(elementKeyword);
    
    if elementIterator.hasNext
        % Write block header
        fprintf(outputFileHandle, [strIndent, elementKeyword, '\n']);

        % Print all the elements
        printFcnHandle = @(elementHelpContainer) printPrefixHelp(outputFileHandle, elementHelpContainer);

        printAllMembersHelp(elementIterator, printFcnHandle);

        fprintf(outputFileHandle, [strIndent, 'end\n']);
    end
end

%% ------------------------------
function printAllMembersHelp(memberIterator, printMember)
    % printAllMembersHelp - iterates through and prints the help content of
    % the ClassMemberHelpContainers
    while memberIterator.hasNext
        memberHelpContainer = memberIterator.next;
        printMember(memberHelpContainer);
    end    
end

%% ------------------------------
function printMethodHelp(outputFileHandle, memberHelpContainerObj, functionFormat)
    % printMethodHelp - writes help comments for a class method to the
    % output file.
    twoTabIndent = getIndent(2);
    
    functionFormat = sprintf('%s%s %s\n', twoTabIndent, 'function', functionFormat);
    fprintf(outputFileHandle, functionFormat, memberHelpContainerObj.Name);
    
    methodHelp = memberHelpContainerObj.getHelp;
    
    if ~isempty(methodHelp)
        threeTabIndent = getIndent(3);
        methodHelp = formatHelpString(methodHelp, [threeTabIndent '%']);
        fprintf(outputFileHandle, '%s', methodHelp);
    end
    
    fprintf(outputFileHandle, '%send\n\n', twoTabIndent);
end

%% ------------------------------
function printPrefixHelp(outputFileHandle, prefixHelpContainerObj, postfixComment)
    % printPrefixHelp - writes help comments followed by the identifier name
    if nargin < 3
        postfixComment = '';
    end
    prefixHelp = prefixHelpContainerObj.getHelp;
    indent = getIndent(2);
    if ~isempty(prefixHelp)
        formattedStr = formatHelpString(prefixHelp, [indent '%']);
        fprintf(outputFileHandle, '%s', formattedStr);
    end
    fprintf(outputFileHandle, '%s%s;%s\n\n', indent, prefixHelpContainerObj.Name, postfixComment);
end

%% ------------------------------
function formattedHelp = formatHelpString(origHelpStr, commentIndent)
    % formatHelpString - helper method to format help comments
    formattedHelp = regexprep(origHelpStr, '^.', commentIndent, 'lineanchors');
    
end

%% ------------------------------
function outputStr = getIndent(numTabs)
    % getIndent - helper function to format the indents for help comments
    % in generated file
    outputStr = repmat(' ', 1, numTabs * 4); % tab defined as four spaces
end
