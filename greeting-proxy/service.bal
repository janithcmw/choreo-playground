import ballerina/http;
import ballerina/log;

type GreetRequest record {|
    string name;
|};

type GreetResponse record {|
    string message;
|};

// Choreo's token cache handles refresh automatically — no manual token management needed.
final http:Client greetingClient = check new (greetingServiceUrl, {
    auth: <http:OAuth2ClientCredentialsGrantConfig>{
        tokenUrl: asgardeoTokenUrl,
        clientId: clientId,
        clientSecret: clientSecret
    }
});

service /proxy on new http:Listener(8091) {

    resource function get hello(string name = "World") returns GreetResponse|http:InternalServerError {
        GreetResponse|error response = greetingClient->get(string `/greet/hello?name=${name}`);
        if response is error {
            log:printError("Failed to call greeting service.", response);
            return http:INTERNAL_SERVER_ERROR;
        }
        return response;
    }

    resource function post hello(@http:Payload GreetRequest payload) returns GreetResponse|http:InternalServerError {
        GreetResponse|error response = greetingClient->post("/greet/hello", payload);
        if response is error {
            log:printError("Failed to call greeting service.", response);
            return http:INTERNAL_SERVER_ERROR;
        }
        return response;
    }

    resource function get health() returns GreetResponse {
        return {message: "ok"};
    }
}
