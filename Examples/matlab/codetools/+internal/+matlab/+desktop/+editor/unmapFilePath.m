function filename = unmapFilePath(filename)
% unmapFilePath pass through proxy to permit access to private/unmapFile.m

filename = unmapFile(filename);
