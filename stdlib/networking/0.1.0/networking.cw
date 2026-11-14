namespace Networking {
    class Runtime {
        public:
        int64 socketCreate()
        bool socketConnect(int64 fd, String host, int64 port)
        int64 socketSend(int64 fd, buffer data)
        int64 socketSendString(int64 fd, String data)
        buffer socketRecv(int64 fd, int64 maxBytes)
        String socketRecvString(int64 fd, int64 maxBytes)
        void socketClose(int64 fd)
        void socketSetTimeout(int64 fd, int64 milliseconds)
        int64 serverBind(String host, int64 port, int64 backlog)
        int64 serverAccept(int64 fd)
        int64 serverPort(int64 fd)
        bool serverListen(int64 fd, int64 backlog)
    }

    class Socket {
        private:
        int64 _fd
        bool _connected
        String _host
        int64 _port

        public:
        Socket() {
            _fd = Runtime().socketCreate()
            _connected = false
            _host = ""
            _port = 0
        }

        Socket(int64 fd) {
            _fd = fd
            _connected = fd >= 0
            _host = ""
            _port = 0
        }

        bool connect(String host, int64 port) {
            _connected = Runtime().socketConnect(_fd, host, port)
            if (_connected) {
                _host = host
                _port = port
            }
            return(_connected)
        }

        int64 send(buffer data) {
            return(Runtime().socketSend(_fd, data))
        }

        int64 sendString(String data) {
            return(Runtime().socketSendString(_fd, data))
        }

        buffer recv(int64 maxBytes) {
            return(Runtime().socketRecv(_fd, maxBytes))
        }

        String recvString(int64 maxBytes) {
            return(Runtime().socketRecvString(_fd, maxBytes))
        }

        void close() {
            if (_fd >= 0) {
                Runtime().socketClose(_fd)
                _fd = -1
                _connected = false
            }
        }

        bool isConnected() {
            return(_connected)
        }

        void setTimeout(int64 milliseconds) {
            Runtime().socketSetTimeout(_fd, milliseconds)
        }

        int64 getPort() {
            return(_port)
        }

        String getHost() {
            return(_host)
        }
    }

    class ServerSocket {
        private:
        int64 _fd
        int64 _port

        public:
        ServerSocket() {
            _fd = -1
            _port = 0
        }

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

        bool listen(int64 backlog) {
            return(Runtime().serverListen(_fd, backlog))
        }

        Socket accept() {
            return(Socket(Runtime().serverAccept(_fd)))
        }

        void close() {
            if (_fd >= 0) {
                Runtime().socketClose(_fd)
                _fd = -1
                _port = 0
            }
        }

        bool isBound() {
            return(_fd >= 0)
        }

        int64 getPort() {
            return(_port)
        }
    }

    class Url {
        private:
        String _url
        String _scheme
        String _host
        int64 _port
        String _path
        String _query
        String _fragment

        String copy(String text, int64 first, int64 last) {
            if (last <= first) {
                return("")
            }
            return(text[first..last - 1])
        }

        public:
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
                        String portText = copy(authority, bracketEnd + 2, authority.length)
                        if (portText.length > 0) {
                            _port = portText.toInt64()
                        }
                    } else {
                        if (_scheme.equals("http")) {
                            _port = 80
                        } else {
                            if (_scheme.equals("https")) {
                                _port = 443
                            }
                        }
                    }
                } else {
                    _host = authority
                }
            } else {
                int64 colon = authority.find(":")
                if (colon >= 0) {
                    _host = copy(authority, 0, colon)
                    String portText = copy(authority, colon + 1, authority.length)
                    if (portText.length > 0) {
                        _port = portText.toInt64()
                    }
                } else {
                    _host = authority
                    if (_scheme.equals("http")) {
                        _port = 80
                    } else {
                        if (_scheme.equals("https")) {
                            _port = 443
                        }
                    }
                }
            }
        }

        String scheme() {
            return(_scheme)
        }

        String host() {
            return(_host)
        }

        int64 port() {
            return(_port)
        }

        String path() {
            return(_path)
        }

        String query() {
            return(_query)
        }

        String fragment() {
            return(_fragment)
        }

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
