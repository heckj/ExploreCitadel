A bit of sample code for Joannis' [Citadel](https://github.com/orlandos-nl/Citadel) SSH library for Swift.

This is basically a little functional test loading up a sample ed_25519 key and attempting to connect to a local SSH server running in a docker container.

To check this test locally, run a local SSH server in docker:

```bash
docker run --name openSSH-server -d -p 2222:2222 -e USER_NAME=fred -e PUBLIC_KEY='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvu92Ykn9Yr7jxemV9MVXPK8nchioFkPUs7rC+5Yus9 heckj@Sparrow.local' lscr.io/linuxserver/openssh-server:latest
```

Verifying SSH access on CLI:
- `chmod 600 id_ed25519` // make sure 'permissions' are appropriate for using with SSH
- `ssh fred@127.0.0.1 -p 2222 -i id_ed25519`

To try this locally:
```bash
swift run ExploreCitadel id_ed25519
```

When done, tear down the container:
`docker rm -f openSSH-server`
