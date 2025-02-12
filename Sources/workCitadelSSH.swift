import ArgumentParser
import Foundation
import Citadel
import CryptoKit

// To check this test locally, run a local SSH server in docker:
// docker run --name openSSH-server -d -p 2222:2222 -e USER_NAME=fred -e PUBLIC_KEY='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvu92Ykn9Yr7jxemV9MVXPK8nchioFkPUs7rC+5Yus9 heckj@Sparrow.local' lscr.io/linuxserver/openssh-server:latest
//
// Verifying SSH access on CLI:
//   `chmod 600 id_ed25519` // make sure permissions are secure
//   `ssh fred@127.0.0.1 -p 2222 -i id_ed25519`
//
// To try this locally:
//   `swift run ExploreCitadel id_ed25519`
//
// When done, tear down the container:
//   `docker rm -f openSSH-server`

@main
struct workCitadelSSH: AsyncParsableCommand {
    @Argument(help: "The path to the private SSH key to copy into bastion") var privateKeyLocation: String

    mutating func run() async throws {
        
        let hostname = "127.0.0.1"
        let port: Int = 2222
        let username: String = "fred"
        
        let keyName = URL(fileURLWithPath: privateKeyLocation).lastPathComponent
        
        let urlForData = URL(fileURLWithPath: privateKeyLocation)
        let dataFromURL = try Data(contentsOf: urlForData)  // 411 bytes
        let key: Curve25519.Signing.PrivateKey = try Curve25519.Signing.PrivateKey(sshEd25519: dataFromURL)

        print("Connecting to \(hostname):\(port) as \(username) with key \(keyName)")
        
        let client = try await SSHClient.connect(
            host: hostname,
            authenticationMethod: .ed25519(username: username, privateKey: key),
            hostKeyValidator: .acceptAnything(),
            // ^ Please use another validator if at all possible, this is insecure
            reconnect: .never
        )

        var stdoutData: Data = Data()
        var stderrData: Data = Data()

        do {
            let streams = try await client.executeCommandStream("uname", inShell: true)

            for try await event in streams {
                switch event {
                case .stdout(let stdout):
                    stdoutData.append(Data(buffer: stdout))
                case .stderr(let stderr):
                    stderrData.append(Data(buffer: stderr))
                }
            }
            // Citadel API appears to provide a return code on failure, but not on success -
            // and through the process of throwing an exception while reading the above streams.

            print("Command STDOUT:")
            print(String(data: stdoutData, encoding: .utf8) ?? " - No output -")
            print("Command STDERR:")
            print(String(data: stderrData, encoding: .utf8) ?? " - No output -")
        } catch let error as SSHClient.CommandFailed {
            print("Command failed with exit code \(error.exitCode)")
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
}
