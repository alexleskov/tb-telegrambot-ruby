# frozen_string_literal: true

module Decorators
  module Account
    include Formatter

    def title
      "#{Emoji.t(:house)} #{I18n.t('company')} — #{tb_id}: #{name}"
    end

    def main_info
      ["<b>#{title}</b>\n",
       "client_id: <pre>#{client_id}</pre>",
       "curator_tg_id: <pre>#{curator_tg_id || I18n.t('empty')}</pre>",
       "support_tg_id: <pre>#{support_tg_id || I18n.t('empty')}</pre>"].join("\n")
    end
  end
end
