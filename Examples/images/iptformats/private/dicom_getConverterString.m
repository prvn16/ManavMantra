function converterString = dicom_getConverterString(definedTerm)
%dicom_getConverterString   Translate DICOM defined term into ICU string.
%   ICUSTR = dicom_getConverterString(DEFINED_TERM) converts the DICOM
%   defined term for "Specific Character Set" into the character set
%   description understood by the ICU conversion engine. If DEFINED_TERM is
%   unrecognized, a warning is issued and the native locale is used.

% Copyright 2015 The MathWorks, Inc.

switch (definedTerm)
case {'ISO_IR 100', 'ISO_IR 101', 'ISO_IR 109', 'ISO_IR 110', ...
      'ISO_IR 144', 'ISO_IR 127', 'ISO_IR 126', 'ISO_IR 138', ...
      'ISO_IR 148', 'ISO_IR 6', 'GB18030', 'GBK', 'ISO_IR100'}
    converterString = definedTerm;
case 'ISO_IR 13'
    converterString = 'Shift_JIS';
case 'ISO_IR 166'
    converterString = 'tis620.2533';
case 'ISO 2022 IR 6'
    converterString = 'ISO IR 6';
case 'ISO 2022 IR 100'
    converterString = 'ISO IR 100';
case 'ISO 2022 IR 101'
    converterString = 'ISO IR 101';
case 'ISO 2022 IR 109'
    converterString = 'ISO IR 109';
case 'ISO 2022 IR 110'
    converterString = 'ISO IR 110';
case 'ISO 2022 IR 144'
    converterString = 'ISO IR 144';
case 'ISO 2022 IR 127'
    converterString = 'ISO IR 127';
case 'ISO 2022 IR 126'
    converterString = 'ISO IR 126';
case 'ISO 2022 IR 138'
    converterString = 'ISO IR 138';
case 'ISO 2022 IR 148'
    converterString = 'ISO IR 148';
case 'ISO 2022 IR 13'
    converterString = 'Shift_JIS';
case 'ISO 2022 IR 166'
    converterString = 'tis620.2533';
case 'ISO 2022 IR 87'
    converterString = 'ISO-2022-JP';
case 'ISO 2022 IR 159'
    converterString = '';  % Possibly 'MS_Kanji'
case 'ISO 2022 IR 149'
    converterString = 'ISO IR 149';
case 'ISO 2022 IR 58'
    converterString = 'ISO IR 58';
case 'ISO_IR 192'
    converterString = 'UTF-8';
otherwise
    converterString = '';
end

if (isempty(converterString))
    warning(message('images:dicominfo:unhandledCharacterSet', definedTerm))
end