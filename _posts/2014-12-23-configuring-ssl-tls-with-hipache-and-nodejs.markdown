---
layout: post
location: Clermont-Fd Area, France
tldr: false
audio: false
title: "Configuring SSL/TLS With Hipache (And Node.js)"
---

_2014-12-26 - most of the patches I have sent to Hipache have already been
merged, making Hipache safer than ever._

Lately, I have been working on configuring a **SSL/TLS layer** for a project. As
you may (or may not) think, it is not only about creating SSL certificates. In
the following article, I am going to describe how to properly configure SSL/TLS
with [Hipache](https://github.com/hipache/hipache), a distributed HTTP(s) and
websocket proxy.
_Disclaimer: even if I am really interested in security, I am not a security
expert._

---

Getting SSL certificates (`key`, `crt`, `pem` files) is a good start, but it is
definitely not enough. With the recent security issues such as
[POODLE](https://www.openssl.org/~bodo/ssl-poodle.pdf),
[Heartbleed](http://heartbleed.com/) and so on, configuring this layer requires
more attention than ever.
**Want to check your current configuration?** [Qualys SSL Server
Test](https://www.ssllabs.com/ssltest/index.html) to the rescue! First time I
tried, I got a C grade...

## Secure Protocols

There are five secure procotols, part of the SSL/TLS family, but most of them
should **not** be used. **SSLv2 and SSLv3 are insecure**, do not used them! Yes,
[disable SSLv3](https://disablessl3.com/) now! TLSv1 is also insecure, whereas
TLSv1.1 and TLSv1.2 are not, or at least are without known security issues
(yet).

**Hipache** is a [Node.js](http://nodejs.org/) application. The good thing about
this platform is that people seem to care about security, and since `v0.10`
[SSLv2 and SSLv3 are disabled by
default](https://github.com/joyent/node/pull/8551). Hipache relies on [Node's
`https.createServer()`](http://nodejs.org/api/https.html#https_https_createserver_options_requestlistener)
method, and a `secureProtocol` option is available to specify the secure
protocol to use. Its default value is `SSLv23_method` and is about negotiating a
protocol from the highest level down to whatever the client supports. Yes, worst
name ever! Another option called `secureOptions` is available and can be used to
explicitly disable the use of SSLv3 and SSLv2. Since `v0.10.33`, it is disabled
by default though. Such a configuration [protects against the POODLE attack in
Node.js](https://gist.github.com/3rd-Eden/715522f6950044da45d8).

Unfortunately, I could not get it work as is using Hipache, so I ended up
patching this load balancer to [support the `secureOptions`
parameter](https://github.com/hipache/hipache/pull/178). This patch provides the
exact same configuration as described above. (Note: I maintain a [Docker image
with my Hipache tweaks](https://registry.hub.docker.com/u/willdurand/hipache/),
running in production).

Securing secure protocols: _done!_

## Secure Cipher Suites

Next step is about defining **how secure communication takes place**. That is
important for enabling [Forward
Secrecy](https://community.qualys.com/blogs/securitylabs/2013/06/25/ssl-labs-deploying-forward-secrecy),
which means that for an attacker it wil not be possible to decrypt your previous
data exchanges if they get access to your private key, and to protect against
the [BEAST
attack](https://community.qualys.com/blogs/securitylabs/2011/10/17/mitigating-the-beast-attack-on-tls)
(which is **not impractical**).

After having read how to [configure Apache, Nginx, and OpenSSL for Forward
Secrecy](https://community.qualys.com/blogs/securitylabs/2013/08/05/configuring-apache-nginx-and-openssl-for-forward-secrecy),
I decided to use the following **cipher suite** (which [disables
RC4](https://community.qualys.com/blogs/securitylabs/2013/03/19/rc4-in-tls-is-broken-now-what)
by the way):

    DH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4

So far so good. Not exactly, because stable Node.js version (`v0.10.34`) does
not support **Elliptic Curve Diffie-Hellman** (ECDH) ciphers yet, even if a
[patch](https://github.com/joyent/node/commit/bb909ad64285194b3d02322e3fb4b17ff5192c50)
has been merged. Node `v0.11.14` (unstable) contains this patch, therefore it is
the **version to use if one wants to deploy Forward Secrecy**. It is important
to support ECDHE because it is **supported by all major modern browsers**
whereas Diffie-Hellman (DHE) does not.

Hipache exposes a `ciphers` option but does not provide the `honorCipherOrder`
one, which is [recommended to mitigate BEAST attacks in Node.js
documentation](http://nodejs.org/api/tls.html). Then again, there is a
[pull-request for that](https://github.com/hipache/hipache/pull/177)!

My Hipache `https` configuration now looks like this:

```json
"https": {
    "port": 443,
    "bind": [ "0.0.0.0" ],
    "key": "/etc/ssl/ssl.key",
    "cert": "/etc/ssl/ssl.crt",
    "ciphers": "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4",
    "honorCipherOrder": true
}
```

Doing all of this allowed me to get a **A** grade with Qualys' tool, which is
quite good. In the next section, I am going to describe a few more security
points that everyone should know and check.

## What's Next?

### Client-Initiated Renegotiation

In TLS, **renegotiation allows parties to stop exchanging data** in order to
renegotiate how the communication is secured. The protocol lets the client
renegotiate certain aspects of the TLS session. Thing is, **client-initiated
renegotiation** may lead to [Denial of
Service](https://community.qualys.com/blogs/securitylabs/2011/10/31/tls-renegotiation-and-denial-of-service-attacks)
(DoS), and therefore **must be disabled**.

In Node.js, [renegotiations are limited to three times every 10
minutes](http://nodejs.org/api/tls.html#tls_client_initiated_renegotiation_attack_mitigation).
While these default values seems legit to me, Qualys' tool [reports no
protection against this attack](https://community.qualys.com/thread/14077).

### TLS Compression

The [CRIME
attack](https://community.qualys.com/blogs/securitylabs/2012/09/14/crime-information-leakage-attack-against-ssltls)
exploits **a flaw with data compression**. When used to recover the content of
secret authentication cookies, it allows an attacker to perform session
hijacking on an authenticated web session, allowing the launching of further
attacks (says [Wikipedia](http://en.wikipedia.org/wiki/CRIME)).

In order to protect against this attack, Node.js [disables all
compression](https://github.com/joyent/node/issues/1523).

## Downgrade Attack Prevention

A **Man-In-The-Middle** (MITM) can disrupt an SSL handshake and cause the client
and server to select an earlier SSL protocol version. This is known as an SSL
downgrade attack. **Disabling SSLv3 protects against this attack**.

It is worth mentioning that Google has written an
[RFC](https://tools.ietf.org/html/draft-ietf-tls-downgrade-scsv-00) to propose
an extension to SSL/TLS named `TLS_FALLBACK_SCSV` that seeks to prevent protocol
downgrade attacks. The latest OpenSSL `1.0.1j` version support
`TLS_FALLBACK_SCSV` which Node `v0.11.14` does not support yet (`1.0.1i` by
now).

### OpenSSL

Reminder: [make sure to use a secure version of
OpenSSL](http://serverfault.com/questions/587324/heartbleed-how-to-reliably-and-portably-check-the-openssl-version).

### HTTP Headers

Enable [HTTP Strict Transport
Security](https://www.owasp.org/index.php/HTTP_Strict_Transport_Security) (HSTS)
in your web server (Nginx here) configuration:

    # Enable HSTS
    add_header Strict-Transport-Security max-age=63072000;

## Resources

* [SSL/TLS Deployment Best
  Practices](https://www.ssllabs.com/downloads/SSL_TLS_Deployment_Best_Practices.pdf)
* [Qualys' Blog - Security Labs](https://community.qualys.com/blogs/securitylabs)
* [Mozilla Security/Server Side
  TLS](https://wiki.mozilla.org/Security/Server_Side_TLS)
