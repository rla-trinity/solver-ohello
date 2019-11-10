import Data.Char

data Player = Black | White deriving (Show, Eq) 
data Status = Full Player | Empty deriving (Eq)
type Location = (Int, Int) 
type Cell = (Location, Player) --possible wrong syntax
type Board = [(Location, Player)]
type Game = (Board, Player)
type Move = (Location, Player)

numRC = [0..7]

allLocs = [(x,y) | x <- numRC, y <- numRC]

allDirections = [(1,0),(1,1),(1,-1),(0,1),(0,-1),(-1,0),(-1,1),(-1,-1)]

instance Show Status where
   show (Full White) = " | W | "
   show (Full Black) = " | B | "
   show (Empty) = " |   | "


initialBoard = [ if loc == (3,3) || loc == (4,4) then (loc,Full White)
                      else if loc == (3,4) || loc == (4,3) then (loc, Full Black)
                      else (loc, Empty)| loc <- allLocs]

--a "nothing" means the cell doesn't exist
findCell :: Board -> (Int, Int) -> Maybe Cell
findCell cells (x,y) = let poss = [((a,b), status) | ((a,b), status) <- cells, (a == x) && (b == y)]
                       in if null poss then Nothing else Just $ head poss

findCell :: Board -> (Int, Int) -> Cell
findCell cells (x,y) = head [((a,b), status) | ((a,b), status) <- cells, (a == x) && (b == y)]
--returns list of adjacent cells, each tupled with the direction it is adjacent in. if there are no adjacent cells it returns an empty list.
--empty cells are represented by a Nothing tupled with the direction they are in.
getAdjacentCells :: Board -> Cell -> [(Maybe Cell, Direction)]
getAdjacentCells :: Board -> Cell -> [Cell]
getAdjacentCells cells ((x,y), status) = let validDirections = [(a,b) | (a,b) <- allDirections, a+x < 8, b+y <8]
                                         in [((findCell cells (a+x,b+y)), (a,b)) | (a,b) <- validDirections]


--returns a row of cells of the non-turn color which ends in a cell of the turn color,
--not including the cell of the turn color. returns Nothing if the row does not
--end in a cell of the turn color (ie the board ends first, or it runs into empty cell first)
getRow :: Game -> Cell -> Direction -> Maybe [Cell]
getRow (board, turn) cell dir = let possNext = getNext board cell dir
                                    aux = getRowAux (board, turn) possNext dir
                                in if any isNothing aux then Nothing else Just (map fromJust aux)


getRowAux :: Game -> Maybe Cell -> Direction -> [Maybe Cell]
getRowAux board Nothing (a,b) =[ Nothing] --ran into an empty cell
getRowAux (board, turn) (Just (loc,player))) dir= if player == turn then [] --row ends in cell of the turn color
                                                  else if overruns board (loc,player) dir then [Nothing] -- the board ends
                                                  else ((Just (loc,player)):(getRowAux (board,turn) (getNext board (loc,player) dir) (a,b)))

--returns next cell in a given direction, or nothing if the board ends
getNext :: Board -> Cell -> Direction -> Maybe Cell
getNext board ((x,y), player) (a,b) = findCell board (x+a, y+b)

overruns :: Board -> Cell -> Direction -> Bool
overruns board ((x,y), player) (a,b) = (x+a) > 7 || (y+b) > 7

otherPlayer :: Player -> Player
otherPlayer White = Black
otherPlayer Black = White


checkValid :: Board -> Cell -> Bool
checkValid = undefined

--checks if game is over
--game is over when both players cannot make a move, or board is full
--true means game is over
gameOver :: Board -> Bool
gameOver board = 
    --undefined
    --option 1: check valid moves available for each player using makeMove or validMoves
    --if only nothings then true else false
    let all = validMovesAll board
    in if gameOverAux all then True else False

