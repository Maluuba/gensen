curl -LO 'http://nlp.stanford.edu/data/glove.840B.300d.zip'
unzip glove.840B.300d.zip
rm glove.840B.300d.zip
python glove2h5.py