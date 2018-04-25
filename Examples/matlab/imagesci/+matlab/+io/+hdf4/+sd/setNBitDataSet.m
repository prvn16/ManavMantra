function setNBitDataSet(sdsID,startBit,bitLen,ext,fillone)
%setNBitDataSet Specify non-standard bit length for data set values.
%   setNBitDataSet(sdsID,STARTBIT,BITLEN,EXT,FILLONE) specifies that the
%   integer data set identified by sdsID contains data of a non-standard
%   length defined by STARTBIT and BITLEN.
%
%   Any length between 1 and 32 bits can be specified.  After 
%   setNBitDataset has been called for the data set array, any read or
%   write operation will involve conversion between the new data length of
%   the data set array and the data length of the read or write buffer.
%
%   Bit lengths of all data types are counted from the right of the bit
%   field starting with 0.  In a bit field containing the values 01111011,
%   bits 2 and 7 are set to 0 and all the other bits are set to 1.  The
%   least significant bit is bit 0.
%
%   The STARTBIT parameter specifies the leftmost position of the
%   variable-length bit field to be written.  For example, in the bit field
%   described in the preceding paragraph a STARTBIT parameter set to 4
%   would correspond to the fourth bit value of 1 from the right.
%
%   The parameter BITLEN specifies the number of bits of the
%   variable-length bit field to be written. This number includes the
%   starting bit and the count proceeds toward the right end of the bit
%   field - toward the lower-bit numbers. For example, starting at bit 5
%   and writing 4 bits of the bit field described in the preceding
%   paragraph would result in the bit field 1110 being written to the data
%   set. This would correspond to a STARTBIT value of 5 and a BITLEN value
%   of 4.
% 
%   The parameter EXT specifies whether to use the left-most bit of the
%   variable-length bit field to sign-extend to the left-most bit of the
%   data set data. For example, if 9-bit signed integer data is extracted
%   from bits 17-25 and the bit in position 25 is 1, then when the data is
%   read back from disk, bits 26-31 will be set to 1. Otherwise bit 25 will
%   be 0 and bits 26-31 will be set to 0. The EXT parameter can be set
%   to true (or 1) or false (or 0); specify true to sign-extend.
% 
%   The parameter FILLONE specifies whether to fill the "background" bits
%   with the value 1 or 0. This parameter is also set to either true (or 1)
%   or false (or 0).
% 
%   The "background" bits of a non-standard length data set are the bits
%   that fall outside of the non-standard length bit field stored on disk.
%   For example, if five bits of an unsigned 16-bit integer data set
%   located in bits 5 to 9 are written to disk with the parameter FILLONE
%   set to true (or 1), then when the data is reread into memory bits 0 to
%   4 and 10 to 15 would be set to 1. If the same 5-bit data was written
%   with a FILLONE value of false (or 0), then bits 0 to 4 and 10 to 15
%   would be set to 0.
% 
%   The operation on FILLONE is performed before the operation on EXT.  For
%   For example, using the EXT example above, bits 0 to 16 and 26 to 31
%   will first be set to the background bit value, and then bits 26 to 31
%   will be set to 1 or 0 based on the value of the 25th bit.
%
%   This function corresponds to the SDsetnbitdataset in the HDF library C
%   API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','int32',[10 20]);
%       sd.setNBitDataSet(sdsID,6,4,0,0);
%       data = int32([1:200]);
%       data = reshape(data,10,20);
%       sd.writeData(sdsID,[0 0],data);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.setCompress.

%   Copyright 2010-2013 The MathWorks, Inc.

if islogical(ext)
    ext = double(ext);
end
if islogical(fillone)
    fillone = double(fillone);
end
nbit_sds_id = hdf('SD','setnbitdataset',sdsID,startBit,bitLen,ext,fillone);
if nbit_sds_id < 0
    hdf4_sd_error('SDsetnbitdataset');
end
