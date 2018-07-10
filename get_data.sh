#!/usr/bin/env bash

# Get Moses for tokenization and other pre-processing
echo "Fetching moses ..."
git clone https://github.com/moses-smt/mosesdecoder.git data/mosesdecoder

TOKENIZER=$(pwd)/data/mosesdecoder/scripts/tokenizer/tokenizer.perl
LOWERCASER=$(pwd)/data/mosesdecoder/scripts/tokenizer/lowercase.perl

echo "Creating folder for corpora"
if [ ! -d "data/corpora" ]; then
	mkdir data/corpora
fi

cd data/corpora

echo "Fetching SNLI ..."
wget https://nlp.stanford.edu/projects/snli/snli_1.0.zip

unzip snli_1.0.zip
rm snli_1.0.zip

awk -F "\t" '{print$1}' snli_1.0/snli_1.0_train.txt | awk '{if(NR>1)print}' > snli_1.0/snli_1.0_train.txt.lab
awk -F "\t" '{print$1}' snli_1.0/snli_1.0_dev.txt   | awk '{if(NR>1)print}' > snli_1.0/snli_1.0_dev.txt.lab
awk -F "\t" '{print$1}' snli_1.0/snli_1.0_test.txt  | awk '{if(NR>1)print}' > snli_1.0/snli_1.0_test.txt.lab

awk -F "\t" '{print$6}' snli_1.0/snli_1.0_train.txt > snli_1.0/snli_1.0_train.txt.s1
awk -F "\t" '{print$6}' snli_1.0/snli_1.0_dev.txt > snli_1.0/snli_1.0_dev.txt.s1
awk -F "\t" '{print$6}' snli_1.0/snli_1.0_test.txt > snli_1.0/snli_1.0_test.txt.s1

awk -F "\t" '{print$7}' snli_1.0/snli_1.0_train.txt > snli_1.0/snli_1.0_train.txt.s2
awk -F "\t" '{print$7}' snli_1.0/snli_1.0_dev.txt > snli_1.0/snli_1.0_dev.txt.s2
awk -F "\t" '{print$7}' snli_1.0/snli_1.0_test.txt > snli_1.0/snli_1.0_test.txt.s2

echo "Tokenizing and lowercasing files ..."

perl $TOKENIZER -l en -threads 8 < snli_1.0/snli_1.0_train.txt.s1 | $LOWERCASER  | awk '{if(NR>1)print}' > snli_1.0/snli_1.0_train.txt.s1.tok
perl $TOKENIZER -l en -threads 8 < snli_1.0/snli_1.0_dev.txt.s1   | $LOWERCASER  | awk '{if(NR>1)print}' > snli_1.0/snli_1.0_dev.txt.s1.tok
perl $TOKENIZER -l en -threads 8 < snli_1.0/snli_1.0_test.txt.s1  | $LOWERCASER  | awk '{if(NR>1)print}' > snli_1.0/snli_1.0_test.txt.s1.tok

perl $TOKENIZER -l en -threads 8 < snli_1.0/snli_1.0_train.txt.s2 | $LOWERCASER  | awk '{if(NR>1)print}' > snli_1.0/snli_1.0_train.txt.s2.tok
perl $TOKENIZER -l en -threads 8 < snli_1.0/snli_1.0_dev.txt.s2   | $LOWERCASER  | awk '{if(NR>1)print}' > snli_1.0/snli_1.0_dev.txt.s2.tok
perl $TOKENIZER -l en -threads 8 < snli_1.0/snli_1.0_test.txt.s2  | $LOWERCASER  | awk '{if(NR>1)print}' > snli_1.0/snli_1.0_test.txt.s2.tok

echo "Pasting files together"

paste -d "\t" snli_1.0/snli_1.0_train.txt.s1.tok snli_1.0/snli_1.0_train.txt.s2.tok snli_1.0/snli_1.0_train.txt.lab > snli_1.0_train.txt.clean
paste -d "\t" snli_1.0/snli_1.0_dev.txt.s1.tok snli_1.0/snli_1.0_dev.txt.s2.tok snli_1.0/snli_1.0_dev.txt.lab > snli_1.0_dev.txt.clean
paste -d "\t" snli_1.0/snli_1.0_test.txt.s1.tok snli_1.0/snli_1.0_test.txt.s2.tok snli_1.0/snli_1.0_test.txt.lab > snli_1.0_test.txt.clean

rm -rf snli_1.0

echo "Fetching MultiNLI"

wget https://www.nyu.edu/projects/bowman/multinli/multinli_1.0.zip
unzip multinli_1.0.zip
rm multinli_1.0.zip

echo "Tokenizing and lowercasing files ..."

awk -F "\t" '{print$1}' multinli_1.0/multinli_1.0_train.txt | awk '{if(NR>1)print}' > multinli_1.0/multinli_1.0_train.txt.lab
awk -F "\t" '{print$6}' multinli_1.0/multinli_1.0_train.txt > multinli_1.0/multinli_1.0_train.txt.s1
awk -F "\t" '{print$7}' multinli_1.0/multinli_1.0_train.txt > multinli_1.0/multinli_1.0_train.txt.s2

