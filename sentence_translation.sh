#!/bin/bash
python scripts/spm_encode.py --model data-bin/papiamento_en_pap_pt_bpe16000/sentencepiece.bpe.model |	
fairseq-interactive \
    data-bin/papiamento_en_pap_pt_bpe16000/ \
    --task multilingual_translation \
    --encoder-langtok tgt \
    --lang-pairs en-pap,en-pt \
    --source-lang en --target-lang pap \
    --path checkpoints/checkpoint_best.pt \
    --beam 6 --lenpen 1.2 \
    --scoring sacrebleu \
    --remove-bpe=sentencepiece \
    --quiet
