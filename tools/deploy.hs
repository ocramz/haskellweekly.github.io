#!/usr/bin/env stack
{-
  stack
  --resolver lts-10.0
  script
  --package directory
  --package filepath
  --package process
-}

import qualified Control.Monad as Monad
import qualified System.Directory as Directory
import qualified System.Environment as Environment
import qualified System.FilePath as FilePath
import qualified System.Process as Process

main :: IO ()
main = do
  token <- Environment.getEnv "GITHUB_TOKEN"
  branch <- Environment.getEnv "TRAVIS_BRANCH"
  commit <- Environment.getEnv "TRAVIS_COMMIT"
  isPullRequest <- Environment.getEnv "TRAVIS_PULL_REQUEST"

  Monad.guard (branch == "hakyll")
  Monad.guard (isPullRequest == "false")

  Directory.setCurrentDirectory (FilePath.joinPath ["_site"])
  writeFile "CNAME" "haskellweekly.news"
  let
    git = Process.callProcess "git"
    email = "taylor@fausak.me"
    name = "Taylor Fausak"
    author = "Haskell Weekly <info@haskellweekly.news>"
    message = "Automatic deploy of " ++ commit
    origin = "https://" ++ token ++ "@github.com/haskellweekly/haskellweekly.github.io.git"

  git ["init"]
  git ["add", "."]
  git ["config", "--global", "user.email", email]
  git ["config", "--global", "user.name", name]
  git ["commit", "--author", author, "--message", message]
  git ["remote", "add", "origin", origin]
  git ["push", "--force", "--quiet", "origin", "master"]