gameOverAux :: [Maybe Board] -> Bool
gameOverAux [] = True
gameOverAux (x:xs) = 
    let recur = gameOverAux xs
    in if x /= Nothing then recur else False


--if game is over, returns a winner
--else return nothing
checkWinner :: Board -> Maybe Player
checkWinner board = 
    let gameStatus = gameOver board
    in if gameStatus then winnerIs board else Nothing

--helper function that calculates winner
--winner is player with most pieces on board
--board = [(location, player)]
winnerIs :: Board -> Maybe Player
winnerIs board = 
    let 
        lstOfCells = board
        lstOfColors = [colors | (loc, colors) <- lstOfCells]
        count = winnerIsAux lstOfColors
    in if count == 0 then Nothing else blackOrWhite count
    
    where
        blackOrWhite count = 
            if count > 0 then Just Black
            else Just White

        --black += 1, white -= 1
        winnerIsAux :: [Player] -> Int
        winnerIsAux [] = 0
        winnerIsAux (x:xs) = 
            let recur = winnerIsAux xs
            in if x == Black then 1 + recur else (-1) + recur


updateBoard :: (Location, Player) -> Board -> Maybe Board
updateBoard ((x, y), stat) cellList = 
    undefined
    {-
                                        if (length checkExists) /= (length cellList)
                                      then flipper ((x,y), stat) (((x,y), stat) : cellList)
                                      else flipper ((x,y), stat) cellList
    where
        checkExists = filter (\((i, j), stati) -> (i /= x) && (j /= y)) cellList
    -}

flipper :: Cell -> Board -> Board
flipper ((x, y), stat) cellList = undefined

{-
fancyShow :: Board -> String
fancyShow = concat [ show(status) | (loc,status)<-board ]
-}

--if for both players then only useful to check when game is over
--call updateBoard on each cell
validMovesAll :: Board -> [Maybe Board]
validMovesAll board = 
    --undefined
    let allCells = fillEmpty board
    in [validMovesAllAux x board | x <- allCells]

validMovesAllAux :: Maybe Cell -> Board -> Maybe Board
validMovesAllAux Nothing board = Nothing
validMovesAllAux (Just x) board = updateBoard x board


lstOfNothings = [Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing] ++
                [Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing] ++
                [Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing] ++
                [Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing] ++
                [Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing] ++
                [Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing] ++
                [Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing] ++
                [Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing]
                
--list of Nothings and cells
fillEmpty :: Board -> [Maybe Cell]
fillEmpty board = 
    fillEmptyAux board lstOfNothings

fillEmptyAux :: Board -> [Maybe Cell] -> [Maybe Cell]
fillEmptyAux [] lst = lst
fillEmptyAux (x:xs) lst = 
    let removeHead = tail lst ++ [Just x]
    in fillEmptyAux xs removeHead


--ex input "A1" 
--from A-H, 1-7
parseString :: String -> Maybe Move
parseString str = 
    let
        column = letterToInt $ head str
        row = digitToInt (head $ tail str)
        loc = (column, row)
        
    in Just (loc, White) 

letterToInt :: Char -> Int
letterToInt 'A' = 0
letterToInt 'B' = 1
letterToInt 'C' = 2
letterToInt 'D' = 3
letterToInt 'E' = 4
letterToInt 'F' = 5
letterToInt 'G' = 6
letterToInt 'H' = 7

--help
changePlayer :: Player -> Player
changePlayer (Black) = White
changePlayer (White) = Black

{-
countPieces :: Player -> Board -> Int
--countPieces counts the number of pieces on the board belonging to a given player.
--It does this by filtering the list of cells in the Board down to only those that 
--we would like to count, then taking the length of that list.
countPieces player cellList = length $ filter (\(location, status) -> status == Full player) cellList
-}

testBoard = [((0::Int,0::Int), Black), ((0::Int,1::Int), Black)]
testBoardFull = testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ 
                testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ 
                testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ 
                testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard ++ testBoard 
                
