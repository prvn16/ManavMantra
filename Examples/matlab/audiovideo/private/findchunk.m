function [chunk,msg,msgID] = findchunk(fid,chunktype)
%FINDCHUNK find chunk in AVI
%   [CHUNK,MSG,msgID] = FINDCHUNK(FID,CHUNKTYPE) finds a chunk of type CHUNKTYPE
%   in the AVI file represented by FID.  CHUNK is a structure with fields
%   'ckid' and 'cksize' representing the chunk ID and chunk size
%   respectively.  Unknown chunks are ignored (skipped). 

%   Copyright 1984-2013 The MathWorks, Inc.

chunk.ckid = '';
chunk.cksize = 0;
msg = '';
msgID='';

while( strcmp(chunk.ckid,chunktype) == 0 )
  [msg, msgID] = skipchunk(fid,chunk);
  if ~isempty(msg)
    fclose(fid);
    error(msgID,msg);
  end
  [id, count] = fread(fid,4,'uchar');
  chunk.ckid = [char(id)]';
  if (count ~= 4 )
    msg = getString(message('MATLAB:audiovideo:findchunk:unexpectedChunkType',chunktype));
    msgID = 'MATLAB:audiovideo:findchunk:unexpectedChunkType';
  end
  [chunk.cksize, count] = fread(fid,1,'uint32');
  if (count ~= 1)
    msg = getString(message('MATLAB:audiovideo:findchunk:unexpectedChunkType',chunktype));
    msgID = 'MATLAB:audiovideo:findchunk:unexpectedChunkType';
  end
  if ( ~isempty(msg) ), return; end
end
return;
