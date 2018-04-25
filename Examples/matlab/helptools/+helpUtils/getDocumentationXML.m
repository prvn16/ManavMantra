function docXML = getDocumentationXML(topic)
%getDocumentationXML Extracts the documentation content from the live function file to be displayed in doc.
%   getDocumentationXML(topic) topic is the file path of the live function file.
%   Copyright 2017 The MathWorks, Inc. 

   filePath = which(topic, 'all');
   isMlxFile = com.mathworks.services.mlx.MlxFileUtils.isMlxFile(filePath);
   if ~isMlxFile
       docXML = '';
       return;
   end
   opcPackage  = com.mathworks.services.mlx.MlxFileUtils.read(java.io.File(filePath));
   docXML  = com.mathworks.services.mlx.OpcUtils.getDocumentationFromOpcPackage(opcPackage);
   docXML = com.mathworks.services.mlx.documentation.DocumentationParser.getReleaseCompatibleXML(docXML);
end