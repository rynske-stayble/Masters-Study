path = 'deprotonated.pdb'

with open(path) as f:
    s = f.read()
    sod = s.count('SOD')/2
    oh = (s.count('H') - sod)/2
    depRate = float(sod) / (float(sod) + float(oh))
    print(depRate)