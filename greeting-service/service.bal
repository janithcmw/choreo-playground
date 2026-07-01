import ballerina/http;

type GreetRequest record {|
    string name;
|};

type GreetResponse record {|
    string message;
|};

service /greet on new http:Listener(8090) {

    // GET /greet/hello?name=John  →  { "message": "Hello, John!" }
    resource function get hello(string name = "World") returns GreetResponse {
        return {message: string `${greetingPrefix}, ${name}!`};
    }

    // POST /greet/hello  body: { "name": "John" }  →  { "message": "Hello, John!" }
    resource function post hello(@http:Payload GreetRequest payload) returns GreetResponse {
        return {message: string `${greetingPrefix}, ${payload.name}!`};
    }

    // GET /greet/health  →  { "message": "ok" }
    resource function get health() returns GreetResponse {
        return {message: "ok"};
    }
}
