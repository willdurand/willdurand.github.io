---
layout: post
title: "Geocoder: the missing PHP library"
location: Zürich, Switzerland
tags: [PHP]
updates:
  - date: 2022-04-19
    content: I proofread this article and updated some links.
---

Seven months ago, I released [Geocoder][], a PHP 5.3+ library to ease geocoding
manipulations. More and more applications have to deal with geolocation and,
even if HTML5 provides a [Geolocation API][], a server-side library is always
useful. Today, this library has more than 230 watchers on GitHub and it's time
to introduce it here.

The library is standalone and split in two parts: `HttpAdapters`, which
are responsible for getting data from remote APIs, and `Providers`, which own
the logic to extract information.

## Adapters

There are many adapters to use Geocoder with, like
[Buzz](https://github.com/kriswallsmith/Buzz),
[cURL](https://www.php.net/manual/en/book.curl.php),
[Guzzle](https://github.com/guzzle/guzzle) and the Zend Http Client. If you want
to use another HTTP layer, you can easily write your own provider by implementing
the `HttpAdapterInterface` interface.

## Providers

The most important part of Geocoder is probably all its providers: FreeGeoIp,
[HostIp][], [IpInfoDB][], Yahoo! PlaceFinder, [Google Maps][], [Bing Maps][],
[OpenStreetMaps][], CloudMade, and even [Geoip][], the PHP extension. Same thing
here, you can easily write your own provider by implementing the
`ProviderInterface` interface.

Geocoder supports both geocoding and reverse geocoding. It depends on the
provider you choose and also what you want to do. The API is really simple:

```php
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
```

The `$result` variable is an instance of [`ResultInterface`][ResultInterface].
Again, the API is simple.

## Dumpers

Another feature provided by Geocoder is the ability to dump a `ResultInterface`
object in standard formats like GPS eXchange (GPX), [GeoJSON][], [Keyhole Markup
Language][KML] (KML), Well-Known Binary (WKB) or Well-Known Text (WKT). This is
too small to become a separated library and it can be helpful if you need to
share geolocated data.

## Conclusion

Geocoder is quite stable now. It is well integrated with [Propel][] thanks to
the [GeocodableBehavior][] and with [Doctrine][] thanks to the [DoctrineBehaviors][].
Both behaviors are really powerful. Install them and your model objects
(entities) become geo-aware! For Drupal folks, [the geocoder module should use
Geocoder](https://www.drupal.org/node/1334838) sooner or later.

Geocoder has more than ten contributors (thank you so much!!!). It is actively
maintained and already used in production! Oh and it's well unit tested, with
more than a hundred tests and almost a thousand assertions!

If you plan to deal with geocoding stuff in your PHP project, you should give
Geocoder a try ;)

## Links

- [The Geocoder website](https://geocoder-php.org/)
- [The GitHub repository][Geocoder]

[Geocoder]: https://github.com/willdurand/Geocoder
[Geolocation API]: https://www.w3.org/TR/geolocation/
[HostIP]: https://www.hostip.info/
[IpInfoDB]: https://www.ipinfodb.com/
[Google Maps]: https://developers.google.com/maps/documentation/geocoding/
[Bing Maps]: https://docs.microsoft.com/en-us/bingmaps/rest-services/locations/
[OpenStreetMaps]: https://nominatim.openstreetmap.org/ui/search.html
[Geoip]: https://www.php.net/manual/en/book.geoip.php
[ResultInterface]: https://github.com/willdurand/Geocoder/blob/master/src/Geocoder/Result/ResultInterface.php
[GeoJSON]: https://geojson.org/
[KML]: https://en.wikipedia.org/wiki/Keyhole_Markup_Language
[Propel]: http://propelorm.org/
[Doctrine]: https://www.doctrine-project.org/
[DoctrineBehaviors]: https://github.com/KnpLabs/DoctrineBehaviors#geocodable
[GeocodableBehavior]: https://github.com/willdurand/GeocodableBehavior