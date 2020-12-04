open Lwt.Syntax

let () =
  Logs.set_level (Some Logs.Debug);
  Logs.set_reporter (Logs.format_reporter ());
  Lwt_main.run
    (let* addresses =
       Lwt_unix.getaddrinfo "localhost" "2379" [ Unix.(AI_FAMILY PF_INET) ]
     in
     let socket = Lwt_unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
     let* () = Lwt_unix.connect socket (List.hd addresses).Unix.ai_addr in
     let null_auth ~host:_ _ = Ok None in
     let config =
       Tls.Config.client ~authenticator:null_auth ~alpn_protocols:[ "h2" ]
         ~ciphers:Tls.Config.Ciphers.http2 ()
     in
     let* tls_client = Tls_lwt.Unix.client_of_fd config socket in
     let error_handler = function
       | `Malformed_response s -> print_endline ("malformed response: " ^ s)
       | `Invalid_response_body_length _res ->
           print_endline "invalid response body length"
       | `Protocol_error (code, s) ->
           print_endline
             ("protocol error: " ^ s ^ " " ^ H2.Error_code.to_string code)
       | `Exn exn -> print_endline (Printexc.to_string exn)
     in
     let+ _connection =
       H2_lwt_unix.Client.TLS.create_connection ~error_handler tls_client
     in
     ())
