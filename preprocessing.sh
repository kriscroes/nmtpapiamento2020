#!/bin/bash
SRC=en
TGT=pap

BPESIZE=3000
TRAIN_MINLEN=1  # remove sentences with <1 BPE token
TRAIN_MAXLEN=200  # remove sentences with >200 BPE tokens

ROOT=$(dirname "$0")
SCRIPTS=$ROOT/scripts
DATA=$ROOT/corpus
TRAIN_SET=train
VALID_SET=valid
TEST_SET=test

TMP=$DATA/papiamento_${SRC}_${TGT}_bpe${BPESIZE}
DATABIN=$ROOT/data-bin/papiamento_${SRC}_${TGT}_bpe${BPESIZE}
mkdir -p $TMP $DATABIN

SRC_TOKENIZER="bash $SCRIPTS/tok.sh "
TGT_TOKENIZER="bash $SCRIPTS/tok.sh"  # learn target-side BPE over untokenized (raw) text
SPM_TRAIN=$SCRIPTS/spm_train.py
SPM_ENCODE=$SCRIPTS/spm_encode.py

echo "pre-processing data"

$SRC_TOKENIZER $DATA/${TRAIN_SET}.$SRC > $TMP/train.$SRC
$TGT_TOKENIZER $DATA/${TRAIN_SET}.$TGT > $TMP/train.$TGT
$SRC_TOKENIZER $DATA/${VALID_SET}.$SRC > $TMP/valid.$SRC
$TGT_TOKENIZER $DATA/${VALID_SET}.$TGT > $TMP/valid.$TGT
$SRC_TOKENIZER $DATA/${TEST_SET}.$SRC > $TMP/test.$SRC
$TGT_TOKENIZER $DATA/${TEST_SET}.$TGT > $TMP/test.$TGT

# learn BPE with sentencepiece
python $SPM_TRAIN \
  --input=$TMP/train.$SRC,$TMP/train.$TGT \
  --model_prefix=$DATABIN/sentencepiece.bpe \
  --vocab_size=$BPESIZE \
  --character_coverage=1.0 \
  --model_type=bpe

cut -f1 $DATABIN/sentencepiece.bpe.vocab| tail -n +4 | sed "s/$/ 100/g" > $DATABIN/fairseqdict.txt

# encode train/valid/test
python $SPM_ENCODE \
  --model $DATABIN/sentencepiece.bpe.model \
  --output_format=piece \
  --inputs $TMP/train.$SRC $TMP/train.$TGT \
  --outputs $TMP/train.bpe.$SRC $TMP/train.bpe.$TGT \
  --min-len $TRAIN_MINLEN --max-len $TRAIN_MAXLEN
for SPLIT in "valid" "test"; do \
  python $SPM_ENCODE \
    --model $DATABIN/sentencepiece.bpe.model \
    --output_format=piece \
    --inputs $TMP/$SPLIT.$SRC $TMP/$SPLIT.$TGT \
    --outputs $TMP/$SPLIT.bpe.$SRC $TMP/$SPLIT.bpe.$TGT
done


# binarize data
echo "binarising the data for fairseq ingestion"
fairseq-preprocess \
  --source-lang $SRC --target-lang $TGT \
  --trainpref $TMP/train.bpe --validpref $TMP/valid.bpe --testpref $TMP/test.bpe \
  --destdir $DATABIN \
  --joined-dictionary \
  --tokenizer space \
  --workers 4 \
  --srcdict $DATABIN/fairseqdict.txt
# fairseq compatible dictionary is created and used to binarise the data
# binarised data can be used in training process now.
# empty lines are filtered by fairseq preprocess so, final corpus size is slightly lower
