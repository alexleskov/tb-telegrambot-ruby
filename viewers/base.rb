module Teachbase
  module Bot
    module Viewers
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
          try_signin_again
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
          menu.settings
        end

        def edit_settings
          menu.edit_settings
        end

        def choose_localization
          menu.choosing("Setting", :localization)
        end

        def choose_scenario
          menu.choosing("Setting", :scenario)
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

        def try_signin_again
          menu.create(buttons: InlineCallbackButton.sign_in,
                      mode: :none,
                      type: :menu_inline,
                      text: "#{I18n.t('error')} #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}")
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
      end
    end
  end
end
