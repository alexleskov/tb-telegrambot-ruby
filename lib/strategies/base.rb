# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Base < Teachbase::Bot::Strategies
        def setting
          strategies_methods_class::Setting.new(controller)
        end

        def content
          strategies_methods_class::Content.new(controller)
        end

        def cs
          strategies_methods_class::CourseSession.new(controller)
        end

        def profile
          strategies_methods_class::Profile.new(controller)
        end

        def section
          strategies_methods_class::Section.new(controller)
        end

        def document
          strategies_methods_class::Document.new(controller)
        end

        def find(options = {})
          strategies_methods_class::Find.new(controller, options)
        end

        def notify(options = {})
          strategies_methods_class::Notify.new(controller, options)
        end

        def help
          interface.sys.text.help_info.show
        end

        def sign_out
          interface.sys.menu.farewell(appshell.user_fullname(:string)).show
          appshell.reset_to_default_scenario if demo_mode_on?
          appshell.logout
          appshell.context.handle
          appshell.context.current_strategy.starting
        rescue RuntimeError => e
          interface.sys.text.on_error(e).show
        end

        def reset_password
          # Reset password is only for demo mode
          appshell.change_scenario(Teachbase::Bot::Strategies::DEMO_MODE_NAME)
          interface.sys.menu(text: "#{Emoji.t(:point_down)} #{I18n.t('click_to_send_contact')}").take_contact.show
          contact = appshell.request_data(:none)
          unless contact.is_a?(Teachbase::Bot::ContactController)
            appshell.reset_to_default_scenario if appshell.user_settings.scenario == Teachbase::Bot::Strategies::DEMO_MODE_NAME
            return interface.sys.menu(text: I18n.t('declined')).starting.show
          end
          raise if contact.tg_user.id != controller.tg_user.id

          result = appshell.authorizer.reset_password(contact)
          raise "User password not changed" unless result

          interface.sys.text.password_changed.show
          appshell.context.current_strategy.sign_in
        rescue RuntimeError, TeachbaseBotException => e
          appshell.logout
          interface.sys.menu(text: I18n.t('declined')).starting.show
          title = to_text_by_exceiption_code(e)
          interface.sys.menu(text: title).sign_in_again.show
          appshell.reset_to_default_scenario if appshell.user_settings.scenario == Teachbase::Bot::Strategies::DEMO_MODE_NAME
        end

        alias closing sign_out

        def change_account
          appshell.logout_account
          sign_in
        rescue RuntimeError, TeachbaseBotException => e
          # $logger.debug "On auth error: #{e.class}. #{e.inspect}"
          title = to_text_by_exceiption_code(e)
          title = "#{I18n.t('accounts')}: #{title}" if e.is_a?(TeachbaseBotException::Account)
          appshell.logout if access_denied?(e) || e.is_a?(TeachbaseBotException::Account)
          interface.sys.menu.starting.show
          interface.sys.menu(text: title).sign_in_again.show
        end

        alias accounts change_account

        def ready; end

        def send_contact; end

        # TO DO: Aliases made for CommandController commands using. Will remove after refactoring.
        def settings_list
          setting.list
        end

        def cs_list
          cs.states
        end

        def studying
          cs.states
        end

        def more_actions
          profile.links
        end

        def user_profile
          profile.me
        end

        def documents
          document.list_by
        end

        private

        def strategies_methods_class
          appshell.context.current_strategy ? appshell.context.current_strategy.class : default_strategies_methods_class
        end
      end
    end
  end
end
