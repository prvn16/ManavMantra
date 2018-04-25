function putAtt(ncid,varid,attname,attvalue)
%netcdf.putAtt Write netCDF attribute.
%   netcdf.putAtt(ncid,varid,attrname,attrvalue) writes an attribute
%   to a netCDF variable specified by varid.  In order to specify a 
%   global attribute, use netcdf.getConstant('GLOBAL') for the varid.  
%
%   Note: You cannot use netcdf.putAtt to set the _FillValue attribute of
%   NetCDF4 files. Use the netcdf.defVarFill function to set the fill value
%   for a variable. 
%
%   This function corresponds to the "nc_put_att" family of functions in 
%   the netCDF library C API.
%
%   Example:
%       ncid = netcdf.create('myfile.nc','CLOBBER');
%       varid = netcdf.getConstant('GLOBAL');
%       netcdf.putAtt(ncid,varid,'creation_date',datestr(now));
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.getAtt, netcdf.defVarFill, netcdf.getConstant.
%

%   Copyright 2008-2013 The MathWorks, Inc.

fmt = netcdf.inqFormat(ncid);

validateattributes(attvalue,{'numeric','char'},{},'','ATTVALUE');

persistent nc_classes;
nc_classes = { 'double','single','int64','uint64', 'int32','uint32', ...
    'int16', 'uint16', 'int8', 'uint8','char'};
validatestring(class(attvalue), nc_classes);

% Determine the xtype (datatype) and attribute data parameters.
% Get the datatype from the class of data.
switch ( class(attvalue) )
    case 'double'
        xtype = netcdf.getConstant('double');
        funstr = 'putAttDouble';
    case 'single'
        xtype = netcdf.getConstant('float');
        funstr = 'putAttFloat';
    case 'int64'
        xtype = netcdf.getConstant('int64');
        funstr = 'putAttInt64';
    case 'uint64'
        xtype = netcdf.getConstant('uint64');
        funstr = 'putAttUint64';
    case 'int32'
        xtype = netcdf.getConstant('int');
        funstr = 'putAttInt';
    case 'uint32'
        xtype = netcdf.getConstant('uint');
        funstr = 'putAttUint';
    case 'int16'
        xtype = netcdf.getConstant('short');
        funstr = 'putAttShort';
    case 'uint16'
        xtype = netcdf.getConstant('ushort');
        funstr = 'putAttUshort';
    case 'int8'
        xtype = netcdf.getConstant('byte');
        funstr = 'putAttSchar';
    case 'uint8'
        if strcmp(fmt,'FORMAT_CLASSIC') ...
                || strcmp(fmt,'FORMAT_64BIT') ...
                || strcmp(fmt,'NETCDF4_FORMAT_CLASSIC')
            xtype = netcdf.getConstant('byte');
            funstr = 'putAttUchar';
        else
            xtype = netcdf.getConstant('ubyte');
            funstr = 'putAttUbyte';
        end
    case 'char'
        xtype = netcdf.getConstant('char');
        funstr = 'putAttText';
end


% Invoke the correct netCDF library routine.
if ischar(attvalue)
    netcdflib('putAttText',ncid,varid,attname,attvalue);
else
    netcdflib(funstr,ncid,varid,attname,xtype,attvalue);
end


