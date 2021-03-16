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
    @bodyParam("options", "options")
    @bodyParam("dependencies", "dependencies")
    Json run(string lang, Json files, Json options, Json dependencies) @safe;
}

/++
 +
 +/
public class RunAPI : IRunAPI
{
    /++
     +
     +/
    public Json run(string lang, Json files, Json options, Json dependencies) @safe
    {
        import std.conv : to;
        import std.array : split, join;
        import viva.io : println;
        import viva.docker : DockerOptions, runDockerShell;
        import dide.model : Result;
        import dide.util.language : dockerImageFromLanguage;

        const(string) jsonData = serializeToJsonString([
            "language": serializeToJson(lang),
            "files": files,
            "options": serializeToJson(options),
            "dependencies": dependencies
        ]);

        string runnerCommand = "java -jar --enable-preview runner " ~ jsonData;

        string dockerImage = dockerImageFromLanguage(lang);
        if (dockerImage is null)
        {
            struct Error
            {
                string code;
                string status;
                string message;
            }

            return serializeToJson(
                Error("404", "lang image not found", "docker image for lang '" ~ lang ~ "' not found")
            );
        }
        DockerOptions dockerOptions = DockerOptions(dockerImageFromLanguage(lang), runnerCommand);
        string rawResult = runDockerShell(dockerOptions);

        string fixedResult = join(rawResult.split("\n")[2..$], "\n");
        Json rawJson = parseJson(fixedResult);

        return serializeToJson(Result(
            rawJson["stdout"].to!string,
            rawJson["stderr"].to!string,
            rawJson["error"].to!string
        ));
    }
}