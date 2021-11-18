
from __future__ import print_function
import argparse
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torchvision import datasets, transforms
from torch.autograd import Variable
from models.binarized_modules import BinarizeLinear,BinarizeConv2d,myBinarizeLinear,testBinarizeLinear
from models.binarized_modules import  Binarize,HingeLoss
import logging
from utils import *
from multiprocessing import freeze_support
import copy

# Training settings
parser = argparse.ArgumentParser(description='PyTorch MNIST Example')
parser.add_argument('--batch-size', type=int, default=64, metavar='N',
                    help='input batch size for training (default: 256)')
parser.add_argument('--test-batch-size', type=int, default=100, metavar='N',
                    help='input batch size for testing (default: 100)')
parser.add_argument('--epochs', type=int, default=30, metavar='N',
                    help='number of epochs to train (default: 20)')
parser.add_argument('--lr', type=float, default=0.005, metavar='LR',
                    help='learning rate (default: 0.001)')
parser.add_argument('--momentum', type=float, default=0.5, metavar='M',
                    help='SGD momentum (default: 0.5)')
parser.add_argument('--no-cuda', action='store_true', default=False,
                    help='disables CUDA training')
parser.add_argument('--seed', type=int, default=1, metavar='S',
                    help='random seed (default: 1)')
parser.add_argument('--gpus', default=3,
                    help='gpus used for training - e.g 0,1,3')
parser.add_argument('--log-interval', type=int, default=10, metavar='N',
                    help='how many batches to wait before logging training status')
args = parser.parse_args()
args.cuda = not args.no_cuda and torch.cuda.is_available()

torch.manual_seed(args.seed)
if args.cuda:
    torch.cuda.manual_seed(args.seed)


kwargs = {'num_workers': 1, 'pin_memory': True} if args.cuda else {}
train_loader = torch.utils.data.DataLoader(
    datasets.MNIST('../data', train=True, download=True,
                   transform=transforms.Compose([
                       transforms.ToTensor()
                       #,
                       #transforms.Normalize((0.1307,), (0.3081,))
                   ])),
    batch_size=args.batch_size, shuffle=True, **kwargs)
test_loader = torch.utils.data.DataLoader(
    datasets.MNIST('../data', train=False, transform=transforms.Compose([
                       transforms.ToTensor()
                       #,
                       #transforms.Normalize((0.1307,), (0.3081,))
                   ])),
    batch_size=args.test_batch_size, shuffle=True, **kwargs)



class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        num_hidden = 256
        self.quant = torch.quantization.QuantStub()
        self.fc1 = nn.Linear(784, num_hidden)
        self.relu1 = nn.ReLU()
        self.fc2 = nn.Linear(num_hidden, num_hidden)
        self.relu2 = nn.ReLU()
        self.fc3 = nn.Linear(num_hidden, num_hidden)
        self.relu3 = nn.ReLU()
        self.fc4 = nn.Linear(num_hidden, 10)
        self.logsoftmax=nn.LogSoftmax()
        self.drop=nn.Dropout(0.2)
        self.dequant = torch.quantization.DeQuantStub()

    def forward(self, x):
        x = self.quant(x)
        x = x.view(-1, 28*28)
        x = self.fc1(x)
        x = self.relu1(x)
        x = self.fc2(x)
        x = self.relu2(x)
        x = self.fc3(x)
        x = self.relu3(x)
        x = self.fc4(x)
        x = self.dequant(x)
        x = self.logsoftmax(x)
        return x

model = Net()
model.qconfig = torch.quantization.get_default_qat_qconfig('fbgemm')
model = torch.quantization.fuse_modules(model,[['fc1', 'relu1'],['fc2', 'relu2'],['fc3', 'relu3']])
model = torch.quantization.prepare_qat(model)

criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=args.lr)


def train(epoch):
    if args.cuda:
        torch.device("cuda")
        torch.cuda.set_device(0)
        model.cuda()
    model.train()
    for batch_idx, (data, target) in enumerate(train_loader):
        if args.cuda:
            data, target = data.cuda(), target.cuda()
        data, target = Variable(data), Variable(target)
        optimizer.zero_grad()
        output = model(data)
        loss = criterion(output, target)

        if epoch%40==0:
            optimizer.param_groups[0]['lr']=optimizer.param_groups[0]['lr']*0.1

        optimizer.zero_grad()
        loss.backward()
        for p in list(model.parameters()):
            if hasattr(p,'org'):
                p.data.copy_(p.org)
        optimizer.step()
        for p in list(model.parameters()):
            if hasattr(p,'org'):
                p.org.copy_(p.data.clamp_(-1,1))

        if batch_idx % args.log_interval == 0:
            print('Train Epoch: {} [{}/{} ({:.0f}%)]\tLoss: {:.6f}'.format(
                epoch, batch_idx * len(data), len(train_loader.dataset),
                100. * batch_idx / len(train_loader), loss.item()))
        
        
    train_loss = 0
    correct = 0
    for data, target in train_loader:
        if args.cuda:
            data, target = data.cuda(), target.cuda()
        data, target = Variable(data), Variable(target)
        output = model(data)
        train_loss += criterion(output, target).item() # sum up batch loss
        pred = output.data.max(1, keepdim=True)[1] # get the index of the max log-probability
        correct += pred.eq(target.data.view_as(pred)).cpu().sum()
    train_acc = 100. * correct / len(train_loader.dataset)
    return train_acc, train_loss

def test():
    model.eval()
    torch.device("cpu")
    md = copy.deepcopy(model)
    md.cpu()
    model_int8 = torch.quantization.convert(md)
    test_loss = 0
    correct = 0
    with torch.no_grad():
        for data, target in test_loader:
            data, target = Variable(data), Variable(target)
            output = model_int8(data)
            test_loss += criterion(output, target).item() # sum up batch loss
            pred = output.data.max(1, keepdim=True)[1] # get the index of the max log-probability
            correct += pred.eq(target.data.view_as(pred)).cpu().sum()

    test_loss /= len(test_loader.dataset)
    
    test_acc = 100. * correct / len(test_loader.dataset)
    print('\nTest set: Average loss: {:.4f}, Accuracy: {}/{} ({:.0f}%)\n'.format(
        test_loss, correct, len(test_loader.dataset),
        test_acc))
    return test_acc, test_loss

if __name__ == "__main__":
    freeze_support()
    setup_logging('mnist_train_fixed.log')
    for epoch in range(1, args.epochs + 1):
        train_acc, train_loss = train(epoch)
        test_acc, test_loss = test()
        logging.info('\n Epoch: {0}\t'
                     'Training Loss {train_loss:.4f} \t'
                     'Training Acc {train_acc:.3f}% \t'
                     'Validation Loss {val_loss:.4f} \t'
                     'Validation Acc {val_acc:.3f}% \t'
                     .format(epoch, train_loss=train_loss, train_acc=train_acc,
                             val_loss=test_loss, val_acc=test_acc))
        if epoch%5==0:
            optimizer.param_groups[0]['lr']=optimizer.param_groups[0]['lr']*0.1
    torch.save(model.state_dict(), 'mnist_fixed.pth.tar')
