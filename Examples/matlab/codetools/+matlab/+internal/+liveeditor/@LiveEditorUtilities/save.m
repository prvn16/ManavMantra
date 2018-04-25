function save(javaRichDocument, fileName)
% save - saves a Live Code file

import matlab.internal.liveeditor.LiveEditorUtilities

fileName = LiveEditorUtilities.resolveFileName(fileName);

import com.mathworks.services.mlx.MlxFileUtils
if ~(MlxFileUtils.isMlxFile(fileName))
    error('matlab:internal:liveeditor:save', 'FileName must be a Live Code file.');
end

import com.mathworks.mde.liveeditor.widget.rtc.RichDocumentBackingStore
jFile = java.io.File(fileName);
backingStore = RichDocumentBackingStore.createWithExistentBackingFile(jFile);
backingStore.doSaveAs(javaRichDocument, jFile);
end