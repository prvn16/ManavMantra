function tf = isdicomFromFID(fid)

% Copyright 2006-2016

% Get the possible DICOM header and inspect it for DICOM-like data.
header = fread(fid, 132, 'uint8=>uint8');

if ((numel(header) == 132) && isequal(char(header(129:132))', 'DICM'))

  % It's a proper DICOM file.
  tf = true;

elseif (numel(header) < 8)
  
  % Eight is the absolute minimum length of an attribute, even an
  % empty one.
  tf = false;
  
else
  
  % Use a hueristic approach, examining the first "attribute".  A
  % valid attribute will likely start with 0x0002 or 0x0008.
  group = typecast(header(1:2), 'uint16');
  if (isequal(group, uint16(2)) || isequal(swapbytes(group), uint16(2)) || ...
      isequal(group, uint16(8)) || isequal(swapbytes(group), uint16(8)))
    
    tf = true;
    
  else
    tf = false;
  end
  
end
