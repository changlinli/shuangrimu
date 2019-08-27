{-# LANGUAGE GADTs, RankNTypes, ScopedTypeVariables #-}

import Debug.Trace (traceShow, trace)

data Nat0 where
    Zero :: () -> Nat0
    Succ :: Nat0 -> Nat0

data Nat1 where
    ZeroOrSucc :: Either () Nat1 -> Nat1

type Nat2F x = Either () x

data Nat2 where
    K :: Nat2F Nat2 -> Nat2

-- K is an isomorphism between Nat2F Nat2 and Nat2. One direction is the
-- arrow. The reverse direction is pattern matching.
-- Note that there is also a 

-- Many different ways of encoding a list.

-- Standard ADT

data List0 a where
    Nil0 :: List0 a
    Cons0 :: a -> List0 a -> List0 a
    deriving Show

-- Church encoding


-- Scott encoding

-- Parigot encoding

-- Boehm-Berarducci

-- Unfolding/corecursion
data List3

data List a where
    Nil :: List a
    Cons :: a -> List a -> List a
    deriving Show

type List' a = (forall b. b -> (a -> b -> b) -> b)

toChurch :: List a -> (forall b r. b -> (a -> b -> b) -> b)
toChurch Nil start _ = start
toChurch (Cons x xs) start f = f x (toChurch xs start f)

fromChurch :: (forall b. b -> (a -> b -> b) -> b) -> List a
fromChurch f = f Nil Cons

at :: Int -> List a -> Maybe a
at 0 Nil = Nothing
at 0 (Cons x xs) = Just x
at n Nil = Nothing
at n (Cons _ xs) = at (n - 1) xs

newtype List'' a = List'' { uncons :: forall r. r -> (a -> List'' a -> r) -> r}

tailBlah :: List a -> List a
tailBlah (l @ Nil) = l
tailBlah (Cons _ xs) = xs

{-tail'' :: forall a. List'' a -> List'' a-}
{-tail'' (List'' f) = List'' blah-}
  {-where-}
    {-blah :: forall r1. a -> (a -> List'' a -> r1) -> r1-}
    {-blah = (f f (\_ xs -> uncons xs))-}

at' :: Int -> (forall b. b -> (a -> b -> b) -> b) -> Maybe a
at' 0 l = l Nothing (\y _ -> Just y)
at' n l = at' (n - 1) (\nil cons -> l nil (\_ ys -> ys))

nil' :: List' a
nil' = \nil cons -> nil

consA :: a -> List a -> List a
consA x l = case l of
                 Nil -> Cons x Nil
                 Cons y ys -> Cons x (Cons y ys)

cons' :: a -> List' a -> List' a
cons' x l = \nil cons -> cons x (l nil cons)

{-list123 : List' Int-}
{-list123 = \nil cons -> -}

mapA :: (a -> b) -> List a -> List b
mapA f xs = case xs of
                 Nil -> Nil
                 Cons y ys -> Cons (f y) (mapA f ys)

map' :: (a -> b) -> List' a -> List' b
map' f l = \nil cons -> l nil (\y ys -> cons (f y) ys)

tail' :: List' a -> List' a
tail' l = \nil cons -> l nil (\_ ys -> ys)

blah0 = fromChurch (toChurch (Cons 3 (Cons 2 (Cons 1 Nil))))
blah1 = toChurch (Cons 3 (Cons 2 (Cons 1 Nil)))
