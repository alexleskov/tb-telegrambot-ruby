module Teachbase
  module Bot
    class Strategies
      class Base < Teachbase::Bot::Strategies
        TEACHSUPPORT_TG_ID = 439_802_952

        def setting
          Teachbase::Bot::Strategies::Setting.new(controller)
        end

        def content
          Teachbase::Bot::Strategies::Content.new(controller)
        end

        def cs
          Teachbase::Bot::Strategies::CourseSession.new(controller)
        end

        def profile
          Teachbase::Bot::Strategies::Profile.new(controller)
        end

        def section
          Teachbase::Bot::Strategies::Section.new(controller)
        end

        def document
          Teachbase::Bot::Strategies::Document.new(controller)
        end

        def find(options = {})
          Teachbase::Bot::Strategies::Find.new(controller, options)
        end

        def notify(options = {})
          Teachbase::Bot::Strategies::Notify.new(controller, options)
        end

        def support_tg_id
          if appshell.current_account(:without_api) && appshell.current_account.support_tg_id
            appshell.current_account.support_tg_id
          else
            TEACHSUPPORT_TG_ID
          end
        end

        def curator_tg_id
          return unless appshell.current_account(:without_api) && appshell.current_account.support_tg_id
          
          appshell.current_account.curator_tg_id
        end

        def user_tg_id_by(tb_id)
          Teachbase::Bot::User.find_by(tb_id: tb_id).auth_sessions.where.not(auth_at: nil)
                              .order(auth_at: :desc).select(:tg_account_id).pluck(:tg_account_id).first
        end

        def sign_out
          interface.sys.menu.farewell(appshell.user_fullname(:string)).show
          appshell.reset_to_default_scenario if demo_mode_on?
          appshell.logout
          current_strategy = appshell.context.handle
          current_strategy.starting
        rescue RuntimeError => e
          interface.sys.text.on_error(e).show
        end

        def reset_password
          # Reset password only for demo mode
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
          current_strategy = appshell.context.handle
          current_strategy.sign_in
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
          $logger.debug "On auth error: #{e.class}. #{e.inspect}"
          title = to_text_by_exceiption_code(e)
          title = "#{I18n.t('accounts')}: #{title}" if e.is_a?(TeachbaseBotException::Account)
          appshell.logout if access_denied?(e) || e.is_a?(TeachbaseBotException::Account)
          interface.sys.menu.starting.show
          interface.sys.menu(text: title).sign_in_again.show
        end

        alias accounts change_account

        def ready; end

        def send_contact; end

        #TO DO: Aliases made for CommandController commands using. Will remove after refactoring.
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

      end
    end
  end
end