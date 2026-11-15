/*
 * tests/functional/positive/positive_stdlib_networking.cw
 *
 * Checks stdlib networking.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import networking as Networking

start {
    Networking.Socket socket = Networking.Socket()
    print(socket.isConnected() == false)
    print(socket.getPort() == 0)
    print(socket.getHost().length == 0)
    print(socket.connect("127.0.0.1", -1) == false)
    print(socket.send(buffer(0)) == -1)
    print(socket.sendString("hello") == -1)
    print(socket.recv(1) == null)
    print(socket.recvString(1).length == 0)
    socket.setTimeout(100)
    socket.close()

    Networking.ServerSocket server = Networking.ServerSocket()
    print(server.isBound() == false)
    print(server.bind(0))
    print(server.isBound())
    print(server.getPort() > 0)
    print(server.listen(1))
    Networking.Socket client = Networking.Socket()
    print(client.connect("127.0.0.1", server.getPort()))
    print(client.sendString("ping") > 0)
    Networking.Socket accepted = server.accept()
    print(accepted.isConnected())
    print(accepted.recvString(4).equals("ping"))
    client.close()
    accepted.close()
    server.close()
    print(server.isBound() == false)

    Networking.Url url = Networking.Url("https://example.com/path")
    print(url.scheme())
    print(url.host())
    print(url.port())
    print(url.path())
    print(url.query().length == 0)
    print(url.fragment().length == 0)
    print(url.toString())

    Networking.Url detailed = Networking.Url("http://example.com:8080/a/b?x=1#part")
    print(detailed.scheme())
    print(detailed.host())
    print(detailed.port())
    print(detailed.path())
    print(detailed.query())
    print(detailed.fragment())
}
