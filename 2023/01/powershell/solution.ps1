#!/snap/bin/pwsh
function GetFirstCharacterIfNumber ($String) {
  # If our string begins with a number (English or Number)
  # we want to return it.  Otherwise, return a blank string.
  # First, if the string begins with zero through nine, we replace
  # it with the value.
  # Last, if the first character is a number, we return it, otherwise
  # we return a blank string.
  $String `
    -replace '^zero','0' `
    -replace '^one','1' `
    -replace '^two','2' `
    -replace '^three','3' `
    -replace '^four','4' `
    -replace '^five','5' `
    -replace '^six','6' `
    -replace '^seven','7' `
    -replace '^eight','8' `
    -replace '^nine','9' `
    -replace '^([0-9]?).*','$1'
  ? { $_.length -gt 0 } # Exclude blank entries from our result
}

function BreakStringToSubstrings ($String) {
  # Break our string into all possible substrings, anchored to the right.
  # ie: abcde, bcde, cde, de, e
  0..(($String.Length)-1) | % { $String.substring($_,$String.Length - $_) }
}

function StringToCalibrationInt ($String) {
  # Return the first and last numbers found in our string
  ( # First, find our numbers and join them to a 
    (BreakStringToSubstrings $String | % { GetFirstCharacterIfNumber $_ }) -join ''
  )[0,-1] -join '' # Extract the first and last numbers
}

Get-Content input.txt | % { StringToCalibrationInt $_ } |
% -begin {$sum=0} -process {$sum+=$_} -end {$sum}

