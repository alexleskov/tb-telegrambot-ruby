# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Base
        class Menu < Teachbase::Bot::Interfaces::Menu
          def administration
            @type = :menu
            @slices_count = 2
            @text ||= "#{Emoji.t(:wrench)} <b>#{I18n.t('admin_menu_message')}</b>"
            @buttons = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[accounts_manager new_account starting]).raw
            self
          end

          def starting
            @type = :menu
            @slices_count = 2
            @text ||= I18n.t('start_menu_message').to_s
            @buttons = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[demo_mode sign_in settings_list]).raw
            self
          end

          def take_contact
            @type = :menu
            @mode ||= :none
            @slices_count = 2
            @text ||= "#{I18n.t('meet_with_bot')}\n\n#{Emoji.t(:point_down)} #{I18n.t('click_to_send_contact')} #{I18n.t('notice_about_safety')}"
            @buttons = TextCommandKeyboard.collect(buttons: [TextCommandButton.take_contact(init_commands),
                                                             TextCommandButton.decline(init_commands)]).raw
            self
          end

          def sign_in_again
            @type = :menu_inline
            @buttons = InlineCallbackKeyboard.collect(buttons: [InlineCallbackButton.sign_in(router.g(:main, :login).link)]).raw
            @mode ||= :none
            @text ||= "#{I18n.t('error')}. #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}"
            self
          end

          def after_auth
            @type = :menu
            @slices_count = 2
            @text ||= I18n.t('start_menu_message').to_s
            @buttons = TextCommandKeyboard.g(commands: init_commands,
                                             buttons_signs: %i[studying user_profile documents more_actions settings_list sign_out]).raw
            self
          end

          def on_empty
            @type = :menu_inline
            @mode ||= :none
            @buttons = InlineCallbackKeyboard.collect(buttons: [InlineCallbackButton.custom_back(back_button[:action])]).raw
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
              buttons_signs.each do |buttons_sign|
                buttons_actions << router.g(:content, :confirm_answer, id: entity.tb_id,
                                                                       p: [cs_id: cs_tb_id, sec_id: entity.section.id, type: entity.class.type_like_sym,
                                                                           answer_type: answer_type, param: buttons_sign]).link
              end
            end
            @type = :menu_inline
            @slices_count = 2
            @buttons = InlineCallbackKeyboard.g(buttons_signs: to_i18n(buttons_signs), buttons_actions: buttons_actions,
                                                emojis: %i[ok leftwards_arrow_with_hook]).raw
            @text ||= ["<b>#{I18n.t('send').capitalize} #{I18n.t(answer_type.to_s).downcase}</b>\n",
                       "#{Emoji.t(:memo)} #{I18n.t('text').capitalize}:",
                       "<pre>#{user_answer[:text]}</pre>\n",
                       "#{Emoji.t(:bookmark_tabs)} #{I18n.t('attachments').capitalize}: #{user_answer[:files].size}"].join("\n")
            self
          end

          def settings(settings_data)
            @type = :menu_inline
            @text ||= ["<b>#{Emoji.t(:wrench)}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>\n",
                       # TODO: Get it back after update scenarios logics
                       # "#{I18n.t('scenario')}: #{I18n.t(to_snakecase(settings_data[:scenario]))}",
                       "#{I18n.t('localization')}: #{I18n.t(settings_data[:localization])}"].join("\n")
            @mode ||= :none
            @buttons = InlineCallbackKeyboard.g(buttons_signs: ["#{I18n.t('edit')} #{I18n.t('settings').downcase}"],
                                                buttons_actions: [router.g(:setting, :edit).link]).raw
            self
          end

          def edit_settings
            @type = :menu_inline
            @slices_count = 2
            @text ||= "<b>#{Emoji.t(:wrench)} #{I18n.t('editing_settings')}</b>"
            @mode ||= :edit_msg
            buttons_actions = []
            buttons_signs = settings_class::PARAMS
            buttons_signs.each { |buttons_sign| buttons_actions << router.g(:setting, :edit, p: [param: buttons_sign]).link }
            @buttons = InlineCallbackKeyboard.g(buttons_signs: to_i18n(buttons_signs), buttons_actions: buttons_actions,
                                                back_button: back_button).raw
            self
          end

          def choosing(class_type, option_name)
            @type = :menu_inline
            @text ||= "<b>#{Emoji.t(:wrench)} #{I18n.t("choose_#{option_name.downcase}")}</b>"
            buttons_actions = []
            class_for_choosing = "Teachbase::Bot::#{class_type.capitalize}::"
            buttons_signs = to_constantize("#{option_name.upcase}_PARAMS", class_for_choosing)
            buttons_signs.each do |buttons_sign|
              buttons_actions << router.g(:setting, option_name.downcase.to_sym, p: [param: buttons_sign]).link
            end
            @slices_count = buttons_signs.size
            @buttons = InlineCallbackKeyboard.g(buttons_signs: to_i18n(buttons_signs), buttons_actions: buttons_actions,
                                                emojis: to_constantize("#{option_name.upcase}_EMOJI", class_for_choosing),
                                                back_button: back_button).raw
            self
          end

          def ready
            @type = :menu
            @text ||= "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_next_answer')} #{Emoji.t(:point_down)}"
            @buttons = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[ready]).raw
            self
          end

          def decline
            @type = :menu
            @text ||= I18n.t('start_menu_message').to_s
            @buttons = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[decline]).raw
            self
          end

          def links(links_list)
            raise unless links_list.is_a?(Array)

            @type = :menu_inline
            @mode ||= :edit_msg
            @text ||= "#{create_title(title_params)}<b>#{Emoji.t(:link)} #{I18n.t('attachments')}</b>"
            @buttons = InlineUrlKeyboard.collect(buttons: build_links_buttons(links_list), back_button: back_button).raw
            self
          end

          def accounts(accounts_list, options = [])
            raise unless accounts_list.first.is_a?(Teachbase::Bot::Account)

            @type = :menu_inline
            @slices_count = 2
            @mode ||= :none
            @text ||= "<b>#{Emoji.t(:school)} #{I18n.t('choose_account')}</b>"
            @buttons = build_accounts_buttons(accounts_list, options)
            self
          end

          def about_bot
            @type = :hide_kb
            @text ||= I18n.t('about_bot').to_sym
            self
          end

          def greetings(custom_text = "")
            @type = :hide_kb
            @text ||= "<b>#{I18n.t('greetings')}!</b>\n\n#{custom_text}"
            self
          end

          def farewell(user_name)
            @type = :hide_kb
            @text ||= "<b>#{user_name}!</b> #{I18n.t('farewell_message')} #{Emoji.t(:crying_cat_face)}"
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

          def settings_class
            Teachbase::Bot::Setting
          end
        end
      end
    end
  end
end
