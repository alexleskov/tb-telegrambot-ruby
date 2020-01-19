module Teachbase
  module Bot
    module Scenarios
      module Base
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods; end

        def signin
          answer.send_out "#{Emoji.t(:rocket)}<b>#{I18n.t('enter')} #{I18n.t('in_teachbase')}</b>"
          appshell.authorization
          menu.hide("<b>#{answer.user_fullname_str}!</b> #{I18n.t('greetings')} #{I18n.t('in_teachbase')}!")
          menu.after_auth
        rescue RuntimeError => e
          answer.send_out "#{I18n.t('error')} #{e}"
        end

        def sign_out
          answer.send_out "#{Emoji.t(:door)}<b>#{I18n.t('sign_out')}</b>"
          appshell.logout
          menu.hide("<b>#{answer.user_fullname_str}!</b> #{I18n.t('farewell_message')} :'(")
          menu.starting
        rescue RuntimeError => e
          answer.send_out "#{I18n.t('error')} #{e}"
        end

        def settings
          buttons = [[text: "#{I18n.t('edit')} #{I18n.t('settings').downcase}", callback_data: "edit_settings"]]
          menu.create(buttons, :menu_inline,
                      "<b>#{Emoji.t(:wrench)}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>
                       \n #{Emoji.t(:video_game)} #{I18n.t('scenario')}: #{respond.incoming_data.settings.scenario}
                       \n #{Emoji.t(:ab)} #{I18n.t('localization')}: #{respond.incoming_data.settings.localization}", 1)
        end

        def edit_settings
          buttons = []
          Teachbase::Bot::Setting::PARAMS.each do |setting|
            setting.to_s
            buttons << [text: I18n.t(setting).to_s, callback_data: setting.to_s]
          end
          menu.create(buttons, :menu_inline,
                      "<b>#{Emoji.t(:wrench)} #{I18n.t('editing_settings')}</b>", 2)
        end

        def match_data
          on %r{edit_settings} do
            edit_settings
          end
        end

        def match_text_action
          on %r{^/start} do
            answer.send_out_greeting_message
            menu.starting
          end

          on %r{^/close} do
            menu.hide("<b>#{answer.user_fullname_str}!</b> #{I18n.t('farewell_message')} :'(")
          end
        end
      end
    end
  end
end
