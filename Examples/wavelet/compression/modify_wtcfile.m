function typeCODE = modify_wtcfile(option,filename,typeSAVE,flagDEL)
%MODIFY_WTCFILE Modification of Wavelet Toolbox compression files.
%   typeCODE = MODIFY_WTCFILE(OPTION,FILENAME,TYPESAVE)
%   MODIFY_WTCFILE is used by all compression methods.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Apr-2004.
%   Last Revision: 06-May-2009.
%   Copyright 1995-2009 The MathWorks, Inc.

% File settings.
%---------------
tmp_filename  = def_tmpfile(filename);

switch option
    case {'save','recode'}
        if isequal(option,'save')
            if nargin<4
                flagDEL = true;
            else
                flagDEL = isequal(flagDEL,true);
            end
        else
            tmp_filename = filename;
            flagDEL = false;
            filename = [pathSTR , filesep , 'NEW_WTC_' nameSTR , extSTR];
        end
        fidTMP = fopen(tmp_filename);
        TabCODE = fread(fidTMP,'ubit1');
        fclose(fidTMP);
        fid = fopen(filename,'wb');
        fwrite(fid,typeSAVE,'uint8');
        switch typeSAVE
            case 1 , fwrite(fid,TabCODE,'ubit1');
            case 2
                nb_BITS  = length(TabCODE);
                idxOnes  = find(TabCODE==1);
                diff_idxOnes = diff(idxOnes);
                to_ENCODE = [idxOnes(1) ; diff_idxOnes];
                nb_CODED = length(to_ENCODE);
                HC_Struct = whuffencode(to_ENCODE);
                TabCODE = HC_Struct.HC_tabENC;
                HCTab = HC_Struct.HC_codes;
                len_TabCODE = length(TabCODE);
                nb_HC = length(HCTab);
                %------------------------------------
                fwrite(fid,nb_BITS,'uint32');
                fwrite(fid,nb_CODED,'uint32');
                fwrite(fid,nb_HC,'uint16');
                fwrite(fid,HCTab,'ubit2');
                fwrite(fid,len_TabCODE,'uint32');
                fwrite(fid,TabCODE,'ubit1');
                %------------------------------------
            case 3
                nb_BITS  = length(TabCODE);
                idxOnes  = find(TabCODE==1);
                diff_idxOnes = diff(idxOnes);
                to_ENCODE = [idxOnes(1) ; diff_idxOnes];
                nb_CODED = length(to_ENCODE);
                HC_Struct = whuffencode(to_ENCODE);
                TabCODE = HC_Struct.HC_tabENC;
                HCTab = HC_Struct.HC_codes;
                len_TabCODE = length(TabCODE);
                nb_HC = length(HCTab);
                %------------------------------------
                fwrite(fid,nb_BITS,'uint64');
                fwrite(fid,nb_CODED,'uint64');
                fwrite(fid,nb_HC,'uint64');
                fwrite(fid,HCTab,'ubit2');
                fwrite(fid,len_TabCODE,'uint64');
                fwrite(fid,TabCODE,'ubit1');
                %------------------------------------
                
        end
        fclose(fid);
        if flagDEL
            try
                delete(tmp_filename);
            catch ME    %#ok<NASGU>
            end
        end
        
    case 'load'
        fid  = fopen(filename);
        typeSAVE = fread(fid,1,'uint8');
        switch typeSAVE
            case 1
                TabCODE = fread(fid,'ubit1');
                fclose(fid);
                
            case 2
                nb_BITS  = fread(fid,1,'uint32');
                nb_CODED = fread(fid,1,'uint32');
                nb_HC    = fread(fid,1,'uint16');
                HCTab    = fread(fid,nb_HC,'ubit2');
                len_TabCODE = fread(fid,1,'uint32');
                TabCODE = fread(fid,len_TabCODE,'ubit1');
                fclose(fid);
                %-------------------------------------------------
                TabDECODED = whuffdecode(HCTab,TabCODE,nb_CODED);
                idx_LOADED = cumsum(TabDECODED,2);
                TabCODE = zeros(nb_BITS,1);
                TabCODE(idx_LOADED) = 1;
                
            case 3
                nb_BITS  = fread(fid,1,'uint64');
                nb_CODED = fread(fid,1,'uint64');
                nb_HC    = fread(fid,1,'uint64');
                HCTab    = fread(fid,nb_HC,'ubit2');
                len_TabCODE = fread(fid,1,'uint64');
                TabCODE = fread(fid,len_TabCODE,'ubit1');
                fclose(fid);
                %-------------------------------------------------
                TabDECODED = whuffdecode(HCTab,TabCODE,nb_CODED);
                idx_LOADED = cumsum(TabDECODED,2);
                TabCODE = zeros(nb_BITS,1);
                TabCODE(idx_LOADED) = 1;
                
                
        end
        fid = fopen(tmp_filename,'wb');
        fwrite(fid,TabCODE,'ubit1');
        fclose(fid);
        fid = fopen(tmp_filename);
        typeCODE = fread(fid,1,'*char');
        typeCODE = wtcmngr('meth_name',typeSAVE,typeCODE);
        fclose(fid);
end

