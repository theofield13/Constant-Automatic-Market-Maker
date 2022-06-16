# Concentrated AMM

## ~Definition
Meaning liquidity at prices. Prices are derived from tokens in the reserve

## Spec

## Allocate

Add tokens to reserves at some price and give me liquidity tokens.

## Swap

Input tokens and get some tokens out at a specific price.

## Remove

Remove tokens from reserves, burn my liq. at some price.

### Uniswap V3 reference

- Tracks sqrt(Price) instead of reserves
- Ticks are mapped to prices with the formula 1.0001¹ -> 0.01% -> 1 basis point difference in prices
- Ticks are ordered by price, which lets up loop thorugh them when we swap
- Something like Price = Y / X
- L = sqrt(XY)
- L² = XY
- L² = k
- Add liquidity, liquidityToAdd * reserve0 / 



### Price & Reserves

We have reserves X and Y. We have a price 

'Price = Y /X'

'Y = X / Price'

'X = Y * Price'

## Swap

'dX + X = (Y - dY) / Price'
'dY + Y = (X - dX) / Price'

## Problem

- No way to loop over the prices and see how much liquidity there is


## Swap? What happens?

1. tell contract to swap ´amount' of token for AT MOST 'price'
2. get the current price
3. get the current liquidity ath the current price 
4. get the next price (?)
5. get the atctual amount that are being swapped, both the input and output amounts
6. do the swap
7. update the price if we actually get to the next price?
8. Transfer the tokens