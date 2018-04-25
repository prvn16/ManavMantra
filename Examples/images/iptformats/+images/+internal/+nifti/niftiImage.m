classdef niftiImage < handle
%NIFTIIMAGE nifti image class. 
%   This class holds both the header containing the metadata, as well as
%   imagery (3D or ND volume). It handles conversions between the 'raw'
%   header format and the simplified header structure presented through the
%   niftiread and info functions. 
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within other toolbox classes and
%   functions. Its behavior may change, or the feature itself may be
%   removed in a future release.
%
%   References:
%   -----------
%   [1] Cox, R.W., Ashburner, J., Breman, H., Fissell, K., Haselgrove, C.,
%   Holmes, C.J., Lancaster, J.L., Rex, D.E., Smith, S.M., Woodward, J.B.
%   and Strother, S.C., 2004. A (sort of) new image data format standard:
%   Nifti-1. Neuroimage, 22, p.e1440.

%   Copyright 2017 The MathWorks, Inc.
    
    properties
        % This class contains three public properties:
        % header: containing the 'raw' metadata contents of the file.
        header
        % byteorder: containing 'ieee-le' or 'ieee-be' depending on the
        % encoding of the file.
        byteorder
        % img: the image content of the file: 1D to 7D numeric matrix.
        img
    end
        
    methods 
        
        function self = niftiImage(varargin)
        % niftiImage: create a niftiImage object from either the full file 
        % names for the header and image components, or a single .nii file.
        % It returns a niftiImage object, that contains the header
        % information in the 'header' property, byte order information in
        % the 'byteorder' property, and can hold the imagery data in the
        % 'img' property. the 'img' property is not filled by default, and
        % can be populated using the 'readVolume' method.
        
        %   Copyright 2017 The MathWorks, Inc.
        
            if ischar(varargin{1})
                [self.header, self.byteorder] = self.parseHeader(varargin{1});
            elseif isstruct(varargin{1})
                self.header = varargin{1};
                self.byteorder = 'ieee-le';
            end
        end
        
        function [] = readVolume(self, filename)
        % readVolume: reads image data from filename into niftiImage. 
        %    This function is intended to be run after loading in the
        %    header information into the niftiImage object. Using either
        %    the .NII filename (used to read the header), or a .IMG file
        %    which contains the corresponding volume, this function loads
        %    the image into the 'img' field of the object. 
        
            self.img = self.parseImage(filename);
        end
        
        function img = parseImage(self, filename)
        % parseImage: parse file for image data.
        %    this method parses the file specified by filename for the
        %    image data, using the header details already extracted into
        %    the object. It returns the image as a numeric vector 'img'.
            
            byteOrder = self.byteorder;
            headerStruct = self.header;
            
            fid = fopen(filename, 'r', byteOrder);
            if fid > 0
                fseek(fid, 0, 'bof'); % beginning of file
                % seek to vox_offset, from where the image data begins.
                fseek(fid, headerStruct.vox_offset, 'bof');

                imageSize = prod(headerStruct.dim(2:8));

                [precision, ~, ~] = self.getDataType();     

                % Read image data.
                img = fread(fid, imageSize, sprintf('*%s',precision));

                if numel(img) ~= imageSize
                    fclose(fid);
                    error(message('images:nifti:dataHeaderMismatch')); 
                end

                %  Update the global min and max values 
                headerStruct.glmax = double(max(img(:)));
                headerStruct.glmin = double(min(img(:)));

                % remove squeeze.
                img = (reshape(img, headerStruct.dim(2:8)));
                if isempty(img)
                    img = []; % empty matrices can also have a non-empty size. Force 0x0.
                end

            else
                fclose(fid);
                error(message('images:nifti:cannotOpenImageRead'));
            end
            fclose(fid);
        end
        
        function simplifiedStruct = simplifyStruct(self)
        %simplifyStruct: convert standard NIfTI header to a simplified
        %version.
        %    This method converts a standard form NIfTI header (as
        %    specified in the NIfTI standard) into a more MATLAB usable
        %    form.
        
            rawStruct = self.header;
            
            % descrip -> Description
            simplifiedStruct.Description = rawStruct.descrip;

            % dim -> imageSize
            simplifiedStruct.ImageSize = rawStruct.dim(2:rawStruct.dim(1)+1);

            % pixdim -> pixelDimensions
            simplifiedStruct.PixelDimensions = rawStruct.pixdim(2:rawStruct.dim(1)+1);

            % datatype -> datatype (in decoded characters)
            simplifiedStruct.Datatype = self.getDataType();

            % bitpix -> bitsPerPixel
            simplifiedStruct.BitsPerPixel = rawStruct.bitpix;

            % xyzt_units -> [spatialUnits, timeUnits] (in decoded characters)
            [simplifiedStruct.SpaceUnits, simplifiedStruct.TimeUnits] = self.getSpaceTimeUnits();

            % [scl_slope, scl_inter] -> [Scaling and Offset]
            simplifiedStruct.AdditiveOffset = rawStruct.scl_inter;
            simplifiedStruct.MultiplicativeScaling = rawStruct.scl_slope;

            % intent_code -> intent (in decoded characters)
            % intent_name -> intentDescription
            % intent_p* -> intentParams [p1, p2, p3] three element float vector.
            if rawStruct.intent_code ~= 0 % if not 'None'
                [simplifiedStruct.Intent, simplifiedStruct.IntentDescription, simplifiedStruct.IntentParams] = self.getIntent();
            end

            % Show this only for MRI data. If all zeros, don't show in simplified.
            % slice_start ... -> [sliceStart, sliceEnd, sliceDuration, sliceTimeOffset,
            % dim_info] (dim_info decoded)
            if rawStruct.slice_start ||  rawStruct.slice_end || rawStruct.slice_duration
                simplifiedStruct.SliceStart = rawStruct.slice_start;
                simplifiedStruct.SliceEnd = rawStruct.slice_end;
                simplifiedStruct.SliceDuration = rawStruct.slice_duration;
            end
            simplifiedStruct.TimeOffset = rawStruct.toffset;

            simplifiedStruct.SliceCode = self.getSliceCode();
            [simplifiedStruct.FrequencyDimension, simplifiedStruct.PhaseDimension, simplifiedStruct.SpatialDimension ] = self.getDimInfo();

            simplifiedStruct.DisplayIntensityRange = [rawStruct.cal_min, rawStruct.cal_max];

            [XformName, Xform] = self.getXForm();
            simplifiedStruct.TransformName = XformName;
            simplifiedStruct.Transform = Xform;
            simplifiedStruct.Qfactor = rawStruct.pixdim(1);

            % aux_file ->auxiliaryFile
            if ~isempty(rawStruct.aux_file)
                simplifiedStruct.AuxiliaryFile = rawStruct.aux_file;
            end

        end
        
        function [fid, bytesWritten] = writeHeader(self, fid, machineFmt)
        %writeHeader: helper method to write metadata to a NIfTI file.
        %    Inputs include a fileID to write data to, and a MATLAB
        %    structure containing the fields to write. machineFmt is either
        %    big or little endian.
        
            headerStruct = self.header;
            if (fid > 0)
                bytesWritten = 0;
                fseek(fid, 0, 'bof'); % beginning of file

                count = fwrite(fid, headerStruct.sizeof_hdr, 'int32', machineFmt);
                bytesWritten = bytesWritten + count*4; % int32 = 4 bytes.

                % unused sections.
                count = fwrite(fid, repmat(' ', 1, 10), 'uchar', machineFmt);%data_type
                bytesWritten = bytesWritten + count; % 10 bytes.
                count = fwrite(fid, repmat(' ', 1, 18), 'uchar', machineFmt);%db_name
                bytesWritten = bytesWritten + count; % 18 bytes.
                %extents: value to keep other non-NIFTI aware software happy.
                count = fwrite(fid, 16384, 'int32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, 0, 'short', machineFmt);%session_error
                bytesWritten = bytesWritten + count*2; % 2 bytes.
                %regular: value to keep other non-NIFTI aware software happy.
                count = fwrite(fid, 'r', 'uchar', machineFmt);
                bytesWritten = bytesWritten + count; % 1 byte.
                count = fwrite(fid, headerStruct.dim_info, 'uchar', machineFmt);
                bytesWritten = bytesWritten + count; % 1 byte.

                % bytesWritten should be 40 here.

                count = fwrite(fid, headerStruct.dim, 'short', machineFmt);
                bytesWritten = bytesWritten + count*2; % 8*2 bytes.
                count = fwrite(fid, headerStruct.intent_p1, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, headerStruct.intent_p2, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, headerStruct.intent_p3, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.    
                count = fwrite(fid, headerStruct.intent_code, 'short', machineFmt);
                bytesWritten = bytesWritten + count*2; % 2 bytes.
                count = fwrite(fid, headerStruct.datatype, 'short', machineFmt);
                bytesWritten = bytesWritten + count*2; % 2 bytes.
                count = fwrite(fid, headerStruct.bitpix, 'short', machineFmt);
                bytesWritten = bytesWritten + count*2; % 2 bytes.
                count = fwrite(fid, headerStruct.slice_start, 'short', machineFmt);
                bytesWritten = bytesWritten + count*2; % 2 bytes.
                count = fwrite(fid, headerStruct.pixdim, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 8*4 bytes.
                count = fwrite(fid, headerStruct.vox_offset, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, headerStruct.scl_slope, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, headerStruct.scl_inter, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, headerStruct.slice_end, 'short', machineFmt);
                bytesWritten = bytesWritten + count*2; % 2 bytes.    
                count = fwrite(fid, headerStruct.slice_code, 'uchar', machineFmt);
                bytesWritten = bytesWritten + count; % 1 byte.
                count = fwrite(fid, headerStruct.xyzt_units, 'uchar', machineFmt);
                bytesWritten = bytesWritten + count; % 1 byte.
                count = fwrite(fid, headerStruct.cal_max, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, headerStruct.cal_min, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, headerStruct.slice_duration, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, headerStruct.toffset, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.

                %unused section.
                count = fwrite(fid, 0, 'int32', machineFmt);%glmax
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, 0, 'int32', machineFmt);%glmin
                bytesWritten = bytesWritten + count*4; % 4 bytes.

                % bytesWritten should be 148 here.

                assert(length(headerStruct.descrip) <= 80);
                fullDescription = [headerStruct.descrip repmat(' ', 1, 80-length(headerStruct.descrip))];   
                count = fwrite(fid, fullDescription, 'uchar', machineFmt);
                bytesWritten = bytesWritten + count; % 80*1 bytes.
                assert(length(headerStruct.aux_file) <= 24);
                fullAuxFile = [headerStruct.aux_file repmat(' ', 1, 24-length(headerStruct.aux_file))];   
                count = fwrite(fid, fullAuxFile, 'uchar', machineFmt);
                bytesWritten = bytesWritten + count; % 24*1 bytes.

                % bytesWritten should be 252 here.

                count = fwrite(fid, headerStruct.qform_code, 'short', machineFmt);
                bytesWritten = bytesWritten + count*2; % 2 bytes.
                count = fwrite(fid, headerStruct.sform_code, 'short', machineFmt);
                bytesWritten = bytesWritten + count*2; % 2 bytes.    

                count = fwrite(fid, headerStruct.quatern_b, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, headerStruct.quatern_c, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, headerStruct.quatern_d, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.

                count = fwrite(fid, headerStruct.qoffset_x, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, headerStruct.qoffset_y, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.
                count = fwrite(fid, headerStruct.qoffset_z, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4 bytes.

                count = fwrite(fid, headerStruct.srow_x, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4*4 bytes.
                count = fwrite(fid, headerStruct.srow_y, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4*4 bytes.
                count = fwrite(fid, headerStruct.srow_z, 'float32', machineFmt);
                bytesWritten = bytesWritten + count*4; % 4*4 bytes.

                % bytesWritten should be 328 here.

                assert(length(headerStruct.intent_name) <= 16);
                fullIntentName = [headerStruct.intent_name repmat(' ', 1, 16-length(headerStruct.intent_name))];   
                count = fwrite(fid, fullIntentName, 'uchar', machineFmt);
                bytesWritten = bytesWritten + count; % 16*1 bytes.
                count = fwrite(fid, headerStruct.magic, 'uchar', machineFmt);
                bytesWritten = bytesWritten + count; % 4*1 bytes.
            else
                error(message('images:nifti:cannotOpenHeaderWrite'));
            end
        end
        
        function [fid, bytesWritten] = writeImage(self, V, fid, machineFmt)
        %writeImage: helper method to write image data to a NIfTI file.
        %    Inputs include a fileID to write data to, and the numeric
        %    volume to write into the file. machineFmt is either big or
        %    little endian.
            [precision, sizeOfEachItem] = self.getDataType();

            count = fwrite(fid, V, precision, 0, machineFmt); % skip 0.

            if count ~= numel(V)
               error(message('images:nifti:voxelsWrittenMismatch')); 
            end
            
            bytesWritten = count*(sizeOfEachItem/8); % size in bits.

        end
        
    end
    
    % The following methods are used by the simplifyStruct method to
    % convert from the raw header field format to the simplified header
    % structure.
    
    methods(Access = private)
        
        function [dataTypeName, sizeOfEachItem, bitpix] = getDataType(self)
        %getDataType: loads the datatype and bitpix fields into simpler
        %MATLAB structure.
        %    This helper function reads the datatype and bitpix field from
        %    a standard NIfTI header, and returns a textual and simplified
        %    version.

            dataTypeCodeInput = self.header.datatype;
            datatypeCode = {1, 2, 4, 8, 16, 16, 64, 2, 256, 512, 768, 1024, 1280};
            
            % Codes 1536, 2048 and 2304 are not allowed (128 bit double,
            % complex and RGBA32)
            if isempty(find([datatypeCode{:}] == dataTypeCodeInput, 1))
               error(message('images:nifti:imageDataTypeNotSupported')); 
            end
            
            datatypeStr = {'ubit1', 'uint8', 'int16', 'int32', 'single', 'single', ...
                        'double', 'uint8', 'int8', 'uint16', 'uint32', 'int64', ...
                        'uint64'};
            dataMap = containers.Map(datatypeCode, datatypeStr);
            dataTypeName = dataMap(dataTypeCodeInput);

            sizeSet = {1, 8, 16, 32, 32, 32, 64, 8, 8, 16, 32, 64, 64};
            sizeMap = containers.Map(datatypeCode, sizeSet);
            sizeOfEachItem = sizeMap(dataTypeCodeInput);

            if nargout > 2
                bitpixVal = {1, 8, 16, 32, 32, 64, 64, 24, 8, 16, 32, 64, 64};
                bitpixMap = containers.Map(datatypeCode, bitpixVal);
                bitpix = bitpixMap(dataTypeCodeInput);
            end

        end
        
        function [spaceUnits, timeUnits] = getSpaceTimeUnits(self)
        %getSpaceTimeUnits: converts raw units information to readable
        %text.
        %    This helper function converts the byte long information about
        %    space and time units in the standard NIfTI header into user
        %    readable textual format.
        
            spaceUnitCode = bitand(self.header.xyzt_units, uint8(7));
            timeUnitCode  = bitand(self.header.xyzt_units, uint8(56)); % 0x38

            spaceKey   = {0, 1, 2, 3};
            spaceValue = {'Unknown', 'Meter', 'Millimeter', 'Micron'};

            if isempty(find([spaceKey{:}] == spaceUnitCode, 1))
               error(message('images:nifti:spaceUnitNotSupported')); 
            end
            
            spaceMap = containers.Map(spaceKey, spaceValue);
            spaceUnits = spaceMap(spaceUnitCode);

            timeKey = {0, 8, 16, 24, 32, 40, 48};
            timeValue = {'None', 'Second', 'Millisecond', 'Microsecond', 'Hertz', 'PartsPerMillion', 'Radian'};

            if isempty(find([timeKey{:}] == timeUnitCode, 1))
               error(message('images:nifti:timeUnitNotSupported')); 
            end
            
            timeMap = containers.Map(timeKey, timeValue);
            timeUnits = timeMap(timeUnitCode);

        end
        
        function [code, name, params] = getIntent(self)
        %getIntent: converts raw intent code, name, and parameters to more
        %readable form.
        %    This helper function reads the raw intent code, name and
        %    parameters as defined in the NIfTI standard, and converts it
        %    to a more readable format in MATLAB.
        
            keySet = {0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, ...
                      18, 19, 20, 21, 22, 23, 24, 1001, 1002, 1003, 1004, 1005, ...
                      1006, 1007, 1008, 1009, 1010,1011, 2001, 2002, 2003, 2004, 2005};

            valueSet = {'None', 'Correlation', 'T-Test', 'F-Test', 'Z-Score', ...
                        'Chi-Squared', 'Beta', 'Binomial', 'Gamma', 'Poisson', ...
                        'Normal', 'Noncentral F-statistic', 'Noncentral Chi-squared', ...
                        'Logistic', 'Laplace', 'Uniform', 'Noncentral T-test', ...
                        'Weibull', 'Chi', 'Inverse Gaussian', 'Extreme Value', ...
                        'p-value', 'ln p-value', 'log p-value', 'Estimate', 'Label', ...
                        'NeuroName Label', 'General Matrix', 'Symmetric Matrix', ...
                        'Displacement Vector', 'Vector', 'Point Set', 'Triangle', ...
                        'Quaternion', 'Dimensionless', 'Time Series', 'Node Index', ...
                        'RGB Triplet', 'RGBA vector', 'Shape'};

            mapObj = containers.Map(keySet, valueSet);
            name = self.header.intent_name;
            
            if isempty(find([keySet{:}] == self.header.intent_code, 1))
               error(message('images:nifti:intentCodeNotSupported')); 
            end
            
            code = mapObj(self.header.intent_code);
            params = [self.header.intent_p1 self.header.intent_p2 self.header.intent_p3];

        end
        
        function [f_d, p_d, s_d] = getDimInfo(self)
        %getDimInfo: converts raw dimInfo to simplified form.
        %    This helper function separates the contents of the dimInfo
        %    byte in the NIfTI header into a more readable form in MATLAB.
        
            dimInfo = uint8(self.header.dim_info);

            f_d = bitand(dimInfo,uint8(3));
            p_d = bitand(bitshift(dimInfo, -2),uint8(3));
            s_d = bitand(bitshift(dimInfo, -4),uint8(3));

        end
        
        function sliceCode = getSliceCode(self)
        %getSliceCode: converts raw slice code to simplified form.
        %    This helper function converts the raw slice code as defined in
        %    the NIfTI standard to a textual form, which is easier to read
        %    in MATLAB. 
        
            slice_code_key   = {0, 1, 2, 3, 4, 5, 6};
            sliceCodeValue = {'Unknown', 'Sequential-Increasing', 'Sequential-Decreasing', ...
                              'Alternate-Increasing', 'Alternate-Decreasing', ...
                              'Alternate-Increasing-2', 'Alternate-Decreasing-2'};
                          
            sliceCodeMap = containers.Map(slice_code_key, sliceCodeValue);
            
            if isempty(find([slice_code_key{:}] == self.header.slice_code, 1))
               error(message('images:nifti:sliceCodeValueNotSupported')); 
            end
            
            sliceCode = sliceCodeMap(self.header.slice_code);

        end
        
        function [xformName, xform] = getXForm(self)
        %getXForm: converts raw transform to simplified form.
        %    This helper function converts the raw transform information as
        %    defined in the NIfTI standard to a simplified form usable in
        %    MATLAB as an affine3D object.
            try
                if self.header.sform_code > 0
                    xformName = 'Sform';
                    xform = affine3d([self.header.srow_x; ...
                                      self.header.srow_y; ...
                                      self.header.srow_z; ...
                                      0 0 0 1]');
                elseif self.header.qform_code > 0
                    xformName = 'Qform';

                    b = self.header.quatern_b;
                    c = self.header.quatern_c;
                    d = self.header.quatern_d;

                    if 1.0-(b*b+c*c+d*d) < 0
                        a = 0;
                    else
                        a = sqrt(1.0-(b*b+c*c+d*d));
                    end

                    qfactor = self.header.pixdim(1);

                    if qfactor == 0
                        qfactor = 1; 
                    end

                    i = self.header.pixdim(2);
                    j = self.header.pixdim(3);
                    k = qfactor * self.header.pixdim(4);

                    R = [a*a+b*b-c*c-d*d 2*b*c-2*a*d     2*b*d+2*a*c
                         2*b*c+2*a*d     a*a+c*c-b*b-d*d 2*c*d-2*a*b
                         2*b*d-2*a*c     2*c*d+2*a*b     a*a+d*d-c*c-b*b];

                    T = [self.header.qoffset_x, ...
                         self.header.qoffset_y, ...
                         self.header.qoffset_z];
                    R = R * diag([i j k]);

                    xform = affine3d([R zeros(3,1); T 1]');
                else
                    xformName = 'None';
                    xform = affine3d();
                end
            catch ME 
                % if affine transform is singular, setup default tform.
                if isequal(ME.identifier,'images:geotrans:singularTransformationMatrix')
                    xformName = 'None';
                    xform = affine3d();
                else
                    rethrow(ME)
                end
            end
        end
        
    end
    
    % The following methods are static, and can be used without a 'live'
    % instance of the niftiImage class. These are generally used in
    % niftiinfo to parse the header, and niftiwrite, to convert the simple
    % structure to the raw format.
    
    methods(Static, Access = public, Hidden)
        
        function [headerStruct, byteOrder] = parseHeader(filename, headerStruct)
        %parseHeader: parse the header content of a NIfTI file.
        %    This method parses the header content from a .nii file, or a
        %    .hdr file. It returns a struct, which corresponds to all the
        %    'raw' fields in the metadata, as specified by the NIfTI
        %    standard. It also returns the byteorder of the file, either
        %    'little' or 'big', which is then used to read the volume data.
        
            fid = fopen(filename, 'r', 'b');
            
            fseek(fid, 0, 'eof'); % end of file
            position = ftell(fid);
            if position < 348
               fclose(fid);
               error(message('images:nifti:headerSmallerThan348'));
            end
            
            if fid > 0
                fseek(fid, 0, 'bof'); % beginning of file

                % The first 'data' should be 348, interpreted as int32.
                % 348 for NIfTI1, 540 for NIfTI2. 

                % The file encoding may be big-endian or little endian.
                % If this is not 348 in either big or little endian formats, 
                % then error out. Else, use the same formatting throughout the 
                % read process.
                headerStruct.sizeof_hdr = fread(fid, 1, 'int32');

                if headerStruct.sizeof_hdr ~= 348
                    fclose(fid);
                    fid = fopen(filename, 'r', 'l');
                    fseek(fid, 0, 'bof'); % beginning of file
                    headerStruct.sizeof_hdr = fread(fid, 1, 'int32');
                    byteOrder = 'ieee-le';
                    if headerStruct.sizeof_hdr ~= 348
                        fclose(fid);
                        error(message('images:nifti:headerSmallerThan348'));
                    end
                else
                    byteOrder = 'ieee-be';
                end

                fread(fid, 10, 'uchar'); % data_type (unused)
                fread(fid, 18, 'uchar'); % db_name (unused)
                fread(fid, 1, 'int32'); % extents (unused)
                fread(fid, 1, 'short'); % session_error (unused)
                fread(fid, 1, 'uchar'); % regular (unused)

                headerStruct.dim_info = fread(fid, 1, 'uchar=>char')';
                headerStruct.dim = fread(fid, 8, 'short')';

                headerStruct.intent_p1 = fread(fid, 1, 'float32');
                headerStruct.intent_p2 = fread(fid, 1, 'float32');
                headerStruct.intent_p3 = fread(fid, 1, 'float32');
                headerStruct.intent_code = fread(fid, 1, 'short');
                headerStruct.datatype = fread(fid, 1, 'short');
                headerStruct.bitpix = fread(fid, 1, 'short');

                headerStruct.slice_start = fread(fid, 1, 'short');
                headerStruct.pixdim = fread(fid, 8, 'float32')';
                headerStruct.vox_offset = fread(fid, 1, 'float32');
                headerStruct.scl_slope = fread(fid, 1, 'float32');
                headerStruct.scl_inter = fread(fid, 1, 'float32');
                headerStruct.slice_end = fread(fid, 1, 'short');

                headerStruct.slice_code = fread(fid, 1, 'uchar');
                headerStruct.xyzt_units = fread(fid, 1, 'uchar');

                headerStruct.cal_max = fread(fid, 1, 'float32');
                headerStruct.cal_min = fread(fid, 1, 'float32');
                headerStruct.slice_duration = fread(fid, 1, 'float32');
                headerStruct.toffset = fread(fid, 1, 'float32');

                fread(fid, 1, 'int32'); % glmax (unused)
                fread(fid, 1, 'int32'); % glmin (unused)

                headerStruct.descrip = deblank(fread(fid, 80, 'uchar=>char')');
                headerStruct.aux_file = deblank(fread(fid, 24, 'uchar=>char')');

                headerStruct.qform_code = fread(fid, 1, 'short');
                headerStruct.sform_code = fread(fid, 1, 'short');

                headerStruct.quatern_b = fread(fid, 1, 'float32');
                headerStruct.quatern_c = fread(fid, 1, 'float32');
                headerStruct.quatern_d = fread(fid, 1, 'float32');

                headerStruct.qoffset_x = fread(fid, 1, 'float32');
                headerStruct.qoffset_y = fread(fid, 1, 'float32');
                headerStruct.qoffset_z = fread(fid, 1, 'float32');

                headerStruct.srow_x = fread(fid, 4, 'float32')';
                headerStruct.srow_y = fread(fid, 4, 'float32')';
                headerStruct.srow_z = fread(fid, 4, 'float32')';

                headerStruct.intent_name = deblank(fread(fid, 16, 'uchar=>char')');
                headerStruct.magic = fread(fid, 4, 'uchar=>char')';
            else
                fclose(fid); 
                error(message('images:nifti:cannotOpenHeaderRead')); 
            end
            fclose(fid);
        end
        
        function headerStruct = niftiDefaultHeader(V, isNII)
        %niftiDefaultHeader: returns an appropriate default header
        %structure for NIfTI files.
        %    This method attempts to create a 'default' header structure,
        %    making sure to comply with the imagery data. All the other
        %    fields except dim, pixdim, datatype, bitpix are either
        %    0/empty/unknown.
        
            headerStruct.sizeof_hdr = 348;
            headerStruct.vox_offset = 352;
            headerStruct.descrip = '';
            headerStruct.aux_file = '';

            if isNII
                headerStruct.magic = sprintf('n+1\0'); % .nii
            else
                headerStruct.magic = sprintf('ni1\0'); % .img/.hdr
            end

            imageDims = length(size(V));
            headerStruct.dim = [imageDims size(V) ones(1, 7 - imageDims)];
            headerStruct.pixdim = [1 ones(1,imageDims) zeros(1, 7 - imageDims)];
            [headerStruct.datatype, headerStruct.bitpix] = images.internal.nifti.niftiImage.setDataType(class(V));

            headerStruct.scl_slope = 0;
            headerStruct.scl_inter = 0;
            headerStruct.xyzt_units = images.internal.nifti.niftiImage.setSpaceTimeUnits('Unknown', 'None');

            %intent_p1, intent_p2, %intent_p3. intent_code. intent_name
            [headerStruct.intent_code, headerStruct.intent_name, ...
             headerStruct.intent_p1, headerStruct.intent_p2, ...
             headerStruct.intent_p3] = images.internal.nifti.niftiImage.setIntent('None', '', [0, 0, 0]);

            headerStruct.slice_start = 0;
            headerStruct.slice_end = 0;
            headerStruct.slice_duration = 0;
            headerStruct.toffset = 0;

            headerStruct.slice_code = 0;
            headerStruct.dim_info = ' ';

            % cal_max and cal_min
            headerStruct.cal_max = 0;
            headerStruct.cal_min = 0;

            % xform
            headerStruct.qform_code = 0;
            headerStruct.sform_code = 0;
            headerStruct.quatern_b = 0;
            headerStruct.quatern_c = 0;
            headerStruct.quatern_d = 0;
            headerStruct.qoffset_x = 0;
            headerStruct.qoffset_y = 0;
            headerStruct.qoffset_z = 0;
            headerStruct.srow_x = [0 0 0 0];
            headerStruct.srow_y = [0 0 0 0];
            headerStruct.srow_z = [0 0 0 0];

        end
        
        function rawStruct = toRawStruct(simpleStruct, isNII)
        %toRawStruct: converts simplified header struct to standard form.
        %    This method converts the simplified header structure (as
        %    presented to the user) to the equivalent raw header format (as
        %    specified in the NIfTI standard). We do not support custom
        %    header "extensions" as indicated in the standard.
        
            rawStruct.sizeof_hdr = 348;
            if isNII
                rawStruct.magic = sprintf('n+1\0');
            else
                rawStruct.magic = sprintf('ni1\0');
            end
            rawStruct.vox_offset = 352;

            rawStruct.descrip = simpleStruct.Description;
            if isfield(simpleStruct, 'AuxiliaryFile')
                rawStruct.aux_file = simpleStruct.AuxiliaryFile;
            else
                rawStruct.aux_file = '';
            end

            imageDims = length(simpleStruct.ImageSize);
            rawStruct.dim = [imageDims simpleStruct.ImageSize ones(1, 7 - imageDims)];
            rawStruct.pixdim = [simpleStruct.Qfactor simpleStruct.PixelDimensions ones(1, 7 - imageDims)];

            if isfield(simpleStruct, 'AdditiveOffset')
                rawStruct.scl_inter = simpleStruct.AdditiveOffset;
            else
                rawStruct.scl_inter = 0;
            end
            
            if isfield(simpleStruct, 'MultiplicativeScaling')
                rawStruct.scl_slope = simpleStruct.MultiplicativeScaling;
            else
                rawStruct.scl_slope = 0;
            end

            rawStruct.xyzt_units = images.internal.nifti.niftiImage.setSpaceTimeUnits(simpleStruct.SpaceUnits, simpleStruct.TimeUnits);

            %intent_p1, intent_p2, %intent_p3. intent_code. intent_name
            if isfield(simpleStruct, 'Intent') && isfield(simpleStruct, 'IntentDescription') && isfield(simpleStruct, 'IntentParams')
            [rawStruct.intent_code, rawStruct.intent_name, ...
             rawStruct.intent_p1, rawStruct.intent_p2, ...
             rawStruct.intent_p3] = images.internal.nifti.niftiImage.setIntent(simpleStruct.Intent, ...
                                                 simpleStruct.IntentDescription, ...
                                                 simpleStruct.IntentParams);
            else
            [rawStruct.intent_code, rawStruct.intent_name, ...
             rawStruct.intent_p1, rawStruct.intent_p2, ...
             rawStruct.intent_p3] = images.internal.nifti.niftiImage.setIntent('None', ...
                                                 '', ...
                                                 [0, 0, 0]);
            end

            [rawStruct.datatype, rawStruct.bitpix] = images.internal.nifti.niftiImage.setDataType(simpleStruct.Datatype);

            if isfield(simpleStruct, 'SliceStart') && isfield(simpleStruct, 'SliceEnd') && isfield(simpleStruct, 'SliceDuration')
                rawStruct.slice_start = simpleStruct.SliceStart;
                rawStruct.slice_end = simpleStruct.SliceEnd;
                rawStruct.slice_duration = simpleStruct.SliceDuration;
            else
                rawStruct.slice_start = 0;
                rawStruct.slice_end = 0;
                rawStruct.slice_duration = 0;
            end
            
            if isfield(simpleStruct, 'TimeOffset')
                rawStruct.toffset = simpleStruct.TimeOffset;
            else
                rawStruct.toffset = 0;
            end

            rawStruct.slice_code = images.internal.nifti.niftiImage.setSliceCode(simpleStruct.SliceCode);
            rawStruct.dim_info = images.internal.nifti.niftiImage.setDimInfo(simpleStruct.FrequencyDimension, simpleStruct.PhaseDimension, simpleStruct.SpatialDimension);

            % cal_max and cal_min
            if isfield(simpleStruct, 'DisplayIntensityRange')
                rawStruct.cal_max = simpleStruct.DisplayIntensityRange(2);
                rawStruct.cal_min = simpleStruct.DisplayIntensityRange(1);
            else
                rawStruct.cal_max = 0;
                rawStruct.cal_min = 0;
            end

            % xform
            if isfield(simpleStruct, 'TransformName') && isfield(simpleStruct, 'Transform')
                rawStruct = images.internal.nifti.niftiImage.setXForm(rawStruct, simpleStruct);
            else
                rawStruct.qform_code = 0;
                rawStruct.sform_code = 0;
                rawStruct.quatern_b = 0;
                rawStruct.quatern_c = 0;
                rawStruct.quatern_d = 0;
                rawStruct.qoffset_x = 0;
                rawStruct.qoffset_y = 0;
                rawStruct.qoffset_z = 0;
                rawStruct.srow_x = [0 0 0 0];
                rawStruct.srow_y = [0 0 0 0];
                rawStruct.srow_z = [0 0 0 0];
            end

        end
        
    end
    
    % The following methods are helper functions that are used only in
    % the toRawStruct and niftiDefaultHeader static methods. They aren't
    % intended for use outside the scope of these two.
    
    methods(Static, Access = private)
        
        function [dataTypeCode, bitpix] = setDataType(precision)
        %setDataType: convert simplified datatype to standard form.
        %    This is a helper function to convert simplified data type to
        %    the raw data type code.
        
            precisionStr = {'ubit1', 'uint8', 'int16', 'int32', 'single', 'single', ...
                        'double', 'uint8', 'int8', 'uint16', 'uint32', 'int64', ...
                        'uint64'};
            datatypeVal = {1, 2, 4, 8, 16, 16, 64, 2, 256, 512, 768, 1024, 1280};        
            dataMap = containers.Map(precisionStr, datatypeVal);
            
            if isempty(find(strcmp(precisionStr, precision), 1))
               error(message('images:nifti:imageDataTypeNotSupported')); 
            end
            
            dataTypeCode = dataMap(precision);

            sizeSet = {1, 8, 16, 32, 32, 32, 64, 8, 8, 16, 32, 64, 64};
            sizeMap = containers.Map(precisionStr, sizeSet);
            
            bitpix = sizeMap(precision);

        end
        
        function xyztCode = setSpaceTimeUnits(spaceUnitText, timeUnitText)
        %setSpaceTimeUnits: convert simplified space time units to standard
        %form.
        %    This is a helper function to convert simplified space and time
        %    units to the raw format as specified in the NIfTI header.
        
            spaceKey   = {0, 1, 2, 3};
            spaceValue = {'Unknown', 'Meter', 'Millimeter', 'Micron'};

            spaceMap = containers.Map(spaceValue, spaceKey);
            
            if isempty(find(strcmp(spaceValue, spaceUnitText), 1))
               error(message('images:nifti:spaceUnitNotSupported')); 
            end
            
            spaceUnits = spaceMap(spaceUnitText);

            timeValue = {'None', 'Second', 'Millisecond', 'Microsecond', 'Hertz', 'PartsPerMillion', 'Radian'};
            timeKey = {0, 8, 16, 24, 32, 40, 48};

            timeMap = containers.Map(timeValue, timeKey);
            
            if isempty(find(strcmp(timeValue, timeUnitText), 1))
               error(message('images:nifti:timeUnitNotSupported')); 
            end
            
            timeUnits = timeMap(timeUnitText);

            spaceUnitCode = bitand(uint8(spaceUnits),uint8(7));
            timeUnitCode  = bitand(uint8(timeUnits),uint8(56)); % 0x38

            xyztCode = bitor(spaceUnitCode, timeUnitCode);

        end
        
        function [i_code, i_name, p1, p2, p3] = setIntent(code, name, params)
        %setIntent: convert simplified intent code, name and parameters to
        %standard form.
        %    This helper function converts simplified intent code, name and
        %    parameters to the raw format.
        
            keySet = {'None', 'Correlation', 'T-Test', 'F-Test', 'Z-Score', ...
                        'Chi-Squared', 'Beta', 'Binomial', 'Gamma', 'Poisson', ...
                        'Normal', 'Noncentral F-statistic', 'Noncentral Chi-squared', ...
                        'Logistic', 'Laplace', 'Uniform', 'Noncentral T-test', ...
                        'Weibull', 'Chi', 'Inverse Gaussian', 'Extreme Value', ...
                        'p-value', 'ln p-value', 'log p-value', 'Estimate', 'Label', ...
                        'NeuroName Label', 'General Matrix', 'Symmetric Matrix', ...
                        'Displacement Vector', 'Vector', 'Point Set', 'Triangle', ...
                        'Quaternion', 'Dimensionless', 'Time Series', 'Node Index', ...
                        'RGB Triplet', 'RGBA vector', 'Shape'};

            valueSet = {0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, ...
                      18, 19, 20, 21, 22, 23, 24, 1001, 1002, 1003, 1004, 1005, ...
                      1006, 1007, 1008, 1009, 1010,1011, 2001, 2002, 2003, 2004, 2005};

            mapObj = containers.Map(keySet, valueSet);
            
            if isempty(find(strcmp(keySet, code), 1))
               error(message('images:nifti:intentCodeNotSupported')); 
            end

            i_name = name;
            i_code = mapObj(code);
            p1 = params(1);
            p2 = params(2);
            p3 = params(3);

        end
        
        function dimInfo = setDimInfo(f_d, p_d, s_d)
        %dimInfo: converts simplified dimInfo to standard form.
        %    This helper function creates the dimInfo field of the raw
        %    NIfTI header from the independent parameters in the simplified
        %    format.
        
            dimInfo = bitor(bitor(bitand(f_d, uint8(3)), ...
                            bitshift(bitand(p_d, uint8(3)), 2)), ...
                            bitshift(bitand(s_d, uint8(3)), 4));
            dimInfo = char(dimInfo);

        end
        
        function slice_code = setSliceCode(sliceCode)
        %setSliceCode: converts simplified slice code to standard form.
        %    This helper converts the textual slice code specification to
        %    the raw header code, as specified in the NIfTI standard.
        
            slice_code_key   = {0, 1, 2, 3, 4, 5, 6};
            sliceCodeValue = {'Unknown', 'Sequential-Increasing', 'Sequential-Decreasing', ...
                              'Alternate-Increasing', 'Alternate-Decreasing', ...
                              'Alternate-Increasing-2', 'Alternate-Decreasing-2'};

            sliceCodeMap = containers.Map(sliceCodeValue, slice_code_key);
            
            if isempty(find(strcmp(sliceCodeValue, sliceCode), 1))
               error(message('images:nifti:sliceCodeValueNotSupported')); 
            end
            
            slice_code = sliceCodeMap(sliceCode);

        end
        
        function rawStruct = setXForm(rawStruct, simpleStruct)
        %setXForm: converts simplified transform to standard form.
        %    This helper function converts the affine3D object from the
        %    simplified structure to the various raw header fields as
        %    specified by the NIfTI standard.
        
            if isempty(find(strcmp({'Sform', 'Qform', 'None'}, simpleStruct.TransformName), 1))
               error(message('images:nifti:transformNotSupported')); 
            end
            
            if strcmp(simpleStruct.TransformName,'Sform')
                rawStruct.qform_code = 0;
                rawStruct.sform_code = 1;
                rawStruct.quatern_b = 0;
                rawStruct.quatern_c = 0;
                rawStruct.quatern_d = 0;
                rawStruct.qoffset_x = 0;
                rawStruct.qoffset_y = 0;
                rawStruct.qoffset_z = 0;
                rawStruct.srow_x = simpleStruct.Transform.T(:,1)';
                rawStruct.srow_y = simpleStruct.Transform.T(:,2)';
                rawStruct.srow_z = simpleStruct.Transform.T(:,3)';
            elseif strcmp(simpleStruct.TransformName,'Qform')
                rawStruct.qform_code = 1;
                rawStruct.sform_code = 0;
                a = 0.5*sqrt(1+simpleStruct.Transform.T(1,1)+ ...
                               simpleStruct.Transform.T(2,2)+ ...
                               simpleStruct.Transform.T(3,3));
                if a == 0
                    a = 1e-5;
                end
                rawStruct.quatern_b = 0.25*(simpleStruct.Transform.T(2,3)- ...
                                            simpleStruct.Transform.T(3,2))/a;
                rawStruct.quatern_c = 0.25*(simpleStruct.Transform.T(1,3)- ...
                                            simpleStruct.Transform.T(3,1))/a;
                rawStruct.quatern_d = 0.25*(simpleStruct.Transform.T(1,2)- ...
                                            simpleStruct.Transform.T(3,1))/a;
                rawStruct.qoffset_x = simpleStruct.Transform.T(4,1);
                rawStruct.qoffset_y = simpleStruct.Transform.T(4,2);
                rawStruct.qoffset_z = simpleStruct.Transform.T(4,3);
                rawStruct.srow_x = [0 0 0 0];
                rawStruct.srow_y = [0 0 0 0];
                rawStruct.srow_z = [0 0 0 0];
            else % Xform is none, and any other specification.
                rawStruct.qform_code = 0;
                rawStruct.sform_code = 0;
                rawStruct.quatern_b = 0;
                rawStruct.quatern_c = 0;
                rawStruct.quatern_d = 0;
                rawStruct.qoffset_x = 0;
                rawStruct.qoffset_y = 0;
                rawStruct.qoffset_z = 0;
                rawStruct.srow_x = [0 0 0 0];
                rawStruct.srow_y = [0 0 0 0];
                rawStruct.srow_z = [0 0 0 0];
            end
            
        end
        
    end

end