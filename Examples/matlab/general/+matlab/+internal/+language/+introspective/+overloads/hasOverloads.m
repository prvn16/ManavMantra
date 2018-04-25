function doesHaveOverload = hasOverloads(topic)
    doesHaveOverload = ~isempty(matlab.internal.language.introspective.overloads.getOverloads(topic, true, false));
end
