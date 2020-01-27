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
          auth = appshell.authorization
          return unless auth

          menu.hide("<b>#{answer.user_fullname(:string)}!</b> #{I18n.t('greetings')} #{I18n.t('in_teachbase')}!")
          menu.after_auth
        rescue RuntimeError => e
          answer.send_out "#{I18n.t('error')} #{e}"
        end

        def sign_out
          answer.send_out "#{Emoji.t(:door)}<b>#{I18n.t('sign_out')}</b>"
          appshell.logout
          menu.hide("<b>#{answer.user_fullname(:string)}!</b> #{I18n.t('farewell_message')} :'(")
          menu.starting
        rescue RuntimeError => e
          answer.send_out "#{I18n.t('error')} #{e}"
        end

        def settings
          buttons = [[text: "#{I18n.t('edit')} #{I18n.t('settings').downcase}", callback_data: "edit_settings"]]
          menu.create(buttons: buttons,
                      type: :menu_inline,
                      text: "<b>#{Emoji.t(:wrench)}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>
                             \n #{Emoji.t(:video_game)} #{I18n.t('scenario')}: #{I18n.t(snakecase(respond.incoming_data.settings.scenario))}
                             \n #{Emoji.t(:ab)} #{I18n.t('localization')}: #{I18n.t(respond.incoming_data.settings.localization)}",
                      slices_count: 1)
        end

        def edit_settings
          buttons = menu.
                    create_inline_buttons(Teachbase::Bot::Setting::PARAMS, command_prefix = "settings:")
          menu.create(buttons: buttons,
                      mode: :edit_msg,
                      type: :menu_inline,
                      text: "<b>#{Emoji.t(:wrench)} #{I18n.t('editing_settings')}</b>",
                      slices_count: 2)
        end

        def choose_localization
          buttons = menu.
                    create_inline_buttons(Teachbase::Bot::Setting::LOCALIZATION_PARAMS, command_prefix = "language_param:")
          buttons << [text: "Back", callback_data: "edit_settings"] # TODO: Take from last_message
          menu.create(buttons: buttons,
                      mode: :edit_msg,
                      type: :menu_inline,
                      text: "<b>#{Emoji.t(:abc)} #{I18n.t('choose_localization')}</b>",
                      slices_count: 2)
        end

        def choose_scenario
          buttons = menu.
                    create_inline_buttons(Teachbase::Bot::Setting::SCENARIO_PARAMS, command_prefix = "scenario_param:")
          menu.create(buttons: buttons,
                      type: :menu_inline,
                      text: "<b>#{Emoji.t(:abc)} #{I18n.t('choose_scenario')}</b>",
                      slices_count: 2)          
        end

        def change_language(lang)
          appshell.change_localization(lang.to_s)
          I18n.with_locale appshell.settings.localization.to_sym do
            answer.send_out "#{Emoji.t(:floppy_disk)} #{I18n.t('editted')}. #{I18n.t('localization')}: <b>#{I18n.t(lang)}</b>"
            menu.starting
          end
        end

        def change_scenario(mode)
          appshell.change_scenario(mode)
        end

        def match_data
          on %r{edit_settings} do
            edit_settings
          end

          on %r{^settings:localization} do
            choose_localization
          end

          on %r{^language_param:} do
            @message_value =~ %r{^language_param:(\w*)}
            change_language($1)
          end

          on %r{settings:scenario} do
            choose_scenario
          end

          on %r{^scenario_param:} do
            @message_value =~ %r{^scenario_param:(\w*)}
            mode = $1
            change_scenario(mode)
            answer.send_out "#{Emoji.t(:floppy_disk)} #{I18n.t('editted')}. #{I18n.t('scenario')}: <b>#{I18n.t(mode)}</b>"
          end

        end

        def match_text_action
          on %r{^/start} do
            answer.greeting_message
            menu.starting
          end

          on %r{^/settings} do
            settings
          end

          on %r{^/close} do
            menu.hide("<b>#{answer.user_fullname(:string)}!</b> #{I18n.t('farewell_message')} :'(")
          end
        end

        private

        def snakecase(string)
          string.to_s.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr('-', '_').
          gsub(/\s/, '_').
          gsub(/__+/, '_').
          downcase
        end
      end
    end
  end
end
