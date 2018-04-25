classdef(Hidden) TestScriptMFileModel < matlab.unittest.internal.TestScriptFileModel
    % The TestScriptMFileModel utilizes static analysis in order to retrieve
    % the test content contained inside test code sections.
    
    %  Copyright 2016 The MathWorks, Inc.
    
    properties(SetAccess = immutable)
        FileCode
        TestSectionNameList
        TestSectionCodeExtentList
        SharedVariableSectionCodeExtent
        FunctionSectionCodeExtent
    end
    
    properties(Dependent, SetAccess=immutable)
        ScriptValidationFcn
    end
    
    methods(Static)
        function model = fromFile(fileName, parseTree)
            if nargin < 2
                parseTree = mtree(fileName,'-file','-cell');
            end
            info = getScriptInformation(fileName, parseTree);
            model = matlab.unittest.internal.TestScriptMFileModel(info);
        end
    end
    
    methods
        function model = TestScriptMFileModel(info)
            model = model@matlab.unittest.internal.TestScriptFileModel(info.Filename);
            model.FileCode = matlab.internal.getCode(info.Filename);
            model.TestSectionNameList = info.TestSectionNameList;
            model.SharedVariableSectionCodeExtent = info.SharedVariableSectionCodeExtent;
            model.TestSectionCodeExtentList = info.TestSectionCodeExtentList;
            model.FunctionSectionCodeExtent = info.FunctionSectionCodeExtent;
        end
        
        function value = get.ScriptValidationFcn(model)
            import matlab.unittest.internal.ScriptFileValidator;
            value = ScriptFileValidator.createScriptFileValidationFcn(model.Filename,...
                'WithExtension',true, 'WithCode',true);
        end
    end
end


function info = getScriptInformation(fileName, parseTree)
info.Filename = fileName;
info.TestSectionNameList = cell(0,1);
info.TestSectionCodeExtentList = cell(0,1);
info.SharedVariableSectionCodeExtent = [1,0];
info.FunctionSectionCodeExtent = [1,0];
info.FileCodeLength = 0;

if isInvalidTree(parseTree)
    info = finalizeScriptInformation(info);
    return;
end

info.FileCodeLength = parseTree.rightposition;
info = addSectionInformation(info,parseTree);
info = finalizeScriptInformation(info);
end


function bool = isInvalidTree(parseTree)
bool = parseTree.isnull || (parseTree.count == 1 && parseTree.iskind('ERR'));
end


function info = addSectionInformation(info,parseTree)
info.SharedVariableSectionCodeExtent = [1,info.FileCodeLength];
thisNode = parseTree.select(1);
while ~isempty(thisNode)
    kind = thisNode.kind;
    if strcmp(kind,'CELLMARK')
        info = addTestSection(info,thisNode);
    elseif strcmp(kind,'FUNCTION')
        info = addFunctionSection(info,thisNode);
        break;
    end
    thisNode = thisNode.Next;
end
end


function info = addTestSection(info,thisNode)
sectionExtent = getSectionExtent(info, thisNode);
info = shortenPreviousSection(info,sectionExtent(1));
info.TestSectionCodeExtentList{end+1} = sectionExtent;
info.TestSectionNameList(end+1) = regexp(thisNode.string,...
    '^\s*%%\s*(.*?)\s*$','tokens','once');
end


function info = addFunctionSection(info,thisNode)
sectionExtent = getSectionExtent(info, thisNode);
info = shortenPreviousSection(info,sectionExtent(1));
info.FunctionSectionCodeExtent = sectionExtent;
end


function sectionExtent = getSectionExtent(info, thisNode)
sectionStartIndex = thisNode.position;
sectionLength = info.FileCodeLength - sectionStartIndex + 1;
sectionExtent = [sectionStartIndex, sectionLength];
end


function info = shortenPreviousSection(info,currentSectionStartIndex)
if isempty(info.TestSectionCodeExtentList)
    info.SharedVariableSectionCodeExtent(2) = ...
        currentSectionStartIndex - 1;
else
    info.TestSectionCodeExtentList{end}(2) = ...
        currentSectionStartIndex - info.TestSectionCodeExtentList{end}(1);
end
end


function info = finalizeScriptInformation(info)
import matlab.lang.makeValidName;
import matlab.lang.makeUniqueStrings;
if isempty(info.TestSectionNameList)
    % If no test sections (identified by %%) then use everything
    % except for the function section as a single test section.
    [~,shortName,~] = fileparts(info.Filename);
    info.TestSectionNameList = {shortName};
    info.TestSectionCodeExtentList = {info.SharedVariableSectionCodeExtent};
    info.SharedVariableSectionCodeExtent = [1,0];
else
    [validNames, invalidIdx] = makeValidName(info.TestSectionNameList,'Prefix','test');
    validNames(~invalidIdx) = makeUniqueStrings(validNames(~invalidIdx), {}, namelengthmax);
    info.TestSectionNameList = makeUniqueStrings(validNames, invalidIdx, namelengthmax);
end
end

% LocalWords:  isnull lang iskind CELLMARK