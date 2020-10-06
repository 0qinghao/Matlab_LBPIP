# 切割 CTU
[CTU, src] = spilt_CTU()
提取视频帧的代码已有(yuvRead.m)，提取对象写死在代码里
CTU: 结构体，包含 64*64 大小的数据块 data，及左上角的坐标 x,y
src: 原始数据（单帧）


# 编码 CTU
[CTU_bits(i), img_rebuild, spilt_frame, mode_frame] = encode_CTU(CTU(i), img_rebuild, spilt_frame, mode_frame)
取 64*64 块的 RDCost 作为当前 CTU 的体积 CTU_bits(i)，重建图像加入当前 CTU，当前 CTU 的分块记录替换为分块结果后的分块记录，当前 CTU 的模式记录替换为分块结果后的模式记录

## 计算 256个 4*4 块的 RDCost
[spilt_frame, mode_frame, rdc_4] = get_rdc4(CTU, img_src, img_rebuild, spilt_frame, mode_frame)
按 Z-order 顺序作为 rdc_4 下标，将分块记录 spilt_frame 对应 CTU 的位置填满 4，将临时模式记录 mode_frame 对应 CTU 的位置填满模式，img_rebuild 只在内部每处理完一个 PU 时进行填充，不需要传出

### RDCost 的计算
rdc = cal_rdc(res, mode_bits, mode_blk)

根据 mode_blk 扫描出 res，用 huffman_test 测算需要的 bits，再加上 mode_bits，以编码该块需要的 bits 作为 RDCost

### 待编码残差的计算
[res, ~, ~, mode_blk] = mode_select_blk(img_src, img_rebuild_temp, CTU.x, CTU.y, cu_size)

img_rebuild_temp 在外部每处理完一个 PU 就填充对应位置的数据

### 模式 bits 的计算
mode_btits = Mode1()

每处理一个块之前，需要临时把 mode_frame 填充上，根据是否选用大分块确定是否还原前一步的 mode_frame

## 计算 64 个 8*8 块的 RDCost
[spilt_frame, mode_frame, rdc_8] = get_rdc8(CTU, img_src, img_rebuild, spilt_frame, mode_frame, rdc_4)

输入的 mode_frame 和 spile_frame 和 rdc_4 是经过上一步处理后的数据

每个 8\*8 块与其覆盖的 4 个 4\*4 块 RDCost 总和进行比较，取较小者作为 8*8 块的 RDCost，按 Z-order 顺序作为 rdc_8 下标，同时更新分块记录 spilt_frame 和临时模式记录 mode_frame（rdc_8 更小则填充对应模式和分块模式 8，否则保持上一层结果不变）

img_rebuild_temp 在外部每处理完一个 PU 就填充对应位置的数据

## 计算 16 个 16*16 块的 RDCost
每个 16\*16 块与其覆盖的 4 个 8\*8 块 RDCost 总和进行比较，取较小者作为 16*16 块的 RDCost，按 Z-order 顺序作为数据下标，同时更新分块记录和临时模式记录


## 计算 4 个 32*32 块的 RDCost
每个 32\*32 块与其覆盖的 4 个 16\*16 块 RDCost 总和进行比较，取较小者作为 32*32 块的 RDCost，按 Z-order 顺序作为数据下标，同时更新分块记录和临时模式记录

## 计算 1 个 64*64 块的 RDCost
64\*64 块与其覆盖的 4 个 32\*32 块 RDCost 总和进行比较，取较小者作为 64*64 块的 RDCost，同时更新分块记录和临时模式记录


# 统计
[size_all, blk_size_sum] = summary(CTU_bits, spilt_frame, mode_frame)
统计结果
size_all 为一帧图像的大小
blk_size_sum 分别记录大小为 4 8 16 32 64 块的数量




# 切割 CTU
[CTU, src] = spilt_CTU()
提取视频帧的代码已有(yuvRead.m)，提取对象写死在代码里
CTU: 结构体，包含 64*64 大小的数据块 data，及左上角的坐标 x,y
src: 原始数据（单帧）


# 编码 CTU
[CTU_bits(i), img_rebuild, spilt_frame, mode_frame, loop_mode_frame] = encode_CTU(CTU(i), img_rebuild, spilt_frame, mode_frame)
取 64*64 块的 RDCost 作为当前 CTU 的体积 CTU_bits(i)，重建图像加入当前 CTU，当前 CTU 的分块记录替换为分块结果后的分块记录，当前 CTU 的模式记录替换为分块结果后的模式记录

## 计算 256个 4*4 块的 RDCost
[spilt_frame, mode_frame, loop_mode_frame, rdc_4] = get_rdc4(CTU, img_src, img_rebuild, spilt_frame, mode_frame, loop_mode_frame)
按 Z-order 顺序作为 rdc_4 下标，将分块记录 spilt_frame 对应 CTU 的位置填满 4，将临时模式记录 mode_frame 对应 CTU 的位置填满模式，img_rebuild 只在内部每处理完一个 PU 时进行填充，不需要传出

### RDCost 的计算
rdc = cal_rdc(res, mode_bits_loop, mode_blk)

根据 mode_blk 扫描出 res，用 huffman_test 测算需要的 bits，再加上 mode_bits，以编码该块需要的 bits 作为 RDCost

### 待编码残差的计算
[res, ~, ~, mode_blk] = mode_select_loop(img_src, img_rebuild_temp, CTU.x, CTU.y, cu_size)

img_rebuild_temp 在外部每处理完一个 PU 就填充对应位置的数据

### 模式 bits 的计算
mode_bits_loop = huffman_test(mode_diff)
mode_diff 通过多读取上一层的结果得到初始值

每处理一个块之前，需要临时把 mode_frame 填充上，根据是否选用大分块确定是否还原前一步的 mode_frame

## 计算 64 个 8*8 块的 RDCost
[spilt_frame, mode_frame, rdc_8] = get_rdc8(CTU, img_src, img_rebuild, spilt_frame, mode_frame, rdc_4)

输入的 mode_frame 和 spile_frame 和 rdc_4 是经过上一步处理后的数据

每个 8\*8 块与其覆盖的 4 个 4\*4 块 RDCost 总和进行比较，取较小者作为 8*8 块的 RDCost，按 Z-order 顺序作为 rdc_8 下标，同时更新分块记录 spilt_frame 和临时模式记录 mode_frame（rdc_8 更小则填充对应模式和分块模式 8，否则保持上一层结果不变）

img_rebuild_temp 在外部每处理完一个 PU 就填充对应位置的数据

## 计算 16 个 16*16 块的 RDCost
每个 16\*16 块与其覆盖的 4 个 8\*8 块 RDCost 总和进行比较，取较小者作为 16*16 块的 RDCost，按 Z-order 顺序作为数据下标，同时更新分块记录和临时模式记录


## 计算 4 个 32*32 块的 RDCost
每个 32\*32 块与其覆盖的 4 个 16\*16 块 RDCost 总和进行比较，取较小者作为 32*32 块的 RDCost，按 Z-order 顺序作为数据下标，同时更新分块记录和临时模式记录

## 计算 1 个 64*64 块的 RDCost
64\*64 块与其覆盖的 4 个 32\*32 块 RDCost 总和进行比较，取较小者作为 64*64 块的 RDCost，同时更新分块记录和临时模式记录


# 统计
[size_all, blk_size_sum] = summary(CTU_bits, spilt_frame, mode_frame)
统计结果
size_all 为一帧图像的大小
blk_size_sum 分别记录大小为 4 8 16 32 64 块的数量