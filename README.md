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
> https://www.haproxy.com/blog/using-haproxy-as-an-api-gateway-part-5-monetization

OAuth 2 library for HAProxy, This installs jwtverify.lua and its dependencies to 
 `/usr/local/share/lua/5.4/jwtverify.lua`  
> https://github.com/haproxytech/haproxy-lua-oauth

Configuring Keycloak  
> https://www.keycloak.org/server/configuration  

All guides of keycloak
> https://www.keycloak.org/guides#server

## Remember
### Keycloak web url  
- development mode => http://127.0.0.1/auth/
### Initial id/password  
- admin

  ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/ff607765-d308-4c40-b8b2-dea8277ed6cb)
    
### Acquire Admin Access Token. Client Credentials Grant. Process Flow
1. Create Realm. (weather-services)  
   - Create realm
     ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/7df746e9-bf88-49a1-acf4-92b41ef3861b)
     ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/7ae789a3-a162-4d02-ab47-ae7b5680c000)
     ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/6b8caf30-1ec4-46a2-acda-fefdf23f08c2)
   - Check the default Algorithm field to RS256
     ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/cccd9986-49cc-473a-893e-9cc1f6171c5e)

2. Create client Scopes. (bronze, silver, gold)
      ```
      Use Keycloak to define a shared client configuration in an entity called a client scope. A client scope configures protocol mappers and role scope mappings for multiple clients.
      ```
      - Create the Client Scopes, Add three scopes-bronze, silver, and gold
        ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/4fccf2b2-1a1b-4255-94e3-19709bb8aba1)
        ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/22467c36-5067-46d2-973d-7c6dd67195ea)
      - Check the type as Default
      - Check the include in token scope

3. Click the Create button on the Clients screen to add a new client.
      - Create Clients
        ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/f704c8a4-0fab-4e48-a76d-062ce30ad984)
        ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/e7972ef7-4dbe-44c6-9bf2-16c2891ee6eb)
        ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/204769b1-f6b7-480b-9b25-b02116165515)
      - Client Scopes tab, add the bronze scope. Remove all of the other previously assigned client scopes
        ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/0a98427d-05ba-4362-a938-2fe301a07b01)

4. Go to the Mappers tab and create a new mapper.
    - Configure a new mapper  
      ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/590c48b5-b123-495f-9eda-5301731ef9eb)
    - Click Audience  
      ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/d341fd26-4e42-4b0f-8c56-5a3a9194aa02)
    - Add Custom Audience `http://localhost/api/weather-services`  
      ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/553fc370-5d9d-4264-9e04-b6dbbf7ff2f2)

5. Get secret in the client Credentials, and change the client's Service account roles
  - Clients -> Credentials -> copy Client Secret  
    ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/dd7967d9-4e0b-45a4-a07c-939b366c767e)

6. Get a public key in realm settings, and change the pubkey.pem file and keycloak restarted with pubkey.pem file
   ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/a05ca89d-7260-4b0b-85dc-b67d4bb26874)
   ```
   $ docker-compose restart haproxy
   [+] Running 1/1
   - Container haproxy-api-monetization-demo-test-haproxy-1  Started  
   ```

7. Get an Access Token.
      ```
      $ curl --request POST \
      --url 'http://localhost/auth/realms/weather-services/protocol/openid-connect/token' \
      --data 'client_id=acme-corp' \
      --data 'client_secret=7f2587ee-a178-4152-bd91-7b758c807759' \
      --data 'grant_type=client_credentials'
      ```
      ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/64b16fa4-53df-476c-9294-9844bf88688d)

8. Use the access token, and send the request with header
      ```
      $ curl --request GET \
      --url http://localhost/api/weather-services/43213 \
      --header 'authorization: Bearer ACCESS_TOKEN'
      ```
      ![image](https://github.com/pustinia/haproxy-api-monetization-demo-test/assets/17061046/dd92926b-a351-4380-aaf7-cad1112b808b)

## Fixing point
### use_backend warn messages
```
a 'http-request' rule placed after a 'use_backend' rule will still be processed before.  <-- warn
```
- Change the order of use_backend in the haproxy.cfg file

### Keycloak error when startup
```
haproxy-api-monetization-demo-keycloak-1  | Option: '--http-relative-path /auth' 
is not expected to contain whitespace, please remove any unnecessary quoting/escaping
haproxy-api-monetization-demo-keycloak-1  | Possible solutions: 
--http-enabled, --http-host, --http-port, --https-port, --https-cipher-suites, --https-protocols, --https-certificate-file, --https-certificate-key-file, --https-key-store-file, --https-key-store-password, --https-key-store-type, --https-trust-store-file, --https-trust-store-password, --https-trust-store-type, --http-max-queued-requests, --http-pool-max-threads, --http-relative-path, --https-client-auth
```
- move into the environment variable, in the docker-compose.yaml file

### Keycloak configuration for persistence, using h2
```
volumes:
      - ./data/:/opt/keycloak/data/h2/
```
- docker-compose.yaml file
