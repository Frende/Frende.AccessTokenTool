# Frende AccessToken Tool

This bash-script is primarily meant for developers who want to create a test token. It should NOT be used in production.
Compatibility has only been tested on Ubuntu 16.04, but Mac OS X or other OSes with semi-recent openssl should be able to run it.

To get an access token you need your client ID, a private key whose public key has been sent to Frende, and a birth number for which the token is requested.

Example:
`.\get_access_token.sh frendeforsikring .\key.pem 09079200139`