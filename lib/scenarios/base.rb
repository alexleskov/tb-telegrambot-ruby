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
          raise unless auth

          menu.hide("<b>#{answer.user_fullname(:string)}!</b> #{I18n.t('greetings')} #{I18n.t('in_teachbase')}!")
          menu.after_auth
        rescue RuntimeError => e
          menu.create(buttons: MenuButton.t(:inline_cb, buttons_sign: [:signin]),
                      mode: :none,
                      type: :menu_inline,
                      text: "#{I18n.t('error')} #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}")
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
          buttons = MenuButton.t(:inline_cb,
                                  buttons_sign: [:settings],
                                  command_prefix: "edit_",
                                  text: "#{I18n.t('edit')} #{I18n.t('settings').downcase}")
          menu.create(buttons: buttons,
                      type: :menu_inline,
                      mode: :none,
                      text: "<b>#{Emoji.t(:wrench)}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>
                             \n #{Emoji.t(:video_game)} #{I18n.t('scenario')}: #{I18n.t(to_snakecase(respond.incoming_data.settings.scenario))}
                             \n #{Emoji.t(:ab)} #{I18n.t('localization')}: #{I18n.t(respond.incoming_data.settings.localization)}",
                      slices_count: 1)
        end

        def edit_settings
          buttons = MenuButton.t(:inline_cb,
                                  buttons_sign: Teachbase::Bot::Setting::PARAMS,
                                  command_prefix: "settings:",
                                  back_button: true,
                                  sent_messages: @tg_user.tg_account_messages)
          menu.create(buttons: buttons,
                      type: :menu_inline,
                      text: "<b>#{Emoji.t(:wrench)} #{I18n.t('editing_settings')}</b>",
                      slices_count: 2)
        end

        def choose_localization
          choose_menu("Setting", :localization)
        end

        def choose_scenario
          choose_menu("Setting", :scenario)  
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

        def show_breadcrumbs(level, stage_names, params = {})
          raise "'stage_names' is a #{stage_names.class}. Must be an Array." unless stage_names.is_a?(Array)

          breadcrumbs = init_breadcrumbs(params)
          raise "Can't find breadcrumbs." unless breadcrumbs

          delimeter = "\n"
          result = []
          stage_names.each do |stage_name|
            result << breadcrumbs[level.to_sym][stage_name]
          end
          to_bolder(result.last)
          result.join(delimeter)
        end

        private

        def choose_menu(type, param_name)
          buttons_sign = to_constantize("#{param_name.upcase}_PARAMS", "Teachbase::Bot::#{type.capitalize}::")
          buttons = MenuButton.t(:inline_cb,
                                  buttons_sign: buttons_sign,
                                  command_prefix: "#{param_name.downcase}_param:",
                                  back_button: true,
                                  sent_messages: @tg_user.tg_account_messages)
          menu.create(buttons: buttons,
                      type: :menu_inline,
                      text: "<b>#{Emoji.t(:abc)} #{I18n.t("choose_#{param_name.downcase}")}</b>",
                      slices_count: 2)
        end
      end
    end
  end
end
