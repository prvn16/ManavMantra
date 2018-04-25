function b = isObjectDirectorySpecified(topic)
    b = ~isempty(regexp(topic, '(^|[\\/])[@+]', 'once'));
end