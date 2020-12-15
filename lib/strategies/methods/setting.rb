# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Setting < Teachbase::Bot::Strategies
        def list
          interface.sys.menu.settings(scenario: appshell.user_settings.scenario,
                                      localization: appshell.user_settings.localization).show  
        end

        def edit
          interface.sys.menu(back_button: { mode: :custom, order: :ending,
                                            action: router.setting(path: :root).link }).edit_settings.show
        end

        def choose_one(setting)
          interface.sys.menu(back_button: build_back_button_data.merge!(order: :ending)).choosing("Setting", setting.to_sym).show
        end

        def langugage_change(lang)
          raise "Lang param is empty" if lang.empty?

          appshell.change_localization(lang.to_s)
          I18n.with_locale appshell.user_settings.localization.to_sym do
            interface.sys.text.on_save("localization", lang).show
            interface.sys.menu.starting.show
          end
        end

        def scenario_change(mode)
          raise "Mode param is empty" if mode.empty?

          appshell.change_scenario(mode)
          interface.sys.text.on_save("scenario", mode).show
          interface.sys.menu.starting.show
        end
      end
    end
  end
end
