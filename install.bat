@echo off
setlocal

REM Check if AWS CLI is installed
where aws >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: AWS CLI is not installed. Please install it and try again.
    exit /b
)

REM Check if pip is installed
where pip >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: pip is not installed. Please install pip/Python and try again.
    exit /b
)

REM Check if the AWS credentials are provided
if "%1"=="" goto PrintUsage
if "%2"=="" goto PrintUsage

set AWS_ACCESS_KEY_ID=%1
set AWS_SECRET_ACCESS_KEY=%2

REM Check if the version argument is provided (optional), otherwise default to latest release
REM TODO: Allow empty version to list all available versions
if "%3"=="" (
   set PACKAGE=fappcli
) else (
   set PACKAGE=fappcli==%3
)

REM Get pypi info and login token
for /f "delims=" %%a in ('aws sts get-caller-identity --query "Account" --output text') do set ACCOUNT_ID=%%a
for /f "delims=" %%a in ('aws codeartifact get-authorization-token --domain acap-dev-support --domain-owner %ACCOUNT_ID% --region eu-north-1 --query authorizationToken --output text') do set CODEARTIFACT_AUTH_TOKEN=%%a
set INDEX_URL=https://aws:%CODEARTIFACT_AUTH_TOKEN%@acap-dev-support-%ACCOUNT_ID%.d.codeartifact.eu-north-1.amazonaws.com/pypi/acap-dev-support/simple/

REM Install the package
pip install %PACKAGE% --extra-index-url=%INDEX_URL%

endlocal
goto :EOF

:PrintUsage
echo Error: Usage: .\install.bat AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY VERSION:optional
goto :EOF