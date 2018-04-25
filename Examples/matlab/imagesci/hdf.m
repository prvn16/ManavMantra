function varargout = hdf(varargin)
%HDF MATLAB-HDF gateway function.
%   HDF is a MEX-File interface to the HDF4 library developed and supported 
%   by The HDF Group.
%
%   Currently HDF supports all or a portion of the following HDF4 
%   interfaces: SD, V, VS, VF, VH, AN, DFR8, DF24, H, HE, and HD.  In 
%   addition, a MathWorks-specific ML interface contains a few utilities 
%   for managing the gateway.  To use these functions, you should be 
%   familiar with the information about their respective interfaces 
%   contained in the User's Guide and Reference Manual for HDF version 
%   4.2.5.  This documentation may be obtained from The HDF Group at 
%   <http://www.hdfgroup.org>.
%
%   Support is available for the HDF-EOS version 2.17 interfaces 
%   GD, PT, and SW.  Additional information about their respective 
%   interfaces is contained in the following documents:
%
%       HDF-EOS Library User's Guide for the ECS Project,
%       Volume 1:  Overview and Examples
%
%       HDF-EOS Library User's Guide for the ECS Project,
%       Volume 2:  Function Reference Guide
%
%   This documentation may be obtained at 
%   <http://newsroom.gsfc.nasa.gov/sdptoolkit/TKDocuments.html>, and 
%   additional information may be found at <http://hdfeos.org/>.
%
%   You should not use this function directly.  Instead, use the functions 
%   that are interface specific.  For example, to access an HDF function 
%   in the SD interface, use MATLAB.IO.HDF4.SD.
%
%   Please read the file hdf4copyright.txt for more information.
%
%   See also MATLAB.IO.HDF4.SD, MATLAB.IO.HDFEOS.GD, MATLAB.IO.HDFEOS.SW, 
%            HDFINFO, HDFREAD, HDFTOOL, HDFAN, HDFDF24, HDFDFR8, HDFH, 
%            HDFHD, HDFHE, HDFHX, HDFML, HDFPT, HDFV, HDFVF, HDFVH, HDFVS,
%            HDF5

%   Copyright 1984-2015 The MathWorks, Inc.

error('MATLAB:imagesci:hdf:missingMEX', 'Missing MEX-file HDF');
