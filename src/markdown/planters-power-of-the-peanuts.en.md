---
lang        : en
title       : "Power Of The Peanut"
permalink   : planters-power-of-the-peanuts
id          : planters-power-of-the-peanuts
date        : 2013-06-10 11:44
author      : Daniele Pelagatti <daniele.pelagatti@unit9.com>
template    : default.en.jade
tags        : daniele,pelagatti,interactive,developer
description : "Power of the Peanut is an interactive HTML5 microsite built to introduce the people of America to the nutritional power of peanuts."
twittertags :
    - powerofthepeanut
---

# [Planters: Power Of The Peanut](http://www.powerofthepeanut.com/) #
## Front End Developer ##

[![](#{base}img/power_of_the_peanut.jpg "Optional title")](http://www.powerofthepeanut.com/)

Power of the Peanut is an interactive HTML5 microsite built to introduce the people of America to the nutritional power of peanuts.

With Bill Hader (South Park and Saturday Night Live) as the voice of Mr Peanut as the central figure in a motivational seminar, the site allows visitors to embrace and acknowledge the affirming nutritional benefits of peanuts and complements the TV and digital spots perfectly.

Delving behind the shiny, polished and pumped up protein power of the site, a team chiselled away at making certain aspects of the experience as engaging as possible, encouraging visitors to embrace the power of pose and upload their profiles to visualise success.

The important thing with this site was to strike the right tone: we wanted it to be funny not just because it’s a peanut man with his own website, but because all motivational websites have an inherently ridiculous, cult-like feel. So we tried to design the experience as closely as we could to a real motivational program, where the longer you spend with it the deeper you are drawn into this pseudo-intellectual philosophy.

Kanish Patel, tech lead on POTP, and developer Fábio Azevedo focused on a succ-sizzle cut out tool, which would allow users to cut out an image of themselves and build a simple animation of them living the successful life.

We had to create something that was simple for someone who wasn’t a photoshop expert, and yet would result in an image that gave us a reasonable amount of creative freedom for the animation. Our original idea was for the user to cut out their entire body, but this soon changed to just their upper body simply because we expected visitors were more likely to have such an image on their desktop. Explains Kanish.

The original prototype of the cut out tool had the user using a ‘brush’ tool to erase the areas of their image they didn’t want. Although this worked, it could be time consuming to do even a crude cutout of your image, and needed too many tools to be properly usable (brush size, zoom in/out, rotate, undo).
 
For the final version we put the focus on usability and minimised the interface to 3 tools (point, rotate, undo) by emulating the photoshop pen tool. The Tablet version of the tool includes an additional feature where we show a zoomed bubble above where you tap, since the point you tap will always be obscured by your finger. Explains Kanish.
 
As problematic as this process seemed, they still needed to embed the animation, and as HTML5 Canvas is the popular choice at the moment for web, but creating the animation in html throughout the review process to share with the client would have been significantly time consuming. Kanish saw a number of possibilities.

There are 4 possible versions of the animation as 2 sections are randomly chosen for each submitted photo. We animated and reviewed the entire video in Flash using a placeholder image for the user image, and only when we had the final version of the animation, then we used a tool from Adobe and CreateJS to export the animation to HTML Canvas.
 
The exported animation then required minimal tweaking by developers to replace the placeholder with the user’s image, and to improve the performance somewhat to support as many browsers as possible.

## Press ##

[Forbes](http://www.forbes.com/sites/brandindex/2013/12/12/power-of-the-peanut-health-drive-may-be-driving-buzz-for-planters/)

>Planters also created a microsite – www.PowerOfThePeanut.com – showing off how the protein and nutrients from peanuts can help reshape every aspect of people’s lives: from their career to relationships to overall wellness. 

## Credits ##

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