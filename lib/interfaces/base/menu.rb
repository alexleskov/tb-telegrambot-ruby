# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Base
        class Menu < Teachbase::Bot::InterfaceController
          def sign_in_again
            params.merge!(type: :menu_inline,
                          buttons: InlineCallbackKeyboard.collect(buttons: [InlineCallbackButton.sign_in(router.main(path: :login).link)]).raw)
            params[:mode] ||= :none
            params[:text] ||= "#{I18n.t('error')}. #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}"
            answer.menu.create(params)
          end

          def starting
            params.merge!(type: :menu, slices_count: 2)
            params[:text] ||= I18n.t('start_menu_message').to_s
            params[:buttons] = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[sign_in settings]).raw
            answer.menu.create(params)
          end

          def on_empty
            params.merge!(type: :menu_inline)
            params[:text] ||= "#{params[:text]}\n#{sing_on_empty}"
            params[:mode] ||= :none
            back_button = InlineCallbackButton.custom_back(params[:back_button][:action])
            params[:buttons] = InlineCallbackKeyboard.collect(buttons: [back_button]).raw
            answer.menu.create(params)
          end

          def custom_back
            answer.menu.custom_back(params)
          end

          def back
            answer.menu.back(params)
          end

          def confirm_answer(answer_type)
            buttons_signs = %i[accept decline]
            buttons_actions = []
            if answer_type.to_sym == :message
              buttons_actions = buttons_signs
            else
              buttons_signs.each do |buttons_sign|
                buttons_actions << router.content(path: :confirm_answer, id: entity.tb_id,
                                                  p: [param: buttons_sign, answer_type: answer_type, type: entity.class.type_like_sym,
                                                      sec_id: entity.section.id, cs_id: cs_tb_id]).link
              end
            end
            params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: to_i18n(buttons_signs),
                                                        buttons_actions: buttons_actions,
                                                        emojis: %i[ok leftwards_arrow_with_hook]).raw
            params[:text] ||= "<b>#{I18n.t('send').capitalize} #{I18n.t(answer_type.to_s).downcase}</b>\n<pre>#{params[:user_answer]}</pre>"
            answer.menu.confirmation(params)
          end

          def settings
            params.merge!(slices_count: 1, type: :menu_inline)
            params[:text] ||= "<b>#{Emoji.t(:wrench)}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>
                              \n #{I18n.t('scenario')}: #{I18n.t(to_snakecase(params[:scenario]))}
                              #{I18n.t('localization')}: #{I18n.t(params[:localization])}"
            params[:mode] ||= :none
            params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: ["#{I18n.t('edit')} #{I18n.t('settings').downcase}"],
                                                        buttons_actions: [router.setting(path: :edit).link]).raw
            answer.menu.create(params)
          end

          def edit_settings
            params.merge!(slices_count: 2, type: :menu_inline)
            params[:text] ||= "<b>#{Emoji.t(:wrench)} #{I18n.t('editing_settings')}</b>"
            buttons_actions = []
            buttons_signs = settings_class::PARAMS
            buttons_signs.each do |buttons_sign|
              buttons_actions << router.setting(path: :edit, p: [param: buttons_sign]).link
            end
            params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: to_i18n(buttons_signs),
                                                        buttons_actions: buttons_actions,
                                                        back_button: params[:back_button]).raw
            answer.menu.create(params)
          end

          def choosing(type, option_name)
            params[:text] ||= "<b>#{Emoji.t(:wrench)} #{I18n.t("choose_#{option_name.downcase}")}</b>"
            buttons_actions = []
            buttons_signs = to_constantize("#{option_name.upcase}_PARAMS", "Teachbase::Bot::#{type.capitalize}::")
            emojis = to_constantize("#{option_name.upcase}_EMOJI", "Teachbase::Bot::#{type.capitalize}::")
            buttons_signs.each do |buttons_sign|
              buttons_actions << router.setting(path: option_name.downcase.to_s, p: [param: buttons_sign]).link
            end
            params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: to_i18n(buttons_signs),
                                                        buttons_actions: buttons_actions,
                                                        emojis: emojis,
                                                        back_button: params[:back_button]).raw
            params.merge!(type: :menu_inline, slices_count: buttons_signs.size)
            answer.menu.create(params)
          end

          def ready
            params.merge!(type: :menu, slices_count: 1)
            params[:text] ||= "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_next_answer')} #{Emoji.t(:point_down)}"
            params[:buttons] = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[ready]).raw
            answer.menu.create(params)
          end

          def show_more
            path_params = [offset: params[:offset_num], lim: params[:limit_count]]
            path_params = params[:param] ? path_params << { param: params[:param] } : path_params
            params[:callback_data] = router.public_send(params[:object_type], path: params[:path],
                                                                              p: path_params).link
            answer.menu.show_more(params)
          end

          def links
            raise unless params[:links].is_a?(Array)

            params.merge!(slices_count: 1, type: :menu_inline, mode: :edit_msg)
            params[:text] ||= "#{create_title(params)}<b>#{Emoji.t(:link)} #{I18n.t('attachments')}</b>"
            buttons = []
            params[:links].each do |link_params|
              raise unless link_params.is_a?(Hash)

              buttons << InlineUrlButton.to_open(link_params["source"], link_params["title"])
            end
            params[:buttons] = InlineUrlKeyboard.collect(buttons: buttons, back_button: params[:back_button]).raw
            answer.menu.create(params)
          end

          def accounts
            raise unless params[:accounts].is_a?(Array)

            acc_ids = []
            acc_names = []
            params[:accounts].each do |account|
              next if account["status"] == "disabled"

              acc_ids << account["id"]
              acc_names << account["name"]
            end
            params[:text] ||= "<b>#{Emoji.t(:school)} #{I18n.t('choose_account')}</b>"
            params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: acc_names,
                                                        buttons_actions: acc_ids,
                                                        back_button: params[:back_button]).raw
            params.merge!(type: :menu_inline, slices_count: 2, mode: :none)
            answer.menu.create(params)
          end

          private

          def init_commands
            answer.menu.command_list
          end

          def settings_class
            Teachbase::Bot::Setting
          end
        end
      end
    end
  end
end
