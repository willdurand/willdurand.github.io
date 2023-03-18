---
layout: post
title: "GitHub Container Registry, Proxy and Synology"
location: Clermont-Fd Area, France
image:
mastodon_id:
---

Last week, I migrated a private application from Heroku to my Synology NAS
(compatible with Docker). Thanks to [GitHub Actions][actions], this application
is built and tested for every commit on the main branch and Pull Requests. In
addition, every time the main branch is updated, a new private "Docker image" is
built and pushed to the [GitHub Container Registry][ghcr].

This article is _not_ about the migration or the CI pipeline but it is important
to know some of the context to better understand the rest of the post.

On the NAS, one may think that running the private application is just a matter
of signing in the GitHub Container Registry, pulling the image and creating a
container. Correct, this works from the command line (over SSH). Having said
that, [Synology DiskStation Manager (DSM)][dsm] – the Operating System powering
my NAS – offers a user interface (UI) to manage Docker images, containers,
networks and registries. I tried to use this UI to add the GitHub Registry but
it failed to load the list of images 😓

![](/images/posts/2023/03/synology-error-registry.webp)
_"Registry returned bad results" said DSM, sigh._
{:.with-caption}

I don't quite like when obvious things don't work... [Synology's docs say both
v1 and v2 registries are supported][kb-registry] and the GitHub Container
Registry [supports "Docker"][docker-registry]. Shortly after, I realized that
the GitHub Container Registry didn't fully implement the [Docker Registry HTTP
API][docker-http-api].

Fortunately, I know [a thing][containers-1] or [two][containers-2] about
containers, registries, etc. so I wrote a [Container Registry Proxy][repo] to
fix GitHub's container registry for _my_ needs[^1]. This proxy exposes two new
API endpoints specified by the [HTTP API v2][docker-http-api] and uses the
[GitHub REST API][rest-packages] to retrieve the necessary data. All the other
calls are transparently forwarded to the upstream GitHub registry.

[^1]: This is important: it works for me™ but that doesn't mean all edge cases are covered. This might explain why GitHub isn't fully compatible with the HTTP API v2 yet.

![](/images/posts/2023/03/container-registry-proxy.webp)
{:.can-invert-image-in-dark-mode}

This proxy only requires a GitHub token with `read:packages` permission. The
application is written in Go and distributed as a [lightweight Docker image
published on the Docker Hub][docker-image]. Installing this proxy on a Synology
NAS should therefore be straightforward.

There are two caveats, though. First, the proxy registry should ideally be a
local registry because Docker allows (insecure) local registries by default.
Second, the DSM UI has some weird validation rules that prevent
`http://127.0.0.1:10000` to be accepted as a "valid URL". That is unfortunate
because this address *is* our local registry... This forces us to edit a
configuration file directly on the NAS using SSH ([instructions on
GitHub][repo]).

![](/images/posts/2023/03/synology-registry-setting.webp)
_The list of (Docker) registries in DSM. Both the Docker Hub and the local
registry are configured. The local registry – named "GitHub Registry (Proxied)"
– is in use._
{:.with-caption}

This proxy works reasonably well so far. I am not sure what the future of this
small project is going to be since it does what I want already. Maybe some other
known registries have similar issues?

![](/images/posts/2023/03/synology-docker-images.webp)
_The list of (Docker) images in DSM. The first image comes from the GitHub
Registry via the local proxy registry. The other two are from the Docker Hub.
The third/last image is the Container Registry Proxy introduced above._
{:.with-caption}

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
