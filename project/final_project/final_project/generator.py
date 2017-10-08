from random import randint

x = int(input("input x"))
y = int(input("input y"))
string = 'mountain:\n'
for i in range(x):
    string += '.db '
    for j in range(y):
        string += str(randint(10,128))
        if j != y - 1:
            string += ','
    string += '\n'

with open("mountain.asm", 'w') as f:
    print(string, file = f)
