function saveas(javaRichDocument, fileName, varargin)
% saveas - saves MLX file as

import matlab.internal.liveeditor.LiveEditorUtilities

fileName = LiveEditorUtilities.resolveFileName(fileName);

import com.mathworks.services.mlx.MlxFileUtils
if MlxFileUtils.isMlxFile(fileName)
    error('matlab:internal:liveeditor:save', 'FileName must be a Live Code file.');
end

jFile = java.io.File(fileName);
exporter = com.mathworks.mde.liveeditor.widget.rtc.export.ExporterFactory.getExporter(jFile);
exporter.export(javaRichDocument, jFile, varargin);
end