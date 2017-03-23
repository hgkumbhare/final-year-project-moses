#!/bin/sh
#tuning script

cd ~/corpus

~/mosesdecoder/scripts/tokenizer/tokenizer.perl -l en < nl_file_tuning.en > ~/corpus/nl_file_tuning.tok.en

~/mosesdecoder/scripts/tokenizer/tokenizer.perl -l en < se_file_tuning.en > ~/corpus/se_file_tuning.tok.en

# Note we made "truecase-model.en" as "~/corpus/truecase-model_nl.en"
~/mosesdecoder/scripts/recaser/truecase.perl --model ~/corpus/truecase-model_nl.en < ~/corpus/nl_file_tuning.tok.en > ~/corpus/nl_file_tuning.true.en


~/mosesdecoder/scripts/recaser/truecase.perl --model ~/corpus/truecase-model_se.en < ~/corpus/se_file_tuning.tok.en > ~/corpus/se_file_tuning.true.en

cd ~/working
pwd

nohup nice ~/mosesdecoder/scripts/training/mert-moses.pl ~/corpus/se_file_tuning.true.en ~/corpus/nl_file_tuning.true.en ~/mosesdecoder/bin/moses train/model/moses.ini --mertdir ~/mosesdecoder/bin/ &> mert.out &

#how to add this line for speed
#echo `--decoder-flags="threads 4"`

echo "TUNING SCRIPT RAN SUCCESSFULLY"


# To speed up process by making binarised model

mkdir ~/working/binarised-model
cd ~/working
pwd
~/mosesdecoder/bin/processPhraseTableMin -in train/model/phrase-table.gz -nscores 4 -out binarised-model/phrase-table
~/mosesdecoder/bin/processLexicalTableMin -in train/model/reordering-table.wbe-msd-bidirectional-fe.gz -out binarised-model/reordering-table

cp ~/working/mert-work/moses.ini ~/working/binarised-model/

# Running moses on input file

~/mosesdecoder/bin/moses -f ~/working/train/model/moses.ini < input_file.txt > output_file.txt

#Running moses on input file using binarised model

: ' Comments
 For running binarised-model of moses:
Then make a copy of the ~/working/mert-work/moses.ini in the binarised-model directory
and change the phrase and reordering tables to point to the binarised versions, as follows:
1. Change PhraseDictionaryMemory to PhraseDictionaryCompact
2. Set the path of the PhraseDictionary feature to point to $HOME/working/binarised-model/phrase-table
3. Set the path of the LexicalReordering feature to point to $HOME/working/binarised-model/reordering-table

Run on terminal:
~/mosesdecoder/bin/moses -f ~/working/binarised-model/moses.ini
'

sed -i 's/PhraseDictionaryMemory/PhraseDictionaryCompact/g' ~/working/binarised-model/moses.ini

sed -i 's/train\/model/binarised-model/g' ~/working/binarised-model/moses.ini

sed -i 's/phrase-table.gz/phrase-table/g' ~/working/binarised-model/moses.ini

sed -i 's/reordering-table.wbe-msd-bidirectional-fe.gz/reordering-table/g' ~/working/binarised-model/moses.ini


~/mosesdecoder/bin/moses -f ~/working/binarised-model/moses.ini < input_file.txt > output_file_binarised.txt


echo "BINARISED MODEL SUCCESSFULLY"
