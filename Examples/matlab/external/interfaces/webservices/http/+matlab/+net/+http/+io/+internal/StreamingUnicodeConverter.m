classdef StreamingUnicodeConverter < matlab.net.http.io.internal.StreamingConverter
% StreamingUnicodeConverter converts a uint8 input stream to Unicode char vector
%   based on a character set.
%
% This class is for internal use only. It may change in a future release.

% Copyright 2017 The MathWorks, Inc.
    properties 
        Charset char
    end
    
    properties (Access=private)
        PartialData uint8 = uint8.empty
        IsUTF8 logical = false
    end
    
    methods
        function obj = StreamingUnicodeConverter(charset)
        % StreamingUnicodeConverter Construct a converter for a character set
        %   CONVERTER = StreamingUnicodeConverter(CHARSET) returns a converter for
        %   converting a uint8 stream to Unicode given the specified CHARSET. Currently
        %   the converter only reliably processes single-byte encodings and UTF-8.
        %
        %   If charset is missing or empty, returns an empty array.
        
            % TBD: Eventually we need to implement a MATLAB API to the streaming unicode
            % conversion utilities as in the example at
            % http://inside.mathworks.com/wiki/Character_Code_Conversion_Cookbook:_Invalid_Character_Detection#Invalid_Character_Detection_Mode_with_Stream_Code_Conversion
            if nargin > 0 && ~isempty(charset)
                obj.Charset = charset;
                obj.IsUTF8 = any(strcmpi(charset,["utf8" "utf-8"]));
            else
                obj = matlab.net.http.io.internal.StreamingUnicodeConverter.empty;
            end
        end
        
        function [ustr, obj] = convert(obj, buf)
        % convert Convert a buffer from native to Unicode
        %   [USTR, CONVERTER] = convert(CONVERTER, BUF) converts BUF, a uint8 vector, to
        %   Unicode based on CONVERTER.Charset. The result USTR, is a char vector.
        %   If BUF ends in the middle of a multibyte character, only part of BUF may be
        %   converted. On the subsequent call to convert, that partial character will
        %   be prepended to BUF.
        %
        %   USTR may be "" if BUF (and any leftover partial character from the previous
        %   call) does not contain a complete character.
        %
        %   If BUF is [], this indicates end of input. Any final character may be
        %   returned, and an exception may be thrown if there was a partial unconverted
        %   character from the previous call. This resets the converter to process a
        %   new stream.
            if ~isempty(buf) && (~isa(buf,'uint8') || ~isvector(buf))
                validateattributes(buf, {'uint8'}, {'vector'}, mfilename, 'BUF');
            end
            if obj.IsUTF8
                % TBD: this is a dumb algorithm that just jumps to the end of a buffer and looks
                % for the start of a single or multi-byte character, and converts everything up
                % to (or including) that character. It doesn't try to count how many bytes in
                % that last character so it always saves it for later as a partial, so it will
                % not convert the last multibyte character in the buffer even if is all there
                % (but it will return that character on the next buffer or end of data).
                % At the end, it doesn't throw an exception if the stream ends with a partial
                % character.
                data = [obj.PartialData buf]; % prepend partial data to buf, if any
                if isempty(buf)
                    % at end of input, always convert all the data we have
                    last = length(data);
                else
                    last = 0; % last character in buffer to convert
                    for i = length(data) : -1 : 1
                        if data(i) < 128
                            % 0xxxxxxx  A single-byte character; include it in output
                            last = i;
                            break    
                        end
                        if data(i) >= 192
                            % 11xxxxxx Start of a multibyte character; include everything up to it
                            last = i-1;  
                            break
                        end
                    end
                end
            else
                data = buf;
                last = length(buf);
            end
            if last > 0
                ustr = native2unicode(data(1:last), obj.Charset);
            else
                ustr = '';
            end
            % Save any bytes not yet processed in PartialData. If buf was empty, this
            % indicates end of data, so toss those characters.
            if last < length(data) && ~isempty(buf)
                obj.PartialData = data(last+1:end);
            else
                obj.PartialData = uint8.empty;
            end
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'convert',2);
         end
        
        function obj = set.Charset(obj, charset)
            native2unicode(0,charset); % just call this to validate the charset
            obj.Charset = charset;
        end
        
        function obj = reset(obj)
            obj.PartialData = uint8.empty;
        end
    end
            
end