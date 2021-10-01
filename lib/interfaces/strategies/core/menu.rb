# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Core
        class Menu < Teachbase::Bot::Interfaces::Menu
          def starting
            @params[:type] = :menu
            @params[:slices_count] = 2
            @params[:text] ||= I18n.t('start_menu_message').to_s
            @params[:buttons] = TextCommandKeyboard.g(commands: init_commands,
                                                      buttons_signs: %i[demo_mode sign_in settings_list]).raw
            self
          end

          def accounts(accounts_list, options = [])
            raise unless accounts_list.first.is_a?(Teachbase::Bot::Account)

            @params[:type] = :menu_inline
            @params[:slices_count] = 1
            @params[:mode] ||= :none
            @params[:text] ||= "<b>#{Emoji.t(:school)} #{I18n.t('choose_account')}</b>"
            @params[:buttons] = build_accounts_buttons(accounts_list, options)
            self
          end

          def take_contact
            @params[:type] = :menu
            @params[:mode] ||= :none
            @params[:slices_count] = 2
            @params[:text] ||= Phrase::Enter.contact
            @params[:buttons] = TextCommandKeyboard.collect(buttons: [TextCommandButton.take_contact(init_commands),
                                                                      TextCommandButton.decline(init_commands)]).raw
            self
          end

          def sign_in_again
            @params[:type] = :menu_inline
            @params[:buttons] = InlineCallbackKeyboard.collect(buttons: [InlineCallbackButton.sign_in(router.g(:main, :login).link)]).raw
            @params[:mode] ||= :none
            @params[:text] ||= Phrase.auth_failed
            self
          end

          def after_auth
            @params[:type] = :menu
            @params[:slices_count] = 2
            @params[:text] ||= I18n.t('start_menu_message').to_s
            @params[:buttons] = TextCommandKeyboard.g(commands: init_commands,
                                                      buttons_signs: %i[studying user_profile documents more_actions settings_list sign_out]).raw
            self
          end

          def on_empty
            @params[:type] = :menu_inline
            @params[:mode] ||= :none
            @params[:buttons] = InlineCallbackKeyboard.collect(buttons: [InlineCallbackButton.custom_back(back_button[:action])]).raw
            on_empty_params
            self
          end

          def confirm_answer(answer_type, user_answer = nil)
            buttons_signs = %i[accept decline]
            buttons_actions = []
            case answer_type.to_sym
            when :message, :choice
              buttons_actions = buttons_signs
            else
              router_parameters = { cs_id: entity.course_session.tb_id, sec_id: entity.section.id,
                                    type: entity.class.type_like_sym, answer_type: answer_type }
              buttons_signs.each do |buttons_sign|
                router_parameters[:param] = buttons_sign
                buttons_actions << router.g(:content, :confirm_answer, id: entity.tb_id, p: [router_parameters]).link
              end
            end
            @params[:type] = :menu_inline
            @params[:slices_count] = 2
            @params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: to_i18n(buttons_signs), buttons_actions: buttons_actions,
                                                         emojis: %i[ok leftwards_arrow_with_hook]).raw
            @params[:text] ||= ["<b>#{I18n.t('send').capitalize} #{I18n.t(answer_type.to_s).downcase}</b>\n",
                                "#{Emoji.t(:memo)} #{I18n.t('text').capitalize}:\n",
                                "#{user_answer[:text]}\n",
                                "#{Phrase.attachments}: #{user_answer[:files].size}"].join("\n")
            self
          end

          def settings(settings_data)
            @params[:type] = :menu_inline
            @params[:text] ||= ["<b>#{Emoji.t(:wrench)}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>\n",
                                # TODO: Get it back after update scenarios logics
                                # "#{I18n.t('scenario')}: #{I18n.t(to_snakecase(settings_data[:scenario]))}",
                                "#{I18n.t('localization')}: #{I18n.t(settings_data[:localization])}"].join("\n")
            @params[:mode] ||= :none
            @params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: ["#{I18n.t('edit')} #{I18n.t('settings').downcase}"],
                                                         buttons_actions: [router.g(:setting, :edit).link]).raw
            self
          end

          def edit_settings
            @params[:type] = :menu_inline
            @params[:slices_count] = 2
            @params[:text] ||= "<b>#{Emoji.t(:wrench)} #{I18n.t('editing_settings')}</b>"
            @params[:mode] = :edit_msg
            buttons_actions = []
            buttons_signs = Teachbase::Bot::Setting::PARAMS
            buttons_signs.each { |buttons_sign| buttons_actions << router.g(:setting, :edit, p: [param: buttons_sign]).link }
            @params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: to_i18n(buttons_signs), buttons_actions: buttons_actions,
                                                         back_button: back_button).raw
            self
          end

          def choosing(class_type, option_name)
            @params[:type] = :menu_inline
            @params[:text] ||= "<b>#{Emoji.t(:wrench)} #{I18n.t("choose_#{option_name.downcase}")}</b>"
            buttons_actions = []
            class_for_choosing = "Teachbase::Bot::#{class_type.capitalize}::"
            buttons_signs = to_constantize("#{option_name.upcase}_PARAMS", class_for_choosing)
            buttons_signs.each do |buttons_sign|
              buttons_actions << router.g(:setting, option_name.downcase.to_sym, p: [param: buttons_sign]).link
            end
            @params[:slices_count] = buttons_signs.size
            @params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: to_i18n(buttons_signs), buttons_actions: buttons_actions,
                                                         emojis: to_constantize("#{option_name.upcase}_EMOJI", class_for_choosing),
                                                         back_button: back_button).raw
            self
          end

          def ready
            @params[:type] = :menu
            @params[:text] ||= Phrase::Enter.next_answer
            @params[:buttons] = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[ready]).raw
            self
          end

          def decline
            @params[:type] = :menu
            @params[:text] ||= I18n.t('start_menu_message').to_s
            @params[:buttons] = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[decline]).raw
            self
          end

          def about_bot
            @params[:type] = :hide_kb
            @params[:text] ||= I18n.t('about_bot').to_sym
            self
          end

          def greetings(custom_text = "")
            @params[:type] = :hide_kb
            @params[:text] ||= "<b>#{I18n.t('greetings')}!</b>\n\n#{custom_text}"
            self
          end

          def farewell
            @params[:type] = :hide_kb
            @params[:text] ||= "#{I18n.t('farewell_message').capitalize} #{Emoji.t(:crying_cat_face)}"
            self
          end

          private

          def build_accounts_buttons(accounts_list, options)
            keyboard_params = { buttons_signs: accounts_list.pluck(:name), buttons_actions: accounts_list.pluck(:tb_id),
                                back_button: back_button }
            if options.include?(:statuses)
              keyboard_params[:emojis] = accounts_list.pluck(:active).map { |state| state ? :white_check_mark : :construction }
            end
            if options.include?(:tb_ids)
              accounts_list.pluck(:tb_id).each_with_index do |account_tb_id, ind|
                keyboard_params[:buttons_signs][ind] = "#{account_tb_id}: #{keyboard_params[:buttons_signs][ind]}"
              end
            end
            InlineCallbackKeyboard.g(keyboard_params).raw
          end
        end
      end
    end
  end
end
