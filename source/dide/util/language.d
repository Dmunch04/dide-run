module dide.util.language;

/++
 +
 +/
public string dockerImageFromLanguage(string lang) @safe
{
    switch (lang)
    {
        case "csharp", "cs": return "munchii/dide-csharp:latest";
        case "dlang", "d": return "munchii/dide-dlang:latest";
        case "golang", "go": return "munchii/dide-golang:latest";
        case "java": return "munchii/dide-java:latest";
        case "javascript", "js": return "munchii/dide-javascript:latest";
        case "kotlin", "kt": return "munchii/dide-kotlin:latest";
        case "python", "python3", "py": return "munchii/dide-python:latest";
        case "rust", "rs": return "munchii/dide-rust:latest";
        case "typescript", "ts": return "munchii/dide-typescript:latest";
        //case "zig": return "munchii/zig:latest";

        default: return null;
    }
}