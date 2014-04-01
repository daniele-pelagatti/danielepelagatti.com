---
lang        : it
title       : Loro Piana
permalink   : loro-piana
id          : loro-piana
date        : 2011-10-12 10:12
author      : Daniele Pelagatti <daniele.pelagatti@unit9.com>
template    : default.it.jade
tags        : loro piana,fashion,ecommerce,site,flash,as3
description : "Commissionato dal brand [Loro Piana](http://www.loropiana.com), la sensazione che si ha navigando questo sito è quella di lusso ed eleganza classica, tutto quello che Loro Piana rappresenta."
twittertags :
    - loropiana
---

# [Loro Piana](http://www.loropiana.com) #
## Tech Lead ##

[![](#{base}img/loropiana_it.jpg "Loro Piana")](http://www.loropiana.com)

Commissionato dal brand [Loro Piana](http://www.loropiana.com), la sensazione
che si ha navigando questo sito è quella di lusso ed eleganza classica, tutto
quello che Loro Piana rappresenta.

Il progetto, durato due anni è composto da un Front-end in Flash, due
applicazioni mobile per iOS e Android e un Visual CMS basato sul framework
Adobe Flex. L'implementazione tecnica del front-end e del Visual CMS è stata
interamente realizzata da unit9 Italia. Un'altra azienda Italiana, Value Team,
ha sviluppato il sistema di back-end, mentre unit9 London ha curato l'aspetto
creativo, le applicazioni mobile e la produzione.

## Sulle soluzioni tecniche

La sfida più grande che si pone nello sviluppare un corporate website in Flash
composto da centinaia di pagine e pannelli è l'eliminazione dei memory leaks.
Assicurarsi che l'utente viva un esperienza fluida e veloce durate tutta la
durata della navigazione è la chiave del successo di questo sito. Per
assicurarsi che questo requisito fosse soddisfatto abbiamo costruito un
sistema di riciclo degli asset che garantisce uno spreco di allocazione di
memoria minima. Il sistema che abbiamo sviluppato si è dimostrato solido e
sicuro, garantendo una navigazione fluida anche su macchine low-end.

L'integrazione con il back-end ha posto un'altra sfida per il team tecnico:
Loro Piana, quando il progetto è iniziato, aveva già un proprio sistema di
gestione dei magazzini e delle scorte, il team di back-end ha sviluppato uno
sistema che si pone al di sopra del sistema esistente e permette al front-end
di conoscere le disponibilità e i prezzi di tutti i prodotti offerti. Questo
“strato intermedio”, basato sulla piattaforma Hybris, è in grado di
interrogare il database di Loro Piana, gestire gli ordini, il carrello, i
prodotti preferiti, la registrazione utente e tutti i controlli necessari per
permettere l'acquisto, la prenotazione e il cambio di merci direttamente dal
sito.

Dall'altro lato il front-end è stato sviluppato con un sistema di cache delle
chiamate al backend. Questo sistema permette al sito di mettere in cache molte
chiamate al backend (proprio come fa un browser con una pagina web
tradizionale) riducendo enormemente il carico di lavoro del server e la
quantità di dati trasmessa attraverso la rete. Il sistema non è stato semplice
da implementare in quanto la cache va eleminata o modificata in base a un alto
numero di variabili (come il login e logout del cliente). Infatti le risposte
date dal server cambiano in base a una moltitudini di condizioni. Un altra
grande preoccupazione è stata la sicurezza: tutti i dati sensibili vengono
trasferiti tramite protocollo HTTPS e la procedura di acquisto con carta di
credito è stata accuratamente testata per fare in modo che rispettasse i più
alti standard.

Il team di sviluppo italiano ha inoltre costruito il Visual CMS che permette
al cliente di cambiare a piacimento tutti gli aspetti del sito che non sono
gestiti dal back-end quali: “Home Scenes”, “Hotspots”, cataloghi, language
localizations, etc. Il Visual CMS usa files XML per comunicare con il front-
end e ha un sistema di staging che permette al cliente di mettere l'intero
sito in modalità preview prima di pubblicare eventuali cambiamenti.

## Riconoscimenti

**Team UNIT9**

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

**Team Loro Piana**

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

