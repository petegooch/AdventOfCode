#!/usr/bin/awk -f

# Sample input
# Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53

BEGIN {
  FS="[:|]"
  # $1 = Card
  # $2 = Winning Numbers
  # $3 = Scratched
  firsttotalscore=0
}
{
  # For each card, let's figure out the scores and values
  count=0
  score=0
  split($1,cardlabel," ")
  split($2,winningnumbers," ")
  split($3,candidates," ")
  cardnumber=cardlabel[2]
  for (expectednumberindex in winningnumbers) {
    expectednumber = winningnumbers[expectednumberindex]
    print "Checking for", expectednumber
    for (candidateindex in candidates) {
      candidate=candidates[candidateindex]
      if (candidate==expectednumber) {
        confirmed[count++] = expectednumber
        if (score==0) {
          score=1
        }
        else {
          score=score*2
        }
        #print "Found", candidate
      }
    }
  }
  print cardnumber, count, score
  # Although we figured the count and score for the card
  # we do not yet have enough information to sum the scores
  # We will need to do a final pass later to figure out
  # how many of each card we might have
  result[cardnumber, "count"] = count
  result[cardnumber, "score"] = score
  result[cardnumber, "copies"] = 1 # The cards are already in the stack
  firsttotalscore=firsttotalscore+score
}
END {
  totalcardcount=0
  
  # We know we are going to have at least the first card to play
  currentcard=1
  result[currentcard, "copies"] = 1

  # As long as we have cards, we can keep scratching
  while (result[currentcard, "copies"] > 0) {
    print "Card", currentcard, "Copies", result[currentcard, "copies"], "Count", result[currentcard, "count"]
    totalcardcount = totalcardcount + result[currentcard, "copies"]
    # Increment the counts of the next batch of cards
    for (i=1; i<=result[currentcard, "count"]; i++) {
      nextcardindex=currentcard+i
      nextcardcopies=result[nextcardindex, "copies"]
      # If card 1 has 2 winnings, we earn card 2 and card 3
      # If card 2 has 2 winnings, we earn another card 3 and a card 4
      # If card 3 has 2 winnings, we earn another card 4 and a card 5 for each copy of card 3
      nextcardcopies=nextcardcopies + (result[currentcard, "copies"])
      print "  Card", nextcardindex, "from", result[nextcardindex, "copies"], "to", nextcardcopies
      result[nextcardindex, "copies"]=nextcardcopies
    }
    currentcard++
  }
  
  
  # Now that we know how many of each card we are going to have
  
  print "First Solution: ", firsttotalscore
  print "Second Solution:", totalcardcount
}
