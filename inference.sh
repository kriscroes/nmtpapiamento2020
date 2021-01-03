#!/usr/bin/env python
BPESIZE=3000
fairseq-generate \
    data-bin/papiamento_en_pap_bpe$BPESIZE/ \
    --task translation \
    --source-lang en --target-lang pap \
    --path checkpoints/checkpoint_best.pt \
    --beam 6 --lenpen 1.2 \
    --gen-subset test \
    --scoring sacrebleu \
    --remove-bpe=sentencepiece
