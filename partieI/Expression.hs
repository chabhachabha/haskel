module Expression where

  import Prelude
  import Data.Char
  import Data.Tuple
  import Data.List
  import Text.Read

  import ErrorHandler

  type Key = String
  type Value = Float
  
  data Expression = Not Expression
    | Add Expression Expression
    | Mul Expression Expression
    | Expo Expression Expression
    | Variable Key
    | Constant Value  
    deriving (Show)
  --exp = Mul (Add (Constant 2) (Expo (Variable "x") (Constant 2))) (Not (Constant 1))
  --exp = (2+x^2)*(-1)

  data Store = Store [(Key, Value)] deriving (Show)
  --store  = Store [("x", 1), ("y", 2)]
  --exp = parseExp "x*2 + y"
  --eval store exp

  --trouver le valuer quand on sait le cle 
  --facon 1
  findTuple :: Key -> Store -> [(Key,Value)]
  findTuple key (Store store) = filter (\(x,_) -> x == key) store

  getValue :: Key -> Store -> Value
  getValue key (Store store) = snd $ head (findTuple key (Store store))

  --facon 2
  -- getValue :: Key -> Store -> Float
  -- getValue var (Store xs) = case filter ((var ==).fst) xs of
  --       [] -> error "Variable not found"
  --       result -> snd $ head result  

  evaExp :: Store -> Expression -> Float
  --évaluation de la negation (-)
  evaExp (Store store) (Not exp) = 
    let x = evaExp (Store store) exp
    in 0-x

  --évaluation du somme (+)
  evaExp (Store store) (Add left right) = 
    let x = evaExp (Store store) left
        y = evaExp (Store store) right
    in x + y
  
  --évaluation du multiplication (*)
  evaExp (Store store) (Mul left right) = 
    let x = evaExp (Store store) left
    y = evaExp (Store store) right
    in x * y

  --évaluation d'exponentiation (^)
  evaExp (Store store) (Expo left right) = 
    let x = evaExp (Store store) left
        y = evaExp (Store store) right
    in x**y

  --évaluation de constant 
  evaExp (Store store) (Constant x) = x

  --évaluation de variable
  evaExp (Store store) (Variable key) = getValue key (Store store)

  eval :: Store -> Expression -> Maybe Float 
  eval (Store store) str = case (unsafeCleanup $ evaExp (Store store) str) of
                                                 Nothing -> Nothing
                                                 result -> result                                                
