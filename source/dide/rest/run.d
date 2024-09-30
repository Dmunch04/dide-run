module dide.rest.run;

import vibe.d;

/++
 +
 +/
// TODO: i wanted the path to be `/api/run` and the request to be `/` but that doesn't work
@path("/api")
public interface IRunAPI
{
    /++
     +
     +/
    @path("/run")
    @method(HTTPMethod.POST)
    @bodyParam("lang", "language")
    @bodyParam("files", "files")
    @bodyParam("entry", "entry")
    @bodyParam("options", "options")
    @bodyParam("dependencies", "dependencies")
    Json run(string lang, Json files, string entry, Json options, Json dependencies) @safe;
}

/++
 +
 +/
public class RunAPI : IRunAPI
{
    /++
     +
     +/
    public Json run(string lang, string entry, Json files, Json options, Json dependencies) @safe
    {
        import std.conv : to;
        import std.base64 : Base64;
        import std.array : split, join, appender;
        import viva.docker : DockerOptions, runDockerShell;
        import dide.util.language : dockerImageFromLanguage;
        import dide.model : Result, DideError;

        const(string) jsonData = serializeToJsonString([
            "language": serializeToJson(lang),
            "files": files,
            "entry": entry,
            "options": serializeToJson(options),
            "dependencies": dependencies
        ]);

        auto builder = appender!string();
        Base64.encode(jsonData, builder);
        string encodedData = builder.data();

        string runnerCommand = "./runner " ~ encodedData;

        string dockerImage = dockerImageFromLanguage(lang);
        if (dockerImage is null)
        {
            return serializeToJson(
                DideError("404", "lang image not found", "docker image for lang '" ~ lang ~ "' not found")
            );
        }
        DockerOptions dockerOptions = DockerOptions(dockerImage, runnerCommand);
        string res = runDockerShell(dockerOptions, sudo:false);
        Json rawJson = parseJson(res);

        return serializeToJson(Result(
            rawJson["stdout"].to!string,
            rawJson["stderr"].to!string
        ));
    }
}