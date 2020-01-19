require 'gemoji'

module Emoji
  def t(emoji_alias)
    find_by_alias(emoji_alias.to_s).raw
  end
end