perl $TOKENIZER -l en -threads 8 < multinli_1.0/multinli_1.0_train.txt.s1 | $LOWERCASER  | awk '{if(NR>1)print}' > multinli_1.0/multinli_1.0_train.txt.s1.tok
perl $TOKENIZER -l en -threads 8 < multinli_1.0/multinli_1.0_train.txt.s2 | $LOWERCASER  | awk '{if(NR>1)print}' > multinli_1.0/multinli_1.0_train.txt.s2.tok

paste -d "\t" multinli_1.0/multinli_1.0_train.txt.s1.tok multinli_1.0/multinli_1.0_train.txt.s2.tok multinli_1.0/multinli_1.0_train.txt.lab > multinli_1.0_train.txt.clean

cat snli_1.0_train.txt.clean multinli_1.0_train.txt.clean > allnli.train.txt

awk -F "\t" '($3 != "-")' allnli.train.txt > allnli.train.txt.clean.noblank
awk -F "\t" '($3 != "-")' snli_1.0_dev.txt.clean > snli_1.0_dev.txt.clean.noblank
awk -F "\t" '($3 != "-")' snli_1.0_test.txt.clean > snli_1.0_test.txt.clean.noblank

echo "Fetching de-en data"
if [ ! -d "nmt" ]; then
	mkdir nmt
fi

cd nmt

# Europarl
wget http://www.statmt.org/wmt13/training-parallel-europarl-v7.tgz 
tar -xvf training-parallel-europarl-v7.tgz

# Commoncrawl
wget http://www.statmt.org/wmt13/training-parallel-commoncrawl.tgz
tar -xvf training-parallel-commoncrawl.tgz
mv commoncrawl.de-en.de training
mv commoncrawl.de-en.en training
mv commoncrawl.fr-en.fr training
mv commoncrawl.fr-en.en training
rm commoncrawl*

echo "Fetching remaining data for fr-en"
echo "Warning this could take a while ..."

# UN Corpus
wget http://www.statmt.org/wmt13/training-parallel-un.tgz
tar -xvf training-parallel-un.tgz
mv un/undoc.2000.fr-en.fr training
mv un/undoc.2000.fr-en.en training
rm -rf un

# En-Fr Giga
wget http://www.statmt.org/wmt10/training-giga-fren.tar
tar -xvf training-giga-fren.tar
gunzip giga-fren.release2.fixed.en.gz
gunzip giga-fren.release2.fixed.fr.gz
mv giga-fren.release2.fixed.en training
mv giga-fren.release2.fixed.fr training

echo "Creating Training data ..."

cat training/commoncrawl.de-en.de training/europarl-v7.de-en.de > training/nmt.de-en.de
cat training/commoncrawl.de-en.en training/europarl-v7.de-en.en > training/nmt.de-en.en

echo "Tokenizing"

perl $TOKENIZER -l de -threads 8 < training/nmt.de-en.de | $LOWERCASER > training/nmt.de-en.de.tok
perl $TOKENIZER -l en -threads 8 < training/nmt.de-en.en | $LOWERCASER > training/nmt.de-en.en.tok

cat training/commoncrawl.fr-en.fr training/europarl-v7.fr-en.fr training/undoc.2000.fr-en.fr training/giga-fren.release2.fixed.fr > training/nmt.fr-en.fr
cat training/commoncrawl.fr-en.en training/europarl-v7.fr-en.en training/undoc.2000.fr-en.en training/giga-fren.release2.fixed.en > training/nmt.fr-en.en

perl $TOKENIZER -l fr -threads 8 < training/nmt.fr-en.fr | $LOWERCASER > training/nmt.fr-en.fr.tok
perl $TOKENIZER -l en -threads 8 < training/nmt.fr-en.en | $LOWERCASER > training/nmt.fr-en.en.tok

get_seeded_random()
{
    seed="$1"
    openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt \
        </dev/zero 2>/dev/null
}

shuf --random-source=<(get_seeded_random 42) training/nmt.de-en.de.tok | tail -1000 > training/dev.nmt.de-en.de.tok
shuf --random-source=<(get_seeded_random 42) training/nmt.de-en.de.tok | head -4318332 > training/train.nmt.de-en.de.tok

shuf --random-source=<(get_seeded_random 42) training/nmt.de-en.en.tok | tail -1000 > training/dev.nmt.de-en.en.tok
shuf --random-source=<(get_seeded_random 42) training/nmt.de-en.en.tok | head -4318332 > training/train.nmt.de-en.en.tok

shuf --random-source=<(get_seeded_random 42) training/nmt.fr-en.fr.tok | tail -1000 > training/dev.nmt.fr-en.fr.tok
shuf --random-source=<(get_seeded_random 42) training/nmt.fr-en.fr.tok | head -40658082 > training/train.nmt.fr-en.fr.tok

shuf --random-source=<(get_seeded_random 42) training/nmt.fr-en.en.tok | tail -1000 > training/dev.nmt.fr-en.en.tok
shuf --random-source=<(get_seeded_random 42) training/nmt.fr-en.en.tok | head -40658082 > training/train.nmt.fr-en.en.tok

