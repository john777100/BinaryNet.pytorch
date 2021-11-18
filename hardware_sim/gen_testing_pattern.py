import random
import numpy as np
TEST_DATA_CNT	= 50
BIT_WIDTH 			= 2
CHANNEL_CNT			= 4
INPUT_DIM			= 10
OUTPUT_DIM			= 10

value_up_limit		= CHANNEL_CNT/2-1 ## 1
value_in			= np.random.randint(CHANNEL_CNT, size=(TEST_DATA_CNT, INPUT_DIM))
weight				= np.random.randint(2, size=(OUTPUT_DIM, INPUT_DIM))

real_weight			= np.where(weight<1, -1, 1)
real_value_in 		= np.where(value_in<CHANNEL_CNT/2, value_in, value_in-CHANNEL_CNT) 
real_value_out 		= np.matmul(real_value_in, np.transpose(real_weight))
real_value_out		= np.where(real_value_out > value_up_limit, value_up_limit, real_value_out)
real_value_out		= np.where(real_value_out < -CHANNEL_CNT/2, -CHANNEL_CNT/2, real_value_out)
value_out		= np.where(real_value_out < 0, real_value_out+CHANNEL_CNT, real_value_out)




with open("pattern/file_x.txt",'w') as f:
	for i in range(TEST_DATA_CNT):
		for j in range(INPUT_DIM):
			f.writelines(str(value_in[i,j])+'\n')


with open("pattern/file_weight.txt",'w') as f:
	for i in range(OUTPUT_DIM):
		for j in range(INPUT_DIM):
			f.writelines(str(weight[i,j])+'\n')

with open("pattern/file_y.txt",'w') as f:
	for i in range(TEST_DATA_CNT):
		for j in range(OUTPUT_DIM):
			f.writelines(str(value_out[i,j])+'\n')
