function helpContent = mlxFile(fullPath)
%mlxFile Provides the help string to display in the command window for live functions.
%   mlxFile(fullPath) Uses fullpath of the live fucntion file and reads the documentation part.
%   Copyright 2017 The MathWorks, Inc. 

  [~, scriptName, ext] = fileparts(fullPath);
  content = java.lang.String('');
  fileWithNoExtension = false;
  if(isempty(ext))
      fileWithNoExtension = true; 
  else
      opcPackage  = com.mathworks.services.mlx.MlxFileUtils.read(java.io.File(fullPath));
      % Make sure that if the file is a function and does not have
      % documentation, then we save the file and update the opcPackage
      if(isFunctionAndDoesNotHaveDocumentation(opcPackage))
            matlab.internal.liveeditor.openAndSave(fullPath, fullPath);
            opcPackage  = com.mathworks.services.mlx.MlxFileUtils.read(java.io.File(fullPath));
      end
      content  = com.mathworks.services.mlx.OpcUtils.getDocumentationFromOpcPackage(opcPackage);
  end
  if(content.length == 0 || fileWithNoExtension)
    isLiveScriptMessage = helpUtils.formatHelpTextLine(getString(message('MATLAB:helpUtils:displayHelp:IsALiveScript', scriptName)));

    if matlab.internal.display.isHot
        openLiveScriptMessage = helpUtils.createMatlabLink('edit', scriptName, getString(message('MATLAB:helpUtils:displayHelp:OpenInLiveEditor')));
        openLiveScriptMessage = helpUtils.formatHelpTextLine(openLiveScriptMessage);
    else 
        openLiveScriptMessage = helpUtils.createMatlabCommandWithTitle(false, getString(message('MATLAB:helpUtils:displayHelp:OpenInLiveEditor')), 'edit', scriptName);
    end

    helpContent = [10 isLiveScriptMessage 10 openLiveScriptMessage];
  else
    syntax = com.mathworks.services.mlx.documentation.DocumentationParser.getSyntax(content);
    purpose = com.mathworks.services.mlx.documentation.DocumentationParser.getPurpose(content);
    description = com.mathworks.services.mlx.documentation.DocumentationParser.getDescription(java.lang.String(content), scriptName);
    descriptionWrapped = matlab.internal.display.printWrapped(char(description), 70);
    descriptionWrapped = cellfun(@(x)[sprintf('%s', '    ') strtrim(x)], splitlines(descriptionWrapped),'UniformOutput', false);
    descriptionResults = strjoin(descriptionWrapped, '\n');
    referenceLink = helpUtils.createMatlabLink('doc', char(scriptName), getString(message('MATLAB:helpUtils:displayHelp:OpenDocumentationInHelpBrowser')));
    helpContent = [[sprintf('%s', ' ') scriptName], [sprintf('%s', '   ') char(purpose)], newline, [sprintf('%s', '   ') char(syntax)], newline];
    if ~isempty(char(deblank(descriptionResults)))
        helpContent = [helpContent, char(deblank(descriptionResults)), [newline newline]];
    end
    helpContent = [helpContent, [sprintf('%s', '    ') char(referenceLink)], newline];
  end
end

function result = isFunctionAndDoesNotHaveDocumentation(opcPackage)
    matlabCode = com.mathworks.services.mlx.OpcUtils.getMATLABCode(opcPackage);
    mTree = com.mathworks.widgets.text.mcode.MTree.parse(matlabCode);
    fileType = mTree.getFileType().toString();
    isFunctionFile = fileType.equals('FunctionFile');
    documentation  = com.mathworks.services.mlx.OpcUtils.getDocumentationFromOpcPackage(opcPackage);
    hasDocumentation = documentation.length > 0;
    result = isFunctionFile && ~hasDocumentation;
end