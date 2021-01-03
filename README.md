##### SETTING UP VIRTUAL ENVIRONMENT
* `Python 3.6.9` to be installed.
* `bash environmentsetup.sh` to create a virtual environment, install fairseq, sentencepiece etc
* `source ../env/bin/activate` to activate the created environmnet for use.
* `python input_formatter.py pap_en.tsv` to add full stops, output is saved to `formatted_corpus.tsv`
* `bash prepare_corpus.sh` to download data and create necessary files for training, testing and validation
* `bash preprocessing.sh` to tokenise the data using sentencepiece and then binarise for fairseq ingestion
* `bash train.sh` to train the model
* `bash inference.sh` to run inference using the trained models
*  For multilingual nmt using Portuguese the preprocessing and prepare corpus scripts are appended with `_mt`
*  For sentence level translation do something like this. `echo "This is test sentence" | bash spmencoder.sh | bash sentence_translation.sh` Model paths etc. can be set inside these two bash files.

