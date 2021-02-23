# frozen_string_literal: true

module Emoji
  def t(emoji_alias)
    emoji = find_by_alias(emoji_alias.to_s)
    emoji ? emoji.raw : "\u2022 "
  end
end