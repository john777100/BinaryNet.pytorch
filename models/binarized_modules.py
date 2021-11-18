import torch
import pdb
import torch.nn as nn
import math
from torch.autograd import Variable
from torch.autograd import Function

import numpy as np

def Binarize(tensor,quant_mode='det'):
    if quant_mode=='det':
        return tensor.sign()
    else:
        return tensor.add_(1).div_(2).add_(torch.rand(tensor.size()).add(-0.5)).clamp_(0,1).round().mul_(2).add_(-1)




class HingeLoss(nn.Module):
    def __init__(self):
        super(HingeLoss,self).__init__()
        self.margin=1.0

    def hinge_loss(self,input,target):
            #import pdb; pdb.set_trace()
            output=self.margin-input.mul(target)
            output[output.le(0)]=0
            return output.mean()

    def forward(self, input, target):
        return self.hinge_loss(input,target)

class SqrtHingeLossFunction(Function):
    def __init__(self):
        super(SqrtHingeLossFunction,self).__init__()
        self.margin=1.0

    def forward(self, input, target):
        output=self.margin-input.mul(target)
        output[output.le(0)]=0
        self.save_for_backward(input, target)
        loss=output.mul(output).sum(0).sum(1).div(target.numel())
        return loss

    def backward(self,grad_output):
       input, target = self.saved_tensors
       output=self.margin-input.mul(target)
       output[output.le(0)]=0
       import pdb; pdb.set_trace()
       grad_output.resize_as_(input).copy_(target).mul_(-2).mul_(output)
       grad_output.mul_(output.ne(0).float())
       grad_output.div_(input.numel())
       return grad_output,grad_output

def Quantize(tensor,quant_mode='det',  params=None, numBits=8):
    tensor.clamp_(-2**(numBits-1),2**(numBits-1))
    if quant_mode=='det':
        tensor=tensor.mul(2**(numBits-1)).round().div(2**(numBits-1))
    else:
        tensor=tensor.mul(2**(numBits-1)).round().add(torch.rand(tensor.size()).add(-0.5)).div(2**(numBits-1))
        quant_fixed(tensor, params)
    return tensor

#import torch.nn._functions as tnnf


class BinarizeLinear(nn.Linear):

    def __init__(self, *kargs, **kwargs):
        super(BinarizeLinear, self).__init__(*kargs, **kwargs)

    def forward(self, input):

        if input.size(1) != 784:
            input.data=Binarize(input.data)
        if not hasattr(self.weight,'org'):
            self.weight.org=self.weight.data.clone()
        self.weight.data=Binarize(self.weight.org)
        out = nn.functional.linear(input, self.weight)
        if not self.bias is None:
            self.bias.org=self.bias.data.clone()
            out += self.bias.view(1, -1).expand_as(out)

        return out

class myBinarizeLinear(nn.Linear):

    def __init__(self, *kargs, **kwargs):
        super(myBinarizeLinear, self).__init__(*kargs, **kwargs)

    def forward(self, input):
        batch_size = input.data.shape[0]
        input_size = input.data.shape[1]
        if input.size(1) != 784:
            input.data = input.data.multiply(255).add(-128) # normalize to -128~127
        else:
            input.data = input.data.multiply(255).add(-128) # normalize to -128~127

        K=5
        input.data = input.data.divide(2**(K-1)) # prune K=3, being -16~15
        # input.data = input.data.multiply(2) # scale to -32~30
        post_channel_num = int(256/(2**K))
        x_num = input.data.add(post_channel_num).multiply(0.5) #(input.data + 256)/2 (getting # of 1)
        bin_input = torch.arange(0, post_channel_num,
                step=1).long().expand(batch_size, input_size, post_channel_num)
        x_num = x_num.expand(post_channel_num, batch_size, input_size).permute(1, 2, 0) # x_num.shape = [64, 784, 256]

        #print(x_num.get_device())
        
        # Common out if cpu only
        x_num = x_num.to('cuda:0')
        bin_input = bin_input.to('cuda:0')

        bin_input = bin_input.less(x_num)
        bin_input = bin_input.int().float().multiply(2).add(-1)# * 2 - 1
        #torch.set_printoptions(threshold=100000000000000)

        if not hasattr(self.weight,'org'):
            self.weight.org=self.weight.data.clone()
        self.weight.data=Binarize(self.weight.org)

        #out = nn.functional.linear(input, self.weight)
        out = nn.functional.linear(bin_input.permute(0, 2,
            1).reshape(batch_size*post_channel_num, input_size), self.weight)
        out = out.reshape(batch_size, post_channel_num, -1)
        out = torch.sum(out, 1) / 2

        if not self.bias is None:
            self.bias.org=self.bias.data.clone()
            out += self.bias.view(1, -1).expand_as(out)

        return out

class testBinarizeLinear(nn.Linear):

    def __init__(self, *kargs, **kwargs):
        super(testBinarizeLinear, self).__init__(*kargs, **kwargs)

    def forward(self, input):
        input.data = input.data*255 - 128

        if not hasattr(self.weight,'org'):
            self.weight.org=self.weight.data.clone()
        self.weight.data=Binarize(self.weight.org)
        out = nn.functional.linear(input, self.weight)
        if not self.bias is None:
            self.bias.org=self.bias.data.clone()
            out += self.bias.view(1, -1).expand_as(out)

        return out


class BinarizeConv2d(nn.Conv2d):

    def __init__(self, *kargs, **kwargs):
        super(BinarizeConv2d, self).__init__(*kargs, **kwargs)


    def forward(self, input):
        if input.size(1) != 3:
            input.data = Binarize(input.data)
        if not hasattr(self.weight,'org'):
            self.weight.org=self.weight.data.clone()
        self.weight.data=Binarize(self.weight.org)

        out = nn.functional.conv2d(input, self.weight, None, self.stride,
                                   self.padding, self.dilation, self.groups)

        if not self.bias is None:
            self.bias.org=self.bias.data.clone()
            out += self.bias.view(1, -1, 1, 1).expand_as(out)

        return out
