{-# LANGUAGE DeriveDataTypeable, StandaloneDeriving, RecordWildCards, DeriveGeneric #-}
-- | This module contains definitions for working with schedules
module Batchd.Common.Schedule where

import GHC.Generics
import Data.Time.Clock
import Data.Time.LocalTime
import Data.Dates
import Data.Dates.Formats
import Data.Aeson
import Text.Parsec
import Text.Parsec.String

import Batchd.Common.Types (jsonOptions)
import Batchd.Common.Data

-- | Time period within day.
data Period =
  Period {
    periodBegin :: TimeOfDay,
    periodEnd :: TimeOfDay
  }
  deriving (Eq, Generic)

instance Show Period where
  show (Period begin end) = show begin ++ " -- " ++ show end

toPeriod :: ScheduleTime -> Period
toPeriod (ScheduleTime {..}) = Period scheduleTimeBegin scheduleTimeEnd

instance ToJSON Period where
  toJSON = genericToJSON (jsonOptions "period")

instance FromJSON Period where
  parseJSON = genericParseJSON (jsonOptions "period")

data ScheduleInfo =
  ScheduleInfo {
    sName :: String
  , sWeekdays :: Maybe [WeekDay]
  , sTime :: Maybe [Period]
  }
  deriving (Eq, Show, Generic)

instance ToJSON ScheduleInfo where
  toJSON = genericToJSON (jsonOptions "s")

instance FromJSON ScheduleInfo where
  parseJSON = genericParseJSON (jsonOptions "s")

anytime :: ScheduleInfo
anytime = ScheduleInfo "anytime" Nothing Nothing

getTime :: DateTime -> TimeOfDay
getTime (DateTime {..}) = TimeOfDay hour minute (fromIntegral second)

parsePeriod :: String -> Either ParseError Period
parsePeriod str = parse parser "(period description)" str 
  where
    format :: Format
    format = [HOUR True 2,Fixed True ":",MINUTE True 2,Fixed True ":",SECOND True 2]

    parser :: Parser Period
    parser = do
      begin <- formatParser format
      spaces
      end <- formatParser format
      return $ Period (getTime begin) (getTime end)

allows :: ScheduleInfo -> DateTime -> Bool
allows (ScheduleInfo {..}) dt = weekdayOk && timeOk
  where
    weekdayOk = case sWeekdays of
                  Nothing -> True
                  Just weekdays -> dateWeekDay dt `elem` weekdays

    timeOk = case sTime of
               Nothing -> True
               Just lst -> any goodTime lst

    goodTime (Period {..}) = 
                  getTime dt > periodBegin && getTime dt <= periodEnd

allowsU :: ScheduleInfo -> UTCTime -> Bool
allowsU (ScheduleInfo {..}) dt = weekdayOk && timeOk
  where
    date = dayToDateTime (utctDay dt)
    time = timeToTimeOfDay (utctDayTime dt)

    weekdayOk = case sWeekdays of
                  Nothing -> True
                  Just weekdays -> dateWeekDay date `elem` weekdays

    timeOk = case sTime of
               Nothing -> True
               Just lst -> any goodTime lst

    goodTime (Period {..}) = 
                  time > periodBegin && time <= periodEnd

