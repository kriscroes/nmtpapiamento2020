#!/usr/bin/env python

CUDA_VISIBLE_DEVICES=0,1,2,3 fairseq-train \
    data-bin/papiamento_en_pap_pt_bpe16000/ \
    --fp16 \
    --log-format json \
    --task multilingual_translation --lang-pairs en-pap,en-pt \ 
    --arch multilingual_transformer_iwslt_de_en  --share-all-embeddings \ 
    --encoder-langtok  tgt \
    --encoder-normalize-before --decoder-normalize-before \
    --dropout 0.4 --attention-dropout 0.2 --relu-dropout 0.2 \
    --weight-decay 0.0001 \
    --label-smoothing 0.2 --criterion label_smoothed_cross_entropy \
    --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0 \
    --lr-scheduler inverse_sqrt --warmup-updates 4000 --warmup-init-lr 1e-7 \
    --lr 1e-3 --min-lr 1e-9 \
    --max-tokens 4000 \
    --max-epoch 100 --save-interval 25
    #--encoder-layers 6 --decoder-layers 6 \
    #--encoder-embed-dim 512 --decoder-embed-dim 512 \
    #--encoder-ffn-embed-dim 2048 --decoder-ffn-embed-dim 2048 \
    #--encoder-attention-heads 8 --decoder-attention-heads 8 \

# If you have a Volta or newer GPU you can further improve 
# training speed by adding the --fp16 flag.

