from random import randint

mountain = [[00 for _ in range(66)] for _ in range(66)]
neibour = [[set() for _ in range(66)] for _ in range(66)]
for i in range(66):
    for j in range(66):
        if 1<=i<=64 and 1<=j<=64:
            neibour[i][j] = {(i-1,j),(i+1,j),(i,j+1),(i,j-1)}
        else:
            neibour[i][j] = set()
for _ in range(10):
    x = randint(1,64)
    y = randint(1,64)
    print(x,y)
    new_mountain = [[0 for _ in range(66)] for _ in range(66)]
    new_mountain[x][y] = randint(20,64)
    print(new_mountain)
    allnodes = {(x,y)}
    newnodes = {1}
    while len(newnodes) != 0:
        newnodes = set()
        for node in allnodes:
            for n in neibour[node[0]][node[1]]:
                if new_mountain[n[0]][n[1]] == 0:
                    down = randint(0,5)
                    new_mountain[n[0]][n[1]] = new_mountain[node[0]][node[1]] - down
                    print(new_mountain[n[0]][n[1]])
                    if new_mountain[n[0]][n[1]] > 10:
                        newnodes.add(n)
        allnodes |= newnodes
    print(new_mountain)
    for i in range(66):
        for j in range(66):
            if new_mountain[i][j] > mountain[i][j]:
                mountain[i][j] = new_mountain[i][j]

for i in range(1,65):
    for j in range(1,65):
        print(f'{mountain[i][j]:3}', sep = '', end = ' ')
    print()
    
string = 'mountain:\n'
for i in range(64):
    string += '.db '
    for j in range(64):
        string += str(mountain[i][j])
        if j < 63:
            string += ','
    string += '\n'

with open("mountain.asm", 'w') as f:
    print(string, file = f)
