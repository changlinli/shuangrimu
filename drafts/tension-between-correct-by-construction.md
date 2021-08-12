Tree as zipper vs keeping track of indices of where you are on the tree.

Former is correct by construction (indices can't be out of bounds), but the
latter can situationally offer better performance (persist your current tree
location to a file and then reload previous progress).

Correct by construction locks into the former, sacrificing certain performance
access patterns.
