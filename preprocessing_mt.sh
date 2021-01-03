#!/bin/bash
SRC=en
TGT1=pap
TGT2=pt

BPESIZE=16000
TRAIN_MINLEN=1  # remove sentences with <1 BPE token
TRAIN_MAXLEN=200  # remove sentences with >200 BPE tokens

ROOT=$(dirname "$0")
SCRIPTS=$ROOT/scripts
DATA=$ROOT/corpus


TMP=$DATA/papiamento_${SRC}_${TGT1}_${TGT2}_bpe${BPESIZE}
DATABIN=$ROOT/data-bin/papiamento_${SRC}_${TGT1}_${TGT2}_bpe${BPESIZE}
mkdir -p $TMP $DATABIN

SRC_TOKENIZER="bash $SCRIPTS/tok.sh "
TGT_TOKENIZER="bash $SCRIPTS/tok.sh"  # learn target-side BPE over untokenized (raw) text
SPM_TRAIN=$SCRIPTS/spm_train.py
SPM_ENCODE=$SCRIPTS/spm_encode.py

echo "pre-processing data"

$SRC_TOKENIZER $DATA/train.en-pap.$SRC > $TMP/train.en-pap.$SRC
$SRC_TOKENIZER $DATA/train.en-pt.$SRC > $TMP/train.en-pt.$SRC

$TGT_TOKENIZER $DATA/train.en-pap.$TGT1 > $TMP/train.en-pap.$TGT1
$TGT_TOKENIZER $DATA/train.en-pt.$TGT2 > $TMP/train.en-pt.$TGT2

$SRC_TOKENIZER $DATA/valid.en-pap.$SRC > $TMP/valid.en-pap.$SRC
$SRC_TOKENIZER $DATA/valid.en-pt.$SRC > $TMP/valid.en-pt.$SRC

$TGT_TOKENIZER $DATA/valid.en-pap.$TGT1 > $TMP/valid.en-pap.$TGT1
$TGT_TOKENIZER $DATA/valid.en-pt.$TGT2 > $TMP/valid.en-pt.$TGT2


$SRC_TOKENIZER $DATA/test.en-pap.$SRC > $TMP/test.en-pap.$SRC
$SRC_TOKENIZER $DATA/test.en-pt.$SRC > $TMP/test.en-pt.$SRC

$TGT_TOKENIZER $DATA/test.en-pap.$TGT1 > $TMP/test.en-pap.$TGT1
$TGT_TOKENIZER $DATA/test.en-pt.$TGT2 > $TMP/test.en-pt.$TGT2

cat $TMP/train.en-pt.$SRC | wc -l
cat $DATA/train.en-pap.$SRC | wc -l

# learn BPE with sentencepiece
python $SPM_TRAIN \
  --input=$TMP/train.en-pap.$SRC,$TMP/train.en-pap.$TGT1,$TMP/train.en-pt.$SRC,$TMP/train.en-pt.$TGT2 \
  --model_prefix=$DATABIN/sentencepiece.bpe \
  --vocab_size=$BPESIZE \
  --character_coverage=1.0 \
  --model_type=bpe

# encode train/valid/test
python $SPM_ENCODE \
  --model $DATABIN/sentencepiece.bpe.model \
  --output_format=piece \
  --inputs $TMP/train.en-pap.$SRC $TMP/train.en-pap.$TGT1 \
  --outputs $TMP/train.en-pap.bpe.$SRC $TMP/train.en-pap.bpe.$TGT1 \

python $SPM_ENCODE \
  --model $DATABIN/sentencepiece.bpe.model \
  --inputs  $TMP/train.en-pt.$SRC $TMP/train.en-pt.$TGT2  \
  --outputs  $TMP/train.en-pt.bpe.$SRC $TMP/train.en-pt.bpe.$TGT2 \


for SPLIT in "valid.en-pap" "test.en-pap"; do \
  python $SPM_ENCODE \
    --model $DATABIN/sentencepiece.bpe.model \
    --output_format=piece \
    --inputs $TMP/$SPLIT.$SRC $TMP/$SPLIT.$TGT1 \
    --outputs $TMP/$SPLIT.bpe.$SRC $TMP/$SPLIT.bpe.$TGT1
done

for SPLIT in "valid.en-pt" "test.en-pt"; do \
  python $SPM_ENCODE \
    --model $DATABIN/sentencepiece.bpe.model \
    --output_format=piece \
    --inputs $TMP/$SPLIT.$SRC $TMP/$SPLIT.$TGT2 \
    --outputs $TMP/$SPLIT.bpe.$SRC $TMP/$SPLIT.bpe.$TGT2
done
cut -f1 $DATABIN/sentencepiece.bpe.vocab| tail -n +4 | sed "s/$/ 100/g" > $DATABIN/fairseqdict.txt
# binarize data
echo "binarising the data for fairseq ingestion"
fairseq-preprocess \
  --source-lang $SRC --target-lang $TGT2 \
  --trainpref $TMP/train.en-pt.bpe --validpref $TMP/valid.en-pt.bpe --testpref $TMP/test.en-pt.bpe \
  --destdir $DATABIN \
  --joined-dictionary \
  --tokenizer space \
  --workers 4 \
  --srcdict $DATABIN/fairseqdict.txt


fairseq-preprocess \
  --source-lang $SRC --target-lang $TGT1 \
  --trainpref $TMP/train.en-pap.bpe --validpref $TMP/valid.en-pap.bpe --testpref $TMP/test.en-pap.bpe \
  --destdir $DATABIN \
  --joined-dictionary \
  --tokenizer space \
  --workers 4 \
  --srcdict $DATABIN/fairseqdict.txt

