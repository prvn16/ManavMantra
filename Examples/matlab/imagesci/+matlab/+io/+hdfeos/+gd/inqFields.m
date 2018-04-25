function [fldlist,fldRank,fldType] = inqFields(gridID) 
%inqFields Retrieve information about data fields defined in grid.
%   [FLDLIST,FLDRANK,FLDTYPE] = inqFields(gridID) returns the list of
%   fields FLDLIST as a cell array.  FLDRANK contains the rank of each data
%   field.  FLDTYPE is a cell array containing the datatype of each data
%   field.
%
%   This function corresponds to the GDinqfields function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       [fldlist,fldrank,fldtype] = gd.inqFields(gridID);
%       gd.detach(gridID);
%       gd.close(gfid);
%       for j = 1:numel(fldrank)
%           fprintf('%s: Rank %d, datatype %s\n', fldlist{j},fldrank(j),fldtype{j});
%       end
%
%   See also gd, gd.defField.

%   Copyright 2010-2015 The MathWorks, Inc.

[nfields,fieldList,fldRank,fldType] = hdf('GD','inqfields',gridID);
hdfeos_gd_error(nfields,'GDinqfields');

if nfields == 0
    fldlist = {};
    fldRank = [];
    fldType = {};
else
    fldlist = regexp(fieldList,',','split');
    fldlist = fldlist';
    fldRank = fldRank';
    for j = 1:numel(fldType)
        switch(fldType{j})
            case 'float'
                fldType{j} = 'single';
        end
    end
end
