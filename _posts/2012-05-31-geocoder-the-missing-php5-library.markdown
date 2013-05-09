---
layout: post
title: "Geocoder: The Missing PHP5 Library"
location: Zürich, Switzerland
tags: [ PHP ]
---

Seven months ago, I released [Geocoder](https://github.com/willdurand/Geocoder),
a PHP 5.3 library to ease geocoding manipulations. More and more applications
have to deal with geolocation, and even if HTML5 provides a [Geolocation
API](http://www.w3.org/TR/geolocation-API/), a server side library is
always useful. Today this library has more than 230 watchers on GitHub, and it's
time to introduce it here.

The library is standalone, and split in two parts: `HttpAdapters` which
are responsible to get data from remote APIs, and `Providers` which own the
logic to extract information.

### Adapters ###

There are many adapters to use Geocoder with:
[Buzz](https://github.com/kriswallsmith/Buzz),
[cURL](http://php.net/manual/book.curl.php),
[Guzzle](https://github.com/guzzle/guzzle), or [Zend Http
Client](http://framework.zend.com/manual/en/zend.http.client.html).
If you want to use another HTTP layer, you can easily write your own provider by
implementing the `HttpAdapterInterface` interface.


## Providers ###

The most important part of Geocoder is probably all its providers:
[FreeGeoIp](http://freegeoip.net/static/index.html),
[HostIp](http://www.hostip.info/), [IpInfoDB](http://www.ipinfodb.com/), [Yahoo!
PlaceFinder](http://developer.yahoo.com/geo/placefinder/), [Google
Maps](http://code.google.com/apis/maps/documentation/geocoding/), [Bing
Maps](http://msdn.microsoft.com/en-us/library/ff701715.aspx),
[OpenStreetMaps](http://nominatim.openstreetmap.org/),
[CloudMade](http://developers.cloudmade.com/projects/show/geocoding-http-api),
and even [Geoip](http://php.net/manual/book.geoip.php), the PHP extension.
Same thing here, you can easily write your own provider by implementing the
`ProviderInterface` interface.

Geocoder supports both geocoding and reverse geocoding. It depends on the
provider you choose, and also what you want to do. The API is really simple:

{% highlight php %}
<?php

$geocoder = new \Geocoder\Geocoder();
$adapter  = new \Geocoder\HttpAdapter\BuzzHttpAdapter();

$geocoder->registerProviders(array(
    new \Geocoder\Provider\YahooProvider($adapter, 'API_KEY'),
));

// IP based
$result = $geocoder->geocode('88.188.221.14');

// Street address based
$result = $geocoder->geocode('10 rue Gambetta, Paris, France');

// reverse geocoding
$result = $geocoder->reverse($latitude, $longitude);
{% endhighlight %}

The `$result` variable is an instance of [ResultInterface](https://github.com/willdurand/Geocoder/blob/master/src/Geocoder/Result/ResultInterface.php).
Again, the API is simple.


### Dumpers ###

Another feature provided by Geocoder is the ability to dump a
`ResultInterface` object in standard formats like GPS eXchange (GPX),
[GeoJSON](http://geojson.org/),
[Keyhole Markup Language](http://en.wikipedia.org/wiki/Keyhole_Markup_Language)
(KML), Well-Known Binary (WKB), or Well-Known Text (WKT).
This is too small to become a separated library, and it can be helpful if you need
to share geolocated data.


### Conclusion ###

Geocoder is quite stable now, and is well integrated with
[Propel](http://www.propelorm.org) thanks to the
[GeocodableBehavior](https://github.com/willdurand/GeocodableBehavior), and even
with [Doctrine2](http://www.doctrine-project.org/) thanks to the
[DoctrineBehaviors](https://github.com/KnpLabs/DoctrineBehaviors#geocodable).
Both behaviors are really powerful, install them, and your model objects
(entities) will become geo-aware.
Note for Drupal guys, [the geocoder module should use Geocoder](
http://drupal.org/node/1334838), sooner or later.

Geocoder has more than ten contributors (thank you so much guys), is actively
maintained, and already used in production! Oh, and it's heavily unit tested
with more than a hundred tests, and almost a thousand assertions.

If you plan to use geocoding stuff in your project, or to integrate something
in your favourite Framework, you should give Geocoder a try ;)


### Links

* [The Geocoder website](http://geocoder-php.org/);
* [The GitHub repository](https://github.com/willdurand/Geocoder).
