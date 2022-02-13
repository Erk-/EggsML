{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TupleSections #-}

module Main (main) where

import Control.Monad (guard)
import Data.Aeson (FromJSON, ToJSON)
import qualified Data.Aeson as Aeson
import Data.Char (isLetter, toUpper)
import Data.Set (Set)
import qualified Data.Set as Set
import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Text.Encoding as Text
import qualified Data.Text.IO as Text
import Data.FileEmbed
import System.Random (randomRIO)
import System.Environment (getEnv)
import GHC.Generics (Generic)

import Concieggs.Util (getCommandArgs, getEnvDef)
import Concieggs.Stateful (statefulMain)

data Game = Game
  { guesses :: [Text]
  , actual  :: Text
  } deriving (Eq, Ord, Show, Generic, FromJSON, ToJSON)

main :: IO ()
main = do
  wordleGameFile <- (<> "/wordle-state.json") <$> getEnvDef "CONCIEGGS_DB_DIR" "db"
  getCommandArgs >>= statefulMain wordleGameFile newRandomGame handleGame

newRandomGame :: IO Game
newRandomGame = newGame <$> randomChoice wordleWords

handleGame :: (Game, [Text]) -> IO (Game, [Text])
handleGame (game, [guess])
  | isEmpty guess && isGameOver game = do
      game <- newRandomGame
      let response = "Det er tid til WORDLE! Gæt ordet ved at skrive 'wordle <gæt>'"
      pure (game, [response])
  | isGameOver game = newRandomGame >>= \game -> handleGame (game, [guess])
  | isEmpty guess = pure (game, [Text.pack (show game)]) -- FIXME
  | otherwise = case parseWord guess game of
      Left err -> pure (game, [err])
      Right guess -> do
        let newState = addGuess guess game
        let response = if isCorrectGuess guess game
              then ["Tillykke! Du har gættet rigtigt! Ordet var " <> guess <> "!"]
              else ["Gæt igen. Dine gæt indtil videre: " <> showGame newState]
        pure (newState, response)

handleGame (game, _) = pure (game, ["Du skal angive nøjagtigt et ord, som du vil gætte på."])

showGame :: Game -> Text
showGame Game {..} = commas guesses

newGame :: Text -> Game
newGame actual = Game {..}
  where
    guesses = []

parseWord :: Text -> Game -> Either Text Text
parseWord word Game {..} = do
  guardEither (Text.length word == 5) "Ordet skal være fem bogstaver."
  guardEither (Text.all isLetter word) "Ordet må kun bestå af bogstaver."
  let guess = Text.map toUpper word
  guardEither (guess `notElem` guesses) "Det ord er allerede gættet på."
  pure guess

guardEither :: Bool -> e -> Either e ()
guardEither True _ = Right ()
guardEither False e = Left e

wordleWords :: [Text]
wordleWords = Text.lines . Text.decodeUtf8 $ $(embedFile "db/wordle-few")

isEmpty :: Text -> Bool
isEmpty = Text.null

isGameOver :: Game -> Bool
isGameOver Game {..} = actual `elem` guesses

isCorrectGuess :: Text -> Game -> Bool
isCorrectGuess guess game =
  guess == actual game

addGuess :: Text -> Game -> Game
addGuess guess game =
  game { guesses = guesses game <> [guess] }

randomChoice :: [a] -> IO a
randomChoice xs = do
  let max = length xs
  (xs !!) <$> randomRIO (0, max-1)

commas :: [Text] -> Text
commas = Text.intercalate ", "
