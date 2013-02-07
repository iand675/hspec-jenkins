{-# LANGUAGE RecordWildCards, OverloadedStrings #-}
module XmlFormatter (xmlFormatter) where
import Data.List (intercalate)
import Test.Hspec.Formatters
import Test.Hspec.Runner (Path)
import Text.Blaze.Renderer.String (renderMarkup)
import Text.Blaze.Internal

failure, skipped :: Markup -> Markup
failure = customParent "failure"
skipped = customParent "skipped"

name, className, message :: String -> Attribute
name = customAttribute "name" . stringValue
className = customAttribute "classname" . stringValue
message = customAttribute "message" . stringValue

testcase :: Path -> Markup -> Markup
testcase (xs,x) = customParent "testcase" ! name x ! className (intercalate "." xs)

xmlFormatter :: Formatter
xmlFormatter = Formatter{..}
  where
    headerFormatter = do
      writeLine "<?xml version='1.0' encoding='UTF-8'?>"
      writeLine "<testsuite>"
    exampleGroupStarted _ _ _ = return ()
    exampleGroupDone = return ()
    exampleSucceeded path = do
      writeLine $ renderMarkup $
        testcase path ""
    exampleFailed path err = do
      writeLine $ renderMarkup $
        testcase path $
          failure ! message (either formatException id err) $ ""
    examplePending path mdesc = do
      writeLine $ renderMarkup $
        testcase path $
          case mdesc of
            Just desc -> skipped ! message desc  $ ""
            Nothing -> skipped ""
    failedFormatter = return ()
    footerFormatter = do
      writeLine "</testsuite>"
