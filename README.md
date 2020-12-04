# Ocaml H2 TLS Test

To test with etcd:

```sh
make
```

## Requirements

This uses the newest version of ocaml-tls (0.12.7), a [patched gluten](https://github.com/anmonteiro/gluten/pull/16) as well as a [patched h2](https://github.com/jeffa5/ocaml-h2/tree/add-http2-ciphers).

```sh
opam pin add --dev-repo tls
opam pin add 'https://github.com/jeffa5/gluten.git#add-ciphers-option' --no-action
opam pin add 'https://github.com/jeffa5/ocaml-h2.git#add-http2-ciphers' --no-action
opam install h2 h2-lwt-unix
```
