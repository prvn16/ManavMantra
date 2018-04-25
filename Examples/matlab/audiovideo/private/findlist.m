function [listsize,msg,msgID] = findlist(fid,listtype)
%FINDLIST find LIST in AVI
%   [LISTSIZE,MSG,MSGID] = FINDLIST(FID,LISTTYPE) finds the LISTTYPE 'LIST' in
%   the file represented by FID and returns LISTSIZE, the size of the LIST,
%   and MSG. If the LIST is not found, MSG will contain a string with an
%   error message, otherwise MSG is empty.  Unknown chunks in the AVI file
%   are ignored. 

%   Copyright 1984-2013 The MathWorks, Inc.


% Search for the LIST, ignore unknown chunks
found = -1;
while(found == -1)
  [chunk,msg,msgID] = findchunk(fid,'LIST');
  error(msgID,msg);
  [checktype,msg,msgID] = readfourcc(fid);
  error(msgID,msg);
  if (checktype == listtype)
    listsize = chunk.cksize;
    break;
  else
    fseek(fid,-4,0); %Go back so we can skip the LIST
    [msg, msgID]= skipchunk(fid,chunk); 
    error(msgID,msg);
  end
  if ( feof(fid) )  
    msg = getString(message('MATLAB:audiovideo:findlist:unexpectedListType',listtype));
    msgID= 'MATLAB:audiovideo:findlist:unexpectedListType';
    listsize = -1;
  end
end
return;
