classdef Converter
    %CONVERTER Convert and scale audio data from one type to another
    %   Converter converts audio data from one data type to another
    %   and scales the data into the range of the data type.
    %   
    %   Supported input Data Types are:
    %      'double'
    %      'int16'
    %      'uint8'
    %
    %
    
    %    Author(s): NH
    %    Copyright 2010-2013 The MathWorks, Inc.
    %      
 
    
    methods(Access='public', Static)
        
        function output = toDouble( data )
            import audiovideo.internal.audio.Converter;
            Converter.assertDataSupported(data);
            
            switch(class(data))
                case 'double'
                    output = data;
                otherwise % Integer type
                    switch (class(data))
                        case 'int16'
                            output = double(data)/(2^(16-1));
                        case 'uint8'
                            output = double(data)/2^(8-1) - 1.0;
                    end
            end       
        end
        
        function output = toSingle( data )
            import audiovideo.internal.audio.Converter;
            Converter.assertDataSupported(data);
            output = single(Converter.toDouble( data ));
        end
        
        function output = toInt16( data )
            import audiovideo.internal.audio.Converter;
            Converter.assertDataSupported(data);
            switch(class(data))
                case('double')
                   output = int16(data * 2^(16-1));
                case('int16')
                    output = data;
                case('uint8')
                    output = int16(data) - 2^7;
                    output = int16(output * 2^8);
            end
        end
        
        function output = toInt8( data )
            audiovideo.internal.audio.Converter.assertDataSupported(data);
            switch(class(data))
                case('double') % normalized float
                    output = int8(data * 2^7); 
                case('int16')
                    output = int8(data / 2^8);
                case('uint8')
                    output = int8(int16(data) - 2^7);
            end
        end
        
        function output = toUint8( data )
            import audiovideo.internal.audio.Converter;
            Converter.assertDataSupported(data);
            output = Converter.toInt8(data);
            output = uint8(int16(output) + (2^7));
        end
        
        function samples = secondsToSamples( seconds, sampleRate )
            % SECONDSTOSAMPLES Convert from seconds to samples
            %   Given an amount of time SECONDS and a SAMPLERATE
            %   return the number of samples that would fit in that time
            %   based on the SAMPLERATE, rounded to the nearest power of 2.
            
            assert(isnumeric(seconds) && (all(seconds >= 0)));
            assert(isnumeric(sampleRate) && (sampleRate >= 0));
            
            % zero seconds should return 0 samples
            if (seconds == 0)
                samples = 0;
                return;
            end
            
            [f, p] = log2(seconds * sampleRate);
            
            if (f <= 0.75) % find the nearest power of 2
                p = p - 1;
            end
            
            samples = pow2(p);
        end
    end
    
    methods (Access='private', Static)
        function assertDataSupported(data)
            supportedClasses = {'uint8','int16','double'};
            if ~any(strcmp(class(data), supportedClasses))
                error(message('MATLAB:audiovideo:Converter:InvalidInput'));
            end
               
        end
    end
end

