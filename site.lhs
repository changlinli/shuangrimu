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
Essentially you should've seen a "Hello World" example of Hakyll already.

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

In effect you can think of Hakyll as a static site generator generator. You use
it to create an executable (or you can interpret it with `runhaskell`) which is
then your own personal static site generator that you can run.

*Ultimately what we're building here is a compiler that takes everything in
this repository and generates a bunch of HTML, Javascript, and CSS in the
`_site` directory which we can deploy with any webserver capable of serving
static files.*

Let's start with some `import` boilerplate and then dive into what Hakyll gives
us that we wouldn't get if we just tried to build everything from scratch
ourselves.

Actual Code
-----------

> {-# LANGUAGE OverloadedStrings #-}
> {-# LANGUAGE FlexibleContexts #-}
> import           Data.Monoid (mappend, (<>))
> import           Hakyll
> import           Hakyll.Contrib.LaTeX (initFormulaCompilerSVGPure)
> import           Image.LaTeX.Render (defaultEnv, displaymath, preamble)
> import           Image.LaTeX.Render.Pandoc (defaultPandocFormulaOptions, formulaOptions)
> import           Text.Blaze.Html5 (toHtml, toValue, (!))
> import qualified Text.Blaze.Html5 as Html
> import qualified Text.Blaze.Html5.Attributes     as A
> import           Text.Printf
> import           Data.Set (Set)
> import qualified Data.Set as Set
> import qualified Data.HashMap.Lazy as Map
> import qualified Data.Aeson.Types as Aeson
> import           Data.Text (Text, pack, strip, unpack)
> import qualified Data.Text as Text
> import           Control.Monad
> import           Control.Monad.Except
> import           Data.Typeable
> import           Text.Pandoc (writeMarkdown, Pandoc, runPure, writeLaTeX)

If we think back to the steps laid out in the Design section, Hakyll provides
the first step, the ability to read in content, through the `match` function.

The reason why a custom function is provided, rather than simply using
something like `readFile` is that Hakyll provides its own custom monad, the
`Rules` monad, in which all these actions live. By providing a custom monad
rather than simply using `IO`, Hakyll is able to offer some features to make
life easier. Foremost among them is incremental compilation and a preview
server that can automatically pick up on changes and compile them. This is
because under the hood the `Rules` monad is storing the dependencies among your
files of which files depend on which other ones in order to work.

However, this design choice, to access content via `match`, has other
consequences for how to design a program with Hakyll that might seem
unintuitive at first.

Another way of thinking about this is that We are basically building a
dependency graph with `Rules` of actions to execute. `match` allows us to
associate parts of that graph with other parts of our dependency graph. (This
paragraph needs to be rewritten, it's not particularly clear)

Let's dive into the easiest example of using `match`. Most uses of `match` will
follow this pattern, where pass to `match` a `route`, which indicates where in
our `_site` folder our final product will be and a "compiler", which indicates
what transformation we will be doing on top of the file to generate the
artifact that goes into the `_site` folder.

> compileHtAccessFile :: Rules () 
> compileHtAccessFile =
>     match "htaccess" $ do
>         route   (constRoute ".htaccess")
>         compile copyFileCompiler

In this case since we have a single file, we're going to use `constRoute` to
indicate the artifact's name in `_site` should always be the same. We also are
copying the file entirely unchanged so we just the `copyFileCompiler`.

This generates a rule that reads in a file named `htaccess` and then places it
in some build artifact folder (by default this is `_site` under the name
`.htaccess`). The lack of a period in the first argument of the `match` is
because by default Hakyll ignores files starting with a period (this can be
changed in its configuration settings).

A lot of other actions we need to do also are to simply copy files that already
exist into `_site`.

> copyFavicon :: Rules ()
> copyFavicon = 
>     match "favicon.ico" $ do
>         route   idRoute
>         compile copyFileCompiler
>
> copyImages :: Rules ()
> copyImages =
>     match "images/*" $ do
>         route   idRoute
>         compile copyFileCompiler
>
> copyCustomJavascript :: Rules ()
> copyCustomJavascript =
>     match "js/*" $ do
>         route   idRoute
>         compile copyFileCompiler
>
> copyPrettifyJsLibrary :: Rules ()
> copyPrettifyJsLibrary =
>     match "prettify/*" $ do
>         route   idRoute
>         compile copyFileCompiler

We also can compress our CSS to make it more lightweight.

> compileCss :: Rules ()
> compileCss =
>     match "css/*" $ do
>         route   idRoute
>         compile compressCssCompiler

Now we get to meat of things, which is actually turning our posts into properly
formatted HTML.

Let's first specify where the folder with all our Markdown posts is.

> locationOfPosts :: Pattern
> locationOfPosts = "posts/*"

Notice the asterisk, which indicates we want to match against all files in the
`posts` folder.

Next we need to build tags which are then used later to create a sidebar with
tags in all of our pages.

> buildTagsFromPosts = buildTags locationOfPosts (fromCapture "tags/*.html")

> createAboutPage tags = createBasePage "about.md" "#about" (tagsCtx tags)
> createContactPage tags = createBasePage "contact.md" "#contact" (tagsCtx tags)
> createLicensingPage tags = createBasePage "licensing.md" "#licensing" (tagsCtx tags)
> create404Page tags = createBasePageNonRelative "404.md" "" (tagsCtx tags)

As an added bit of cuteness we can create an HTML page out of this very file
itself (since it's valid Markdown after all)!

> createSiteCodePage tags = createBasePage "site.lhs" "" (tagsCtx tags)

> main :: IO ()
> main = hakyll $ do
>     let mathFormulaCompiler = initFormulaCompilerSVGPure defaultEnv
>     let pandocFormulaOptions = defaultPandocFormulaOptions { formulaOptions = (\_ -> displaymath { preamble = (preamble displaymath) ++ "\n\\usepackage{bussproofs}" }) }
>     compileHtAccessFile
>
>     copyFavicon
>     copyImages
>     copyCustomJavascript
>     copyPrettifyJsLibrary
>
>     compileCss
> 
>     tags <- buildTagsFromPosts
> 
>     let postCtxWithTags = injectCustomColor "" <> tagsCtx tags <> postCtx
> 
>     createAboutPage tags
>     createContactPage tags
>     createLicensingPage tags
>     create404Page tags
>     createSiteCodePage tags
>
>     match "posts/*" $ do
>         route $ setExtension "html"
>         compile $ pandocCompilerWithTransformM defaultHakyllReaderOptions defaultHakyllWriterOptions (mathFormulaCompiler pandocFormulaOptions)
>             >>= saveSnapshot "content"
>             >>= loadAndApplyTemplate "templates/post.html"    (tagsField "tags" tags <> injectCustomColor "" <> postCtx)
>             >>= loadAndApplyTemplate "templates/default.html" postCtxWithTags
>             >>= relativizeUrls
>
>     let pandoced = getResourceBody >>= readPandoc
>
>     let writeThroughItemMd (Item itemId body) = case runPure $ fmap unpack $ writeMarkdown defaultHakyllWriterOptions body of
>             Left err -> error $ "blahblah" ++ show err
>             Right item' -> Item itemId item'
>
>     let writeThroughItemTex (Item itemId body) = case runPure $ fmap unpack $ writeLaTeX defaultHakyllWriterOptions body of
>             Left err -> error $ "blahblah" ++ show err
>             Right item' -> Item itemId item'
>
>     match "posts/*" $ version "markdown" $ do
>         route $ setExtension "md"
>         compile $ fmap writeThroughItemMd pandoced
>
>     match "posts/*" $ version "latex" $ do
>         route $ setExtension "tex"
>         compile $ fmap writeThroughItemTex pandoced
> 
>     create ["archives.html"] $ do
>         route idRoute
>         compile $ do
>             posts <- recentFirst =<< loadAllSnapshotsNoVersion "posts/*" "content"
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
>             posts <- recentFirst =<< loadAllSnapshotsNoVersion "posts/*" "content"
>             popularPosts <- (filterM (\post -> fmap (\x -> Set.member x mostPopularPostTitles) (getItemTitle (itemIdentifier post)))) =<< loadAllSnapshotsNoVersion "posts/*" "content"
>             let indexCtx =
>                     listField "popularPosts" postCtx (return popularPosts) <>
>                     listField "posts" postCtxWithIdx (return (zipWith (\post idx -> fmap (\postContents -> (postContents, idx)) post) posts (fmap show [1 :: Integer .. 3]))) <>
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
>
> loadAllSnapshotsNoVersion pattern = loadAllSnapshots (pattern .&&. hasNoVersion)

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
> createBasePageNonRelative :: Pattern -> String -> Context String -> Rules ()
> createBasePageNonRelative sourcefile colortagname generatedTagsCtx =
>     match sourcefile $ do
>         route   $ setExtension "html"
>         compile $ do 
>             pandocCompiler
>                 >>= loadAndApplyTemplate "templates/default.html" (injectCustomColor colortagname <> generatedTagsCtx <> defaultContext)
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
>     collectTags tagsToCollect = map (\(t, _) -> Item (tagsMakeId tagsToCollect t) t) (tagsMap tagsToCollect)
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
> simpleRenderLink :: String -> (Maybe FilePath) -> Maybe Html.Html
> simpleRenderLink _   Nothing         = Nothing
> simpleRenderLink tag (Just filePath) =
>   Just $ Html.a ! A.href (toValue $ toUrl filePath) $ toHtml tag
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
>             loadAllSnapshotsNoVersion "posts/*" "content"
>         renderer feedConfig feedCtx posts
> 
> getItemTitle :: (MonadFail m, MonadMetadata m) => Identifier -> m Text
> getItemTitle identifier = do
>     metadata <- getMetadata identifier
>     case Map.lookup "title" metadata of
>          Nothing -> fail $ "We were unable to find a title for " ++ show identifier
>          Just title -> case title of 
>                             Aeson.String titleText -> return titleText
>                             _ -> fail $ "We found a title for " ++ show identifier ++ " but it doesn't look like a valid JSON string: " ++ show title
