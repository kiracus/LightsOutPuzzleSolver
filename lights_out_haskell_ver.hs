-- A lights out puzzle solver in haskell
-- prints a list of solutions given the size of the grids

{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# OPTIONS_GHC -Wno-incomplete-patterns #-}
{-# HLINT ignore "Use camelCase" #-}

lights_out :: Int -> [[String]]
lights_out num = filter checkSolution (clicklists num)

-- for testing (run main, then type any integer between 1~19 and press enter)
main :: IO ()
main = go

go :: IO()
go = do
    putStr ">>> "
    input <- getLine
    if input == "0" then error "try integer >= 1"
    else do
        let num = read input
        print (lights_out num)
        go


-- define Color
data Color = Blue | Red deriving (Eq)
showColor :: Color -> String
showColor Blue = "Blue"
showColor Red = "Red"
instance Show Color where
    show = showColor

-- generate all candidates
clicklists :: Int -> [[String]]
clicklists number =
    sequence (replicate number ["Flip", "No"])

-- check if a solution is validate
checkSolution :: [String] -> Bool
checkSolution sol = res
    where 
        size            = length sol
        row0            = buildRow0 size
        lastRowColor    = loop size 1 row0 sol
        res              = validate lastRowColor

-- build row 0 (of all "No"s)
buildRow0 :: Int -> [[Char]]
buildRow0 num = replicate num "No"

-- loop through rows
loop :: Int -> Int -> [String] -> [String] -> [Color]
loop size index prevFlip currFlip = rowColor
    where
        -- get color of curr row after flip
        currColor = getColor prevFlip currFlip
        rowColor = 
            if index == size then currColor              -- at last row so return color
            else loop size (index+1) currFlip nextFlip     -- loop to next row
                where nextFlip = getFlip currColor       -- get nextFlip from currColor

-- get next Flip by curr color, only flip the grid with blue grid above
getFlip :: [Color] -> [String]
getFlip [] = []
getFlip (x:xs)
    | x == Blue = "Flip" : getFlip xs
    | otherwise = "No" : getFlip xs

-- get curr color by prev flip and curr flip
getColor :: [String] -> [String] -> [Color]

getColor [h] [x]  -- case of 1*1 grid
    | x == "Flip" = [Red]
    | otherwise = [Blue]

getColor (h:xs) (x:y:ys) = color:zs
    where 
        color = findColor $ countFlip [h, x, y]
        zs = getColor' xs (x:y:ys)

-- cases could be: 
-- H _ _ _    _ _ H _ _    _ _ _ H
-- X Y _ _    _ X Y Z _    _ _ X Y

-- the 1st case is handled in getColor (^^ above)
-- the 2nd and the 3rd case is handled in getColor' (below)

-- getColor' _ _ = [Red]

getColor' :: [String] -> [String] -> [Color]

getColor' [h] [x,y] =   -- end case
    [findColor $ countFlip [h, x, y]]

getColor' (h:xs) (x:y:z:ys) =
    if null xs then [findColor $ countFlip [h, x, y]]
    else color:zs 
    where
        color = findColor $ countFlip [h, x, y, z]
        zs = getColor' xs (y:z:ys)


-- count how many time "Flip" appears in a list
countFlip :: [String] -> Int
countFlip [] = 0
countFlip (x:xs)
    | x == "Flip" = 1 + countFlip xs
    | otherwise = countFlip xs

-- find the color of a grid based on how many time itself and its neighbor flip
findColor :: Int -> Color
findColor num
    | even num = Blue
    | otherwise = Red

-- validate color all red in a row
validate :: [Color] -> Bool
validate [] = True
validate (x:xs)
    | x == Blue = False
    | otherwise = validate xs
        
