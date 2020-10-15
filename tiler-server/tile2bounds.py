"""
Conver tiles to bounds
author: @developmentseed
usage:
      python tile2bounds.py 14/4814/8796
"""
import sys
from mercantile import  bounds, parent , Tile

arrayTile=str(sys.argv[1]).split('/')
lnglatbbox = bounds(Tile(x=int(arrayTile[1]), y=int(arrayTile[2]), z=int(arrayTile[0])))
print(f'{lnglatbbox[0]},{lnglatbbox[1]},{lnglatbbox[2]},{lnglatbbox[3]}')
