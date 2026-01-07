
# Wordle
Creating both an interactive and an automatic guessing Wordle game in Assembly
This repository contains 2 main files: "interactive_wordle.s" which is meant to be an interactive game and "auto_guesser_wordle.s" which is (as it's name suggests) a program that guesses a 5 letter word from the list "cuvinte_wordle".

Interactive game

Like the original Assembly game, next up the words mentioned will refer to 5 letter words!
The interactive game requires an input word to typed in by the user (currently working on a randomized version).
Then, for each guess, a feedback will be displayed, being made out of the following symbols:
G(green) - meaning the letter at that specific index is both at the correct position and has the correct value
Y(yellow) - meaning the letter at that specific index appears in the word but it is NOT in the right position
.(grey) - meaning the letter at that specific index does NOT appear in the word at all 

Once the word has been guessed, the user will see the following message appear on screen 
"Congratulations! You have guessed the wordle of the day!"

In the interactive version, the words have NO limitations in the sense that the words may be imaginary and/or be typed with both capital or small letters (but then the palyer would also have the guess whether that character was a capital or a small letter).

An example in this case:
If the secret word is "AbbBC", then if the guess is "abbBc", then the feedback will be ".GGG.".


A downside of this version is, of course, needing a manual input to start the game. Therefore in order to play the game, two people are required: one to type in the word and one to actually guess.

Auto-guesser

The auto-guesser does exactly what you may have already expected from it to do: guessing the word. The input word (the one to be guessed) must also be manually typed. Then, the program reiterates the list (this version the validity of the word; so the previous example "AbbBC" is not valid in this version) until the word is found and it shows you the progress (feedback) after each iteration. The first ever guess will always be the first word of the list which is "ABACA". The code will check at every word whether it has a G letter (a letter that is the right letter and is also at the right index). Next up, if a word does NOT have that previously guessed letter at the correct position then it is skipped (hence the efficiency). 

Example:
For the input word "CARNE", this will be the output:

-------------------------------------------------
Type here the secret word :CARNE
ABACA
Feedback : Y.YYY
BABAC
Feedback : .G.YY
CACOM
Feedback : GGY..
CADET
Feedback : GG.Y.
CAFRI
Feedback : GG.Y.
CAHLE
Feedback : GG..G
CAINE
Feedback : GG.GG
CARNE
-------------------------------------------------

As you can observe, if a G letter was guessed, all of the following guesses will contain that G letter as well.

A downside of this version is that it is sensitive in the sense that if the word typed does NOT appear in the list or it is written with any small letters, then the code never ends running. Another downside is that it is not completely efficient since it doesn't take into consideration the Y letters, but solely the G's. In that sense, this code does not operate at maximum efficiency.