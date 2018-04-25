function mf = matfile(varargin)
%MATFILE Save and load parts of variables in MAT-files.
%   MATOBJ = MATFILE(FILENAME) constructs an object that can load or save
%   parts of variables in MAT-file FILENAME. MATLAB does not load any data
%   from the file into memory when creating the object. FILENAME can
%   include a full or partial path, otherwise MATFILE searches along the 
%   MATLAB path. If the file does not exist, MATFILE creates the file on
%   the first assignment to a variable.
%
%   MATOBJ = MATFILE(FILENAME,'Writable',ISWRITABLE) enables or disables
%   write access to the file. ISWRITABLE is logical TRUE (1) or FALSE (0).
%   By default, MATFILE opens existing files with read-only access, but
%   creates new MAT-files with write access.
%
%   Access variables in MAT-file FILENAME as properties of MATOBJ, with dot
%   notation similar to accessing fields of structs. The syntax for loading
%   part of variable VARNAME into variable SMALLERVAR is
%
%      SMALLERVAR = MATOBJ.VARNAME(INDICES)
%
%   Similarly, the syntax for saving NEWDATA into variable VARNAME is
%
%      MATOBJ.VARNAME(INDICES) = NEWDATA
%
%  Specify part of a variable by defining indices for every dimension.
%  Indices can be a single value, an equally spaced range of increasing
%  values, or a colon (:), such as:
%
%      MATOBJ.VARNAME(100:500, 200:600)
%      MATOBJ.VARNAME(:, 501:1000)
%      MATOBJ.VARNAME(1:2:1000, 80)
% 
%   Limitations:
%
%    * Using the END keyword when indexing causes MATLAB to load the entire
%      variable into memory. To find the dimensions of a variable without
%      loading, call SIZE with this syntax:
%
%      SIZEMYVAR = SIZE(MATOBJ,'VARNAME')
%             
%    * MATFILE only supports partial loading and saving for MAT-files in
%      V7.3 format. If you index into a variable in a V7 (the current
%      default) or earlier MAT-file, MATLAB warns and temporarily loads the
%      entire contents of the variable. All MAT-Files created with MATFILE
%      use V7.3 format.
%
%    * MATFILE does not support linear indexing, or indexing into sparse
%      arrays, cells of cell arrays, fields of structs, or user-defined
%      classes.
%
%    * You cannot assign complex values to an indexed portion of a real
%      array.
%
%    * You cannot evaluate function handles using a MatFile object.
%
%   Example:
%
%      % Create a MAT-file
%      myfile = fullfile(tempdir,'myfile.mat');
%      matObj = matfile(myfile,'Writable',true);
%
%      % Save into a variable in the file
%      matObj.savedVar(81:100, 81:100) = magic(20);
%
%      % Find the size of a variable in the file
%      [nrows, ncols]=size(matObj,'savedVar');
%
%      % Load data from a variable in the file
%      loadVar = matObj.savedVar(nrows-19:nrows, 86:95);
%
%   See also load, save.

% Copyright 2011 The MathWorks, Inc.

mf = matlab.io.MatFile(varargin{:});

end