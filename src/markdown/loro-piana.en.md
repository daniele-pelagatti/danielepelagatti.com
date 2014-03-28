---
lang        : en
title       : Loro Piana
permalink   : loro-piana
id          : loro-piana
date        : 2011-10-12 10:12
author      : Daniele Pelagatti <daniele.pelagatti@unit9.com>
template    : default.en.jade
tags        : loro piana,fashion,ecommerce,site,flash,as3
description : "Made for the Loro Piana lifestyle brand, the experience one gets from visiting this site website is one of luxury and classic elegance, everything that Loro Piana is."
---

# [Loro Piana](http://www.loropiana.com) #
## Tech Lead ##

[![](#{base}img/loropiana_en.jpg "Loro Piana")](http://www.loropiana.com)

Made for the [Loro Piana](http://www.loropiana.com) lifestyle brand, the
experience one gets from visiting this site website is one of luxury and
classic elegance, everything that Loro Piana is.

This project lasted 2 years, it's composed of a Flash Front-end, two mobile
applications for iOS and Android and a visual CMS made in Adobe Flex. The
front-end and Visual CMS techinical implementation was entirely created by
unit9 italy. Another Italian company, Value Team, developed the back-end,
while unit9 London developed the creative solutions and the mobile
applications and managed the production.

## On the technical solutions

The biggest challenge of building a corporate website in flash, with hundreds
of pages and panels, is to eliminate memory leaks and ensure a smooth
experience during the whole time the user browses the site. In order to solve
this problem we build an asset recycling system that re-uses each page and
panel reducing object allocation to the minimum. The system we developed has
proven stable and fast and allowed us to guarantee a comfortable experience
even on low-end machines.

Back-end integration posed another challenge for the technical team; Loro
Piana already had his own order and stock management system so the back-end
team developed a layer on top of the existing system in order to make the
front-end aware of stock changes and product availability and pricing. This
middle-layer, based on the Hybris platform, is able to fetch data from the
Loro Piana stock management system and pass it to the front-end, it manages
the shopping cart, favorite products, user registration, and performs all the
necessary tasks and checks required to buy products from the site.

On the other side, the front-end was developed with a built-in back-end method
cache. This system allows the site to cache back-end calls (exactly like a
browser does with web pages) greatly reducing the amount of data transferred
over the net. It was not simple to implement such a system cause the cache has
to be rebuilt and modified every time the user performs certain actions (like
logging in or out ) because the reply from the server, especially regarding
prices and stock availability, changes based on a multitude of different
conditions. Security was also a big concern: each back-end service that
exposes sensible data for the user is called through the HTTPS protocol and
the payment process has been thoughtfully tested in order to guarantee maximum
security for the user.

We developed a Visual CMS system based on the Adobe Flex framework in order to
allow the client to change all the visual elements in the site: in order to do
so we save the configuration on XML files that the front-end reads. A staging
system was developed in order to test the changes and the front-end site is
able to operate in a “staging” mode so that the client can review every detail
before publishing the changes. The Visual CMS system manages all the aspects
of the site that are not directly related to products such as “Home Scenes”,
“Hotspots”, catalogs, language localizations, etc.

## Credits

**UNIT9 Team**

 * **Creative Directors**: Marcus Punter-Bradshaw, Steve Price 
 * **Interactive Producers**: Valentina Culatti, Ulla Winkler, Steve Price, Davide de Santis, Emily Bell. 
 * **Project Managers**: Jessica Broms, Eleanor Bourdillon-Miller 
 * **Designers**: Luciano Foglia 
 * **Illustrations**: Bobby Kennedy, Fiona Woodcock. 
 * **Tech Lead**: Daniele Pelagatti 
 * **Motion graphics/Animation**: Marcus Punter-Bradshaw, Simone Nunziato, Poppy Westwell, Rafaelle Sido 
 * **Development**: Filippo Tosetto, Domenico Gemoli, Matteo Bonini, Stefano Guidolin, Neil Rackett, Silvio Paganini, Federico Parodi, Rafaelle Sido. 
 * **Sound**: Steve Nolan. 
 * **Photography**: Emily Bell. 
 * **Copy Writer**: Mike Reed. 

**Loro Piana Team**

 * **Team Leader**: Michal Saad. 
 * **Marketing Communications**: Erica Nicola Broglio, Michela Fioramonti. 
 * **Technical supervisor**: Gianmario Marchini. 

**Shoot Group Team**

 * **Producer**: Michelle Craig 
 * **Production Assistant**: Irene Sophia Lopez. 

**Jaques Vanzo Team**

 * **Design consultants**: Martin Jaques, Luisa Vanzo. 

**Value Team**

 * **Technical supervisor**: Ettore Marcon. 
 * **Developer**: Demis Magoga. 
 * **Project Manager**: Loredana Donghi. 
 * **Account Manager**: Fabrizio Caiani.

