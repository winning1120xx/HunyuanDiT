export CUDA_VISIBLE_DEVICES=0
model='DiT-g/2'                                                   # model type
resume_module_root=./ckpts/t2i/model/pytorch_model_distill.pt     # resume checkpoint
index_file=dataset/porcelain/jsons/porcelain.json                 # the selected data indices
results_dir=./log_EXP                                             # save root for results
batch_size=2                                                      # training batch size
image_size=1024                                                   # training image resolution
grad_accu_steps=1                                                 # gradient accumulation steps
warmup_num_steps=0                                                # warm-up steps
lr=0.0001                                                         # learning rate
ckpt_every=100                                                    # create a ckpt every a few steps.
ckpt_latest_every=2000                                            # create a ckpt named `latest.pt` every a few steps.
rank=128                                                           # rank of lora
max_training_steps=2000                                           # Maximum training iteration steps
task_flag="lora_porcelain_ema_rank${rank}"                             # task flag
echo $task_flag

PYTHONPATH=./ deepspeed hydit/train_deepspeed.py \
    --no-flash-attn \
    --task-flag ${task_flag} \
    --model ${model} \
    --training-parts lora \
    --rank ${rank} \
    --resume \
    --resume-module-root ${resume_module_root} \
    --lr ${lr} \
    --noise-schedule scaled_linear --beta-start 0.00085 --beta-end 0.018 \
    --predict-type v_prediction \
    --uncond-p 0 \
    --uncond-p-t5 0 \
    --index-file ${index_file} \
    --random-flip \
    --batch-size ${batch_size} \
    --image-size ${image_size} \
    --global-seed 999 \
    --grad-accu-steps ${grad_accu_steps} \
    --warmup-num-steps ${warmup_num_steps} \
    --use-fp16 \
    --ema-dtype fp32 \
    --results-dir ${results_dir} \
    --ckpt-every ${ckpt_every} \
    --max-training-steps ${max_training_steps}\
    --ckpt-latest-every ${ckpt_latest_every} \
    --log-every 10 \
    --use-zero-stage 2 \
    --qk-norm \
    --rope-img base512 \
    --rope-real \
    --gradient-checkpointing \
    --deepspeed-optimizer \
    --deepspeed \
    "$@"
