# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        module Setting
          def settings
            interface.sys.menu(scenario: appshell.settings.scenario,
                               localization: appshell.settings.localization).settings
          end

          def settings_edit
            interface.sys.menu(back_button: build_back_button_data).edit_settings
          end

          def setting_choose(setting)
            interface.sys.menu(back_button: build_back_button_data).choosing("Setting", setting.to_sym)
          end

          def langugage_change(lang)
            raise "Lang param is empty" if lang.empty?

            appshell.change_localization(lang.to_s)
            I18n.with_locale appshell.settings.localization.to_sym do
              interface.sys.text.on_save("localization", lang)
              interface.sys.menu.starting
            end
          end

          def scenario_change(mode)
            raise "Mode param is empty" if mode.empty?

            appshell.change_scenario(mode)
            interface.sys.text.on_save("scenario", mode)
            interface.sys.menu.starting
          end          
        end
      end
    end
  end
end