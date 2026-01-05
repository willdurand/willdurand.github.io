---
layout: post
title: "GitHub Container Registry, Proxy and Synology"
location: Clermont-Fd Area, France
image: /images/posts/2023/03/synology-socia.webp
mastodon_id: 110049046797980380
credits: Photo used on social media by [Claudio Schwarz](https://unsplash.com/@purzlbaum).
tags: [side projects]
---

Last week, I migrated a private application from Heroku to my Synology NAS
(compatible with Docker). Thanks to [GitHub Actions][actions], every time the
main branch of the project is updated, a new private "Docker image" is built and
pushed to the [GitHub Container Registry][ghcr].

On the NAS, one may think that running this private ("dockerized") application
is just a matter of logging in to the GitHub Container Registry, pulling the
image and creating a container. Correct, this works from the command line (over
SSH).

Having said that, [Synology DiskStation Manager (DSM)][dsm] – the Operating
System powering my NAS – offers a user interface (UI) to manage Docker images,
containers, networks and registries. I tried to use this UI to add the GitHub
Registry but it failed to load the list of images 😓

![](/images/posts/2023/03/synology-error-registry.webp)
_"Registry returned bad results" said DSM, sigh._
{:.with-caption}

I don't quite like when obvious things don't work... [Synology's docs say both
v1 and v2 registries are supported][kb-registry] and the GitHub Container
Registry [supports Docker][docker-registry]. Shortly after, I realized that the
GitHub Container Registry didn't fully implement the [Docker Registry HTTP
API][docker-http-api].

Fortunately, I know [a thing][containers-1] or [two][containers-2] about
containers, registries, etc. so I wrote a [Container Registry Proxy][repo] to
fix GitHub's container registry for _my_ use case[^1]. This proxy exposes two
new API endpoints specified by the [HTTP API v2][docker-http-api] specification
and it uses the [GitHub REST API][rest-packages] to retrieve the necessary data.
All the other calls are transparently forwarded to the upstream GitHub registry.

[^1]: Important: this works for me™ but that doesn't mean all edge cases are handled. This might explain why GitHub isn't fully compatible with the HTTP API v2 specification yet. I don't know.

![](/images/posts/2023/03/container-registry-proxy.webp)
{:.can-invert-image-in-dark-mode}

This proxy only requires a GitHub token with the `read:packages` permission.  It
is written in Go and distributed as a [lightweight Docker image published on the
Docker Hub][docker-image]. Installing this proxy on a Synology NAS should
therefore be straightforward since the Docker Hub registry is configured by
default.

There are two caveats with this overall approach, though. First, the proxy
registry should ideally be a local registry because Docker allows (insecure)
local registries by default. Second, the DSM UI has some weird input validation
rules that prevent `http://127.0.0.1:10000` to be accepted as a "valid URL".
That is unfortunate because this address *is* our local registry... We must edit
a configuration file directly on the NAS using SSH ([more information about that
on GitHub][repo]).

Once configured properly, this proxy works reasonably well.

![](/images/posts/2023/03/synology-registry-setting.webp)
_The list of (Docker) registries in DSM. Both the Docker Hub and the local
registry are configured. The local registry – named "GitHub Registry (Proxied)"
– is in use._
{:.with-caption}

![](/images/posts/2023/03/synology-docker-images.webp)
_The list of (Docker) images in DSM. The first image comes from the GitHub
Registry via the local proxy registry. The other two are from the Docker Hub.
The third/last image is the Container Registry Proxy introduced above._
{:.with-caption}

I am not sure what the future of this small project is going to be since it does
what I want already. Maybe some other known registries have similar issues?  Or
would there be any value in having that kind of proxy for other purposes, e.g.,
statistics, monitoring, etc.?

[actions]: https://docs.github.com/en/actions
[containers-1]: {% post_url 2022-06-21-deep-dive-into-containers %}
[containers-2]: {% post_url 2022-07-11-containers-and-micro-virtual-machines %}
[docker-http-api]: https://docs.docker.com/registry/spec/api/
[docker-image]: https://hub.docker.com/r/willdurand/container-registry-proxy
[docker-registry]: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-docker-registry
[dsm]: https://www.synology.com/en-global/dsm
[ghcr]: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
[kb-registry]: https://kb.synology.com/en-us/DSM/help/Docker/Docker?version=6
[repo]: https://github.com/willdurand/container-registry-proxy
[rest-packages]: https://docs.github.com/en/rest/packages
