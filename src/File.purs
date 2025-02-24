module File where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)

foreign import data File :: Type

foreign import file :: String -> File

foreign import write_ :: File -> String -> Effect (Promise Unit)

write ∷ File → String → Aff Unit
write file_ content = toAffE (write_ file_ content)

foreign import read_ :: File -> Effect (Promise String)

read ∷ File → Aff String
read file_ = toAffE (read_ file_)
