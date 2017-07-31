--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend, (<>), mconcat)
import           Hakyll
import           Text.Blaze.Html5                (toHtml, toValue, (!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes     as A
import           Text.Printf
import           Data.Bifoldable (bifoldMap)
import           System.FilePath
import           Data.List (isSuffixOf)
import           Data.Set (Set)
import qualified Data.Set as Set
import qualified Data.HashMap.Lazy as Map
import qualified Data.Aeson.Types as Aeson
import qualified Data.Aeson as Aeson
import           Data.Text (Text)
import           Control.Monad

--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match ".htaccess" $ do
        route   idRoute
        compile copyFileCompiler
    match "favicon.ico" $ do
        route   idRoute
        compile copyFileCompiler

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "js/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "prettify/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    tags <- buildTags "posts/*" (fromCapture "tags/*.html")

    let postCtxWithTags = injectCustomColor "" <> tagsCtx tags <> postCtx

    createBasePage "about.md" "#about" (tagsCtx tags)

    createBasePage "contact.md" "#contact" (tagsCtx tags)

    createBasePage "licensing.md" "#licensing" (tagsCtx tags)

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/post.html"    (tagsField "tags" tags <> injectCustomColor "" <> postCtx)
            >>= loadAndApplyTemplate "templates/default.html" postCtxWithTags
            >>= relativizeUrls

    create ["archives.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAllSnapshots "posts/*" "content"
            let archiveCtx =
                    listField "posts" postCtx (return posts) <>
                    constField "title" "Archives"            <>
                    injectCustomColor "#archives"            <>
                    tagsCtx tags                             <>
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    createFeed ["atom.xml"] renderAtom

    createFeed ["rss.xml"] renderRss

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAllSnapshots "posts/*" "content"
            popularPosts <- (filterM (\post -> fmap (\x -> Set.member x mostPopularPostTitles) (getItemTitle (itemIdentifier post)))) =<< loadAllSnapshots "posts/*" "content"
            let indexCtx =
                    listField "popularPosts" postCtx (return popularPosts) <>
                    listField "posts" postCtxWithIdx (return (zipWith (\post idx -> fmap (\postContents -> (postContents, idx)) post) posts (fmap show [1 .. 3]))) <>
                    constField "title" "Home"                <>
                    tagsCtx tags                             <>
                    injectCustomColor  ""                    <>
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/withSlider.html" indexCtx
                >>= relativizeUrls

    tagsRules tags $ \tag pattern -> do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll pattern
            let ctx = 
                    constField "tagname" tag <> 
                    injectCustomColor "" <>
                    tagsCtx tags <> 
                    listField "posts" postCtx (return posts) <> 
                    defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/tag.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------

mostPopularPostTitles :: Set Text
mostPopularPostTitles = Set.fromList [ "S.P.Q.R.", "Rosa Rosa Rosam" ]

createBasePage :: Pattern -> String -> Context String -> Rules ()
createBasePage sourcefile colortagname generatedTagsCtx =
    match sourcefile $ do
        route   $ setExtension "html"
        compile $ do 
            pandocCompiler
                >>= loadAndApplyTemplate "templates/default.html" (injectCustomColor colortagname <> generatedTagsCtx <> defaultContext)
                >>= relativizeUrls

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

type IdxAsString = String

postCtxWithIdx :: Context (String, IdxAsString)
postCtxWithIdx = Context f
  where
    postCtxF = unContext (postCtx)
    idxCtxF = unContext (field "listIndex" $ return . itemBody)
    f "listIndex" things item = idxCtxF "listIndex" things (fmap snd item)
    f key things item = postCtxF key things (fmap fst item)

tagsCtx :: Tags -> Context a
tagsCtx tags = tagsFieldAsLIs "tags" tags

tagsFieldAsLIs :: String -> Tags -> Context a
tagsFieldAsLIs contextKey tags = listField contextKey defaultContext (return (collectTags tags))
  where
    collectTags tags = map (\(t, _) -> Item (tagsMakeId tags t) t) (tagsMap tags)

injectCustomColor :: String -> Context String
injectCustomColor = constField "headstyle" . colorSelection 
  where
    colorSelection "#about" = "#about" <> toInterpolate (255, 127, 127)
    colorSelection "#archives" = "#archives" <> toInterpolate (127, 127, 255)
    colorSelection "#contact" = "#contact" <> toInterpolate (127, 200, 127)
    colorSelection "#licensing" = "#licensing" <> toInterpolate (200, 200, 127)
    colorSelection _ = ""

toInterpolate :: (Int, Int, Int) -> String
toInterpolate (x, y, z) = printf "{color:rgb(%s, %s, %s); background-color:rgb(220, 220, 220)}" (show x) (show y) (show z)

simpleRenderLink :: String -> (Maybe FilePath) -> Maybe H.Html
simpleRenderLink _   Nothing         = Nothing
simpleRenderLink tag (Just filePath) =
  Just $ H.a ! A.href (toValue $ toUrl filePath) $ toHtml tag

-- Begin from http://www.rohanjain.in/hakyll-clean-urls/
cleanHTMLRoute :: Routes
cleanHTMLRoute = customRoute createIndexRoute
  where
    createIndexRoute ident = takeDirectory p </> takeBaseName p </> "index.html"
                            where p = toFilePath ident

cleanIndexUrls :: Item String -> Compiler (Item String)
cleanIndexUrls = return . fmap (withUrls cleanIndex)

cleanIndexHtmls :: Item String -> Compiler (Item String)
cleanIndexHtmls = return . fmap (replaceAll pattern replacement)
    where
      pattern = "/index.html"
      replacement = const "/"

cleanIndex :: String -> String
cleanIndex url
    | idx `isSuffixOf` url = take (length url - length idx) url
    | otherwise            = url
  where idx = "index.html"

-- End from http://www.rohanjain.in/hakyll-clean-urls/

feedConfig :: FeedConfiguration
feedConfig = FeedConfiguration
    { feedTitle = "Shuang Rimu"
    , feedDescription = "A blog about random things"
    , feedAuthorName = "Changlin Li"
    , feedAuthorEmail = "rimu@shuangrimu.com"
    , feedRoot = "http://www.shuangrimu.com"
    }

createFeed
  :: [Identifier]
     -> (FeedConfiguration
         -> Context String -> [Item String] 
         -> Compiler (Item String)
         )
     -> Rules ()
createFeed filename renderer = create filename $ do
    route idRoute
    compile $ do
        let feedCtx = postCtx <> bodyField "description"
        posts <- fmap (take 10) . recentFirst =<<
            loadAllSnapshots "posts/*" "content"
        renderer feedConfig feedCtx posts

getItemTitle :: MonadMetadata m => Identifier -> m Text
getItemTitle identifier = do
    metadata <- getMetadata identifier
    case Map.lookup "title" metadata of
         Nothing -> fail $ "We were unable to find a title for " ++ show identifier
         Just title -> case title of 
                            Aeson.String titleText -> return titleText
                            _ -> fail $ "We found a title for " ++ show identifier ++ " but it doesn't look like a valid JSON string: " ++ show title
