import vibe.d;

private void handleError(HTTPServerRequest _, HTTPServerResponse res, HTTPServerErrorInfo error)
{
    import std.conv : to;

    string errorDebug = "";
    debug errorDebug = error.debugMessage;

    struct Error
    {
        string code;
        string status;
        string message;
    }

    res.contentType = "application/json";
    res.writeBody(serializeToJsonString(["error": Error(
        error.code.to!string,
        error.message,
        error.debugMessage
    )]));
}

void main()
{
	import dide.rest : RunAPI;

	URLRouter router = new URLRouter();

	router.registerRestInterface(new RunAPI());

	HTTPServerSettings serverSettings = new HTTPServerSettings();
	serverSettings.bindAddresses = ["0.0.0.0"];
	serverSettings.port = 8084;
	serverSettings.errorPageHandler = toDelegate(&handleError);

	listenHTTP(serverSettings, router);

	runApplication();
}
