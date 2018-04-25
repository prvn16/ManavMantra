classdef ColorEncoder
    % ColorEncoder Encode and decode color values
    %
    %    A color encoder can encode floating-point color values into another data type, typically an
    %    integer type. It can also decode values from another data type, producing floating-point
    %    unencoded values.
    %
    %    ColorEncoder is an abstract class. Subclasses need to define the Constant properties
    %    EncoderFunctionTable and DecoderFunctionTable. Each of these properties has a value that
    %    is a struct. The field names correspond to types, and the field values are function handles
    %    that perform encoding to or decoding from that type. For example, if the
    %    EncoderFunctionTable contains a field named 'uint8' whose value is @encodeToUint8, then
    %    this function call:
    %
    %        out = encode(encoder,in,'uint8')
    %
    %    will call encodeToUint8 to do the encoding. Similarly, if the DecoderFunctionTable contains
    %    a field named 'uint16' whose value is @decodeFromUint16, then this function call:
    %
    %        out = decode(encoder,in)
    %
    %    will call decodeFromUint16 to do the encoding if the input type is uint16.
    
    %    Copyright 2014 The MathWorks, Inc.

    properties (Abstract, Constant)
        % EncoderFunctionTable - Struct containing functions that encode to different types
        EncoderFunctionTable
        
        % DecoderFunctionTable - Struct containing functions that decode from different types
        DecoderFunctionTable
    end
    
    methods
        function out = decode(this_encoder, in)
            % decode Decode color values
            %
            %    out = decode(encoder,in)
            %
            %    Converts input color values to unencoded, floating-point values.
            
            type = checkDecodeInputType(this_encoder, in);
            decoder_function_table = this_encoder.DecoderFunctionTable;
            decoder_function = decoder_function_table.(type);
            
            out = decoder_function(in);
        end
        
        function out = encode(this_encoder, in, output_type)
            % encode Encode color values
            %
            %    out = encode(encoder,in,output_type)
            %
            %    Converts unencoded, floating-point values to encoded values of the specified type.
            
            checkEncodeOutputType(this_encoder, output_type);
            encoder_function_table = this_encoder.EncoderFunctionTable;
            encoder_function = encoder_function_table.(output_type);
            
            out = encoder_function(in);
        end
    end
    
    methods (Hidden)
        function type = checkDecodeInputType(this_encoder, in)
            % checkDecodeInputType Validate input type for decoding
            %
            %     type = checkDecodeInputType(encoder,in)
            %
            %     Errors if there is no entry in the DecoderFunctionTable corresponding to the input
            %     type. Otherwise returns the matched type (as a string).
            
            type = '';
            supported_types = fieldnames(this_encoder.DecoderFunctionTable)';
            for k = 1:length(supported_types)
                type_k = supported_types{k};
                if isa(in, type_k)
                    type = type_k;
                    break
                end
            end
            
            if isempty(type)
                % Did not find a supported type.
                s = strjoin(supported_types,' ');
                throwAsCaller( ...
                    MException(message('images:color:unsupportedDecodeInputType',class(in),s)));
            end
        end
        
        function checkEncodeOutputType(this_encoder, out_type)
            % checkEncodeOutputType Validate output type for encoding
            %
            %    checkEncodeOutputType(encoder,output_type)
            %
            %    Errors if there is no entry in the EncoderFunctionTable corresponding to the
            %    specified output type.
            
            supported_types = fieldnames(this_encoder.EncoderFunctionTable)';
            if ~ismember(out_type, supported_types)
                s = strjoin(supported_types,' ');
                throwAsCaller( ...
                    MException(message('images:color:unsupportedEncodeOutputType',out_type,s)));
            end
        end
    end
end
