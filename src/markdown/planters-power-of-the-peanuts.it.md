---
lang        : it
title       : "Power Of The Peanut"
permalink   : planters-power-of-the-peanuts
id          : planters-power-of-the-peanuts
date        : 2013-06-10 11:44
author      : Daniele Pelagatti <daniele.pelagatti@unit9.com>
template    : default.it.jade
tags        : daniele,pelagatti,interactive,developer
description : "Power of the Peanut è un microsito HTML5 interattivo pensato per far conoscere al pubblico i poteri nutritivi delle noccioline."
twittertags :
    - powerofthepeanut
---

# [Planters: Power Of The Peanut](http://www.powerofthepeanut.com/) #
## Front End Developer ##

[![](#{base}img/power_of_the_peanut.jpg "Optional title")](http://www.powerofthepeanut.com/)

Power of the Peanut è un microsito HTML5 interattivo pensato per far conoscere al pubblico i poteri nutritivi delle noccioline.

Con Bill Hader (South Park e Saturday Night Live), voce di Mr Peanut, come figura centrale del seminario motivazionale, il sito permette ai visitatori di conoscere e accettare gli affermati benefici nutrizionali delle noccioline e fa da perfetto complemento agli spot televisivi.

Per il regista Michael Sugarman il tono era di fondamentale importanza.

La cosa importante con questo sito era trovare il tono giusto: volevamo che fosse divertente non solo perché è il sito di un uomo-nocciolina ma anche perché tutti i siti *motivazionali* hanno un ché di ridicolo, di cult. Quindi abbiamo provato a progettare un esperienza il più possibile simile ai veri programmi motivazionali, dove più tempo vi trascorri, più vieni risucchiato dentro questa filosofia pseudo-intelletuale.

Kanish Patel, tech lead del progetto, e lo sviluppatore Fábio Azevedo si sono concentrati sul *succ-sizzle cut out tool*, che permette agli utenti di ritagliare un immagine di se stessi e proiettarla in un animazione di loro stessi che vivono una vita di successo

Dovevamo creare qualcosa che fosse semplice anche per qualcuno che non fosse un esperto di photoshop eppure producesse un immagine che ci desse una ragionevole libertà creativa. La nostra idea originale era quella di permettere all'utente di ritagliare il corpo intero ma poi abbiamo optato per un immagine tagliata all'altezza del torso perchè gli utenti avrebbero avuto più probabilità di avere un immagine del genere usando un computer; spiega Kanish.

Il prototipo originale del *cut out tool* dava in mano all'utente un pennello virtuale per cancellare le parti dell'immagine che non voleva. Anche se questo approccio funzionava, poteva risultare lungo da eseguire e il risultato era spesso molto grezzo.

Per la versione finale abbiamo messo l'accento sull'usabilità e minimizzato l'interfaccia a 3 soli strumenti (punta, ruota, annulla) emulando lo strumento penna di photoshop. La versione Tablet dello strumento ha  la capacità aggiuntiva di ingrandire l'area dove agisce il dito in modo da rendere visibile l'azione dell'utente sullo schermo. 
 
Per quanto problematico sembri questo processo, avevamo sempre bisogno di mostrare il risultato finale su un Canvas HTML5, dato che questa è la tecnologia più popolare degli ultimi tempi. Creare un animazione un html da mostrare al cliente attraverso tutte le fasi di approvazione non è semplice. Kanish però ha intravisto delle possibilità

Ci sono 4 possibili versioni dell'animazione visto che 2 sezioni sono intercambiabili casualmente. Abbiamo animato e approvato in Flash usando un *placeholder* per l'immagine dell'utente e solo quando avevamo la versione finale dell'animazione questa è stata esportata in HTML5 con un tool Adobe chiamato CreateJS.

L'animazione esportata ha richiesto solo un minimo intervento per far si che il *placeholder* fosse rimpiazzato dall'immagine dell'utente vera e propria, per ottimizzarne la performance e per renderla compatibile con più browser possibili.

## Stampa ##

[Forbes](http://www.forbes.com/sites/brandindex/2013/12/12/power-of-the-peanut-health-drive-may-be-driving-buzz-for-planters/)

>Planters also created a microsite – www.PowerOfThePeanut.com – showing off how the protein and nutrients from peanuts can help reshape every aspect of people’s lives: from their career to relationships to overall wellness. 

## Riconoscimenti ##

 * **Agency**: TBWA
 * **Brand**: Planters
 * **Director**: Michael Sugarman
 * **Production Company**: UNIT9
 * **Producer**: Valentina Culatti Alisi
 * **Executive Producer**: Alessandro Pula
 * **Project Manager**: Sabina Chaudry
 * **Tech Lead**: Kanish Patel
 * **Lead Designer**: Fredrick Aven
 * **Desktop Developer**: Daniele Pelagatti, Fábio Azevedo, Damien Mortini
 * **Mobile Developer**: Anthony Boutet, Neil Carpenter, Artur Gutkowski
 * **Animation**: Benz Anwat Vongtanee, Janusz Zywert
 * **Back End Developer**: Tomasz Brunarski, Kamil Cholewinski
 * **Systems Administrator**: Thomas Pedoussaut
 * **Quality Assurance**: Peter Law