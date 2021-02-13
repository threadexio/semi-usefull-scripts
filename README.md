## Some quick scripts to assist you in your everyday activities

### mount.jffs2 - mounts jffs2 filesystems
```
Usage: mount.jffs2 [jffs2 file] [mount path]
```

### mount.luks - mounts encrypted volumes using the luks filesystem
```
Usage:
 mount.luks m [device path] [device name] [mountpoint]
 mount.luks u [device name] [mountpoint]
 mount.luks l

Options:
 m - Mount mode
 u - Unmount mode
 l - List devices

Examples:
 mount.luks m /dev/xda S3cr3t /mnt
 mount.luks u S3cr3t /mnt
 mount.luks l
 ```

### gencert.sh - generates self-signed certificates & certificate signing requests
```
Usage:
Self-Signed Cert: $0 ssc [digest] [days] [RSA bits] [crt out] [key out]
Cert Signing Request: $0 csr [RSA bits] [csr out] [key out]

Examples:
 gencert.sh ssc sha512 365 4096 cert.crt private.key
 gencert.sh csr 4096 request.csr private.key
 ```

 ### netns.sh - creates a network namespace with access to the network of the given interface

 ```
 Usage: ./netns.sh [iface]

 Examples:
  ./netns.sh wlan0 - Creates a namespace that can access wlan0's network (can also be used to access the internet)

Attention:
  If you run OpenVPN in the namespace your host's /etc/resolv.conf will be overwritten, thus disabling DNS resolving from the host
 ```
