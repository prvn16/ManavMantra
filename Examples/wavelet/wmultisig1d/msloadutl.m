function [signals,varName] = msloadutl(filedataname)
%MSLOADUTL Multisignal load utilities.
%   [signals,varName] = MSLOADUTL(filedataname)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-May-2006.
%   Last Revision: 12-Nov-2013.

varNAM_Cell = {'signals','X','Y'};
InVAL = load(filedataname);
varInFile = fieldnames(InVAL);
ok = false;
for k = 1:length(varNAM_Cell)
    varNAM = varNAM_Cell{k};
    idxVAR = strcmpi(varInFile,varNAM);
    if any(idxVAR)
        idxVAR = find(idxVAR,1,'first'); 
        break
    end
end
if ~ok , idxVAR = 1; end
varName = varInFile{idxVAR};
signals = InVAL.(varName);