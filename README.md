# HAProxy API Monetization Demo

This project demonstrates how to use HAProxy with Keycloak to restrict access to the 
API servers to only clients that present a valid OAuth 2 access token. Each token
includes a scope field that's set to *bronze*, *silver*, or *gold*. You could charge
clients a fee to access the API at the various subscription levels.

HAProxy enforces rate limits:

- bronze = up to 10 request/minute
- Silver = up to 100 requests/minute
- Gold = up to 1000 requests/minute

Setup
-----

To set up the demo project, initialize it with Docker Compose:

```
sudo docker-compose build
sudo docker-compose up -d
```

The application listens on *localhost*. Go to http://localhost/auth/ to set up clients in Keycloak. Keycloak issues access tokens, which HAProxy validates.


Changes
-----
haproxy + keycloak, article info  
https://www.haproxy.com/blog/using-haproxy-as-an-api-gateway-part-5-monetization

OAuth 2 library for HAProxy, This installs jwtverify.lua and its dependencies to /usr/local/share/lua/5.4/jwtverify.lua  
https://github.com/haproxytech/haproxy-lua-oauth

## Fixeing point
### use_backend warns
```
a 'http-request' rule placed after a 'use_backend' rule will still be processed before.  <-- warn
```
- Change the order of use_backend in the haproxy.cfg file

### Keycloak error
```
haproxy-api-monetization-demo-keycloak-1  | Option: '--http-relative-path /auth' 
is not expected to contain whitespace, please remove any unnecessary quoting/escaping
haproxy-api-monetization-demo-keycloak-1  | Possible solutions: 
--http-enabled, --http-host, --http-port, --https-port, --https-cipher-suites, --https-protocols, --https-certificate-file, --https-certificate-key-file, --https-key-store-file, --https-key-store-password, --https-key-store-type, --https-trust-store-file, --https-trust-store-password, --https-trust-store-type, --http-max-queued-requests, --http-pool-max-threads, --http-relative-path, --https-client-auth
```
- move into the environment variable, in the docker-compose.yaml file

