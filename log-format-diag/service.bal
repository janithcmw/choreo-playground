import ballerina/http;
import ballerina/log;

type DiagResponse record {|
    string message;
|};

// Standalone reproduction of the cst-commons diagnostic log:printInfo call
// (cst-commons/api-impl/service.bal:111) — used to compare Ballerina's default
// `logfmt` output against `format = "json"` in this org's Choreo Application Logs,
// without touching the real cst-commons deployment.
service /diag on new http:Listener(8092) {

    // GET /diag/logtest?tag=wso2is-4.5.0.437
    // Same parsing + log:printInfo shape as the CST ACR-missing-product path,
    // minus the buggy comma-split index that panics there.
    resource function get logtest(string tag = "wso2is-4.5.0.437") returns DiagResponse {
        string[] productDetails = re `-`.split(tag);
        string product = productDetails[0];
        string versionWithUpdatelevel = productDetails.length() > 1 ? productDetails[1] : "";
        string[] versionWithUpdatelevelSplit = re `[.]`.split(versionWithUpdatelevel);
        string[] commaSplitParts = re `,`.split(versionWithUpdatelevel);
        log:printInfo("Parsing ACR-missing product",
            product = product,
            versionWithUpdatelevel = versionWithUpdatelevel,
            versionParts = versionWithUpdatelevelSplit.toString(),
            commaSplitParts = commaSplitParts.toString());
        return {message: string `logged diagnostic line for tag=${tag}`};
    }

    // GET /diag/health  →  { "message": "ok" }
    resource function get health() returns DiagResponse {
        return {message: "ok"};
    }
}
