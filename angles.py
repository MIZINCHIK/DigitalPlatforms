import sys
import math


def to_hex(n: float):
    res = 0 if n >= 0 else 2048
    n = round(abs(n) * (2 ** 11 - 1))
    res += int(n)
    return "%.X" % res


if __name__ == "__main__":
    """
        argv[1] - Half of central angle subtended by the arc (in degrees)
                    default = 30 
        argv[2] - Name for output files. Optional argument
                    cos<name>, sin<name>
                    default = .rom
    """
    if len(sys.argv) > 3:
        print("Too many arguments")
    if len(sys.argv) > 1:
        a = int(sys.argv[1])
    else:
        a = 30
    if len(sys.argv) > 2:
        name = sys.argv[2]
    else:
        name = '.rom'
    sin = open('sin'+name, 'w')
    cos = open('cos'+name, 'w')
    print('v2.0 raw', file=sin)
    print('v2.0 raw', file=cos)
    tga = math.tan(math.degrees(float(a)))
    for x in range(1, 25):
        b = math.atan((x - 12.5) / 12 * tga)
        print(to_hex(math.sin(-2 * b)), end=' ', file=sin)
        print(to_hex(math.cos(-2 * b)), end=' ', file=cos)
        if x % 8 == 0:
            print(file=sin)
            print(file=cos)
