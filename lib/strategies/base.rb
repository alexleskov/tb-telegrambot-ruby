# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Base < Teachbase::Bot::Strategies::Core
        def setting
          current_strategy_class::Setting.new(controller)
        end

        def content
          current_strategy_class::Content.new(controller)
        end

        def cs
          current_strategy_class::CourseSession.new(controller)
        end

        def profile
          current_strategy_class::Profile.new(controller)
        end

        def section
          current_strategy_class::Section.new(controller)
        end

        def document
          current_strategy_class::Document.new(controller)
        end

        def find(options = {})
          current_strategy_class::Find.new(controller, options)
        end

        def notify(options = {})
          current_strategy_class::Notify.new(controller, options)
        end

        def reset_password
          appshell.change_scenario(Teachbase::Bot::Strategies::DEMO_MODE_NAME) # Reset password is only for demo mode
          interface.sys.menu(text: "#{Emoji.t(:point_down)} #{I18n.t('click_to_send_contact')}").take_contact.show
          contact = appshell.request_data(:none)
          unless contact.is_a?(Teachbase::Bot::ContactController)
            appshell.to_default_scenario
            return interface.sys.menu(text: I18n.t('declined')).starting.show
          end
          raise if contact.user_id != controller.context.tg_user.id

          current_user = appshell.reset_password(contact)
          raise "User password not changed" unless current_user

          interface.sys.text.password_changed.show
          appshell.authorizer.send(:force_authsession, current_user)
          appshell.controller.context.current_strategy.sign_in
        rescue RuntimeError, TeachbaseBotException => e
          appshell.logout
          interface.sys.menu(text: I18n.t('declined')).starting.show
          title = to_text_by_exceiption_code(e)
          interface.sys.menu(text: title).sign_in_again.show
          appshell.to_default_scenario
        end

        def change_account
          appshell.change_account
          sign_in
        rescue RuntimeError, TeachbaseBotException => e
          $logger.debug "On auth error: #{e.class}. #{e.inspect}"
          title = to_text_by_exceiption_code(e)
          title = "#{I18n.t('accounts')}: #{title}" if e.is_a?(TeachbaseBotException::Account)
          appshell.logout if access_denied?(e) || e.is_a?(TeachbaseBotException::Account)
          interface.sys.menu.starting.show
          interface.sys.menu(text: title).sign_in_again.show
        end

        alias accounts change_account

        # TODO: Aliases made for CommandController commands using. Will remove after refactoring.

        def settings_list
          setting.list
        end

        def cs_list
          cs.states
        end

        alias studying cs_list

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

        def current_strategy_class
          appshell.controller.context.current_strategy ? appshell.controller.context.current_strategy.class : Teachbase::Bot::Strategies::Base
        end
      end
    end
  end
end
