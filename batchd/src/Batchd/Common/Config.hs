{-# LANGUAGE OverloadedStrings #-}
-- | This module contains utility functions for locating and loading
-- configuration files.
module Batchd.Common.Config where

import Control.Exception
import Data.Yaml
import System.IO

import System.Environment

import Batchd.Core.Common.Types
-- import Batchd.Core.Common.Localize
import Batchd.Core.Common.Config
import Batchd.Common.Types

-- | Load job type config file
loadTemplate :: String -> IO (Either Error JobType)
loadTemplate name = loadConfig "jobtypes" name InvalidJobType

-- | Load global config file (@"batchd.yaml"@)
loadGlobalConfig :: Maybe FilePath -> IO (Either Error GlobalConfig)
loadGlobalConfig mbCmdlinePath = do
  mbPath <- case mbCmdlinePath of
              Just path -> return $ Just path
              Nothing   -> locateConfig "" "batchd.yaml"
  case mbPath of
    Nothing -> return $ Left $ FileNotExists "batchd.yaml"
    Just path -> do
      r <- decodeFileEither path
      case r of
        Left err -> return $ Left $ InvalidDbCfg err
        Right cfg -> do
          return $ Right cfg

-- | Read password from stdout.
getPassword :: String    -- ^ Prompt
           -> IO String
getPassword prompt = do
  putStr prompt
  hFlush stdout
  pass <- withEcho False getLine
  putChar '\n'
  return pass

-- | Ask password from stdout twice.
-- Make sure that entered passwords are equal.
getPassword2 :: IO String
getPassword2 = do
  pwd1 <- getPassword "Password: "
  pwd2 <- getPassword "Password again: "
  if pwd1 /= pwd2
    then fail "passwords do not match"
    else return pwd1

-- | Get admin password from the environmetn variable "BATCHD_ROOT_PASSWORD" first,
-- | If not present, call getPassword2
getAdminPassword :: IO String
getAdminPassword = do
  pwd <- lookupEnv "BATCHD_ROOT_PASSWORD"
  case pwd of
    Nothing -> getPassword2
    Just pwd' -> pure pwd'

-- | Execute IO actions with enabled\/disabled terminal echo,
-- and then return echo state to previous.
withEcho :: Bool -> IO a -> IO a
withEcho echo action = do
  old <- hGetEcho stdin
  bracket_ (hSetEcho stdin echo) (hSetEcho stdin old) action

