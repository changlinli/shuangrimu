--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend, (<>), mconcat)
import           Hakyll
import           Text.Blaze.Html5                (toHtml, toValue, (!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes     as A
import           Text.Printf


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
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

    match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    tags <- buildTags "posts/*" (fromCapture "tags/*.html")
    let postCtxWithTags = tagsCtx tags <> postCtx

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtxWithTags
            >>= loadAndApplyTemplate "templates/default.html" postCtxWithTags
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) <>
                    constField "title" "Home"                <>
                    tagsCtx tags                             <>
                    injectCustomColor  ""                    <>
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

tagsCtx :: Tags -> Context a
tagsCtx tags = tagsFieldAsLIs "tags" tags

tagsFieldAsLIs :: String -> Tags -> Context a
tagsFieldAsLIs contextKey tags = listField contextKey defaultContext (return (collectTags tags))
  where
    collectTags tags = map (\(t, _) -> Item (tagsMakeId tags t) t) (tagsMap tags)

collectTags' tags = map (\(t, _) -> Item (tagsMakeId tags t) t) (tagsMap tags)

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

listFieldWithIndex = undefined
