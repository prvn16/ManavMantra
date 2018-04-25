function hdf5()
%HDF5 Summary of MATLAB HDF5 capabilities.
%   MATLAB provides both high-level and low-level access to HDF5 files. The
%   high-level access functions make it easy to read a data set from an
%   HDF5 file or write a variable from the MATLAB workspace into an HDF5
%   file. The MATLAB low-level interface provides direct access to the more
%   than 300 functions in version 1.8.3 of the HDF5 library.
%
%   The following sections provide an overview of both the high- and
%   low-level access. To use these MATLAB functions, you must be familiar
%   with HDF5 C interfaces and, in some cases, details about the functions
%   in the library. To get this information, visit the HDF5 Web site,
%   http://www.hdfgroup.org.
%   
%   High Level Access
%   -----------------
%   MATLAB includes the following functions for high-level access to HDF5
%   files: 
%   
%       H5CREATE   - Create HDF5 dataset.
%       H5DISP     - Print HDF5 metadata.
%       H5INFO     - Return information about HDF5 file.
%       H5READ     - Read data from HDF5 dataset.
%       H5READATT  - Read attribute from HDF5 group or dataset.
%       H5WRITE    - Write to HDF5 dataset.
%       H5WRITEATT - Write HDF5 attribute to group or dataset.
%
%   You must use the low-level interface to create or write to non-numeric
%   datasets or attributes.
%
%   Low-Level Access
%   ----------------
%   MATLAB provides direct access to the over 300 functions in the HDF5
%   library. Using these functions, you can read and write complex
%   datatypes, utilize HDF5 data subsetting capabilities, and take
%   advantage of other features present in the HDF5 library.
%   
%   The HDF5 library organizes the routines in the library into interfaces.  
%   MATLAB organizes the corresponding MATLAB functions into packages that
%   match these HDF5 API library interfaces. For example, the MATLAB 
%   functions for the HDF5 Attribute Interface are available in the H5A  
%   package. The following table lists all the HDF5 library interfaces
%   with their associated MATLAB packages. 
%
%   HDF5 Library    MATLAB Package  
%   Interface       Name               Description
%   ------------------------------------------------------------------
%   Library          H5       General-purpose functions that affect the
%                             entire HDF5 library, such as initialization 
%   Attribute        H5A      Manipulate metadata associated with datasets
%                             or groups      
%   Dataset          H5D      Manipulate multidimensional arrays of data 
%                             elements, together with supporting metadata 
%   Dimension Scale  H5DS     Manipulate dimension scale associated with  
%                             dataset dimensions 
%   Error            H5E      Handle HDF5 errors
%   File             H5F      Access HDF5 files
%   Group            H5G      Organize objects in a file; analogous to  
%                             a directory structure
%   Identifier       H5I      Manipulate HDF5 object identifiers
%   Link             H5L      Manipulate links in a file
%   MATLAB           H5ML     MATLAB utility functions that are not part of
%                             the HDF5 library itself 
%   Object           H5O      Manipulate objects in a file
%   Property         H5P      Manipulate object property lists  
%   Reference        H5R      Manipulate HDF5 references to objects and 
%                             data regions
%   Dataspace        H5S      Define and work with dataspaces, which 
%                             describe the dimensionality of a dataset 
%   Datatype         H5T      Define the type of variable that is stored in
%                             a dataset
%   Filters and      H5Z      Create data filters and data compression
%      Compression            
%
%   In most cases, the syntax of the MATLAB function is identical to the
%   syntax of the HDF5 library function. To get detailed information about 
%   the MATLAB syntax of an HDF5 library function, view the help for the 
%   individual MATLAB function, as follows:
%
%   help H5F.open
%   
%   To view a list of HDF5 functions in a particular interface, type:
%
%   help H5F
%
%   See also HDF, H5CREATE, H5DISP, H5INFO, H5READ, H5READATT, H5WRITE,
%            H5WRITEATT, H5, H5A, H5D, H5DS, H5E, H5F, H5G, H5I, H5L, H5ML,
%            H5O, H5P, H5R, H5S, H5T, H5Z.
%

%   Copyright 2006-2013 The MathWorks, Inc.
