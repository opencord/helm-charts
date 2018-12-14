# XOS Certificate Generation

To create certificates for use with XOS, you'll need a system with `make` and
the `openssl` cli tool.

Most frequently you'll want to run `make all_certs`, then copy the files:

- `xos-CA.pem`
- `xos-core.pem`
- `xos-core.key`

into the `xos-core/pki` chart directory.
