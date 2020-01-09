module Teachbase
  module Bot
    module Scenarios
      module Base
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods ; end

        def signin
          answer.send_out "#{Emoji.find_by_alias('rocket').raw}<b>#{I18n.t('enter')} #{I18n.t('in_teachbase')}</b>"
          appshell.authorization
          menu.hide("<b>#{answer.user_fullname_str}!</b> #{I18n.t('greetings')} #{I18n.t('in_teachbase')}!")
          menu.after_auth
        rescue RuntimeError => e
          answer.send_out "#{I18n.t('error')} #{e}"
        end

        def sign_out
          answer.send_out "#{Emoji.find_by_alias('door').raw}<b>#{I18n.t('sign_out')}</b>"
          appshell.logout
          menu.hide("<b>#{answer.user_fullname_str}!</b> #{I18n.t('farewell_message')} :'(")
          menu.starting
        rescue RuntimeError => e
          answer.send_out "#{I18n.t('error')} #{e}"
        end

        def settings
          answer.send_out "<b>#{Emoji.find_by_alias('wrench').raw}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>
          \n #{Emoji.find_by_alias('video_game').raw} #{I18n.t('scenario')}: #{respond.incoming_data.settings.scenario}
          \n #{Emoji.find_by_alias('ab').raw} #{I18n.t('localization')}: #{respond.incoming_data.settings.localization}"
        end
      end
    end
  end
end