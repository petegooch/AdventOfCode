#!/usr/bin/python3

def stringifyarray(array):
  # For each element, grab the string representation
  # We then join it all back together as a massive string
  return "\n".join(map(lambda x: str(x), array))

def prependspacing(string):
  # Returns a string where every line is indented by two spaces
  return "\n".join(map(lambda x: f"  {str(x)}", string.split("\n")))
    
class Position:
  row=0
  column=0
  def __init__(self, row, column):
    self.row = row
    self.column = column
  
class Number:
  number=0
  def __init__(self, row, column, number):
    self.position=Position(row,column)
    self.number=number
    self.symbols=[]
  
class Symbol:
  symbol=''
  def __init__(self,row,column,symbol):
    self.position=Position(row,column)
    self.symbol=symbol
    self.numbers=[]

class Schematic:
  numbers=[]
  symbols=[]

def loadinput(filename):
  schematic=Schematic()
  
  with open(filename,'r') as file:
    linenumber = 0
    for line in file:
      line=line.strip('\n')
      linenumber += 1
      foundnumbers=[]
      foundsymbols=[]
      print(f"{linenumber} : {line!r}")
      
      # Prepare some variables for processing each line
      column = 0
      processingnumber = False
      tempnumber = 0
      numbercolumn = 0
          
      for character in list(line):
        column+=1
        # We see a number
        if character.isnumeric():
          if processingnumber==False:
            tempnumber=0
            numbercolumn=column
            processingnumber=True
          tempnumber*=10
          tempnumber+=int(character)
        # We don't see a number
        else:
          # We've just finished processing a number
          if processingnumber==True:
            foundnumbers.append(Number(linenumber,numbercolumn,tempnumber))
            processingnumber=False
          # Is this non-numeric a symbol?
          if character!='.':
            foundsymbols.append(Symbol(linenumber,column,character))
      # The last number processing was at the end of the line
      if processingnumber==True:
        foundnumbers.append(Number(linenumber,numbercolumn,tempnumber))

      # Lets copy the numbers and symbols to the collections on the root of the object
      for number in foundnumbers:
        schematic.numbers.append(number)
      for symbol in foundsymbols:
        schematic.symbols.append(symbol)
  return schematic

schematic=loadinput('input.txt')

def connectobjects(number, symbol):
  number.symbols.append(symbol)
  symbol.numbers.append(number)

def issymboladjacent(number, symbol):
  return (
         (number.position.column-1 <= symbol.position.column <= number.position.column + len(str(number.number))) and
         (number.position.row-1 <= symbol.position.row <= number.position.row+1)
         )

for number in schematic.numbers:
  symbols = list(filter(lambda candidate: issymboladjacent(number,candidate),schematic.symbols))
  for symbol in symbols:
    connectobjects(number, symbol)

total1=sum(map(lambda partnumber: partnumber.number, list(filter(lambda candidate: len(candidate.symbols) > 0, schematic.numbers))))
print(total1)

def calculategearratio(symbol):
  ratio=1
  for number in map(lambda n: n.number, symbol.numbers):
    ratio = ratio * number
  return ratio

gears=list(filter(lambda s: s.symbol=='*' and len(s.numbers) == 2, schematic.symbols))
total2 = sum(map(lambda gear: calculategearratio(gear), gears))
print(total2)

