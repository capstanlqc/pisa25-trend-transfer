# PISA25 TREND TRANSFER 

To increase automatic leverage, there are tweaks to do both in the source files and in the TMX files.

## Changes in the source files

### 1. Escape break tags in trend files

Turn

	Ingrid's<br/>Poster

into 

	Ingrid's&lt;br&gt;Poster

### 2. Hide segments with unit ID and unit title

	M00G Advertising Column

which don't need to be translated.

### 3. Remove break tags in some cases

	Height:<br/>250 cm
	Diameter:<br/>100 cm

### 4. Strip tags in unit titles

	<b>Wheelchair Basketball</b>
	<span id="sp1">small bricks</span>
	<b>Bricks</b>
	<b>Pipelines</b>
	<b>Map</b>
	<b>Lotteries</b>

## Changes in the TMX files

### 1. Bilingual segmentation and/or ealignment

For example, turn this

	-- Ingrid wants to use an advertising column as shown on the right to advertise her forthcoming show. She has designed a poster and has already printed 100 copies. All of her posters are 60 cm x 75 cm.
	-- Olivia veut se servir d’une colonne publicitaire, comme celle représentée à droite, pour faire la publicité de son prochain spectacle. Elle a créé une affiche et en a déjà imprimé 100 exemplaires. Toutes ses affiches mesurent 60 cm x 75 cm.

into:

	-- Ingrid wants to use an advertising column as shown on the right to advertise her forthcoming show. 
	-- Olivia veut se servir d’une colonne publicitaire, comme celle représentée à droite, pour faire la publicité de son prochain spectacle. 
	
	-- She has designed a poster and has already printed 100 copies. 
	-- Elle a créé une affiche et en a déjà imprimé 100 exemplaires. 

	-- All of her posters are 60 cm x 75 cm.
	-- Toutes ses affiches mesurent 60 cm x 75 cm.

ChatGPT seems to do a good job: https://chat.openai.com/share/55356635-06ac-43c9-ad15-c6431daea7ef

It would be a matter of checking pricing plans, including number of requests and privacy implications. Then we can write a script that 

 - parses the TMX files
 - sends the paragrams and receives the sentences
 - composes the new, segmented TMX file

### 2. Update source wording in TM

|             Original            |           Updated          |   |   |   |
|:-----------------------------|:---------------------------|---|---|---|
| Select from the pull-down menus to answer the question.                 | Select from the drop-down menus to answer the question.                        |   |   |   |


### 3. Clean-up: remove unit id's from the beginning of segments

In both the source and the target text:

	M273 Pipelines
	M273 Pipelines

Pattern must be something like ^[MSR]\d{3}` with a few exceptions TBC

### 4. Clean-up remove question number from the end of the segment

In both the source and the target text:

	M273 Pipelines Q1
	M273 Pipelines Q1

Pattern `\s+Q\d$`

### 5. Remove double spaces from TM

In both the source and the target text:

Turn this

	Click on either  True  or  False  for each of the statements below.
	Cliquez sur  Vrai  ou  Faux  pour chacune des affirmations ci-dessous.

Turn this

	Click on either True or False for each of the statements below.
	Cliquez sur Vrai ou Faux pour chacune des affirmations ci-dessous.