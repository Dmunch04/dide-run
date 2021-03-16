module dide.util.language;

/++
 +
 +/
public string dockerImageFromLanguage(string lang) @safe
{
    switch (lang)
    {
        case "d": return "munchii/dlang:latest";
        case "zig": return "munchii/zig:latest";

        default: return null;
    }
}