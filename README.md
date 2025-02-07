# transmission-builder
Build statically linked transmission binaries

How to [build](https://blog.yobibyte.com.au/posts/build-statically-linked-transmission-daemon-for-arm64/)

## Proxy Settings

If you are behind a proxy, you need to set the following environment variables before running the build script:

- `HTTP_PROXY`
- `HTTPS_PROXY`
- `http_proxy`
- `https_proxy`

The lower case ones are required by `wget`.
