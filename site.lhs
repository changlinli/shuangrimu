Shuangrimu Static Site Generator
================================

Welcome to the source code of [www.shuangrimu.com](www.shuangrimu.com)!

This file is a literate Haskell file, that is it is the literal code from which
this site is compiled (or at least the static site generator parts of it). For
a higher-level overview of this entire project, see the README that should be
bundled with this code. The documentation in this file will deal mainly with
the details of this site generates the static HTML files that we push.

This also serves as a bit of a Hakyll tutorial for people who are unfamiliar
with it.

I assume an intermediate level knowledge of Haskell and that you have gone 
through at least the basic tutorial of Hakyll 
[https://jaspervdj.be/hakyll/tutorials.html](https://jaspervdj.be/hakyll/tutorials.html "Hakyll basic tutorial").

Design
------

At a high level every static site generator follows the same workflow.

1. Read in a bunch of content (often written in Markdown)
2. Apply a series of templates to it
3. Collate all the results as some set of HTML/CSS/JS files that can be
   immediately served by any static file webserver.

So what is Hakyll? Unlike, say Jekyll, Hakyll is not a static site generator
itself per se. It is better thought of as a toolbox for creating your own
static site generator that best suits your needs.

It gives you an embedded DSL for Haskell that lets you craft a custom compiler
based on Pandoc. Usually you will end up creating a compiler from Markdown to
HTML that has a lot of conventions around where files are supposed to be
located, what the format of the markdown file should be, etc.

In effect you can think of Hakyll as a static site generator generator.

> {-# LANGUAGE OverloadedStrings #-}
> {-# LANGUAGE FlexibleContexts #-}
> import           Data.Monoid (mappend, (<>), mconcat)
> import           Hakyll
> import           Text.Blaze.Html5 (toHtml, toValue, (!))
> import qualified Text.Blaze.Html5 as H
> import qualified Text.Blaze.Html5.Attributes     as A
> import           Text.Printf
> import           Data.Bifoldable (bifoldMap)
> import           System.FilePath
> import           Data.List (isSuffixOf)
> import           Data.Set (Set)
> import qualified Data.Set as Set
> import qualified Data.HashMap.Lazy as Map
> import qualified Data.Aeson.Types as Aeson
> import qualified Data.Aeson as Aeson
> import           Data.Text (Text, splitOn, pack, strip, lines)
> import qualified Data.Text as Text
> import           Control.Monad
> import           Control.Monad.Except

So how does this work?

> main :: IO ()
> main = hakyll $ do
>     match "htaccess" $ do
>         route   (constRoute ".htaccess")
>         compile copyFileCompiler
> 
>     match "favicon.ico" $ do
>         route   idRoute
>         compile copyFileCompiler
> 
>     match "images/*" $ do
>         route   idRoute
>         compile copyFileCompiler
> 
>     match "js/*" $ do
>         route   idRoute
>         compile copyFileCompiler
> 
>     match "prettify/*" $ do
>         route   idRoute
>         compile copyFileCompiler
> 
>     match "css/*" $ do
>         route   idRoute
>         compile compressCssCompiler
> 
>     tags <- buildTags "posts/*" (fromCapture "tags/*.html")
> 
>     let postCtxWithTags = injectCustomColor "" <> tagsCtx tags <> postCtx
> 
>     createBasePage "about.md" "#about" (tagsCtx tags)
> 
>     createBasePage "contact.md" "#contact" (tagsCtx tags)
> 
>     createBasePage "licensing.md" "#licensing" (tagsCtx tags)
> 
>     match "posts/*" $ do
>         route $ setExtension "html"
>         compile $ pandocCompiler
>             >>= saveSnapshot "content"
>             >>= loadAndApplyTemplate "templates/post.html"    (tagsField "tags" tags <> injectCustomColor "" <> postCtx)
>             >>= loadAndApplyTemplate "templates/default.html" postCtxWithTags
>             >>= relativizeUrls
> 
>     create ["archives.html"] $ do
>         route idRoute
>         compile $ do
>             posts <- recentFirst =<< loadAllSnapshots "posts/*" "content"
>             let archiveCtx =
>                     listField "posts" postCtx (return posts) <>
>                     constField "title" "Archives"            <>
>                     injectCustomColor "#archives"            <>
>                     tagsCtx tags                             <>
>                     defaultContext
> 
>             makeItem ""
>                 >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
>                 >>= loadAndApplyTemplate "templates/default.html" archiveCtx
>                 >>= relativizeUrls
> 
>     createFeed ["atom.xml"] renderAtom
> 
>     createFeed ["rss.xml"] renderRss
>
>     match "popular-posts" $ do
>         compile $ getResourceBody >>= saveSnapshot "popular-posts"
> 
>     match "index.html" $ do
>         route idRoute
>         compile $ do
>             listOfPopularPostsStr <- (loadBody "popular-posts" :: Compiler String)
>             let listOfPopularPosts = pack listOfPopularPostsStr
>             mostPopularPostTitles <- parsePopularPostTitles listOfPopularPosts
>             posts <- recentFirst =<< loadAllSnapshots "posts/*" "content"
>             popularPosts <- (filterM (\post -> fmap (\x -> Set.member x mostPopularPostTitles) (getItemTitle (itemIdentifier post)))) =<< loadAllSnapshots "posts/*" "content"
>             let indexCtx =
>                     listField "popularPosts" postCtx (return popularPosts) <>
>                     listField "posts" postCtxWithIdx (return (zipWith (\post idx -> fmap (\postContents -> (postContents, idx)) post) posts (fmap show [1 .. 3]))) <>
>                     constField "title" "Home"                <>
>                     tagsCtx tags                             <>
>                     injectCustomColor  ""                    <>
>                     defaultContext
> 
>             getResourceBody
>                 >>= applyAsTemplate indexCtx
>                 >>= loadAndApplyTemplate "templates/withSlider.html" indexCtx
>                 >>= relativizeUrls
> 
>     tagsRules tags $ \tag pattern -> do
>         route idRoute
>         compile $ do
>             posts <- recentFirst =<< loadAll pattern
>             let ctx = 
>                     constField "tagname" tag <> 
>                     injectCustomColor "" <>
>                     tagsCtx tags <> 
>                     listField "posts" postCtx (return posts) <> 
>                     defaultContext
>             makeItem ""
>                 >>= loadAndApplyTemplate "templates/tag.html" ctx
>                 >>= loadAndApplyTemplate "templates/default.html" ctx
>                 >>= relativizeUrls
> 
>     match "templates/*" $ compile templateCompiler

This is for parsing

> parsePopularPostTitles :: (MonadError [String] m) => Text -> m (Set Text)
> parsePopularPostTitles titles = return $ Set.fromList $ fmap strip $ Text.lines titles
> 
> createBasePage :: Pattern -> String -> Context String -> Rules ()
> createBasePage sourcefile colortagname generatedTagsCtx =
>     match sourcefile $ do
>         route   $ setExtension "html"
>         compile $ do 
>             pandocCompiler
>                 >>= loadAndApplyTemplate "templates/default.html" (injectCustomColor colortagname <> generatedTagsCtx <> defaultContext)
>                 >>= relativizeUrls
> 
> postCtx :: Context String
> postCtx =
>     dateField "date" "%B %e, %Y" `mappend`
>     defaultContext
> 
> type IdxAsString = String
> 
> postCtxWithIdx :: Context (String, IdxAsString)
> postCtxWithIdx = Context f
>   where
>     postCtxF = unContext (postCtx)
>     idxCtxF = unContext (field "listIndex" $ return . itemBody)
>     f "listIndex" things item = idxCtxF "listIndex" things (fmap snd item)
>     f key things item = postCtxF key things (fmap fst item)
> 
> tagsCtx :: Tags -> Context a
> tagsCtx tags = tagsFieldAsLIs "tags" tags
> 
> tagsFieldAsLIs :: String -> Tags -> Context a
> tagsFieldAsLIs contextKey tags = listField contextKey defaultContext (return (collectTags tags))
>   where
>     collectTags tags = map (\(t, _) -> Item (tagsMakeId tags t) t) (tagsMap tags)
> 
> injectCustomColor :: String -> Context String
> injectCustomColor = constField "headstyle" . colorSelection 
>   where
>     colorSelection "#about" = "#about" <> toInterpolate (255, 127, 127)
>     colorSelection "#archives" = "#archives" <> toInterpolate (127, 127, 255)
>     colorSelection "#contact" = "#contact" <> toInterpolate (127, 200, 127)
>     colorSelection "#licensing" = "#licensing" <> toInterpolate (200, 200, 127)
>     colorSelection _ = ""
> 
> toInterpolate :: (Int, Int, Int) -> String
> toInterpolate (x, y, z) = printf "{color:rgb(%s, %s, %s); background-color:rgb(220, 220, 220)}" (show x) (show y) (show z)
> 
> simpleRenderLink :: String -> (Maybe FilePath) -> Maybe H.Html
> simpleRenderLink _   Nothing         = Nothing
> simpleRenderLink tag (Just filePath) =
>   Just $ H.a ! A.href (toValue $ toUrl filePath) $ toHtml tag
> 
> feedConfig :: FeedConfiguration
> feedConfig = FeedConfiguration
>     { feedTitle = "Shuang Rimu"
>     , feedDescription = "A blog about random things"
>     , feedAuthorName = "Changlin Li"
>     , feedAuthorEmail = "rimu@shuangrimu.com"
>     , feedRoot = "http://www.shuangrimu.com"
>     }
> 
> createFeed
>   :: [Identifier]
>      -> (FeedConfiguration
>          -> Context String -> [Item String] 
>          -> Compiler (Item String)
>          )
>      -> Rules ()
> createFeed filename renderer = create filename $ do
>     route idRoute
>     compile $ do
>         let feedCtx = postCtx <> bodyField "description"
>         posts <- fmap (take 10) . recentFirst =<<
>             loadAllSnapshots "posts/*" "content"
>         renderer feedConfig feedCtx posts
> 
> getItemTitle :: MonadMetadata m => Identifier -> m Text
> getItemTitle identifier = do
>     metadata <- getMetadata identifier
>     case Map.lookup "title" metadata of
>          Nothing -> fail $ "We were unable to find a title for " ++ show identifier
>          Just title -> case title of 
>                             Aeson.String titleText -> return titleText
>                             _ -> fail $ "We found a title for " ++ show identifier ++ " but it doesn't look like a valid JSON string: " ++ show title
