/*
 * stdlib/networking/0.1.0/networking.cw — networking package implementation.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Networking {

    /*
     * Runtime is a class in this standard-library package.
     *
     * Its methods include socketCreate, socketConnect, socketSend,
     * socketSendString, socketRecv, socketRecvString, and 6 more.
     */
    class Runtime {
        public:
        /*
         * Handles socket create for this Runtime by calling the native
         * function cwhip_net_socket_create.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 socketCreate()

        /*
         * Handles socket connect for this Runtime by calling the native
         * function cwhip_net_socket_connect.
         *
         * Parameters:
         *   fd — int64 input value.
         *   host — String host.
         *   port — int64 port.
         *
         * Returns bool.
         */
        bool socketConnect(int64 fd, String host, int64 port)

        /*
         * Handles socket send for this Runtime by calling the native function
         * cwhip_net_socket_send.
         *
         * Parameters:
         *   fd — int64 input value.
         *   data — buffer data.
         *
         * Returns int64.
         */
        int64 socketSend(int64 fd, buffer data)

        /*
         * Handles socket send string for this Runtime by calling the native
         * function cwhip_net_socket_send_string.
         *
         * Parameters:
         *   fd — int64 input value.
         *   data — String data.
         *
         * Returns int64.
         */
        int64 socketSendString(int64 fd, String data)

        /*
         * Handles socket recv for this Runtime by calling the native function
         * cwhip_net_socket_recv.
         *
         * Parameters:
         *   fd — int64 input value.
         *   maxBytes — int64 max bytes.
         *
         * Returns buffer.
         */
        buffer socketRecv(int64 fd, int64 maxBytes)

        /*
         * Handles socket recv string for this Runtime by calling the native
         * function cwhip_net_socket_recv_string.
         *
         * Parameters:
         *   fd — int64 input value.
         *   maxBytes — int64 max bytes.
         *
         * Returns String.
         */
        String socketRecvString(int64 fd, int64 maxBytes)

        /*
         * Handles socket close for this Runtime by calling the native function
         * cwhip_net_socket_close.
         *
         * Parameters:
         *   fd — int64 input value.
         *
         * Does not return a value.
         */
        void socketClose(int64 fd)

        /*
         * Handles socket set timeout for this Runtime by calling the native
         * function cwhip_net_socket_set_timeout.
         *
         * Parameters:
         *   fd — int64 input value.
         *   milliseconds — int64 milliseconds.
         *
         * Does not return a value.
         */
        void socketSetTimeout(int64 fd, int64 milliseconds)

        /*
         * Handles server bind for this Runtime by calling the native function
         * cwhip_net_server_bind.
         *
         * Parameters:
         *   host — String host.
         *   port — int64 port.
         *   backlog — int64 backlog.
         *
         * Returns int64.
         */
        int64 serverBind(String host, int64 port, int64 backlog)

        /*
         * Handles server accept for this Runtime by calling the native
         * function cwhip_net_server_accept.
         *
         * Parameters:
         *   fd — int64 input value.
         *
         * Returns int64.
         */
        int64 serverAccept(int64 fd)

        /*
         * Handles server port for this Runtime by calling the native function
         * cwhip_net_server_port.
         *
         * Parameters:
         *   fd — int64 input value.
         *
         * Returns int64.
         */
        int64 serverPort(int64 fd)

        /*
         * Handles server listen for this Runtime by calling the native
         * function cwhip_net_server_listen.
         *
         * Parameters:
         *   fd — int64 input value.
         *   backlog — int64 backlog.
         *
         * Returns bool.
         */
        bool serverListen(int64 fd, int64 backlog)
    }

    /*
     * Socket is a class in this standard-library package.
     *
     * Its methods include constructor, connect, send, sendString, recv,
     * recvString, and 5 more.
     */
    class Socket {
        private:
        int64 _fd
        bool _connected
        String _host
        int64 _port

        public:
        /*
         * Constructs a Socket and stores _fd, _connected, _host, _port.
         *
         * Takes no parameters.
         *
         * Returns the constructed Socket.
         */
        Socket() {
            _fd = Runtime().socketCreate()
            _connected = false
            _host = ""
            _port = 0
        }

        /*
         * Constructs a Socket and stores _fd, _connected, _host, _port.
         *
         * Parameters:
         *   fd — int64 input value.
         *
         * Returns the constructed Socket.
         */
        Socket(int64 fd) {
            _fd = fd
            _connected = fd >= 0
            _host = ""
            _port = 0
        }

        /*
         * Connects the Socket state.
         *
         * Parameters:
         *   host — String host.
         *   port — int64 port.
         *
         * Returns bool.
         */
        bool connect(String host, int64 port) {
            _connected = Runtime().socketConnect(_fd, host, port)
            if (_connected) {
                _host = host
                _port = port
            }
            return(_connected)
        }

        /*
         * Returns Runtime().socketSend(_fd, data).
         *
         * Parameters:
         *   data — buffer data.
         *
         * Returns int64.
         */
        int64 send(buffer data) {
            return(Runtime().socketSend(_fd, data))
        }

        /*
         * Returns Runtime().socketSendString(_fd, data).
         *
         * Parameters:
         *   data — String data.
         *
         * Returns int64.
         */
        int64 sendString(String data) {
            return(Runtime().socketSendString(_fd, data))
        }

        /*
         * Returns Runtime().socketRecv(_fd, maxBytes).
         *
         * Parameters:
         *   maxBytes — int64 max bytes.
         *
         * Returns buffer.
         */
        buffer recv(int64 maxBytes) {
            return(Runtime().socketRecv(_fd, maxBytes))
        }

        /*
         * Returns Runtime().socketRecvString(_fd, maxBytes).
         *
         * Parameters:
         *   maxBytes — int64 max bytes.
         *
         * Returns String.
         */
        String recvString(int64 maxBytes) {
            return(Runtime().socketRecvString(_fd, maxBytes))
        }

        /*
         * Closes the Socket state.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void close() {
            if (_fd >= 0) {
                Runtime().socketClose(_fd)
                _fd = -1
                _connected = false
            }
        }

        /*
         * Returns the stored _connected.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isConnected() {
            return(_connected)
        }

        /*
         * Sets timeout for this Socket.
         *
         * Parameters:
         *   milliseconds — int64 milliseconds.
         *
         * Does not return a value.
         */
        void setTimeout(int64 milliseconds) {
            Runtime().socketSetTimeout(_fd, milliseconds)
        }

        /*
         * Returns the stored _port.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 getPort() {
            return(_port)
        }

        /*
         * Returns the stored _host.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String getHost() {
            return(_host)
        }
    }

    /*
     * ServerSocket is a class in this standard-library package.
     *
     * Its methods include constructor, bind, bindAddress, listen, accept,
     * close, and 2 more.
     */
    class ServerSocket {
        private:
        int64 _fd
        int64 _port

        public:
        /*
         * Constructs a ServerSocket and stores _fd, _port.
         *
         * Takes no parameters.
         *
         * Returns the constructed ServerSocket.
         */
        ServerSocket() {
            _fd = -1
            _port = 0
        }

        /*
         * Binds the ServerSocket state.
         *
         * Parameters:
         *   port — int64 port.
         *
         * Returns bool.
         */
        bool bind(int64 port) {
            if (_fd >= 0) {
                Runtime().socketClose(_fd)
            }
            _fd = Runtime().serverBind("", port, 16)
            if (_fd >= 0) {
                _port = Runtime().serverPort(_fd)
            }
            return(_fd >= 0)
        }

        /*
         * Binds address for this ServerSocket.
         *
         * Parameters:
         *   host — String host.
         *   port — int64 port.
         *
         * Returns bool.
         */
        bool bindAddress(String host, int64 port) {
            if (_fd >= 0) {
                Runtime().socketClose(_fd)
            }
            _fd = Runtime().serverBind(host, port, 16)
            if (_fd >= 0) {
                _port = Runtime().serverPort(_fd)
            }
            return(_fd >= 0)
        }

        /*
         * Returns Runtime().serverListen(_fd, backlog).
         *
         * Parameters:
         *   backlog — int64 backlog.
         *
         * Returns bool.
         */
        bool listen(int64 backlog) {
            return(Runtime().serverListen(_fd, backlog))
        }

        /*
         * Returns Socket(Runtime().serverAccept(_fd)).
         *
         * Takes no parameters.
         *
         * Returns Socket.
         */
        Socket accept() {
            return(Socket(Runtime().serverAccept(_fd)))
        }

        /*
         * Closes the ServerSocket state.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void close() {
            if (_fd >= 0) {
                Runtime().socketClose(_fd)
                _fd = -1
                _port = 0
            }
        }

        /*
         * Returns _fd >= 0.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isBound() {
            return(_fd >= 0)
        }

        /*
         * Returns the stored _port.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 getPort() {
            return(_port)
        }
    }

    /*
     * Url is a class in this standard-library package.
     *
     * Its methods include copy, constructor, scheme, host, port, path, and 3
     * more.
     */
    class Url {
        private:
        String _url
        String _scheme
        String _host
        int64 _port
        String _path
        String _query
        String _fragment

        /*
         * Handles copy for this Url.
         *
         * Parameters:
         *   text — String text.
         *   first — int64 first.
         *   last — int64 last.
         *
         * Returns String.
         */
        String copy(String text, int64 first, int64 last) {
            if (last <= first) {
                return("")
            }
            return(text[first..last - 1])
        }

        public:
        /*
         * Constructs a Url and stores _url, _scheme, _host, _port.
         *
         * Parameters:
         *   urlString — String url string.
         *
         * Returns the constructed Url.
         */
        Url(String urlString) {
            _url = urlString
            _scheme = ""
            _host = ""
            _port = 0
            _path = "/"
            _query = ""
            _fragment = ""

            String rest = urlString
            int64 schemeEnd = rest.find("://")
            if (schemeEnd >= 0) {
                _scheme = copy(rest, 0, schemeEnd)
                rest = copy(rest, schemeEnd + 3, rest.length)
            }

            int64 fragmentStart = rest.find("#")
            if (fragmentStart >= 0) {
                _fragment = copy(rest, fragmentStart + 1, rest.length)
                rest = copy(rest, 0, fragmentStart)
            }
            int64 queryStart = rest.find("?")
            if (queryStart >= 0) {
                _query = copy(rest, queryStart + 1, rest.length)
                rest = copy(rest, 0, queryStart)
            }

            int64 pathStart = rest.find("/")
            String authority = rest
            if (pathStart >= 0) {
                authority = copy(rest, 0, pathStart)
                _path = copy(rest, pathStart, rest.length)
            }

            int64 atSign = authority.find("@")
            if (atSign >= 0) {
                authority = copy(authority, atSign + 1, authority.length)
            }

            if (authority.startsWith("[")) {

                int64 bracketEnd = authority.find("]")
                if (bracketEnd >= 0) {
                    _host = copy(authority, 1, bracketEnd)

                    if (bracketEnd + 1 < authority.length) {
                        String portText = copy(
                                authority,
                                bracketEnd + 2,
                                authority.length)
                        if (portText.length > 0) {
                            _port = portText.toInt64()
                        }
                    }
                    else {
                        if (_scheme.equals("http")) {
                            _port = 80
                        }
                        else {
                            if (_scheme.equals("https")) {
                                _port = 443
                            }
                        }
                    }

                }
                else {
                    _host = authority
                }

            }
            else {

                int64 colon = authority.find(":")
                if (colon >= 0) {
                    _host = copy(authority, 0, colon)
                    String portText = copy(
                            authority,
                            colon + 1,
                            authority.length)
                    if (portText.length > 0) {
                        _port = portText.toInt64()
                    }
                }
                else {
                    _host = authority
                    if (_scheme.equals("http")) {
                        _port = 80
                    }
                    else {
                        if (_scheme.equals("https")) {
                            _port = 443
                        }
                    }
                }

            }

        }

        /*
         * Returns the stored _scheme.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String scheme() {
            return(_scheme)
        }

        /*
         * Returns the stored _host.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String host() {
            return(_host)
        }

        /*
         * Returns the stored _port.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 port() {
            return(_port)
        }

        /*
         * Returns the stored _path.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String path() {
            return(_path)
        }

        /*
         * Returns the stored _query.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String query() {
            return(_query)
        }

        /*
         * Returns the stored _fragment.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String fragment() {
            return(_fragment)
        }

        /*
         * Returns the stored _url.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String toString() {
            return(_url)
        }
    }

    int64 Runtime.socketCreate() from "cwhip_net_socket_create"
    bool Runtime.socketConnect(int64 fd, String host, int64 port) from "cwhip_net_socket_connect"
    int64 Runtime.socketSend(int64 fd, buffer data) from "cwhip_net_socket_send"
    int64 Runtime.socketSendString(int64 fd, String data) from "cwhip_net_socket_send_string"
    buffer Runtime.socketRecv(int64 fd, int64 maxBytes) from "cwhip_net_socket_recv"
    String Runtime.socketRecvString(int64 fd, int64 maxBytes) from "cwhip_net_socket_recv_string"
    void Runtime.socketClose(int64 fd) from "cwhip_net_socket_close"
    void Runtime.socketSetTimeout(int64 fd, int64 milliseconds) from "cwhip_net_socket_set_timeout"

    int64 Runtime.serverBind(String host, int64 port, int64 backlog) from "cwhip_net_server_bind"
    int64 Runtime.serverAccept(int64 fd) from "cwhip_net_server_accept"
    int64 Runtime.serverPort(int64 fd) from "cwhip_net_server_port"
    bool Runtime.serverListen(int64 fd, int64 backlog) from "cwhip_net_server_listen"
}
