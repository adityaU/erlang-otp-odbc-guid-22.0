%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2007-2018. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%
%%

%%
%%----------------------------------------------------------------------
%% Purpose: TODO
%%----------------------------------------------------------------------

%% RFC 8446
%% A.1.  Client
%%
%%                               START <----+
%%                Send ClientHello |        | Recv HelloRetryRequest
%%           [K_send = early data] |        |
%%                                 v        |
%%            /                 WAIT_SH ----+
%%            |                    | Recv ServerHello
%%            |                    | K_recv = handshake
%%        Can |                    V
%%       send |                 WAIT_EE
%%      early |                    | Recv EncryptedExtensions
%%       data |           +--------+--------+
%%            |     Using |                 | Using certificate
%%            |       PSK |                 v
%%            |           |            WAIT_CERT_CR
%%            |           |        Recv |       | Recv CertificateRequest
%%            |           | Certificate |       v
%%            |           |             |    WAIT_CERT
%%            |           |             |       | Recv Certificate
%%            |           |             v       v
%%            |           |              WAIT_CV
%%            |           |                 | Recv CertificateVerify
%%            |           +> WAIT_FINISHED <+
%%            |                  | Recv Finished
%%            \                  | [Send EndOfEarlyData]
%%                               | K_send = handshake
%%                               | [Send Certificate [+ CertificateVerify]]
%%     Can send                  | Send Finished
%%     app data   -->            | K_send = K_recv = application
%%     after here                v
%%                           CONNECTED
%%
%% A.2.  Server
%%
%%                               START <-----+
%%                Recv ClientHello |         | Send HelloRetryRequest
%%                                 v         |
%%                              RECVD_CH ----+
%%                                 | Select parameters
%%                                 v
%%                              NEGOTIATED
%%                                 | Send ServerHello
%%                                 | K_send = handshake
%%                                 | Send EncryptedExtensions
%%                                 | [Send CertificateRequest]
%%  Can send                       | [Send Certificate + CertificateVerify]
%%  app data                       | Send Finished
%%  after   -->                    | K_send = application
%%  here                  +--------+--------+
%%               No 0-RTT |                 | 0-RTT
%%                        |                 |
%%    K_recv = handshake  |                 | K_recv = early data
%%  [Skip decrypt errors] |    +------> WAIT_EOED -+
%%                        |    |       Recv |      | Recv EndOfEarlyData
%%                        |    | early data |      | K_recv = handshake
%%                        |    +------------+      |
%%                        |                        |
%%                        +> WAIT_FLIGHT2 <--------+
%%                                 |
%%                        +--------+--------+
%%                No auth |                 | Client auth
%%                        |                 |
%%                        |                 v
%%                        |             WAIT_CERT
%%                        |        Recv |       | Recv Certificate
%%                        |       empty |       v
%%                        | Certificate |    WAIT_CV
%%                        |             |       | Recv
%%                        |             v       | CertificateVerify
%%                        +-> WAIT_FINISHED <---+
%%                                 | Recv Finished
%%                                 | K_recv = application
%%                                 v
%%                             CONNECTED

-module(tls_connection_1_3).

-include("ssl_alert.hrl").
-include("ssl_connection.hrl").
-include("tls_handshake.hrl").
-include("tls_handshake_1_3.hrl").

%% gen_statem helper functions
-export([start/4,
         negotiated/4,
         wait_cert/4,
         wait_cv/4,
         wait_finished/4
        ]).


start(internal, #change_cipher_spec{}, State0, _Module) ->
    {Record, State} = tls_connection:next_record(State0),
    tls_connection:next_event(?FUNCTION_NAME, Record, State);
start(internal, #client_hello{} = Hello, State0, _Module) ->
    case tls_handshake_1_3:do_start(Hello, State0) of
        #alert{} = Alert ->
            ssl_connection:handle_own_alert(Alert, {3,4}, start, State0);
        {State, start} ->
            {next_state, start, State, []};
        {State, negotiated} ->
            {next_state, negotiated, State, [{next_event, internal, start_handshake}]}
    end;
start(Type, Msg, State, Connection) ->
    ssl_connection:handle_common_event(Type, Msg, ?FUNCTION_NAME, State, Connection).


negotiated(internal, #change_cipher_spec{}, State0, _Module) ->
    {Record, State} = tls_connection:next_record(State0),
    tls_connection:next_event(?FUNCTION_NAME, Record, State);
negotiated(internal, Message, State0, _Module) ->
    case tls_handshake_1_3:do_negotiated(Message, State0) of
        #alert{} = Alert ->
            ssl_connection:handle_own_alert(Alert, {3,4}, negotiated, State0);
        {State, NextState} ->
            {next_state, NextState, State, []}
    end.


wait_cert(internal, #change_cipher_spec{}, State0, _Module) ->
    {Record, State} = tls_connection:next_record(State0),
    tls_connection:next_event(?FUNCTION_NAME, Record, State);
wait_cert(internal,
          #certificate_1_3{} = Certificate, State0, _Module) ->
    case tls_handshake_1_3:do_wait_cert(Certificate, State0) of
        {#alert{} = Alert, State} ->
            ssl_connection:handle_own_alert(Alert, {3,4}, wait_cert, State);
        {State1, NextState} ->
            {Record, State} = tls_connection:next_record(State1),
            tls_connection:next_event(NextState, Record, State)
    end;
wait_cert(Type, Msg, State, Connection) ->
    ssl_connection:handle_common_event(Type, Msg, ?FUNCTION_NAME, State, Connection).


wait_cv(internal, #change_cipher_spec{}, State0, _Module) ->
    {Record, State} = tls_connection:next_record(State0),
    tls_connection:next_event(?FUNCTION_NAME, Record, State);
wait_cv(internal,
          #certificate_verify_1_3{} = CertificateVerify, State0, _Module) ->
    case tls_handshake_1_3:do_wait_cv(CertificateVerify, State0) of
        {#alert{} = Alert, State} ->
            ssl_connection:handle_own_alert(Alert, {3,4}, wait_cv, State);
        {State1, NextState} ->
            {Record, State} = tls_connection:next_record(State1),
            tls_connection:next_event(NextState, Record, State)
    end;
wait_cv(Type, Msg, State, Connection) ->
    ssl_connection:handle_common_event(Type, Msg, ?FUNCTION_NAME, State, Connection).


wait_finished(internal, #change_cipher_spec{}, State0, _Module) ->
    {Record, State} = tls_connection:next_record(State0),
    tls_connection:next_event(?FUNCTION_NAME, Record, State);
wait_finished(internal,
             #finished{} = Finished, State0, Module) ->
    case tls_handshake_1_3:do_wait_finished(Finished, State0) of
        #alert{} = Alert ->
            ssl_connection:handle_own_alert(Alert, {3,4}, finished, State0);
        State1 ->
            {Record, State} = ssl_connection:prepare_connection(State1, Module),
            tls_connection:next_event(connection, Record, State)
    end;
wait_finished(Type, Msg, State, Connection) ->
    ssl_connection:handle_common_event(Type, Msg, ?FUNCTION_NAME, State, Connection).
