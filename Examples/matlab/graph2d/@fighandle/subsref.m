function B = subsref(A,S)
%FIGHANDLE/SUBSREF Subscripted reference for fighandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2008 The MathWorks, Inc. 

B = [];
if ishghandle(A.figStoreHGHandle)

    UD = getscribeobjectdata(A.figStoreHGHandle);

    switch S.subs
     case 'Figure'
      B = get(A.figStoreHGHandle,'Parent');
     case 'HGHandle'
      B = A.figStoreHGHandle;
     otherwise  % HandleStore, ObjectStore, or other
      if isfield(UD,S.subs)
          B = UD.(S.subs);
      end
    end
    
end
