import ballerinax/github;
import ballerina/log;
import ballerina/http;

configurable string githubAccessToken = ?;

type SummarizedIssue record {
    int number;
    string title;
};

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get summary/[string orgName]/repository/[string repoName]() returns SummarizedIssue[]|error? {

        log:printInfo("new request for " + orgName + " " + repoName);
        github:Client githubEndpoint = check new ({auth: {token: githubAccessToken}});
        stream<github:Issue, github:Error?> getIssuesResponse = check githubEndpoint->getIssues(orgName, repoName, issueFilters = {states: [github:ISSUE_OPEN]});
        SummarizedIssue[]? summary = check from github:Issue issue in getIssuesResponse
            order by
            issue.number descending
            limit 10
            select {number: issue.number, title: issue.title.toString()};

        return summary;
    }
}
//comment1