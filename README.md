# PISA25 TREND TRANSFER 

For reminder, instructions to users are available [here](https://capps.capstan.be/doc/pisa2025_trend-transfer_guide.php).

To increase automatic leverage, there are tweaks to do both in the source files and in the TMX files.

## Changes in the source files

### 1. Escape break tags in trend files

Turn

	Ingrid's<br/>Poster

into 

	Ingrid's&lt;br&gt;Poster

This is done by adding the replacements to [`source-xml-linter/config_trend.xlsx`](https://github.com/capstanlqc/source-xml-linter/blob/master/config_trend.xlsx), e.g.

	(<text>Day \d)<br/>(\d+</text>)
	$1&lt;br/&gt;$2

### 2. Hide segments with unit ID and unit title

	M00G Advertising Column

which don't need to be translated.

### 3. Remove break tags in some cases

	Height:<br/>250 cm
	Diameter:<br/>100 cm

### 4. Strip leading and trailing paired tags

THe following replacements must be included in [`source-xml-linter/config_trend.xlsx`](https://github.com/capstanlqc/source-xml-linter/blob/master/config_trend.xlsx):

	<text><span id="removeEg"></span> To delete
	<text><span id="removeEg"></span> ‌To delete

	(span id="Q2sp1"><b>)(T =)(</b></span>)
	$1‌$2‌$3

	(<br/><span id="Q\d+sp\d+">)(Number of .+? spacers:)\s*(</span>)
	$1‌$2‌$3

	(<span id="sp1">) (m²)(</span>)
	$1‌$2‌$3

	(<span id\="(?:Q\d*)?sp\d+">)(?!\x{200C})([^<]{2,})((?<!\x{200C})</span><br/>)
	$1‌$2‌$3

	(<text>[\s\n]*<b>(?!\x{200C}))([^<]+)((?<!\x{200C})</b>[\s\n]*(</text>|<br/>))
	$1‌$2‌$3

	(<br/><span[^>]+>(?!\x{200C}))([^<]+)((?<!\x{200C})</span>\s*<input)
	$1‌$2‌$3

	(<[^>]+><[^>]+>(?!\x{200C}))([^<]+)((?<!\x{200C})</span><br/>)
	$1‌$2‌$3


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

#### 1.1 OmegaT 

In cases where the number of sentences is the same in both source and target and there the final sentence punctuation is a dot on both sides, OmegaT seems to handle segmentation of the whole chunk well, provided that the segmentation type is "paragraph" in the preamble.

In other cases, we might need to look at other options. 

#### 1.2. ChatGPT

ChatGPT seems to do a good job: https://chat.openai.com/share/55356635-06ac-43c9-ad15-c6431daea7ef

It would be a matter of checking pricing plans, including number of requests and privacy implications. Then we can write a script that 

 - parses the TMX files
 - sends the paragrams and receives the sentences
 - composes the new, segmented TMX file

#### 1.3. Okapi, NLTK, etc.

### 2. Source text updates:

|             Original            |           Updated          |
|:-----------------------------|:---------------------------|
| Select from the pull-down menus to answer the question. | Select from the drop-down menus to answer the question. |
| Find the range of value that the length of the third side of the triangle can take. | Find the range of values that the length of the third side of the triangle can take. |
| Type and click on a choice to answer the question. | Type and click on your choice to answer the question. |
| Click on &lt;g1&gt;Yes&lt;/g1&gt; or &lt;g2&gt;No&lt;/g2&gt; for each of the following balls. | Click on either &lt;g1&gt;Yes&lt;/g1&gt; or &lt;g2&gt;No&lt;/g2&gt; for each of the following balls. |
| Click on &lt;g1&gt;Yes&lt;/g1&gt; or &lt;g2&gt;No&lt;/g2&gt; for each pair of segments. | Click on either &lt;g1&gt;Yes&lt;/g1&gt; or &lt;g2&gt;No&lt;/g2&gt; for each pair of segments. |
| Click on &lt;g1&gt;Yes&lt;/g1&gt; or &lt;g2&gt;No&lt;/g2&gt; for each pair of angles. | Click on either &lt;g1&gt;Yes&lt;/g1&gt; or &lt;g2&gt;No&lt;/g2&gt; for each pair of angles. |
| Refer to &quot;Fan Merchandise&quot; on the right.  | Refer to &quot;Z's Fan Merchandise&quot; on the right.  |
| Step 4 is performed before Step 3. | The operation in Step 4 is performed before the operation in Step 3. |
| Step 3 is performed before Step 2. | The operation in Step 3 is performed before the operation in Step 2. |
| <seg>It increases and decreases</seg> | <seg>It increases and decreases.</seg> |
| <seg>It strictly increases</seg> | <seg>It strictly increases.</seg> |
| <seg>It strictly decreases</seg> | <seg>It strictly decreases.</seg> |
| Look at the &lt;g1&gt;tab&lt;/g1&gt;, titled “Angles of Vision,” on the right. | Look at the &lt;g1&gt;tab&lt;/g1&gt; titled “Angles of Vision” on the right. |
| <seg>The equation of the line is &lt;g1&gt;a&lt;/g1&gt; = 115 – &lt;g2&gt;s&lt;/g2&gt;, where &lt;g3&gt;a&lt;/g3&gt; is the angle, in degrees, and &lt;g4&gt;s&lt;/g4&gt; is the speed of the vehicle, in kilometres per hour.</seg> |  <seg>The equation of the line is &lt;g1&gt;a&lt;/g1&gt;&#x00A0;=&#x00A0;115&#x00A0;–&#x00A0;&lt;g2&gt;s&lt;/g2&gt;, where &lt;g3&gt;a&lt;/g3&gt; is the angle, in degrees, and &lt;g4&gt;s&lt;/g4&gt; is the speed of the vehicle, in kilometres per hour.</seg> |

### 3. Updates in both languages

#### 3.1. Remove tags in source and target, where the source has "Refer to UNIT-TITLE on the right.":

	<seg>\s*&lt;i&gt;Refer to "([^"]+)" on the right.</seg>
	<seg>Refer to "$1" on the right.</seg>

#### 3.2. Remove trailing tag, in any of these: 

	<seg>Click on a choice to answer the question.&lt;/i&gt;</seg>
	<seg>  And it was my privilege to listen.”&lt;/i&gt;</seg>
	<seg> And it was my privilege to listen.”&lt;/i&gt;</seg>
	<seg> Type your answers to the question in the boxes below.&lt;/i&gt;</seg>
	<seg> Type your answers to the question in the boxes on the right.&lt;/i&gt;</seg>
	<seg>And it was my privilege to listen.”&lt;/i&gt;</seg>
	<seg>Click on a choice and then type an explanation to answer the question.&lt;/i&gt;</seg>
	<seg>Click on a choice and then type your answer to the question.&lt;/i&gt;</seg>
	<seg>Click on a choice to answer the question.&lt;/i&gt;</seg>
	<seg>Click on a search result to answer the question.&lt;/i&gt;</seg>
	<seg>Click on a sentence in either the Biography or the Article to answer the question.&lt;/i&gt;</seg>
	<seg>Click on the choices in the table to answer the question.&lt;/i&gt;</seg>
	<seg>Then click on a total of three choices to answer the question.&lt;/i&gt;</seg>
	<seg>Then click on the NEXT arrow.&lt;/i&gt;</seg>
	<seg>Type your answer to the question.&lt;/i&gt;</seg>
	<seg>Type your answer to the questions.&lt;/i&gt;</seg>
	<seg>Type your answers to the question in the boxes below.&lt;/i&gt;</seg>
	<seg>Type your answers to the question in the boxes on the right.&lt;/i&gt;</seg>
	<seg>Use drag and drop to answer the question.&lt;/i&gt;</seg>
	<seg>Using the number keys, type your answer to the question.&lt;/i&gt;</seg>
	<seg>When you are finished, click on the NEXT arrow to continue.&lt;/i&gt;</seg>

Pattern: 

	<seg>([^&\n<]+)&lt;/i&gt;</seg>
	<seg>$1</seg>

#### 3.3. Remove leading break tags with class

	<seg>&lt;br class="clear" /&gt;\s*
	<seg>

#### 3.4. Optional: Remove `</g1><br/>.+` in both languages in cases like this

(Low priority)

	Tossing Coins</g1><br/> Question
	Testa o croce</g1><br/> Domanda

	Tile Arrangement</g1><br/> Question
	Composizione di piastrelle</g1><br/> Domanda

We only want the part before the line break (without the surrounding tags).

If this is tricky because it involves a condition in the source (to match "Question"), please focus on other easier cases.

### 4. Stripping leading/trailing paired tags

This must be done only when the leading tag and the trailing tag are part of the same tag pair. 

Onliner (and pattern) to find those cases:

	perl -ne "print if m~<seg>\s*&lt;([^&]+)&gt;\s*([^&<]+)\s*&lt;/\1&gt;~" *.tmx 

That's to avoid this problem: 

![](https://imgur.com/I0DjKAZ.png)

Also, either both tags are stripped, or none. Otherwise, we have this problem:

![](https://imgur.com/VrKZ7hN.png)

### 5. Remove double spaces from TM

In both the source and the target text:

Turn this

	Click on either  True  or  False  for each of the statements below.
	Cliquez sur  Vrai  ou  Faux  pour chacune des affirmations ci-dessous.

Turn this

	Click on either True or False for each of the statements below.
	Cliquez sur Vrai ou Faux pour chacune des affirmations ci-dessous.

----


### 3. Language pair specific updates (PLEASE IGNORE)

|             Original            |           Updated          |
|:-----------------------------|:---------------------------|
| Refer to "Fan Merchandise" on the right. | Refer to "Z's Fan Merchandise" on the right.  |
| La figura semplificata qui sotto rappresenta una capriata.Nella figura | La figura semplificata qui sotto rappresenta una capriata. Nella figura |