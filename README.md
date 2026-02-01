**## Karate API Automation Framework**

This repository contains API automation built using Karate DSL, focused on validating backend REST APIs through regression, negative, and contract-level testing.
The framework is designed to run reliably both locally and in CI using Jenkins, Docker, and TestRail integration.

**## General Guidelines**

  1. All tests should be written using Karate DSL
  2. The framework intentionally avoids unnecessary third-party libraries to keep execution fast and predictable
  3. Folder and file names are kept lowercase to ensure compatibility with Linux-based CI environments

**## Configuration**

All environment configuration is handled through `karate-config.js`.

Responsibilities include:
1. Base URL configuration
2. Authentication token handling
3. Shared headers
4. Environment variables like gorest access token

Secrets are never committed and must be injected via CI (Jenkins credentials or environment variables).

**##Test Design**

Tests are organized by API domain and written to validate API behavior and outcomes. Implementation details such as payload construction and setup logic are abstracted into reusable helper features.
Where needed,response schema validation is used to ensure contract consistency.

**##CI Execution**

CI execution runs in a Docker-based Linux environment to keep builds consistent and reproducible.Each build starts with a clean runtime while reusing cached Maven dependencies through a mounted .m2 directory.
Secrets are injected securely via the CI system and are never stored in the repository

**##Jenkins Responsibilities**

The Jenkins pipeline is responsible for:
1. Checking out the repository
2. Executing Karate tests via Maven
3. Generating JUnit XML results
4. Generating Karate HTML reports
5. Publishing reports in Jenkins
6. Pushing test results to TestRail

**## Test Reporting**

**##Jenkins**

1. JUnit test results are visible in the **Tests (Karate Api Test Report)** tab
2. Build-level pass/fail status and history are avilable

**## Karate**
1. HTML summary report is generated for each build
2. Used for debugging and execution review

**##TestRail Integration**

This repository integrates with TestRail using TRCLI. JUnit results produced during CI execution are parsed and uploaded automatically, creating or updating TestRail test runs without manual effort.
Test cases are generated and associated based on execution results, providing centralized visibility of automation outcomes directly from the CI pipeline.

**## Local Execution**

Tests can be executed locally using Maven:

mvn clean test -Dgorest.token=YOUR_TOKEN
we can get our own access token from **https://gorest.co.in/** an generate a new one

**##References**
https://docs.karatelabs.io/getting-started/why-karate
https://support.testrail.com/hc/en-us/articles/13774852916628-Integrating-with-Jenkins-pipeline
