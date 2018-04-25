classdef(Hidden) TestScriptMLXFileModel < matlab.unittest.internal.TestScriptFileModel
    % This class is undocumented and may change in a future release.
    
    % The TestScriptMLXFileModel utilizes static analysis (via
    % matlab.internal.livecode.* interfaces) in order to retrieve the test
    % content contained inside test sections.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties(SetAccess = immutable)
        FileCode
        TestSectionNameList
        TestSectionCodeExtentList
        SharedVariableSectionCodeExtent
        FunctionSectionCodeExtent
        FileRelease
    end
    
    properties(Dependent, SetAccess=immutable)
        ScriptValidationFcn
    end
    
    methods(Static)
        function model = fromFile(fileName)
            import matlab.internal.livecode.FileModel;
            fileModel = FileModel.fromFile(fileName); % assumes fileName is a valid mlx file
            info = getScriptInformation(fileName, fileModel);
            model = matlab.unittest.internal.TestScriptMLXFileModel(info);
        end
    end
    
    methods
        function model = TestScriptMLXFileModel(info)
            model = model@matlab.unittest.internal.TestScriptFileModel(info.Filename);
            model.FileCode = info.FileCode;
            model.TestSectionNameList = info.TestSectionNameList;
            model.SharedVariableSectionCodeExtent = info.SharedVariableSectionCodeExtent;
            model.TestSectionCodeExtentList = info.TestSectionCodeExtentList;
            model.FunctionSectionCodeExtent = info.FunctionSectionCodeExtent;
            model.FileRelease = info.FileRelease;
        end
        
        function value = get.ScriptValidationFcn(model)
            import matlab.unittest.internal.ScriptFileValidator;
            value = ScriptFileValidator.createScriptFileValidationFcn(model.Filename,...
                'WithExtension',true, 'WithLastModifiedMetaData',true);
        end
    end
end

function info = getScriptInformation(fileName, fileModel)
import matlab.internal.livecode.ParagraphType;

numSections = numel(fileModel.Sections);

info.FileRelease = string(fileModel.Release);
info.Filename = fileName;
info.FileCode = fileModel.Code;
testNames = repmat({''}, 1, numSections);
info.TestSectionCodeExtentList = cell(1,numSections);
info.FunctionSectionCodeExtent = [1,0];

info.SharedVariableSectionCodeExtent = [1,0]; % Currently we do not support a shared variable section

prevEndPos = 1;
atLeastOneCodeBlockDiscovered = false;

for k=1:numSections
    sectionModel = fileModel.Sections(k);
    hasCodeBlocks = ~isempty(sectionModel.getParagraphsOfType(ParagraphType.Code));
    
    codeLength = numel(sectionModel.Code);
    
    startPos = prevEndPos + ...
        double(atLeastOneCodeBlockDiscovered && hasCodeBlocks); % + 1 for the newline character
    
    if k==numSections && isFunctionSection(sectionModel)
        info.FunctionSectionCodeExtent = [startPos,codeLength];
        testNames = testNames(1:k-1);
        info.TestSectionCodeExtentList = info.TestSectionCodeExtentList(1:k-1);
        break;
    end
    
    headingParagraphModels = sectionModel.getParagraphsOfType(ParagraphType.Heading);
    if ~isempty(headingParagraphModels)
        testNames{k} = headingParagraphModels(1).Content;
    end
    
    info.TestSectionCodeExtentList{k} = [startPos,codeLength];
    
    prevEndPos = startPos + codeLength;
    atLeastOneCodeBlockDiscovered = atLeastOneCodeBlockDiscovered | hasCodeBlocks;
end

info.TestSectionNameList = fixTestNames(testNames);
end

function bool = isFunctionSection(sectionModel)
sectionTree = mtree(sectionModel.Code);
functionNodes = mtfind(sectionTree,'Kind','FUNCTION');
bool = ~functionNodes.isempty();
end

function testNames = fixTestNames(testNames)
import matlab.lang.makeValidName;
import matlab.lang.makeUniqueStrings;

% Set preferred name for empty cases and cases which will only produce underscores
for k=1:numel(testNames)
    if isempty(regexp(testNames{k},'[a-zA-Z0-9]','once'))
        testNames{k} = sprintf('test_%u',k);
    end
end

[validNames, invalidIdx] = makeValidName(testNames,'Prefix','test');
validNames(~invalidIdx) = makeUniqueStrings(validNames(~invalidIdx), {}, namelengthmax);
testNames = makeUniqueStrings(validNames, invalidIdx, namelengthmax);
end